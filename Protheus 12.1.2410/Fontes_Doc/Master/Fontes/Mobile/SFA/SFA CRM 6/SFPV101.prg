#INCLUDE "SFPV101.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Adiciona Itens      ³Autor - Paulo Lima   ³ Data ³01/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Modulo de Pedidos        					 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SFA CRM 6.0                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³oLbxItePed,aLbxItePed, aItePed, aTab, nTab, aCond ,         ´±±
±±³          ³nCond, cProd, oTxtProd, nQtde, oTxtQtde, nPrc, oTxtPrc, 	  ´±±
±±³			 ³nDesc, oTxtDesc, nTotPed, oTxtTotPed                        ´±±
±±³ 		 |	nTelaPed = 1 => Tela de Pedido Padrao (V.1)               ³±±
±±³	         | 			   2 => Tela de Pedido Especifica (V.2)           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Objetivo: ³ Adicionar os Itens para a Gravacao na Tab. PedidoI         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista    ³ Data   ³Motivo da Alteracao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function PVGrvIte(aColIte,aItePed, nItePed, aCabPed,aObj,cManTes,cProDupl,nOpIte,nTelaPed,nTop)
Local nSubTotI :=0, nLin := 0
Local nQtdAnt  := 0 // Quantidade Anterior guardada na alteração
Local nPrdPeso := 0
If !PVVrfIte(aColIte,aItePed,aCabPed,cProDupl,nOpIte)
   	SetFocus(aObj[3,1])
    Return Nil
Endif

aColIte[9,1] := aColIte[4,1] * aColIte[6,1]

if nItePed=0 //Novo item
	AADD(aItePed,Array(Len(aColIte)))
	For nI := 1 to Len(aColIte)
	  aItePed[Len(aItePed),nI] := aColIte[nI,1]
	Next
	nItePed:=Len(aItePed)
Else	//Alteracao do item                              
	If nTelaPed == 2 	//Tela V.2 => Subtrair valor do item (atual) do Total
		PVCalcPed(aCabPed,aColIte,aItePed,nItePed,.F.,,.F.) 
	Endif
	nQtdAnt := aItePed[nItePed,4]
	For nI:=1 to Len(aColIte)
		aItePed[nItePed,nI]:= aColIte[nI,1] 
	Next         
Endif	

//Aplica regra de desconto no item             
RGAplDescIte(aCabPed[3,1], aCabPed[4,1], aCabPed[7,1], aCabPed[8,1], "", aItePed, nItePed, aColIte, nQtdAnt)

//Adiciona valor do item ao Total do Pedido
PVCalcPed(aCabPed,aColIte,aItePed,nItePed,.T.,aObj,.T.)

If cSfaPeso == "T" .And. HB1->(FieldPos("B1_PBRUTO")) > 0
	HB1->(dbSetOrder(1))
	HB1->(dbSeek(aColIte[1,1]))	
	nPrdPeso := HB1->B1_PBRUTO
	If cUmPeso = "1"
		If nQtdAnt != 0
			aCabPed[17,1] := aCabPed[17,1] - (nQtdAnt * nPrdPeso)
		EndIf
		aCabPed[17,1] := aCabPed[17,1] + (aItePed[nItePed, 4] * nPrdPeso)
	Else
		If HB1->B1_TIPCONV = "M"
			nPrdPeso := Round(nPrdPeso * HB1->B1_CONV,2)
		Else
			nPrdPeso := Round(nPrdPeso / HB1->B1_CONV,2)
		EndIf
		If nQtdAnt != 0
			aCabPed[17,1] := aCabPed[17,1] - (nQtdAnt * nPrdPeso)
		EndIf		
		aCabPed[17,1] := aCabPed[17,1] + (aItePed[nItePed, 4] * nPrdPeso)
	EndIf
	SetText(aObj[2,16], aCabPed[17,1])
EndIf

If nTelaPed == 1 //Tela de Pedido V. 1
	SetArray(aObj[3,1],aItePed)
	CloseDialog()
