#Include 'Protheus.ch'

Function TAFDMA14(aWizard as array, aFiliais as array)
	
	Local cTxtSys  	    := CriaTrab( , .F. ) + ".TXT"
	Local nHandle   	:= MsFCreate( cTxtSys )
	Local cStrTxt		:= ""
	Local cData 		:= Substr(aWizard[1][2],4,4) + Substr(aWizard[1][2],1,2)	

	Local cRegistro 	:= "14"              // 	Tipo
	Local cAnoRefer 	:= Substr(cData,1,4) // 	Ano de Referência
	Local cMesRefer     := Substr(cData,5,2) // 	Mês de Referência
	Local cIE			:= StrZero(VAL(aFiliais[5]),9,0)    // 	Inscrição Estadual
	Local cTotDeb       := replicate("0",12)
	Local cTajUdb       := replicate("0",12)
	Local cEstCre		:= replicate("0",12)
	Local cTotCre		:= replicate("0",12)
	Local cAjuCre       := replicate("0",12)
	Local cEstDeb 		:= replicate("0",12)
	Local cCreAnt 		:= replicate("0",12)

	
	Begin Sequence
	
		DbSelectArea("C2S")		
		C2S->(DbSetOrder(2))
		If C2S->(DbSeek(xFilial("C2S")))
		 	While C2S->(!EOF()) .AND. xFilial("C2S") == aFiliais[1]
		 			 		
		 		If (!(	Substr(DtoS(C2S->C2S_DTINI),1,6) == cData .AND. ;
		 			  	Substr(DtoS(C2S->C2S_DTFIN),1,6) == cData))
	 				C2S->(dbSkip())
		 			Loop
		 		Endif
	
				cTotDeb := StrZero(C2S->C2S_TOTDEB * 100, 12)	//	Valor Débito do Imposto Saídas Tributadas
				cTajUdb := StrZero(C2S->C2S_TAJUDB * 100, 12)	//	Valor Débito do Imposto Outros Débitos
				cEstCre := StrZero(C2S->C2S_ESTCRE * 100, 12)	//	Valor Débito do Imposto Estorno de Crédito
				cTotCre := StrZero(C2S->C2S_TOTCRE * 100, 12)	//	Valor Crédito do Imposto Entradas Tributadas
				cAjuCre := StrZero(C2S->C2S_TAJUCR * 100, 12)	//	Valor Crédito do Imposto Outros Créditos
				cEstDeb := StrZero(C2S->C2S_ESTDEB * 100, 12)	//	Valor Crédito do Imposto Estorno de Débito
				cCreAnt := StrZero(C2S->C2S_CREANT * 100, 12)	//	Valor Crédito do Imposto Saldo Credor Período Anterior
				C2S->(dbSkip())
			EndDo
		EndIf		
	 	
	 	cStrTxt := cRegistro + cAnoRefer + cMesRefer + cIE + cTotDeb + cTajUdb + cEstCre + cTotCre + cAjuCre + cEstDeb + cCreAnt + CRLF	

		 IF cStrTxt != ""
			WrtStrTxt( nHandle, cStrTxt )
			GerTxtDMA( nHandle, cTxtSys, aFiliais[1] + "_TIPO14")
		EndIf 
		
		Recover
		lFound := .F.
	End Sequence
	
Return
