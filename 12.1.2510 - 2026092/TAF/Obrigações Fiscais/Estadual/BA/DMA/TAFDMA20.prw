#Include 'Protheus.ch'

Function TAFDMA20(aWizard as array, aFiliais as array)
	
	Local cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
	Local nHandle   	:= MsFCreate( cTxtSys )
	Local cStrTxt		:= ""
	Local cData 		:= Substr(aWizard[1][2],4,4) + Substr(aWizard[1][2],1,2)

	Local cRegistro 	:= "20"              // 	Tipo
	Local cAnoRefer 	:= Substr(cData,1,4) // 	Ano de Referência
	Local cMesRefer     := Substr(cData,5,2) // 	Mês de Referência
	Local cIE			:= StrZero(VAL(aFiliais[5]),9,0)    // 	Inscrição Estadual	
	Local cVlcRou 		:= replicate("0",12)
	Local cVlPagto      := replicate("0",12)
	Local cVlcRim       := replicate("0",12)
	Local cVlcRes       := replicate("0",12)
	Local cVlcRau       := replicate("0",12)
	Local cVlcRtr       := replicate("0",12)

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
		 		
				cVlcRou  := StrZero(C2S->C2S_VLCROU * 100, 12)	//	Valor Débito do Imposto Saídas Tributadas
				cVlPagto := StrZero(C2S->C2S_VLPGTO * 100, 12)	//	Valor Débito do Imposto Outros Débitos
				cVlcRim  := StrZero(C2S->C2S_VLCRIM * 100, 12)	//	Valor Débito do Imposto Estorno de Crédito
				cVlcRes  := StrZero(C2S->C2S_VLCRES * 100, 12)	//	Valor Crédito do Imposto Entradas Tributadas
				cVlcRau  := StrZero(C2S->C2S_VLCRAU * 100, 12)	//	Valor Crédito do Imposto Outros Créditos
				cVlcRtr  := StrZero(C2S->C2S_VLCRTR * 100, 12)	//	Valor Crédito do Imposto Saldo Credor Período Anterior
				C2S->(dbSkip())
			EndDo
		EndIf

	 	cStrTxt := cRegistro + cAnoRefer + cMesRefer + cIE + cVlcRou + cVlPagto + cVlcRim + cVlcRes + cVlcRau + cVlcRtr + CRLF	

		If cStrTxt != "" 
			WrtStrTxt( nHandle, cStrTxt )
			GerTxtDMA( nHandle, cTxtSys, aFiliais[1] + "_TIPO20")
		EndIf 	

		Recover
		lFound := .F.
	End Sequence
	
Return
