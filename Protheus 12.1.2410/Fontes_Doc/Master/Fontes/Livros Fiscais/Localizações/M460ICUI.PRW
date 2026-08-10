#INCLUDE "PROTHEUS.CH"
#include "SIGAWIN.CH"     // incluido pelo assistente de conversao do AP5 IDE em 09/09/99
#DEFINE X_IMPOSTO    01  // Nome do imposto
#DEFINE X_NUMIMP     02 // Sufixo do imposto

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion   ³ M460ICUI ³ Autor ³ Eduardo Pérez         ³ Data ³26/10/2023³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripc  ³Calculo de Salida de Impuestos Saludables         	      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ M460ICUI                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Impuestos Saludables                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function M460ICUI(cCalculo,nItem,aInfo)

	Local nRet		:= 0
	Local cImp		:= ""
	Local nImporte	:= 0
	Local cCodMun   := ""
	Local cCodIca	:= ""
	Local aImpRef	:= {}
	Local aImpVal	:= {}
	Local aItem    := {}
	Local nI		:= 1
	Local nE        := 1
	Local nMoeda    := 1
	Local nTaxaMoed := 1	
	Local nMoedSFF  := 1
	Local nAliq 	:= 0
	Local nBase		:= 0
	Local nVal		:= 0
	Local lRet      := .F.
	Local cBaseImp	:= ""
	Local cCliFor	:= ""
	Local cLoja		:= ""
	Local cProducto := ""
	Local lExistCpo := .F.
	Local lXfis     := (MafisFound() .And. ProcName(1)!="EXECBLOCK")
	Local cImpIncid:= ""



	Default cCalculo := ""
	Default nItem	 := 0
	Default aInfo	 := {}
	
	if !lXfis	
		aItem:=ParamIxb[1]
		aImp:=ParamIxb[2]
		cImp:=aImp[1]
		cProducto:= aImp[16]
		cImpIncid:=aImp[10]
		nRet := aImp
	Else
		cCliFor := M->F2_CLIENTE
		cLoja	:= M->F2_LOJA
		cCodICA := M->F2_TPACTIV
		cCodMun := M->F2_CODMUN	
		cImp	:= aInfo[X_IMPOSTO]
		cProducto := MaFisRet(nItem,"IT_PRODUTO")
	EndIf

	DbSelectArea("SB1")
	lExistCpo := SB1->(FieldPos("B1_GPIETU")) > 0
	SB1->(dbSetOrder(1))
	If lExistCpo .and. SB1->(dbSeek(xFilial("SB1")+cProducto))
		lRet := If(SB1->B1_GPIETU  $'S',.T.,.F.)
	EndIf

	If lRet
		DbSelectArea("SFB")
		SFB->(DbSetOrder(1))
		If SFB->(MSseek(xFilial("SFB")+cImp))
			nAliq := SFB->FB_ALIQ
		Endif

		dbSelectArea("SFF")
		SFF->(dbSetOrder(18)) // FF_FILIAL+FF_IMPOSTO+FF_CODMUN+FF_CFO_V
		If SFF->(dbseek(xFilial("SFF")+cImp))
			While SFF->(!Eof()) .And. SFF->FF_CODMUN == cCodMun 
				lRet := .F.
				If SFF->FF_COD_TAB == cCodICA .And.	SFF->(FF_IMPOSTO+FF_CODMUN) == cImp+cCodMun
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
		EndIf 

		If lRet
			If !lXFis
				nBase:=aItem[3]+aItem[4]+aItem[5]  //total + frete + otros impostos
				If Subs(aImp[5],4,1) == "S" .And. Len(aImp) >= 18 .And. ValType(aImp[18])=="N"
					nBase-=aImp[18]
				Endif
				//Suma la Base de Cálculo de Impuestos Incidentes
				nI:=At(cImpIncid,";" )
				nI:=Iif(nI==0,Len(AllTrim(cImpIncid))+1,nI)
				While nI>1
					nE:=AScan(aItem[6],{|x| x[1]==Left(cImpIncid,nI-1)})
					If nE>0
						nBase+=aItem[6,nE,4]
					End
					cImpIncid:=Stuff(cImpIncid,1,nI,"")
					nI:=At(cImpIncid,";")
					nI:=Iif(nI==0,Len(AllTrim(cImpIncid))+1,nI)
				End

				aImp[02]:=nAliq
				aImp[03]:=nBase
				aImp[04]:=(nAliq * nBase)/100
				nRet:=aImp
			Else
				Do Case
					Case cCalculo=="B"
						nRet:=MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
						nRegSFC:=(SFC->(Recno()))
						SFC->(DbSetOrder(2)) //FC_FILIAL+FC_TES+FC_IMPOSTO
						If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+cImp)))
							//Considera este como la base para el calculo del Impuesto CUI/BUA.
							cBaseImp:=Alltrim(SFC->FC_INCIMP)
							If SFC->FC_LIQUIDO=="S"
								nRet-=If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
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
						If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+aInfo[X_IMPOSTO])))
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
							
						If Type("M->F2_MOEDA")<>"U"
							nMoeda := M->F2_MOEDA
							nTaxaMoed := M->F2_TXMOEDA						
						EndIf	        
						//Realiza el calculo Impuesto CUI/BUA solo si se cumple con el valor indicado en la SFF						
						If xMoeda(nBase,nMoeda,1,Nil,Nil,nTaxaMoed) >= xMoeda(nImporte,nMoedSFF,1)
							nRet:=nBase * ( nAliq/100)
						Else
							nRet:= 0
						EndIf
				EndCase
			Endif
		Endif
	EndIf
Return( nRet )   
