#Include 'Protheus.ch'

Function TAFDMA99(aWizard, nCont)
Local cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
Local nHandle   := MsFCreate( cTxtSys )

Begin Sequence
	
	cStrTxt := "99"
	cStrTxt += StrZero(nCont,5)	
	cStrTxt += CRLF
		 
	WrtStrTxt( nHandle, cStrTxt )
		
	GerTxtDMA( nHandle, cTxtSys, "99")	

	Recover
	lFound := .F.
End Sequence
	
Return