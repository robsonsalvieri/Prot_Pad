#Include 'Protheus.ch'

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFDAPI00

Rotina de geração da Linha Tipo 00 da DAPI-MG

@Param aWizard	->	Array com as informacoes da Wizard
		nCont ->	Contador das linhas do arquivo
		aFil	->	Array com as informações da filial em processamento

@Author Rafael Völtz
@Since 29/06/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Function TAFDAPI00(aWizard, nCont, aFil, lTermo)

Local cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
Local nHandle   := MsFCreate( cTxtSys )
Local cREG 		:= "00"
Local cStrTxt 	:= ""
Local cTermoAc  := "N"
Local lFound    := .T.

Default lTermo  := .F.

nCont++

Begin Sequence

cStrTxt := cREG 									               	    	 		 	                       		//Tipo Linha					- Valor Fixo: 00
cStrTxt += Substr(aFil[5],1,13)					              	 				                             	//Inscrição Estadual		- M0_INSC ( SIGAMAT )
cStrTxt := Left(cStrTxt,15) + StrZero(Year(aWizard[1][1]),4,0)    		 				                       	//Ano Referência
cStrTxt := Left(cStrTxt,19) + StrZero(Month(aWizard[1][1]),2,0)		 				                         //Mês Referência
cStrTxt := Left(cStrTxt,21) + StrZero(Day(aWizard[1][2]),2,0)			 				                         //Dia final referência
cStrTxt := Left(cStrTxt,23) + StrZero(Day(aWizard[1][1]),2,0)			 				                         //Dia Inicial referência
cStrTxt := Left(cStrTxt,25) + "D1"                                     				                         //Modelo DAPI      - FIXO 'D1'
cStrTxt := Left(cStrTxt,27) + If(aWizard[2][2] == '0 - Não', "N", "S") 				                         //DAPI para substituição?
cStrTxt := Left(cStrTxt,28) + Replicate("0",7)                            		                            //CAE (não necessário, pois existe CNAE-F)
cStrTxt := Left(cStrTxt,35) + Replicate("0",2)                           				                      	//Desmembramento do CAE (não necessário)
cStrTxt := Left(cStrTxt,37) + If(aWizard[1][5] == '1 - Débito e Crédito', "01", "03")                        //Regime de Recolhimento
cStrTxt := Left(cStrTxt,39) + If(aWizard[2][3] == '0 - Não', "N", "S") 				                         //Regime especial de fiscalização?
cStrTxt := Left(cStrTxt,40) + IIF(EMPTY(aWizard[1][6]) == .F., DtoS(aWizard[1][6]), + '00000000')            //Data limite para pagamento
cStrTxt := Left(cStrTxt,48) + "N"                                     				                         //Optante pelo FUNDESE?  SE Modelo da DAPI = “D1” ENTÃO FUNDESE = "N"
cStrTxt := Left(cStrTxt,49) + If(aWizard[2][1] == '0 - Não', "N", "S") 				                         //DAPI com movimento?
cStrTxt := Left(cStrTxt,50) + "N"                                     				                         //Movimento de Café? Apenas para DAPI Modelo 01 e até referencia 07/2005.
cStrTxt := Left(cStrTxt,51) + Substr(aFil[4],1,7)	               				  	                         //CNAE-F
cStrTxt := Left(cStrTxt,58) + IIF(Empty(Substr(aWizard[1][7],1,2)) == .F.,Substr(aWizard[1][7],1,2), + "00") //Desmembramento CNAE-F

cTermoAc := IIF(SubStr(aWizard[2][4],1,1) <> '0' .And.; 
				StrZero(Year(aWizard[1][1]),4,0) + StrZero(Month(aWizard[1][1]),2,0) >= "201805", "S", "N")
				
lTermo := cTermoAc == "S"			

cStrTxt := Left(cStrTxt,60) + cTermoAc																		 //Termo de Aceite (Somente será preenchido com Sim a partir do período de referência de 05/2018

cStrTxt += CRLF

WrtStrTxt( nHandle, cStrTxt )

GerTxtDAPI( nHandle, cTxtSys, cReg, aFil[1] )

Recover
	lFound    := .F.
End Sequence


Return

