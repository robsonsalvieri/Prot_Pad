/*   
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Regra de Bonif V. 2  ³Autor - Paulo Lima   ³ Data ³10/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Adiciona as Bonificacoes no Pedido      					  ³±±
±±³			 ³ 												 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SFA CRM 6.0                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cCliente   -> Cod. do Cliente								  ´±±
±±³			 ³cLoja      -> Loja do Cliente	 	     		   			  ´±±
±±³			 ³cCond      -> Cond. de Pagto. 				   			  ´±±
±±³			 ³cTab       -> Tabela de Preco					   			  ´±±
±±³			 ³cFormPg    -> Forma de Pagto					   			  ´±±
±±³			 ³aPedido    -> Array dos Itens do Pedido					  ´±±
±±³			 ³       [1] -> Cod. do Produto do Item						  ´±±
±±³			 ³       [2] -> Descricao do Produto						  ´±±
±±³			 ³       [3] -> Grupo do Produto							  ´±±
±±³			 ³       [4] -> Qtde. de Produtos do Item  					  ´±±
±±³			 ³       [5] -> Cod. da Tabela de Preco 					  ´±±
±±³			 ³       [6] -> Preco do Produto 							  ´±±
±±³			 ³       [7] -> Desconto									  ´±±
±±³			 ³       [8] -> Tes											  ´±±
±±³			 ³       [9] -> Valor Total por Item						  ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista    ³ Data   ³Motivo da Alteracao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function FtRgrBonus(xPar1,xPar2,cCliente,cLoja,cTabPreco,cCondPg,cFormPg)
Local aRetorno := {}
Local aPos     := {1,2,3}    //Posicao da Colunas no Array de Pedidos
Local aCopia   := {} 		 // Copia do Array do Pedido
Local aRemove  := {}        // Itens que serao removido conforme receberem a Bonificacao
Local aLote    := {}
Local aGrupos  := {}
Local cCursor  := "ACQ"
Local cCursor2 := "ACR"
Local cProduto := ""
Local cGrupo   := ""
Local lQuery   := .F.
Local lValido  := .F.
Local lBonific := .F.
Local lContinua:= .T.
Local nX       := 0
Local nY       := 0
Local nZ       := 0
Local nMult    := 0
Local nCabLote := 0
Local nSoma    := 0
Local nQuant   := 0
Local cCnt	   := ""
Local nRecs    := 0
Local nCnt	   := 1
Local cTesBonus :=""
//DEFAULT cProduto  := Space(Len(HB1->HB1_COD))
//DEFAULT cCliente  := Space(Len(HA1->HA1_COD))
//DEFAULT cLoja     := Space(Len(HA1->HA1_LOJA))
//DEFAULT cTabPreco := Space(Len(HTC->HTC_CODTAB))
//DEFAULT cCondPg   := Space(Len(HTC->HTC_CONDPG))
//DEFAULT cFormPg   := Space(2)

dbSelectArea("HCF")
dbSetOrder(1)
dbSeek(RetFilial("HCF")+"MV_BONUSTS")   

If Eof()
	lContinua:= .F.
Else
	cTesBonus:=HCF->HCF_VALOR
	
	dbSelectArea("HF4")
	dbSetOrder(1)
	dbSeek(RetFilial("HF4")+cTesBonus)
	if !Eof()
		lContinua:= .F.	
	Else
		If SubStr(cTesBonus,1,3)<="500" 
			lContinua := .F.
		Endif
	Endif	

	if !lContinua
		cTesBonus:=Nil
	Endif
	
Endif          

if lContinua
	For nX	:=	1	To Len(xPar1)
		If xPar1[nX][xPar2[aPos[3]]] <> cTesBonus
//			nPosProd	:=	Ascan(aCopia,{|x| x[1] == xPar1[nX][xPar2[1]]})
//			If nPosProd	> 0
//				aCopia[nPosProd][2]	+=	xPar1[nX][xPar2[2]]
//			Else
				AAdd(aCopia,{xPar1[nX][xPar2[aPos[1]]],xPar1[nX][xPar2[aPos[2]]],xPar1[nX][xPar2[aPos[3]]]})
//			Endif
		Endif
	Next

	dbSelectArea("ACQ")
	dbSetOrder(1)
    dbGotop()
	While !Eof()
		lValido:= .F.
		If ((HCQ->HCQ_CODCLI == cCliente .Or. Empty(HCQ->HCQ_CODCLI) ).And.;
				(HCQ->HCQ_LOJA == cLoja .Or. Empty(HCQ->HCQ_LOJA) ) .And.;
				(HCQ->HCQ_CODTAB == cTabPreco .Or. Empty(HCQ->HCQ_CODTAB) ) .And.;
				(HCQ->HCQ_CONDPG == cCondPg .Or. Empty(HCQ->HCQ_CONDPG) ) .And.;
				(HCQ->HCQ_FORMPG == cFormPg .Or. Empty(HCQ->HCQ_FORMPG) ) )
			lValido := .T.
		EndIf
		If lValido
			lBonific := .T.
			If HCQ->(FieldPos("CQ_LOTE"))>0
				nCabLote := Max(HCQ->HCQ_LOTE,0)
			Endif
			dbSelectArea("ACR")
			dbSetOrder(1)
			aRemove := {}
			While ( !Eof() .And. HCQ->HCQ_FILIAL == RetFilial("HCQ") .And. HCQ->HCQ_CODREG == HCR->HCR_CODREG )
				If nCabLote == 0
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Busca por Produto                                                       ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//					nY := aScan(aCopia,{|x| x[aPos[1]]==HCR->HCR_CODPRO .And. x[aPos[2]]>=IIf(nCabLote>0,nCabLote,HCR->HCR_LOTE) .And. x[aPos[3]]<>cTesBonus })
					nY:=0
					For nY:=1 to Len(aCopia) 
						if aCopia[nY,aPos[1]]==HCR->HCR_CODPRO .And. aCopia[nY,aPos[2]]>=IIf(nCabLote>0,nCabLote,HCR->HCR_LOTE) .And. aCopia[nY, aPos[3]]<>cTesBonus 
							break
						Endif
					Next
					If nY > Len(aCopia)
						nY:=0
					Endif       
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Busca por Grupo                                                         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If nY == 0 .And. Empty(HCR->HCR_CODPRO)
						For nX := 1 To Len(aCopia)
							cProduto := aCopia[nX][aPos[1]]
							//nY := aScan(aGrupos,{|x| x[1] == cProduto})
							nY:=0
							For nY:=1 to Len(aGrupos)
								if  aGrupos[nY,1] == cProduto   
							 		Break
							 	Endif
							Next
							if nY > Len(aGrupos)
								nY:=0
							Endif
							
							If nY == 0
								dbSelectArea("HB1")
								dbSetOrder(1)
								dbSeek(RetFilial("HB1")+cProduto)
								cGrupo := HB1->HB1_GRUPO
								aadd(aGrupos,{cProduto,cGrupo})
							Else
								cGrupo := aGrupos[nY][2]
							EndIf
							nY := 0
							If cGrupo == HCR->HCR_GRUPO .And. aCopia[nX][aPos[2]]>=IIf(nCabLote>0,nCabLote,HCR->HCR_LOTE)
								nY := nX
								Exit
							EndIf
						Next
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Avalia o tipo de Bonificacao                                            ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					//Se o tipo de bonificacao for "TODOS" e nao achei algum produto, zerar o aRemove e sair
					If nY <> 0 
					   	Aadd(aRemove,{nY,Int(aCopia[nY][aPos[2]] / HCR->HCR_LOTE),HCR->HCR_LOTE,aCopia[nY][aPos[2]]})
					ElseIf HCQ->HCQ_TPRGBN <> "2"
						aRemove	:=	{}
						Exit
					EndIf
				Else
					Aadd(aLote,{HCR->HCR_CODPRO,HCR->HCR_GRUPO})
				EndIf
				
				dbSelectArea("HCR")
				dbSkip()
			EndDo

			dbSelectArea("HCQ")
			nQuant	:=	HCQ->HCQ_QUANT
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Definir o multiplicador dependendo do tipo de bonificacao, se for tipo "TODOS",³
			//³pego o mínimo multiplo, se for "SOMENTE UM" pego o maximo multiplo.            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nX:=	1	To	Len(aRemove)
				If HCQ->HCQ_TPRGBN=="1"
					nMult	:=	If(nX==1,aRemove[1][2],Min(aRemove[nX][2],nMult))
				Else 
					nMult	:=	If(nX==1,aRemove[1][2],Max(aRemove[nX][2],nMult))
				Endif
			Next							                                         

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Avalia o tipo de Bonificacao                                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lBonific .And. Len(aRemove)>0
				For nX := 1 To Len(aRemove)   
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Anular los items que foram usados em uma Regra de bonificacao ³
					//³por lotes.                                                    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If nCabLote > 0
						aCopia[aRemove[nX][1]][aPos[2]]	:=	0
						nMult	:=	aRemove[nX][2]
					Else
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Se o tipo de bonificacao for por "SOMENTE UM", vou dar bonificacao         ³
						//³de acordo com o item que atingiu a maior bonificacao                       ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If HCQ->HCQ_TPRGBN=="2" 
							If aRemove[nX][2] >= nMult
								aCopia[aRemove[nX][1]][aPos[2]] -= aRemove[nX][3] * nMult
								Exit
							Endif
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Se o tipo de bonificacao for por "TODOS", vou dar bonificacao de acordo com³
						//³o item que limitou a bonificacao (nMult)                                   ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						Else
							aCopia[aRemove[nX][1]][aPos[2]] -= aRemove[nX][3] * nMult
						Endif
					Endif
				Next
				Aadd(aRetorno,{HCQ->HCQ_CODPRO, nMult * nQuant,cTesBonus,HCQ->HCQ_CODREG})
			Endif			
        Endif
//		nY := aScan(aCopia,{|x| x[aPos[2]]>0 })

//		If nY == 0
//			Exit
//		EndIf
		dbSelectArea("HCQ")
		dbSkip()
	Enddo
Endif   
Return (aRetorno)     


Function FScan(aArray, nX, nY, cCond)
For nX:=1 to len(aArray)
	if aArray[nX,nY]==cCond
	     break
	endif
Next

if nX>len(aArray)
	nX:=0
Endif

Return nX