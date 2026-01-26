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
Function RCGrvIte(aColIte,aItePed, nItePed, aCabPed,aObj,cManTes,cProDupl,nOpIte,nTelaPed)
Local nSubTotI :=0, nLin := 0

If !RCVrfIte(aColIte,aItePed,aCabPed,cProDupl,nOpIte)
    Return Nil
Endif

aColIte[9,1] := aColIte[4,1] * aColIte[6,1]

if nItePed=0 //Novo item
//	AADD(aItePed,{AllTrim(cProd),AllTrim(cDescProd),cGrup,nQtde,aTab[nTab],nPrc, nDesc, cTes, nSubTotI,"",0})	
//	AADD(aItePed,{AllTrim(aColIte[1,1]),Alltrim(aColIte[2,1]),aColIte[3,1],aColIte[4,1],aColIte[5,1],aColIte[6,1], aColIte[7,1], aColIte[8,1], aColIte[9,1],aColIte[10,1],aColIte[11,1]})
	AADD(aItePed,Array(Len(aColIte)))
	For nI := 1 to Len(aColIte)
	  aItePed[Len(aItePed),nI] := aColIte[nI,1]
	Next
	nItePed:=Len(aItePed)
Else	//Alteracao do item                              
	If nTelaPed == 2 	//Tela V.2 => Subtrair valor do item (atual) do Total
               // RCCalcPed(aCabPed,aColIte,aItePed,nItePed,.F.,,.F.) 
	Endif
	For nI:=1 to Len(aColIte)
		aItePed[nItePed,nI]:= aColIte[nI,1] 
	Next 
Endif	

RGAplDescIte(aCabPed[3,1], aCabPed[4,1], aCabPed[7,1], aCabPed[8,1], "", aItePed, nItePed,aColIte)
//RGAplDescIte(cCodCli, cLojaCli, Substr(aCond[nCond],1,at("-",aCond[nCond])-1), aTab[nTab], "", aItePed, nItePed,@nDesc)

//Adiciona valor do item ao Total do Pedido
//RCCalcPed(aCabPed,aColIte,aItePed,nItePed,.T.,aObj,.T.)

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
       // RCLimpaItem(aColIte,aObj,cManTes)
	SetArray(aObj[3,1],aProduto)	
	If nLin < 4
		GridSetRow(aObj[3,1],nLin+1)
	Else
		GridSetRow(aObj[3,1],nLin)	
	Endif
Endif

Return Nil


Function RCVrfIte(aColIte,aItePed,aCabPed,cProDupl,nOpIte)
Local nDescMax := 0

HB1->(dbSetOrder(1))
HB1->(dbSeek(RetFilial("HB1")+aColIte[1,1]))
If HB1->(FieldPos("B1_DESCMAX")) <> 0
	nDescMax := HB1->B1_DESCMAX
Else
	nDescMax := 100
Endif

//Valida se o produto ja foi incluido neste pedido
If cProDupl == "F" .And. nOpIte==1 //novo item
	If ScanArray(aItePed, aColIte[1,1],,,1) > 0
		MsgStop("Este produto ja foi incluido!","Verifica Item")
		Return .F.
	EndIf	
EndIf

If Empty(aColIte[1,1]) 
  MsgStop("Escolha um Produto!","Verifica Item")
  Return .f.
Elseif aColIte[4,1] == 0
  MsgStop("Escreva a Qtde!","Verifica Item")
  Return .f.
Elseif aColIte[6,1] == 0
  MsgStop("Escolha/Escreva o Preço!","Verifica Item")  
  Return .f.
Elseif aColIte[7,1] > nDescMax
  MsgStop("Desconto acima do máximo permitido: " + str(nDescMax,3,2) + " %","Verifica Item")
  Return .f.
Elseif Empty(aColIte[8,1])
  MsgStop("Tes não Selecionado!","Verifica Item")  
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
Function RCExcIte(aItePed,nItePed, aCabPed,aObj, lClose, nTelaPed)
Local nLin:=0

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
		return nil
	Endif
Endif
//Alert(nItePed)

If nItePed > 0 .And. !Empty(aItePed[nItePed])

	//Efetua a operacao de Atualizacao do Total 	
	If !lClose	
            //    RCCalcPed(aCabPed,,aItePed,nItePed,.F.,aObj,.T.)
	Else
		SetText(aObj[1,4],aCabPed[12,1])	//Atualiza linha do Total
	Endif	

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
		
		SetArray(aObj[3,1],aProduto)	
		If nLin < 4
			GridSetRow(aObj[3,1],nLin+1)
		Else
			GridSetRow(aObj[3,1],nLin)	
		Endif
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
        

Function RCCanItePed(aCabPed, nItePed,nTotPedAnt,aObj)
if nItePed != 0
// Cancelamento da Alteracao e Restaura Saldo Total Anterior
	aCabPed[11,1]:=nTotPedAnt
	aCabPed[12,1]:=Round(aCabPed[11,1],2)	
	SetText(aObj[1,4],aCabPed[12,1])
Endif
// Fim
CloseDialog()
Return Nil
