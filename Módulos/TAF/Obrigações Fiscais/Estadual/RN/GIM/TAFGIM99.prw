#Include 'Protheus.ch'

Function TAFGIM99(aWizard, cJobAux)

	Local cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
	Local nHandle   	:= MsFCreate( cTxtSys )
	Local cStrTxt		:= ""
	Local oError		:= ErrorBlock( { |Obj| Alert( "Mensagem de Erro: " + Chr( 10 )+ Obj:Description ) } )

	Begin Sequence

		cStrTxt += "75"
		padL(cStrTxt += aWizard[2][1], 30)
		cStrTxt += CRLF

		cStrTxt += "75"
		padL(cStrTxt += aWizard[2][2], 30)
		cStrTxt += CRLF

		cStrTxt += "75"
		padL(cStrTxt += aWizard[2][3], 30)
		cStrTxt += CRLF

	 	WrtStrTxt( nHandle, cStrTxt )
		GerTxtGIM( nHandle, cTxtSys, "99")

		Recover
		lFound := .F.
	End Sequence

	//Tratamento para ocorrência de erros durante o processamento
	ErrorBlock( oError )

	If !lFound
		//Status 9 - Indica ocorrência de erro no processamento
		PutGlbValue( cJobAux , "12" )
		GlbUnlock()

	Else
		//Status 1 - Indica que o bloco foi encerrado corretamente para processamento Multi Thread
		PutGlbValue( cJobAux , "1" )
		GlbUnlock()

	EndIf

Return


