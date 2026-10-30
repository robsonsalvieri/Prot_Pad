#include "SIGAWIN.CH"        // incluido pelo assistente de conversao do AP5 IDE em 09/09/99
#include "PROTHEUS.CH"

//Posicoes  do terceiro array recebido nos impostos a traves da matxfis...
#DEFINE X_IMPOSTO    01 //Nome do imposto
#DEFINE X_NUMIMP     02 //Sufixo do imposto

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calculo de impuesto  ICA 			    			      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ M100ICA2                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Calculo de ICA por ítem                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M100ICA2(cCalculo,nItem,aInfo)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
	//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
	//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
	//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local xRet		:=0
	Local lXFis		:=(MafisFound() .And. ProcName(1)!="EXECBLOCK")
	Local cImp		:= ""
	Local nAliqSFB	:= 0
	Local nImporte	:= 0
	Local cCodMUn   := ""
	Local cCodIca	:= ""
	Local lCodMUn	:= .F.
	Local cFunName	:= FunName()
	Local nMoedSFF  := 1
	Local nTaxaMoed	:= 0
	Local nMoeda    := 1
	Local nPosTPSD1	:=	0
	Local nPosCMSD1 :=  0
	Local cVar 		:=ReadVar()
	Local nAliq :=0
	Local nVal :=0
	Local lRet := .T.
	Local cDescSai :=SuperGetMv('MV_DESCSAI',.T.,'1')	

	Default cCalculo :=""
	Default nItem	:=0
	Default aInfo	:={}

	If lXFis
		xRet:=0
		cImp:=aInfo[X_IMPOSTO]
		nPosTPSD1	:=	aScan(aHeader,{|x| AllTrim(x[2])=="D1_TPACTIV"}) 
		nPosCMSD1	:=  aScan(aHeader,{|x| AllTrim(x[2])=="D1_CODMUN"})
			
		If  cVar == "M->D1_TPACTIV"
			cCodIca:= M->D1_TPACTIV
			If nPosCMSD1 > 0 
				cCodMun	:= aCols[nItem][nPosCMSD1]
			EndIf
		ElseIf cVar == "M->D1_CODMUN"
			cCodMun:= M->D1_CODMUN
			If nPosTPSD1 > 0 
				cCodIca	:= aCols[nItem][nPosTPSD1]
			EndIf
		Else
			If nPosTPSD1 > 0 
				cCodIca	:= aCols[nItem][nPosTPSD1]
			EndIf
			If nPosCMSD1 > 0 
				cCodMun	:= aCols[nItem][nPosCMSD1]
			EndIf
		EndIf		
	Endif
	//Tratamento para Calcular ou Não ICA
	If cModulo$'COM|EST|EIC'
		lRet := (SA2->A2_RETICA == "S")		
	Else
		lRet := (SA1->A1_RETICA == "S")		
	Endif

	dbSelectArea("SFB")
	dbSetOrder(1)
	If MsSeek(xFilial("SFB")+cImp)
		If If(!lXFis,.T.,cCalculo$"AB")
			nAliqSFB  := SFB->FB_ALIQ // Aliquota padrão
		EndIf
	EndIf
	If lRet
		If Empty(cCodIca)
			nAliq   := nAliqSFB  // Aliquota padrão
		Else
			dbSelectArea("SFF")
			dbSetOrder(17)
			If MsSeek(xFilial("SFF")+cImp+cCodMun) 
				While !Eof() .And. xFilial("SFF") == SFF->FF_FILIAL .And. SFF->(FF_IMPOSTO+FF_CODMUN) == cImp+cCodMun
					If ( ALLTRIM(SFF->FF_COD_TAB) == ALLTRIM(cCodICA))
						If FF_FLAG != "1"  .And. cCalculo <>"V"
							RecLock("SFF",.F.)
							Replace FF_FLAG With "1"
						EndIf
						nAliq   := SFF->FF_ALIQ  // Alicuota de Zona Fiscal
						nImporte:= SFF->FF_IMPORTE
						nMoedSFF:= SFF->FF_MOEDA
						lCodMun := .T.
						lRet	:= .T.
						Exit
					Else
						lRet := .F.
					EndIf
					SFF->(dbSkip())
				EndDo
			Endif
			If !lCodMun
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Metodo antigo de busca , pela zona fiscal (departamento) foi DESATIVADA 						³
				//³caso não tenha aliq. por cod.município, obtera' da SFB, que na Colombia devera' estar ZERADA.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nAliq   := nAliqSFB  // Aliquota padrão
				lRet    := .T.
			Endif
		Endif

		If lRet
			Do Case
				Case cCalculo=="B"
					xRet:= 0
					If cDescSai=='1'
						xRet	+= MaFisRet(nItem,"IT_DESCONTO")
					Endif
					//Tira os descontos se for pelo liquido
					SFC->(DbSetOrder(2))
					If (SFC->(MsSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+aInfo[X_IMPOSTO])))
						If SFC->FC_LIQUIDO=="S"
							xRet-=MaFisRet(nItem,"IT_DESCONTO")
						Endif
					Endif
					xRet+= MaFisRet(nItem,"IT_VALMERC") 
				Case cCalculo=="A"
					xRet:=nAliq
				Case cCalculo=="V"
					If Type("M->F1_MOEDA")<>"U" 			   	
						nMoeda := M->F1_MOEDA
						nTaxaMoed := M->F1_TXMOEDA				
					EndIf	        
					If nTaxaMoed==0
						nTaxaMoed:= RecMoeda(nMoeda)
					EndIf
					nVal:=0
					SFC->(DbSetOrder(2))
					If (SFC->(MsSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+aInfo[X_IMPOSTO])))
						If SFC->FC_CALCULO=="I"
							nVal:=MaFisRet(nItem,'IT_BASEIV'+aInfo[X_NUMIMP])
						EndIf
					Endif

					nAliq:=MaFisRet(nItem,"IT_ALIQIV"+aInfo[X_NUMIMP])

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Calcula o imposto somente se o valor da base for maior ou igual a base minima    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If xMoeda(nVal,nMoeda,1,Nil,Nil,nTaxaMoed) >= xMoeda(nImporte,nMoedSFF,1)
						xRet:=nVal * ( nAliq/1000)
					Else
						xRet:= 0
					EndIf
			EndCase
		Endif
	Endif
Return( xRet )
