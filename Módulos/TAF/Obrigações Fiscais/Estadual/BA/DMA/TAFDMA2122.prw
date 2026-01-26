#Include 'Protheus.ch'

Function TAFDMA2122(aWizard as array, aFiliais as array)
Local cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
Local nHandle   	:= MsFCreate( cTxtSys )

Local cMesRefer    := Substr(aWizard[1][2],1,2) //Mes Referencia
Local cAnoRefer    := Substr(aWizard[1][2],4,4) //Ano Referencia

//Contador
Local iIDCont    := aWizard[3][1]
Local cNomeCont  := ""
Local cEmailCont := ""
Local cDDDCont   := ""
Local cFoneCont  := ""

Local cCRC		  := ""
Local cUFCRC	  := ""
Local cTipoLG   := ""
Local cLograd   := ""
Local cUF       := ""
Local cBairro   := ""
Local cNumEnder := ""
Local cCodMun   := "00000"
Local cDesMun   := ""

Local cStrTxt		:= ""

Begin Sequence
	DbSelectArea("C2J") //Contador
	
	//CONTADOR
	C2J->(DbSetOrder(5))
	If C2J->(DbSeek(xFilial("C2J") + iIDCont ))

		cCRC        := Alltrim( C2J->C2J_CRC )

		If Substr( cCRC, 1, 3 ) == "1SP"
			cCRC := Substr( cCRC, 2 )
		EndIF
	
		cCRC 		:= Substr(StrTran(StrTran(cCRC,"-",""),"/",""), 3, 7)
		cUFCRC 		:= FindUFCRC( StrTran(StrTran( Alltrim( C2J->C2J_CRC ),"-",""),"/","") )
		
		cNomeCont   	:= Substr(C2J->C2J_NOME , 1, 35)
		cTipoLG		:=	POSICIONE("C06",3,xFilial("C06")+C2J->C2J_TPLOGR,"C06_CESOCI")
		cLograd		:=	C2J->C2J_END		
		
		cUF			:=	POSICIONE("C09",3,xFilial("C09")+C2J->C2J_UF, "C09_UF")
	
		//-------- REGISTRO TIPO 21
		
		cStrTxt := "21"	
		cStrTxt += cAnoRefer
		cStrTxt += cMesRefer
		cStrTxt += StrZero(VAL(aFiliais[5]),9,0)	
		
		cStrTxt += cCRC
		cStrTxt += cUFCRC
	
		cStrTxt += trim(cNomeCont) + space(35 - len(trim(cNomeCont)))
		cStrTxt += trim(cTipoLG) + space(3 - len(trim(cTipoLG)))
		cStrTxt += trim(cLograd) + space(30 - len(trim(cLograd)))
	
		cStrTxt += cUF	
		cStrTxt += CRLF
		
		//-------- REGISTRO TIPO 22
		
		cStrTxt += "22"	
		cStrTxt += cAnoRefer
		cStrTxt += cMesRefer
		cStrTxt += StrZero(VAL(aFiliais[5]),9,0)	
		
		cBairro       := Substr(C2J->C2J_BAIRRO, 1, 16)
		cNumEnder     := Substr(C2J->C2J_NUM, 1, 6)		
		cDDDCont		:= " " + Substr(C2J->C2J_DDD, 1, 3)		
		cFoneCont 		:= Substr(C2J->C2J_FONE , 1, 8)
		cCEP         	:= C2J->C2J_CEP
		If (C2J->C2J_UF == "000005")
			cCodMun := strzero(val(POSICIONE("T2D",2,xFilial("T2D") + C2J->C2J_CODMUN + "DMABA", "T2D_CODMUN")),5) //POSICIONE("T2D",2,xFilial("T2D") + C2J->C2J_CODMUN + "DMABA", "T2D_CODMUN")
		EndIf				
		cDesMun       := Substr(POSICIONE("C07",3,xFilial("C07")+C2J->C2J_CODMUN,"C07_DESCRI"),1,30)
		
		cStrTxt += trim(cBairro) + space(16 - len(trim(cBairro)))
		cStrTxt += StrZero(VAL(cNumEnder),9)	
		cStrTxt += trim(cDDDCont + cFoneCont) + space(16 - len(trim(cDDDCont + cFoneCont)))
		cStrTxt += cCEP
		cStrTxt += trim(cCodMun)
		cStrTxt += trim(cDesMun) + space(30 - len(trim(cDesMun)))		
		cStrTxt += CRLF
			 
	Endif	
	
	WrtStrTxt( nHandle, cStrTxt )
		
	GerTxtDMA( nHandle, cTxtSys, aFiliais[1] + "_TIPO2122")

	Recover
	lFound := .F.
End Sequence
	
Return


//-------------------------------------------------------------------
/*{Protheus.doc} FindUFCRC

Função auxiliar utilizada para retornar UF do CRC do contabilista

@param cCRC - string com o conteúdo do CRC a ser analisado
@return cUF -  UF do CRC

@OBS - Validado com a squad da contabilidade: 
	   Cada UF tem um padrão e tamanho de CRC, porem todos tem a UF no meio do registro

@author Wesley Pinheiro / Matheus Prada
@since 07/06/2019
@version 1.0
*/
//-------------------------------------------------------------------
Static Function FindUFCRC( cCRC )

	Local nTam := Len( cCRC )
	Local cUF  := ""
	Local nI   := 0
	Local uVal := Nil

	For nI := 1 To nTam
		uVal := Substr( cCRC, nI, 1 )

		If !isDigit( uVal )

			cUF := uVal

			// Validação somente para não gerar error log
			If nI + 1 <= nTam
				cUF += Substr( cCRC, nI + 1, 1 )
				exit
			EndIf
		Endif
	Next

	// Se não encontrou UF, o CRC digitado é inválido
	If Len( cUF ) != 2
		cUF := ""
	EndIf	

Return cUF
