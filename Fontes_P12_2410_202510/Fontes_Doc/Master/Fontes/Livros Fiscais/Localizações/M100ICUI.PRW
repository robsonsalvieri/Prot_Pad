#INCLUDE "PROTHEUS.CH"
#include "SIGAWIN.CH"     // incluido pelo assistente de conversao do AP5 IDE em 09/09/99
#DEFINE X_IMPOSTO     01 //Nome do imposto
#DEFINE X_NUMIMP     02 //Sufixo do imposto

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion   ³ M100ICUI ³ Autor ³ Eduardo Pérz          ³ Data ³26/10/2023³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripc  ³ Calculo de Entrada de Impuestos saludables       	      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ M100ICUI                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Impuestos saludables                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function M100ICUI(cCalculo,nItem,aInfo)

	Local nRet		:= 0
	Local lDesNCCCol := FunName() == "MATA465N" .And. cEspecie == "NCC"
	Local cImp		:= ""
	Local nImporte	:= 0
	Local cCodMun   := ""
	Local cCodTpAct	:= ""
	Local aImpRef	:= {}
	Local aImpVal	:= {}
	Local nI		:= 1
	Local nMoeda    := 1
	Local nTaxaMoed := 1	
	Local nMoedSFF  := 1
	Local nAliq 	:= 0
	Local nBase		:= 0
	Local nVal		:= 0
	Local lRet      := .F.
	Local cBaseImp	:= ""
	Local cProducto := ""
	Local lExistCpo := .F.

	Default cCalculo := ""
	Default nItem	 := 0
	Default aInfo	 := {}

	cProducto := MaFisRet(nItem,"IT_PRODUTO")
	DbSelectArea("SB1")
	lExistCpo := SB1->(FieldPos("B1_GPIETU")) > 0
	SB1->(dbSetOrder(1))
	If lExistCpo .and. SB1->(dbSeek(xFilial("SB1")+cProducto))
		lRet := If(SB1->B1_GPIETU  $'S|1',.T.,.F.)
	EndIf
	cCodTpAct := M->F1_TPACTIV
	cCodMun := M->F1_CODMUN	
	cImp:= aInfo[X_IMPOSTO]

	If lRet
		DbSelectArea("SFB")
		SFB->(DbSetOrder(1))
		If SFB->(MSseek(xFilial("SFB")+cImp))
			nAliq := SFB->FB_ALIQ
		Endif
		dbSelectArea("SFF")
		SFF->(dbSetOrder(17)) //FF_FILIAL+FF_IMPOSTO+FF_CODMUN+FF_CFO_C					
		If SFF->(MSseek(xFilial("SFF")+cImp))
			While SFF->(!Eof()) .And. SFF->FF_CODMUN == cCodMun 
				lRet := .F.
				If SFF->FF_COD_TAB == cCodTpAct .And.	SFF->(FF_IMPOSTO+FF_CODMUN) == cImp+cCodMun
					If SFF->FF_FLAG != "1"
						RecLock("SFF",.F.)
						SFF->FF_FLAG := "1"
					Endif
					nAliq    := SFF->FF_ALIQ  // Alicuota de Zona Fiscal
					nImporte := SFF->FF_IMPORTE
					nMoedSFF := SFF->FF_MOEDA
					lRet 	 := .T.
					Exit
				EndIf
				SFF->(dbSkip())
			EndDo
		Endif
		If lRet
			Do Case
				Case cCalculo=="B"
					nRet:=MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
					nRegSFC:=(SFC->(Recno()))
					SFC->(DbSetOrder(2)) //FC_FILIAL+FC_TES+FC_IMPOSTO
					If (SFC->(MSseek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+cImp)))
						//Considera este como la base para el calculo del Impuesto CUI/BUA.
						cBaseImp:=Alltrim(SFC->FC_INCIMP)
						If SFC->FC_LIQUIDO=="S"
							nRet-=If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
								If GetNewPar('MV_DESCSAI', '1') == '1'  .AND. cModulo $ "FAT|LOJA|FRT|TMK" .And. IIf(lDesNCCCol, .T., .F.)
									nRet += If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
								EndIf
						Endif
					Endif
					If !Empty(cBaseImp)
						aImpRef:=MaFisRet(nItem,"IT_DESCIV")
						aImpVal:=MaFisRet(nItem,"IT_VALIMP")
						For nI:=1 to Len(aImpRef)
							If !Empty(aImpRef[nI])
								IF Trim(aImpRef[nI][1])$cBaseImp
									nRet+=aImpVal[nI]
								Endif
							Endif
						Next nI
					Endif
					SFC->(DbSetOrder(2)) //FC_FILIAL+FC_TES+FC_IMPOSTO
					SFC->(DbGoto(nRegSFC))

				Case cCalculo=="A"
					nRet:=nAliq
				Case cCalculo=="V"         
					nRegSFC:=(SFC->(Recno()))
					SFC->(DbSetOrder(2)) //FC_FILIAL+FC_TES+FC_IMPOSTO
					nVal	:= 0
					If (SFC->(MSseek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+aInfo[X_IMPOSTO])))
						nAliq:=MaFisRet(nItem,"IT_ALIQIV"+aInfo[X_NUMIMP])
						nVal:=0					
						If SFC->FC_CALCULO=="T"
							nBase:=MaFisRet(,"NF_BASEIV"+aInfo[X_NUMIMP])+MaFisRet(nItem,"IT_BASEIV"+aInfo[X_NUMIMP])
							nVal:=MaRetBasT(aInfo[2],nItem,MaFisRet(nItem,'IT_ALIQIV'+aInfo[2]),.T.)
						Else
							nBase:= MaFisRet(nItem,"IT_BASEIV"+aInfo[X_NUMIMP])
							nVal :=	MaFisRet(nItem,'IT_BASEIV'+aInfo[2])
						Endif
					Endif		
					SFC->(DbSetOrder(2)) //FC_FILIAL+FC_TES+FC_IMPOSTO
					SFC->(DbGoto(nRegSFC))
					
					If Type("M->F1_MOEDA")<>"U" 			   	
						nMoeda := M->F1_MOEDA
						nTaxaMoed := M->F1_TXMOEDA			
					EndIf	        
					//Realiza el calculo Impuesto CUI/BUA solo si se cumple con el valor indicado en la SFF						
					If xMoeda(nBase,nMoeda,1,Nil,Nil,nTaxaMoed) >= xMoeda(nImporte,nMoedSFF,1)
						nRet:=nBase * ( nAliq/100)
					Else
						nRet:= 0
					EndIf
			EndCase
		Endif
	EndIf
Return( nRet )   
