#Include 'Protheus.ch'

Function TAFGIM02(aWizard, cJobAux)

	Local cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
	Local nHandle   	:= MsFCreate( cTxtSys )
	Local cStrTxt		:= ""
	Local cData 		:= Substr(aWizard[1][2],4,4) + Substr(aWizard[1][2],1,2)
	Local oError		:= ErrorBlock( { |Obj| Alert( "Mensagem de Erro: " + Chr( 10 )+ Obj:Description ) } )

	Begin Sequence

		DbSelectArea("C2S")
		C2S->(DbSetOrder(2))
		If C2S->(DbSeek(xFilial("C2S")))
		 	While C2S->(!EOF()) .AND. xFilial("C2S") == xFilial("C2S")

		 		If (!(	Substr(DtoS(C2S->C2S_DTINI),1,6) == cData .AND. ;
		 			  	Substr(DtoS(C2S->C2S_DTFIN),1,6) == cData))
	 				C2S->(dbSkip())
		 			Loop
		 		Endif

		 		// 10o Registro - Débito do Imposto
				cStrTxt += padL(cValToChar(C2S->C2S_TOTDEB * 100),14)  	//001 - Por saídas com débito do imposto
				cStrTxt += padL(cValToChar(C2S->C2S_TAJUDB * 100),14) 	//002 - Outros débitos
				cStrTxt += padL(cValToChar(C2S->C2S_ESTCRE * 100),14) 	//003 - Estornos de créditos
				cStrTxt += padL(cValToChar((C2S->C2S_TOTDEB + C2S->C2S_TAJUDB + C2S->C2S_ESTCRE) * 100),14)  	//005 – Total
				cStrTxt += CRLF

				// 11o Registro - Crédito do Imposto
				cStrTxt += padL(cValToChar(C2S->C2S_TOTCRE * 100),14) 	//006 - Por entradas com crédito do imposto
				cStrTxt += padL(cValToChar(C2S->C2S_TAJUCR * 100),14) 	//007 - Outros créditos
				cStrTxt += padL(cValToChar(C2S->C2S_ESTDEB * 100),14) 	//008 - Estornos de débitos
				cStrTxt += padL(cValToChar((C2S->C2S_TOTCRE + C2S->C2S_TAJUCR + C2S->C2S_ESTDEB) * 100),14) 	//010 – Subtotal
				cStrTxt += padL(cValToChar(C2S->C2S_CRESEG * 100),14) 	//011 - Saldo credor
				cStrTxt += padL(cValToChar((C2S->C2S_TOTCRE + C2S->C2S_TAJUCR + C2S->C2S_ESTDEB + C2S->C2S_CRESEG ) * 100),14) //012 – Total
				cStrTxt += CRLF

		 		// 12o Registro - Apuração dos Saldos
				cStrTxt += padL(cValToChar(C2S->C2S_SDOAPU * 100),14) //013 - Saldo devedor
				cStrTxt += padL(cValToChar(C2S->C2S_TOTDED * 100),14) //014 - Deduções
				cStrTxt += padL(cValToChar(C2S->C2S_TOTREC * 100),14) //015 - Imposto a recolher
				cStrTxt += padL(cValToChar(C2S->C2S_CRESEG * 100),14) //016 - Saldo credor p/ período seguinte
				cStrTxt += CRLF

				C2S->(dbSkip())
			EndDo
		EndIf

	 	WrtStrTxt( nHandle, cStrTxt )
		GerTxtGIM( nHandle, cTxtSys, "02")

		Recover
		lFound := .F.
	End Sequence

	//Tratamento para ocorrência de erros durante o processamento
	ErrorBlock( oError )

	If !lFound
		//Status 9 - Indica ocorrência de erro no processamento
		PutGlbValue( cJobAux , "2" )
		GlbUnlock()

	Else
		//Status 1 - Indica que o bloco foi encerrado corretamente para processamento Multi Thread
		PutGlbValue( cJobAux , "1" )
		GlbUnlock()

	EndIf

Return

