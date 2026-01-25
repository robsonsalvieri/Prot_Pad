#Include 'Protheus.ch'

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFDAPI99

Rotina de geração da linha 99 da DAPI-MG

@Param aWizard	->	Array com as informacoes da Wizard
		nCont ->	Contador das linhas do arquivo
		aFil	->	Array com as informações da filial em processamento

@Author Rafael Völtz
@Since 29/06/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Function TAFDAPI99(aWizard, nCont, aFil)

Local cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
Local nHandle   	:= MsFCreate( cTxtSys )
Local cREG 		:= "99"
Local cStrTxt 	:= ""
Local lFound      := ""

nCont++

Begin Sequence

cStrTxt := cREG 									               	    	 				  //Tipo Linha					- Valor Fixo: 00
cStrTxt += Substr(aFil[5],1,13)					              	 				  //Inscrição Estadual		- M0_INSC ( SIGAMAT )
cStrTxt := Left(cStrTxt,15) + StrZero(Year(aWizard[1][1]),4,0)    		 				  //Ano Referência
cStrTxt := Left(cStrTxt,19) + StrZero(Month(aWizard[1][1]),2,0)		 				  //Mês Referência
cStrTxt := Left(cStrTxt,21) + StrZero(Day(aWizard[1][2]),2,0)			 				  //Dia final referência
cStrTxt := Left(cStrTxt,23) + StrZero(Day(aWizard[1][1]),2,0)			 				  //Dia Inicial referência
cStrTxt += StrZero(nCont,4,0)
cStrTxt += CRLF

WrtStrTxt( nHandle, cStrTxt )

GerTxtDAPI( nHandle, cTxtSys, cReg, aFil[1])

Recover
lFound := .F.

End Sequence


Return