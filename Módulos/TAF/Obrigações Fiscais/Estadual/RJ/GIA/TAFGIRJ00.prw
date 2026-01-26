#Include 'Protheus.ch'

Function TAFGIRJ00(aWizard)

	Local cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
	Local nHandle   := MsFCreate( cTxtSys )
	Local cReg 		:= "0000"
	Local cStrTxt 	:= ""

	Begin Sequence
		cStrTxt := cReg 																//Tipo 									- Valor Fixo: 0001
		cStrTxt += DtoS( Date() ) + StrTran(Time(),":","")		 				//Data da Geração do Arquivo 			- Formato: AAAAMMDDHHMMSS (Ex.: 20091231215530)
		cStrTxt += "N"											       			//Indicador de Gerador da SEFAZ-RJ   	- Valor Fixo: N
		cStrTxt += trim(aWizard[1][3]) + space(10 - len(trim(aWizard[1][3])))	//0.0.0.0
		cStrTxt += space(816)
		cStrTxt += "00001"															//Número da linha							- Número da linha
		cStrTxt += CRLF
  
		WrtStrTxt( nHandle, cStrTxt )

		GerTxtGIRJ( nHandle, cTxtSys, cReg )

		Recover
		lFound := .F.
	End Sequence

Return