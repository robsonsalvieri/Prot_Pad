#Include 'Protheus.ch'

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFDIAPAJ

Outros Ajustes e Ajustes de Beneficios fiscais

@Param 	Wizard

@Author Jean Battista Grahl Espindola
@Since 16/11/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Function TAFDIAPAJ(aWizard as array)

	Local cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
	Local nHandle   := MsFCreate( cTxtSys )

	Local cStrTxt	 as Char
	Local nPos 	     as Numeric	
	Local aReg 		 as Array
	  
	Begin Sequence
	
		DbSelectArea("C2S")
		DbSelectArea("C2T")
		DbSelectArea("CHY")
		
		aReg := {}
		
		C2S->(DbSetOrder(2))
		If C2S->(DbSeek(xFilial("C2S")))
		 	While C2S->(!EOF()) .And. xFilial("C2S") == C2S->C2S_FILIAL
		 			 		
		 		If (!(C2S->C2S_DTINI >= aWizard[1, 6] .And. C2S->C2S_DTFIN <= aWizard[1, 7]))
	 				C2S->(dbSkip())
		 			Loop
		 		Endif
	
				C2T->(DbSetOrder(1))
				If C2T->(DbSeek(xFilial("C2T") + C2S->C2S_ID))
					While C2T->(!EOF()) .And. xFilial("C2T") == C2T->C2T_FILIAL .And. C2T->C2T_ID == C2S->C2S_ID			
						
						CHY->(DbSetOrder(1))
						If  CHY->(DbSeek(xFilial("CHY") + C2T->C2T_IDSUBI))
							
							cCodUf := POSICIONE("C09",3,xFilial("C09")+CHY->CHY_IDUF,"C09_UF")
							
							If  cCodUf == "AP"
								If ( CHY->CHY_CODIGO == "00300")
									AADD(aReg, {"DIAPBF", "300", C2T->C2T_VLRAJU})
								Else
									AADD(aReg, {"DIAPOC", Substr(CHY->CHY_CODIGO,3,3), C2T->C2T_VLRAJU})					
								Endif
							Endif	
						EndIf
						C2T->(dbSkip())
					EndDo
				Endif
				C2S->(dbSkip())
			EndDo
		EndIf
		
		aSort(aReg, , , {|x,y| x[1] <= y[1]})
		
		cStrTxt := ""
		For nPos := 1 To len(aReg)		
			cStrTxt += aReg[nPos,1]  + ";"
			cStrTxt += aReg[nPos,2]  + ";"
			cStrTxt += StrZero(aReg[nPos, 3] * 100, 15) + ";"
			cStrTxt += CRLF	
		Next nPos			
		
		WrtStrTxt( nHandle, cStrTxt )
		GerTxtDIAP( nHandle, cTxtSys, "_DIAJ" )

		Recover
		lFound := .F.
	End Sequence
		
Return
