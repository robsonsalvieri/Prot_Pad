#Include 'Protheus.ch'

Function TAFGIR9999(nValor, nCont)

	Local cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
	Local nHandle   := MsFCreate( cTxtSys )
	Local cStrTxt	:= ""

	Begin Sequence
		cStrTxt := "9999"			
	 	cStrTxt += StrZero(nValor  * 100 ,25)	//Somatório de todos os valores monetários informados	 	
	 	cStrTxt += "00001"              	//Total de declarações
	 	cStrTxt += StrZero(nCont	, 5)	   //Total de registros (incluindo header e trailler)
 		cStrTxt += space(806)       		//Filler
		cStrTxt += StrZero(nCont,5) 		//Contador de linha			
	  
		WrtStrTxt( nHandle, cStrTxt )

		GerTxtGIRJ( nHandle, cTxtSys, "9999" )

		Recover
		lFound := .F.
	End Sequence	

Return