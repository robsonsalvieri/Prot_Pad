#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFDE0100
Gera o reguitro 0100 da DECLANN-IPM
@parametro aWizard
@author 
@since 
@version 1.0
@Altered by Pister in 31/10/2024 Refatoração
/*/ 
//-------------------------------------------------------------------- 
Function TAFDE0100(aWizard)

	Local cTxtSys    as character
	Local nHandle    as numeric
	Local cReg 	     as character
	Local cStrTxt    as character
	Local cUf	     as character
	Local cIdMun     as character
	Local cCodMun    as character
	Local cNumCgc    as character
	Local cTipReg 	 as character	
	
	Local cEmailC1E	 as character
	Local cNomeC1E	 as character
	Local cDddC1E	 as character
	Local cfoneC1E	 as character
	Local cDDDFaxC1E as character
	Local cFAXC1E    as character
	
	Local cNomC2J	 as character
	Local cDddC2J	 as character
	Local cFoneC2J	 as character
	
	//Inicio as variaveis
	cTxtSys 	:= CriaTrab( , .F. ) + ".TXT"
	nHandle 	:= MsFCreate( cTxtSys )
	cReg 		:= "0100"
	cStrTxt 	:= ""
	cUf			:= ""
	cIdMun		:= ""
	cCodMun		:= ""
	cNumCgc     := ""
	cTipReg     := ""
	
	//Variaveis da tabela C1E
	cEmailC1E	:= ""
	cNomeC1E	:= space(64)
	cDddC1E		:= space(4)
	cfoneC1E	:= space(8)
	cDDDFaxC1E 	:= ""
	cFAXC1E   	:= ""
	
	//Variaveis da tabela C2J
	cNomC2J		:= space(64)
	cDddC2J		:= space(4)
	cFoneC2J	:= space(8)

	cStrTxt := "0100"									 //Tipo 									- Valor Fixo: 0001
	cStrTxt += "000000000000001"						 //Número Seqüencial da Declaração 		- Valor Fixo: 0001
	cStrTxt += Substr(AllTrim( FWSM0Util( ):GetSM0Data( , cFilAnt , { "M0_INSC" } )[1][2] ),1,8)					 //Inscrição Estadual					- M0_INSC ( SIGAMAT )
	cStrTxt += Substr(aWizard[2][1],1,4)				 //Ano de Referência (Wizard)			- Formato: AAAA (Ex.: 2009)
	
	If aWizard[2][2] == '0 - Não'                        //Declaração Retificadora (Wizard)		- S = Sim; N = Não
		cStrTxt += "N"
	Else
		cStrTxt += "S"
	Endif

	DbSelectArea("T39")
	DbSetOrder(2)
	If DbSeek(xFilial("T39") + Substr(aWizard[2][1],1,4))

		//1=Simples;2=Normal; 3=Ambos                                                                                                     
	
		If T39->T39_TIPREG == '1'
			cTipReg := "S"		
		ElseIf T39->T39_TIPREG == '2'
			cTipReg := "N"		
		Else  
			cTipReg := "A"		
		EndIf
	EndIf

	cStrTxt += cTipReg		

	cNumCgc := AllTrim( FWSM0Util( ):GetSM0Data( , cFilAnt , { "M0_CGC" } )[1][2] )
	//Tipo de Pessoa -	J = Jurídica, F = Física(Vide Regra)
	if len(cNumCgc) == 11
		cStrTxt += "F"	//Física
	else
		cStrTxt += "J"	//Jurídica
	Endif 
	
	cStrTxt += PADR(cNumCgc,14, " ")		//CNPJ/CPF do Contribuinte	   - M0_CGC
	cStrTxt += PADR(AllTrim( FWSM0Util( ):GetSM0Data( , cFilAnt , { "M0_NOMECOM" } )[1][2] ), 64, " ") 	//Razão Social do Contribuinte - M0_NOME

	//Leitura para buscar os campos relacionados a tabelas C1E
	DbSelectArea("C1E")
	DbSetOrder(3)
	If DbSeek(xFilial("C1E")+PadR(cFilAnt, GetSX3Cache("C1E_FILTAF", "X3_TAMANHO"))+"1")
		cEmailC1E	:= C1E->C1E_EMAIL
		cNomeC1E	:= C1E->C1E_NOMCNT
		cDddC1E	    := C1E->C1E_DDDFON 
		cFoneC1E	:= C1E->C1E_FONCNT
		cDDDFaxC1E  := C1E->C1E_DDDFAX
		cFAXC1E  	:= C1E->C1E_FAXCNT 
	Endif

	cStrTxt += PADR(cEmailC1E, 40, " ") //Correio Eletrônico do Contribuinte - C1E_EMAIL
	cStrTxt += PADR(cDddC1E,4, " ")		 //DDD do Contribuinte 				  - (SIGAMAT)
	cStrTxt += PADR(cFoneC1E,8, " ")	 //Fone do Contribuinte				  - (SIGAMAT)
	cStrTxt += PADR(cDDDFaxC1E,4, " ")	 //DDD do FAX do Contribuinte		  - (SIGAMAT)
	cStrTxt += PADR(cFAXC1E,8, " ")   	 //Fone do FAX do Contribuinte		  - (SIGAMAT)

	cUf     := POSICIONE("C09",1,xFilial("C09")+ "RJ","C09_ID")
	cCodMun := AllTrim( FWSM0Util( ):GetSM0Data( , cFilAnt , { "M0_CODMUN" } )[1][2] )
	cIdMun  := POSICIONE("C07",7,xFilial("C07")+ PadL(cCodMun, GetSX3Cache("C07_MUNDRJ", "X3_TAMANHO"), '0'),"C07_ID")
	cStrTxt += PADR(POSICIONE("T2D",2,xFilial("T2D")+ cIdMun + "MUNRJ","T2D_CODMUN"),8,"")  //Código da localidade do Contribuinte

	cStrTxt += PADR(cNomeC1E,64," ")	//Nome do Representante Legal	 - C1E_NOMCNT
	cStrTxt += PADR(cDddC1E,4, " ")  	//DDD do Representante Legal	 - C1E_DDDFON
	cStrTxt += PADR(cFoneC1E,8, " ") 	//Telefone do Representante Legal- C1E_FONCNT

	DbSelectArea("C2J")
	DbSetOrder(5)
	If DbSeek(xFilial("C2J")+aWizard[2][3])
		cNomC2J	 := C2J_NOME  
		cDddC2J	 := C2J_DDD 
		cFoneC2J := C2J_FONE 
	Endif

	cStrTxt += PADR(cNomC2J, 64, " ")					//Nome do Contabilista		- C2J
	cStrTxt += PADR(cDddC2J,4, " ") 					//DDD do Contabilista		- C2J
	cStrTxt += PADR(cFoneC2J,8, " ") 					//Telefone do Contabilista	- C2J

	If aWizard[2][4] == '0 - Não'						//Declaração de baixa da inscrição (Wizard) - S = Sim; N = Não
		cStrTxt += "N"
	Else 
		cStrTxt += "S"
	EndIf

	cStrTxt += PADR(DtoS( aWizard[2][5] ),14, ' ')		//Data de Encerramento das Atividades (Wizard)

	If aWizard[2][6] == '0 - Não'						//Estabelecimento Principal ou Único no Estado (Ficha "Receita Bruta Mensal") (Wizard) - S = Sim; N = Não
		cStrTxt += "N"
	Else 
		cStrTxt += "S"
	EndIf

	If aWizard[2][7] == '0 - Não'						//Estabelecimento único em território nacional (Ficha "Receita Bruta Mensal") (Wizard) - S = Sim; N = Não
		cStrTxt += "N"
	Else 
		cStrTxt += "S"
	EndIf

	If aWizard[2][8] == '0 - Não'						//Estabelecimento sem receita  no ano-base (Ficha "Receita Bruta Mensal") (Wizard) - S = Sim; N = Não
		cStrTxt += "N"
	Else 
		cStrTxt += "S"
	EndIf

	If aWizard[2][9] == '0 - Não'						//Empresa sem receita no ano-base (Ficha "Receita Bruta Mensal") (Wizard) - S = Sim; N = Não
		cStrTxt += "N"
	Else 
		cStrTxt += "S"
	EndIf
	
	cStrTxt := Left(cStrTxt,356) + "00002"				//Número da linha - Número da linha
 	cStrTxt += CRLF

	WrtStrTxt( nHandle, cStrTxt )
	GerTxtDERJ( nHandle, cTxtSys, cReg )

Return
