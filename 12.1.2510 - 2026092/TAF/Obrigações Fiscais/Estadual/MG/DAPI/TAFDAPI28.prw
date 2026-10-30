#Include 'Protheus.ch'

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFDAPI28

Rotina de geração do Detalhamento Tipo 28 da DAPI-MG

@Param aWizard	->	Array com as informacoes da Wizard
		nCont ->	Contador das linhas do arquivo
		aFil	->	Array com as informações da filial em processamento

@Author Rafael Völtz
@Since 29/06/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Function TAFDAPI28(aWizard, nCont, aFil)

Local cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
Local nHandle   	:= MsFCreate( cTxtSys )
Local cREG 		:= "28"
Local cStrTxt		:= ""
Local nPos			:= 0
Local cPeriodo   := StrZero(Year(aWizard[1][1]),4,0) + StrZero(Month(aWizard[1][1]),2,0)
Local aDetalhe  := {}
Local lFound      := ""
Private cFilDapi := aFil[1]
Private cUFID    := aFil[7]

Begin Sequence

	cStrTxt := cREG 									               	    	 				  //Tipo Linha					- Valor Fixo: 00
	cStrTxt += Substr(aFil[5],1,13)					              	 				 		  //Inscrição Estadual		- M0_INSC ( SIGAMAT )
	cStrTxt := Left(cStrTxt,15) + StrZero(Year(aWizard[1][1]),4,0)    		 				  //Ano Referência
	cStrTxt := Left(cStrTxt,19) + StrZero(Month(aWizard[1][1]),2,0)		 				  //Mês Referência
	cStrTxt := Left(cStrTxt,21) + StrZero(Day(aWizard[1][2]),2,0)			 				  //Dia final referência
	cStrTxt := Left(cStrTxt,23) + StrZero(Day(aWizard[1][1]),2,0)			 				  //Dia Inicial referência

	/***** DETALHAMENTO TIPO 28 - Ressarcimento ICMS  ********/
	aDetalhe := DapiAprSQL(cFilDapi, cUFID, DToS(aWizard[1][1]), DTOS(aWizard[1][2]), "00079","0","ICMSST")

	While nPos < Len(aDetalhe)
		nPos++
		nCont++

		cStrTxt := Left(cStrTxt,25) + PADL(Alltrim(aDetalhe[nPos,7]),15,"0")           	//IE
		cStrTxt := Left(cStrTxt,40) + PADL(Alltrim(aDetalhe[nPos,1]),9)					//Nota Fiscal
		cStrTxt := Left(cStrTxt,49) + PADL(Alltrim(aDetalhe[nPos,2]),3)					//Serie
		cStrTxt := Left(cStrTxt,52) + FormatData(STOD(aDetalhe[nPos,3]),.F.,5)			//Data Documento
		cStrTxt := Left(cStrTxt,60) + FormatData(STOD(aDetalhe[nPos,4]),.F.,5)			//Data do Visto
		cStrTxt := Left(cStrTxt,68) + StrTran(StrZero(aDetalhe[nPos,5], 16, 2),".","")	//Valor do Ajuste
		cStrTxt := Left(cStrTxt,83) + Right(aDetalhe[nPos,6],1)                         	//Código do Motivo

		cStrTxt += CRLF
		WrtStrTxt( nHandle, cStrTxt)
	EndDo

	GerTxtDAPI( nHandle, cTxtSys, cReg, cFilDapi)

Recover
	lFound := .F.

End Sequence

Return