Else //Tela de Pedido V. 2
	nLin := GridRow(aObj[3,1])
	//aProduto[nLin,1] := aColIte[2,1]
	//aProduto[nLin,2] := aColIte[1,1]
	aProduto[nLin,3] :=	 aColIte[4,1]
	aProduto[nLin,4] := aColIte[6,1]
	aProduto[nLin,5] := aColIte[7,1]
	aProduto[nLin,6] := aColIte[9,1]
	PVLimpaItem(aColIte,aObj,cManTes)
	If (nLin+1) > Len(aProduto)
		// Caso seja o ultimo produto, carrega a proxima pagina
		PVDesce(aGrupo,nGrupo,aObj[3,1],@nTop,aItePed,.T.)	
		nLin := 1
	Else
		nLin++
	EndIf
	GridSetRow(aObj[3,1],nLin)
	SetFocus(aObj[3,3])
Endif

Return Nil


Function PVVrfIte(aColIte,aItePed,aCabPed,cProDupl,nOpIte)
Local nDescMax  := 0
Local nTipoDesc := 0

HB1->(dbSetOrder(1))
HB1->(dbSeek(aColIte[1,1]))

// Posiciona produto na tabela
HPR->(dbSetOrder(1))
HPR->(dbSeek(aColIte[1,1] + aCabPed[8,1]))

If HPR->(FieldPos("PR_DESMAX")) > 0
	If HPR->(Found()) .And. HPR->PR_DESMAX > 0
		nTipoDesc := 1
		nDescMax  := HPR->PR_DESMAX
	EndIf
EndIf

If HB1->(FieldPos("B1_DESCMAX")) > 0 
	If nDescMax = 0
		nTipoDesc := 2
		nDescMax  := HB1->B1_DESCMAX
	EndIf
Else
	If nDescMax = 0
		nDescMax := 100
	EndIf
Endif
//Valida se o produto ja foi incluido neste pedido
If cProDupl == "F" .And. nOpIte==1 //novo item
	If ScanArray(aItePed, aColIte[1,1],,,1) > 0
		MsgStop(STR0001,STR0002) //"Este produto ja foi incluido!"###"Verifica Item"
		Return .F.
	EndIf	
EndIf

If Empty(aColIte[1,1]) 
  MsgStop(STR0003,STR0002) //"Escolha um Produto!"###"Verifica Item"
  Return .f.
Elseif aColIte[4,1] <= 0
  MsgStop(STR0004,STR0002) //"Escreva uma Qtde válida!"###"Verifica Item"
  Return .f.
Elseif (cQtdDec == "F") .And. ( (aColIte[4,1] - Int(aColIte[4,1])) > 0)
  MsgStop(STR0005,STR0002) //"Escreva a Qtde sem decimais!"###"Verifica Item"
  Return .f.
Elseif aColIte[6,1] == 0
  MsgStop(STR0006,STR0002)   //"Escolha/Escreva o Preço!"###"Verifica Item"
  Return .f.
Elseif aColIte[7,1] > nDescMax
  If nTipoDesc = 1
      MsgStop(STR0009 + str(nDescMax,3,2) + " %",STR0002) //"Desconto acima do máximo permitido na tabela: "###"Verifica Item"
  Else
      MsgStop(STR0007 + str(nDescMax,3,2) + " %",STR0002) //"Desconto acima do máximo permitido: "###"Verifica Item"
  EndIf
  Return .f.
Elseif Empty(aColIte[8,1])
  MsgStop(STR0008,STR0002)   //"Tes não Selecionado!"###"Verifica Item"
  Return .f.                                      
