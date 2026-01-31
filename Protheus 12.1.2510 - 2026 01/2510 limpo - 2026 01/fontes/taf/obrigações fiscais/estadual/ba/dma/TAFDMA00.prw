#Include 'Protheus.ch'

Function TAFDMA00(aWizard as array, aFiliais as array)
Local cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
Local nHandle  	:= MsFCreate( cTxtSys )

Local cNomeRep	:= ""
Local cCpf		:= ""
Local cIDCont	:= aWizard[3][1]

Begin Sequence

	//CONTADOR Representante
	DbSelectArea("C2J") //Contador
	C2J->(DbSetOrder(5))
	If C2J->(DbSeek(xFilial("C2J") + cIDCont ))
		cNomeRep	:= Substr(C2J->C2J_NOME , 1, 35)
		cCpf	 	:= C2J->C2J_CPF
	endif

	cStrTxt := "00"
	cStrTxt += space(2) + "DMA" //Identificador da Declaração	
	cStrTxt += "O" 
	cStrTxt += trim(cCpf) + space(11 - len(trim(cCpf))) //CPF REPRESENTANTE LEGAL
	cStrTxt += trim(cNomeRep) + space(35 - len(trim(cNomeRep))) //NOME REPRESENTANTE LEGAL
	cStrTxt += "2010"	
	cStrTxt += CRLF
	
	WrtStrTxt( nHandle, cStrTxt )
		
	GerTxtDMA( nHandle, cTxtSys, aFiliais[1] + "_TIPO00")	

	Recover
	lFound := .F.
End Sequence
	
Return