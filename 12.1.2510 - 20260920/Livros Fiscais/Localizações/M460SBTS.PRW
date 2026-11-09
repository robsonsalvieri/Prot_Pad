#INCLUDE "PROTHEUS.CH"
#include "SIGAWIN.CH"     // incluido pelo assistente de conversao do AP5 IDE em 09/09/99
#DEFINE X_IMPOSTO    01  // Nome do imposto
#DEFINE X_NUMIMP     02 // Sufixo do imposto

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion   ³ M460SBTS ³ Autor ³ Verónica Flores       ³ Data ³10/08/2023³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripc  ³Calculo de Salida de la Sobretasa Bomberil  			      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ M460SBTS                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Sobretasa Bomberil                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function M460SBTS(cCalculo,nItem,aInfo)

Local nRet		:= 0
Local cImp		:= ""
Local nImporte	:= 0
Local cCodMun   := ""
Local cCodIca	:= ""
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
Local cCliFor	:= ""
Local cLoja		:= ""

Default cCalculo := ""
Default nItem	 := 0
Default aInfo	 := {}

cCliFor := M->F2_CLIENTE
cLoja	:= M->F2_LOJA
cCodICA := M->F2_TPACTIV
cCodMun := M->F2_CODMUN	
cImp	:= aInfo[X_IMPOSTO]

If cModulo != 'FAT'
	lRet := IIf(SA2->A2_RETICA $'S|1',.T.,.F.)
	If lRet .And. FunName() $ "MATA466N"
		lRet := fDocRel(nItem,aInfo[X_NUMIMP],cCliFor,cLoja)
	EndIf	
EndIf

If lRet
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
		Do Case
			Case cCalculo=="B"
				nRegSFC:=(SFC->(Recno()))
				SFC->(DbSetOrder(2)) //FC_FILIAL+FC_TES+FC_IMPOSTO
				If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+cImp)))
					//Considera este como la base para el calculo del Impuesto BOM.
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
				Else
					nRet += MaFisRet(nItem,"IT_VALMERC")
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
					//Realiza el calculo de la Sobretasa solo si se cumple con el valor indicado en la SFF						
					If xMoeda(nBase,nMoeda,1,Nil,Nil,nTaxaMoed) >= xMoeda(nImporte,nMoedSFF,1)
						nRet:=nBase * ( nAliq/100)
					Else
						nRet:= 0
					EndIf
			EndCase
		Endif
	EndIf
Return( nRet )   

/*/{Protheus.doc} fDocRel
Busca si el item del documento relacionado contiene impuesto de sobretasa bomberil
@type function
@author veronica.flores
@since 10/08/2023
@version 1.0
@param nItem  , numerico , Numero de item
@param nImp   , numerico , Numero de impuesto
@param cCliFor, caracter , Código del Cliente
@param cLoja  , caracter , Código de Tienda
@return lRet  , lógico, Indica si contiene o no sobretasa Bomberil
/*/

Static function fDocRel(nItem,nImp,cCliFor,cLoja)
Local lRet      := .F.  
Local nPosItem := aScan(AHEADER,{|x| Trim(x[2])=="D2_ITEMORI"})   
Local nPosSeri := aScan(AHEADER,{|x| Trim(x[2])=="D2_NFORI"})  
Local nPosDoc  := aScan(AHEADER,{|x| Trim(x[2])=="D2_SERIORI"})
Local nPosProd := aScan(AHEADER,{|x| Trim(x[2])=="D2_COD"})
Local cItem    := aCols[nItem][nPosItem]  
Local cSerie   := aCols[nItem][nPosSeri] 
Local cDoc     := aCols[nItem][nPosDoc] 
Local cProd	   := aCols[nItem][nPosProd] 

Default cCliFor := ""
Default cLoja	:= ""
Default nItem 	:= 0
Default nImp 	:= 0

dbSelectArea("SD1")
SD1->(dbSetOrder(1)) // D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM                                                         					
If SD1->(dbseek(xFilial("SD1")+cSerie+cDoc+cCliFor+cLoja+cProd+cItem))
	lRet := IIf(SD1->&("D1_VALIMP" + nImp) > 0, .T. , .F.)
EndIf
Return lRet
