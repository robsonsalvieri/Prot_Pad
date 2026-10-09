#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFDE0001
Gera o reguitro 0001 da DECLANN-IPM
@parametro aWizard
@author 
@since 
@version 1.0
@Altered by Pister in 31/10/2024 Refatoração
/*/ 
//-------------------------------------------------------------------- 

Function TAFDE0001(aWizard)

	Local cTxtSys  	as character
	Local nHandle   as numeric
	Local cReg 		as character
	Local cStrTxt 	as character

	cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
	nHandle     := MsFCreate( cTxtSys )
	cReg 		:= "0001"
	cStrTxt 	:= ""

	cStrTxt := "0001" 										//Tipo 									- Valor Fixo: 0001
	cStrTxt += DtoS( Date() ) + StrTran(Time(),":","")	    //Data da Geração do Arquivo 			- Formato: AAAAMMDDHHMMSS (Ex.: 20091231215530)
	cStrTxt += "N"											//Arquivo Gerado pelo Sistema da SEFAZ	- Valor Fixo: N
	cStrTxt := Left(cStrTxt,20) + (aWizard[1][3])			//Versão da DECLAN-IPM (Wizard)			- Formato: 9.9.9.9 (Ex.: 2.0.0.0)
	cStrTxt := Left(cStrTxt,30) + space(325)				//Filler 									- Preencher com espaços em branco
	cStrTxt := Left(cStrTxt,356) + "00001"					//Número da linha							- Número da linha
	cStrTxt += CRLF
	
	WrtStrTxt( nHandle, cStrTxt )
	
	GerTxtDERJ( nHandle, cTxtSys, cReg )
	
Return
