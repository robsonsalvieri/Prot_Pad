#Include 'Protheus.ch'

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFDAPI22

Rotina de geração do Detalhamento Tipo 22 da DAPI-MG

@Param aWizard	->	Array com as informacoes da Wizard
		nCont ->	Contador das linhas do arquivo
		aFil	->	Array com as informações da filial em processamento

@Author Rafael Völtz
@Since 29/06/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Function TAFDAPI22(aWizard, nCont, aFil)

Local cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
Local nHandle   	:= MsFCreate( cTxtSys )
Local cREG 		:= "22"
Local cStrTxt		:= ""
Local nPos			:= 0
Local cPeriodo   := StrZero(Year(aWizard[1][1]),4,0) + StrZero(Month(aWizard[1][1]),2,0)
Local aDetalh20  := {}
Local lFound      := ""
Private cFilDapi := aFil[1]
Private cUFID    := aFil[7]

Begin Sequence

	DBSELECTAREA("C09")
	C09->(DBSETORDER(1))
	If (DBSEEK(xFilial("C09")+aFil[6]))
		cUFID := C09->C09_ID
	Endif

	cStrTxt := cREG 									               	    	 				  //Tipo Linha					- Valor Fixo: 00
	cStrTxt += Substr(aFil[5],1,13)					              	 				 		  //Inscrição Estadual		- M0_INSC ( SIGAMAT )
	cStrTxt := Left(cStrTxt,15) + StrZero(Year(aWizard[1][1]),4,0)    		 				  //Ano Referência
	cStrTxt := Left(cStrTxt,19) + StrZero(Month(aWizard[1][1]),2,0)		 				  //Mês Referência
	cStrTxt := Left(cStrTxt,21) + StrZero(Day(aWizard[1][2]),2,0)			 				  //Dia final referência
	cStrTxt := Left(cStrTxt,23) + StrZero(Day(aWizard[1][1]),2,0)			 				  //Dia Inicial referência

	/***** DETALHAMENTO TIPO 22 - Estorno de Débito********/
	aDetalhe := DapiAprSQL(cFilDapi, cUFID, DToS(aWizard[1][1]), DTOS(aWizard[1][2]), "00090","0","ICMS")

	While nPos < Len(aDetalhe)
		nPos++
		nCont++

		If AllTrim(aDetalhe[nPos,11]) == 'C2D'
			DbSelectArea("C2D")
			DbGoto(aDetalhe[nPos,10])
			cJustif := C2D->C2D_DESCRI
			DBCloseArea()
		Else
			DbSelectArea("C2T")
			DbGoto(aDetalhe[nPos,10])
			cJustif := C2T->C2T_AJUCOM
			DBCloseArea()
		EndIf


		cStrTxt := Left(cStrTxt,25) + PADL(Alltrim(aDetalhe[nPos,1]),9)					//Nota Fiscal
		cStrTxt := Left(cStrTxt,34) + PADL(Alltrim(aDetalhe[nPos,2]),3)					//Serie
		cStrTxt := Left(cStrTxt,37) + FormatData(STOD(aDetalhe[nPos,3]),.F.,5)			//Data Documento
		cStrTxt := Left(cStrTxt,45) + StrTran(StrZero(aDetalhe[nPos,5], 16, 2),".","")	//Valor do Ajuste
		cStrTxt := Left(cStrTxt,60) + PADL(Alltrim(cJustif),60)					           //Justificativa
		cStrTxt := Left(cStrTxt,120)+ Right(aDetalhe[nPos,6],1)                         	//Código do Motivo
		cStrTxt += CRLF
		WrtStrTxt( nHandle, cStrTxt)
	EndDo

	GerTxtDAPI( nHandle, cTxtSys, cReg, cFilDapi)

Recover
	lFound := .F.

End Sequence

Return