endif

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Remove Itens        ³Autor - Paulo Lima   ³ Data ³01/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Modulo de Pedidos        					 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SFA CRM 6.0                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³oLbxItePed,aLbxItePed, aItePed, nItePed, aTab, nTab,        ´±±
±±³          ³aCond ,nCond, cProd, oTxtProd,nQtde,oTxtQtde, nPrc,oTxtPrc, ´±±
±±³			 ³nDesc, oTxtDesc, nTotPed, oTxtTotPed                        ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         				OBSERVACAO.             					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ lClose = .T. -> Quando estou efetuando a exclusao do Item 			  ³±±
±±³	da tela Item do Pedido         										  ³±±
±±³ lClose = .F. -> Quando estou efetuando a exclusao do Item do Pedido   ³±±
±±³	(Botao "E" )                     									  ³±±
±±³ nTelaPed = 1 => Tela de Pedido Padrao (V.1)                           ³±±
±±³	           2 => Tela de Pedido Especifica (V.2)                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Objetivo: ³ Remove o Item selecionado							      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista    ³ Data   ³Motivo da Alteracao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/
Function PVExcIte(aItePed,nItePed, aCabPed,aObj, lClose, nTelaPed)
Local nLin:=0
Local nPrdPeso  := 0

if len(aItePed) == 0 
	Return Nil
Endif

If nTelaPed == 1  //Tela 1
	//nItePed:=GridRow(oBrwItePed)
	nItePed:=GridRow(aObj[3,1])
Else  //Tela 2                
	if len(aProduto) == 0
		return nil
	endif
	nLin := GridRow(aObj[3,1])
	If aProduto[nLin,3] <= 0
		SetFocus(aObj[3,1])
		return nil
	Endif
Endif
//Alert(nItePed)

If nItePed > 0 .And. !Empty(aItePed[nItePed])

	//Efetua a operacao de Atualizacao do Total 	
	If !lClose	
		PVCalcPed(aCabPed,,aItePed,nItePed,.F.,aObj,.T.)
	Else
		SetText(aObj[1,4],aCabPed[12,1])	//Atualiza linha do Total
	Endif	

	If cSfaPeso == "T" .And. HB1->(FieldPos("B1_PBRUTO")) > 0
		HB1->(dbSetOrder(1))
		HB1->(dbSeek(aItePed[nItePed,1]))
		nPrdPeso := HB1->B1_PBRUTO
		If 	cUmPeso = "1"
			aCabPed[17,1] := aCabPed[17,1] - (aItePed[nItePed, 4] * nPrdPeso)
		Else
			If HB1->B1_TIPCONV = "M"
				nPrdPeso := Round(nPrdPeso * HB1->B1_CONV,2)
			Else
				nPrdPeso := Round(nPrdPeso / HB1->B1_CONV,2)
			EndIf
			aCabPed[17,1] := aCabPed[17,1] - (aItePed[nItePed, 4] * nPrdPeso)
		EndIf
		SetText(aObj[2,16], aCabPed[17,1])
	EndIf

	//->Remove o Item Selecionado dos Arrays dos Itens do Pedido
	aDel(aItePed,nItePed)
	aSize(aItePed,len(aItePed)-1)
	If nTelaPed == 1
		SetArray(aObj[3,1],aItePed)
	Else
		aProduto[nLin,3] :=	 0
		aProduto[nLin,4] := 0
		aProduto[nLin,5] := 0
		aProduto[nLin,6] := 0
		SetText(aObj[3,3], "")
		SetText(aObj[3,5], "")
		SetText(aObj[3,7], "")
		
		//SetArray(aObj[3,1],aProduto)
		GridSetRow(aObj[3,1],nLin+1)
		SetFocus(aObj[3,1])
		/*If nLin < 4
			GridSetRow(aObj[3,1],nLin+1)
		Else
			GridSetRow(aObj[3,1],nLin)	
		Endif*/
	Endif	
//	if Len(aItePed)==0
//		EnableControl(aObj[2,1])
//		EnableControl(aObj[2,2])
//		EnableControl(aObj[2,3])
//		EnableControl(aObj[2,4])
//	endif
	if lClose // Fecha a Tela do Item do pedido (V.1)
		CloseDialog()
    Endif
Endif

Return Nil
        

Function PVCanItePed(aCabPed, nItePed,nTotPedAnt,aObj)
if nItePed != 0
// Cancelamento da Alteracao e Restaura Saldo Total Anterior
	aCabPed[11,1]:=nTotPedAnt
	aCabPed[12,1]:=Round(aCabPed[11,1],2)	
	SetText(aObj[1,4],aCabPed[12,1])
Endif
// Fim
CloseDialog()
Return Nil
