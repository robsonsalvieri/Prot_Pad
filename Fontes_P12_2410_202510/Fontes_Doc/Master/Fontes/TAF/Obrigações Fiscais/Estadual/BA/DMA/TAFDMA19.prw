#Include 'Protheus.ch'

Function TAFDMA19(aWizard as array, aFiliais as array)
	
	Local cTxtSys  	  := CriaTrab( , .F. ) + ".TXT"
	Local nHandle     := MsFCreate( cTxtSys )
	Local cStrTxt	  := ""
	Local cData 	  := Substr(aWizard[1][2],4,4) + Substr(aWizard[1][2],1,2)	
	
	Local cAnoRefer   := Substr(cData,1,4)               // 	Ano de Referência
	Local cMesRefer   := Substr(cData,5,2)               // 	Mês de Referência
	Local cIE		  := StrZero(VAL(aFiliais[5]),9,0)   // 	Inscrição Estadual
	Local IMCSAlq17   := replicate("0",12)               // 	Valor ICMS creditado na compra e/ou transferencia de material para uso ou consumo procedente do estado e exterior aliquota 17 %
	Local cVlcExp     := replicate("0",12)               // 	Valor do saldo anterior do crédito fiscal na exportação
	Local cVlcExpD	  := replicate("0",12)               // 	Valor do crédito fiscal  na exportação direta gerado no mês
	Local cVlcExpI	  := replicate("0",12)               // 	Valor do crédito fiscal na exportação indireta gerado no mês
	Local nICMSCMes   := replicate("0",12)               // 	Valor para  pagamento do ICMS normal dos créditos utilizados no mês
	Local nICMSTrans  := replicate("0",12)               // 	Valor de transferência para outros estabelecimentos   dos créditos utilizados no mês	
	Local cVlcTerc    := replicate("0",12)               // 	Valor transferido para terceiros de créditos  utilizados no mês
	Local cVlcRex	  := replicate("0",12)               // 	Valor do crédito fiscal acumulado na exportação utilizado no mês na importação de mercadorias do exterior
	Local cCrdEes     := replicate("0",12)               // 	Valor do crédito fiscal acumulado na exportação utilizado no mês decorrente da denuncia espontanea
	Local cRexAu      := replicate("0",12)               // 	Valor do crédito fiscal  na exportação decorrente de   autuação fiscal
	Local cSlanCr     := replicate("0",12)               // 	Valor do saldo anterior do crédito fiscal acumulado em virtude de diferimento, isenção, outros motivos
	Local cVlcRdf     := replicate("0",12)               // 	Valor do crédito gerado no mês decorrente do diferimento
	Local cVlcRis     := replicate("0",12)               // 	Valor do crédito gerado no mês decorrente da isenção
	Local cVlcRrd     := replicate("0",12)               // 	Valor do crédito gerado no mês decorrente da redução base   de cálculo

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

				cVlcRex   := StrZero(C2S->C2S_VLCREX * 100, 12)
				cCrdEes   := StrZero(C2S->C2S_CRDEES * 100, 12)	
				cRexAu    := StrZero(C2S->C2S_CREXAU * 100, 12)
				cSlanCr   := StrZero(C2S->C2S_SLANCR * 100, 12)
				cVlcRdf   := StrZero(C2S->C2S_VLCRDF * 100, 12)	
				cVlcRis	  := StrZero(C2S->C2S_VLCRIS * 100, 12)
				cVlcRrd   := StrZero(C2S->C2S_VLCRRD * 100, 12)	
				C2S->(dbSkip())

			EndDo
		EndIf		

		cStrTxt += "18" + cAnoRefer + cMesRefer + cIE + IMCSAlq17 + cVlcExp + cVlcExpD + cVlcExpI + nICMSCMes + nICMSTrans + cVlcTerc + CRLF
		cStrTxt += "19" + cAnoRefer + cMesRefer + cIE + cVlcRex + cCrdEes + cRexAu + cSlanCr + cVlcRdf + cVlcRis + cVlcRrd + CRLF

	    If  cStrTxt != "" 
			WrtStrTxt( nHandle, cStrTxt )
			GerTxtDMA( nHandle, cTxtSys, aFiliais[1] + "_TIPO19")
		EndIF 
		Recover
		lFound := .F.
	End Sequence
	
Return
