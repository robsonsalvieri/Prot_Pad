#Include 'Protheus.ch'

Function TAFGIRAJU(aWizard, nValor, nCont)
	Local cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
	Local nHandle   	:= MsFCreate( cTxtSys )

	Local cPeriodo  	:= Substr(aWizard[1][4],4,4) + Substr(aWizard[1][4],1,2)
	Local cStrTxt		:= ""
	Local cStrTxtAux	:= ""
	Local cReg 		    := ""
	
	Local cSeqOcor	:= "00000"
	Local cDescri		:= ""
	Local cLegal 		:= ""
	Local cObs1			:= ""
	Local cObs2			:= ""
	Local cObs3			:= ""
	  
	Local aArrayReg 	:= {}
	
	Local nPos := 0	
	
	Begin Sequence
	
		DbSelectArea("C2S")
		DbSelectArea("C2T")
		DbSelectArea("C1A")
		DbSelectArea("CHY")
		
		C2S->(DbSetOrder(2))
		If C2S->(DbSeek(xFilial("C2S")))
		 	While C2S->(!EOF()) .AND. xFilial("C2S") == C2S->C2S_FILIAL
		 			 		
		 		If (!(Substr(DtoS(C2S->C2S_DTINI),1,6) == cPeriodo .AND. Substr(DtoS(C2S->C2S_DTFIN),1,6) == cPeriodo))
	 				C2S->(dbSkip())
		 			Loop
		 		Endif
	
				C2T->(DbSetOrder(1))
				If C2T->(DbSeek(xFilial("C2T") + C2S->C2S_ID))
					While C2T->(!EOF()) .AND. xFilial("C2T") == C2T->C2T_FILIAL .AND. C2T->C2T_ID == C2S->C2S_ID			
					
						C1A->(DbSetOrder(4))
						If C1A->(DbSeek(xFilial("C1A") + C2T->C2T_CODAJU))						
							Do Case
								Case Substr(C1A->C1A_CODIGO,4,1) == "0"
									cReg := "0140"
								Case Substr(C1A->C1A_CODIGO,4,1) == "1"
									cReg := "0150"
								Case Substr(C1A->C1A_CODIGO,4,1) == "2"
									cReg := "0160"
								Case Substr(C1A->C1A_CODIGO,4,1) == "3"
									cReg := "0170"
								Case Substr(C1A->C1A_CODIGO,4,1) == "4"
									cReg := "0180"
								Case Substr(C1A->C1A_CODIGO,4,1) == "5"
									cReg := "0190"
								Otherwise
									C2T->(dbSkip())
									Loop
							EndCase
						EndIF
						
						cSeqOcor	:= "00000" 
						cDescri 	:= "" 
						cLegal  	:= ""						
						cObs1		:= ""
						cObs2		:= ""
						cObs3		:= ""
						
						CHY->(DbSetOrder(1))
						If CHY->(DbSeek(xFilial("CHY") + C2T->C2T_IDSUBI))
							cSeqOcor	:= CHY->CHY_CODIGO 
							cDescri 	:= CHY->CHY_DESCRI 
							cLegal  	:= CHY->CHY_FLEGAL		
							cObs1       := C2T->C2T_OBS1
							cObs2       := C2T->C2T_OBS2
							cObs3       := C2T->C2T_OBS3											
						EndIf
						
						//caso seja um dos subitens de apuração abaixo, gerar para o 0200 
						If ( CHY->CHY_CODIGO $ ("00169|00170|00194|00206|00207|00208|00209|00210|00211|00274"))
							cReg := "0200"						
						Endif
						
						nValor += C2T->C2T_VLRAJU
												
						cStrTxtAux := cReg
						cStrTxtAux += StrZero(1,15) 			    	 					//Identificador da Declaração
					 	cStrTxtAux += cSeqOcor                      						//Seqüencial da Ocorrência
				 		cStrTxtAux += StrZero(C2T->C2T_VLRAJU * 100, 15)					//Valor de Dedução
					 	cStrTxtAux += substr(trim(cDescri),1,150)	 + space(150 - len(trim(cDescri))) //Descrição Complementar
					 	cStrTxtAux += substr(trim(cLegal),1,120)	 + space(120 - len(trim(cLegal)))  //Valor Complementar 1
					 	cStrTxtAux += substr(trim(cObs1),1,120)		 + space(120 - len(trim(cObs1)))   //Valor Complementar 2
					 	cStrTxtAux += substr(trim(cObs2),1,120)		 + space(120 - len(trim(cObs2)))   //Valor Complementar 3
					 	cStrTxtAux += substr(trim(cObs3),1,120)		 + space(120 - len(trim(cObs3)))   //Valor Complementar 4
						cStrTxtAux += space(120) 											//Valor Complementar 5
						cStrTxtAux += space(56)	       				 					//Filler
												
						AADD(aArrayReg, {cReg, cStrTxtAux})
						
						C2T->(dbSkip())
					EndDo
				Endif
				C2S->(dbSkip())
			EndDo
		EndIf
		
		aSort(aArrayReg, , , {|x,y| x[1] <= y[1]})
		
		For nPos := 1 To len(aArrayReg)		
			cStrTxt += aArrayReg[nPos,2]			
			cStrTxt += StrZero(nCont,5) 				 					   //Contador de linha
			cStrTxt += CRLF
			nCont++			
		Next nPos			
		
		WrtStrTxt( nHandle, cStrTxt )

		GerTxtGIRJ( nHandle, cTxtSys, "AJUSTE" )

		Recover
		lFound := .F.
	End Sequence

Return
