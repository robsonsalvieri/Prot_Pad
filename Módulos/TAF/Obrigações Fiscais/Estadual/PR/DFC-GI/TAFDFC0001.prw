#Include 'Protheus.ch'

Function TAFDFC0001(aWizard, nCont)

Local cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
Local nHandle   	:= MsFCreate( cTxtSys )
Local cStrTxt 	:= ""
Local cReg		 	:= "1"

//Variaveis da tabela C2J
Local cC2JCPF		:= space(15)

Begin Sequence

	cStrTxt := cReg										//Tipo do Registro  -  Valor Fixo: 1
	Do Case												//Tipo do Documento
		Case aWizard[1][3] == '21 - Normal'
			cStrTxt += "21"
		Case aWizard[1][3] == '22 - Retificação'
			cStrTxt += "22"
		Case aWizard[1][3] == '24 - Baixa'
			cStrTxt += "24"
	EndCase								
	cStrTxt += Substr(SM0->M0_INSC,1,10)				//Inscrição Estadual			- M0_INSC ( SIGAMAT )
	cStrTxt += SM0->M0_CGC								//CNPJ/CPF do Contribuinte	- M0_CGC
	cStrTxt += aWizard[1][5] + "00"						//Ano referencia + 00
	cStrTxt += "F"										//Tipo Responsável
	
	DbSelectArea("C2J")
	DbSetOrder(5)
	If DbSeek(xFilial("C2J")+aWizard[1][6])
		cC2JCPF	:= C2J_CPF
	Endif
	cStrTxt += Substr(cC2JCPF,1,11) + space(4)		//CPF Contabilista			- C2J
	cStrTxt += "8"										//Modelo da DFC				- Fixo: 8
	
	//espaço em branco 	Char 	59
	cStrTxt += space(59)
	cStrTxt += StrZero(nCont,3)
	
	cStrTxt += CRLF
	
	WrtStrTxt( nHandle, cStrTxt )
	
	GerTxtDFPR( nHandle, cTxtSys, cReg )
	
	Recover
	lFound := .F.

End Sequence


Return
