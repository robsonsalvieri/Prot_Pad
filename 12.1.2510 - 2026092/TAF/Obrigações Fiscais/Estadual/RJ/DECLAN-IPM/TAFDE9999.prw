#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFDE9999
Gera o reguitro 0500 da DECLANN-IPM
@parametro aWizard, nValor, nCont
@author 
@since 
@version 1.0
@Altered by Pister in 31/10/2024 Refatoração
/*/ 
//-------------------------------------------------------------------- 

Function TAFDE9999(aWizard, nValor, nCont)

	Local cTxtSys  	as character
	Local nHandle   as numeric
	Local cReg 		as character

	Local cStrTxt 	as character

	cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
	nHandle     := MsFCreate( cTxtSys )
	cREG 		:= "9999"

	cStrTxt 	:= ""

	cStrTxt := "9999"										//Tipo 							  	- Valor Fixo: 0200
	cStrTxt += StrTran(StrZero(nValor, 26, 2),".","")		//Somar todos os campos de valor
	cStrTxt += "00001"										//Número Seqüencial da Declaração	- Valor Fixo: 000000000000001
	
	nCont ++
	cStrTxt += StrZero(nCont,5) 							//Contador de linhas total			- Número da linha
	cStrTxt := Left(cStrTxt,40) + space(316)				//Filler 								- Preencher com espaços em branco
	cStrTxt += StrZero(nCont,5) 							//Número da linha						- Número da linha

	WrtStrTxt( nHandle, cStrTxt )
	GerTxtDERJ( nHandle, cTxtSys, cReg )
	
Return
