#Include 'Protheus.ch'

Function TAFDMA01(aWizard as array, aFiliais as array)
Local cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
Local nHandle   := MsFCreate( cTxtSys )
Local cStrTxt	:= ""

Local cMesRefer    := Substr(aWizard[1][2],1,2) //Mes Referencia
Local cAnoRefer    := Substr(aWizard[1][2],4,4) //Ano Referencia
Local cDataInv     := DtoS(aWizard[2][5])

cDataInv := Substr(cDataInv,7,2) + Substr(cDataInv,5,2) + Substr(cDataInv,1,4)

nCont := 2

// Realizado tratativa para codigo de município, pois no campo SM0->M0_CODMUN pode ser informado o codigo da UF + o código de municipio
If Len( Alltrim( aFiliais[3] ) )>5 
    aFiliais[3] := Substr(aFiliais[3],3)
Endif

Begin Sequence
		
	cStrTxt := "01"	
	cStrTxt += cAnoRefer //Ano de Referência
	cStrTxt += cMesRefer //Mês de Referência
	cStrTxt += StrZero(VAL(aFiliais[5]),9,0) 
	
	cStrTxt += (If ((aWizard[2][1] == "0 - Não"),"N","S")) //Indicador de Retificadora
	cStrTxt += (If ((aWizard[2][2] == "0 - Não"),"N","S")) //Indicador de Retificadora
	cStrTxt += (If ((aWizard[2][3] == "0 - Não"),"N","S")) //Indicador de Retificadora
	cStrTxt += (If ((aWizard[2][4] == "0 - Não"),"N","S")) //Indicador de Retificadora
	
	cStrTxt += trim(cDataInv) + space(8 - len(trim(cDataInv)))	
	
	cStrTxt += AllTrim(Substr(aFiliais[2],1,50)) + space(50 - len(AllTrim(Substr(aFiliais[2],1,50)))) 
	cStrTxt += StrZero(VAL(AllTrim(aFiliais[3])),5)
	cStrTxt += AllTrim(Substr(aFiliais[4],1,7)) + space(7 - len(AllTrim(Substr(aFiliais[4],1,7))))
	
	cStrTxt += "00"
	cStrTxt += "N"
		
	cStrTxt += CRLF
	
	nCont++ //acrescenta um  no contador para o proximo registro
	 
	WrtStrTxt( nHandle, cStrTxt )
		
	GerTxtDMA( nHandle, cTxtSys, aFiliais[1] + "_TIPO01")
	
	Recover
	lFound := .F.
End Sequence
	
Return
