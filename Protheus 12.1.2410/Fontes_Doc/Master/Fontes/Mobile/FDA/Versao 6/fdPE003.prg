#INCLUDE "FDPE003.ch"
Function NFQTde(oTxtQtde)
Keyboard(1,oTxtQtde)
Return Nil

Function NFPrc(oTxtPrc)
Keyboard(1,oTxtPrc)
Return Nil

Function NFDesc(oTxtDesc)
Keyboard(1,oTxtDesc)
Return Nil

Function NFObs(cObs)
Local oObs
Local oTxtObs, oBtnRet

DEFINE DIALOG oObs TITLE STR0001 //"Obs. do Pedido"
@ 15,15 GET oTxtObs VAR cObs MULTILINE VSCROLL SIZE 156,125 of oObs
@ 142,5 BUTTON oBtnRet CAPTION BTN_BITMAP_OK SYMBOL SIZE 154,12 ACTION CloseDialog() of oObs

ACTIVATE DIALOG oObs

Return Nil                

//Controla a troca da cond. de pagto
Function NFCondNF(aCabPed,aObj,aCmpPag,aIndPag,aColIte,aItePed,cCondInt)
Local cCondAnt := aCabPed[6,1]
Local cTabAnt  := aCabPed[7,1]

SFConsPadrao("HE4",aCabPed[6,1],aObj[2,1],aCmpPag,aIndPag)
If cCondAnt <> aCabPed[6,1]
    //Condicao inteligente
    If cCondInt == "T"
	    aCabPed[7,1] := RGCondInt(aCabPed[3,1],aCabPed[4,1],aCabPed[6,1])
	    SetText(aObj[2,3],aCabPed[7,1])
	    If cTabAnt <> aCabPed[7,1]
		    //Atualizar itens/precos
	     	PVRecalcula(aCabPed,aObj,aColIte,aItePed) 
	    Endif
	Else   
		If !NFVldTab(aCabPed)             
			aCabPed[6,1] := cCondAnt
			SetText(aObj[2,1],aCabPed[6,1])
		Endif	
	Endif
Endif

Return nil


//Controla a alteracao da Tabela de Precos (atualiza os itens)

Function NFTrocaTab(aCabNot,aObj,aCmpTab,aIndTab,aColIte,aIteNot,cCondInt)

Local ni := 1, nItePed := 0
Local cTabAnt := aCabNot[7,1]
Local cResp:=STR0002 //"Nao"
Local nVlrItem := 0

If cCondInt == "T"//Cond. Inteligente
	MsgAlert(STR0003,STR0004) //"A tabela não poderá ser alterada!"###"Condição Inteligente"
	return nil
Endif         

SFConsPadrao("HTC",aCabNot[7,1],aObj[2,3],aCmpTab,aIndTab)

If cTabAnt <> aCabNot[7,1]
	If !NFVldTab(aCabNot)
		aCabNot[7,1] := cTabAnt 
	    SetText(aObj[2,3],aCabNot[7,1])
	Endif
Endif    

If Len(aIteNot) > 0 .And. cTabAnt <> aCabNot[7,1]
	cResp:=if(MsgYesOrNo(STR0005,STR0006),STR0007,STR0008) //"Esta operação irá recalcular os itens do pedido. Deseja continuar?"###"Atenção"###"Sim"###"Não"
	If cResp == STR0008 //"Não"
    	aCabNot[7,1] := cTabAnt  
	    SetText(aObj[2,3],aCabNot[7,1])
	Else
	  MsgStatus(STR0009) //"Alterando pedido, aguarde..."
	  //aIteNotBak := aClone(aIteNot)                               
      //Limpa o array dos itens 
      //aSize(aIteNot, 0)
      
      //Zera totais do cabec. do pedido 
      aCabNot[15,1] := 0
      aCabNot[35,1] := 0        
      nItePed:=Len(aIteNot)

      For ni := 1 to Len(aIteNot) 
	      
          dbSelectArea("HPR")
       	  dbSetOrder(1)
		  dbSeek(aIteNot[ni,3]+aCabNot[7,1])	//Procura preço de venda usando a nova tabela
			
		  If !Eof()                        
		     aIteNot[ni,23] := HPR->PR_UNI
		  Else           
			 dbSelectArea("HB1")
			 dbSetOrder(1)
			 dbSeek(aIteNot[ni,3])     
			 aIteNot[ni,23] := HB1->B1_PRV1
		  Endif                                 
		  // Atualiza tabela de preço
		  //aIteNot[ni,5] := aCabNot[8,1]
     	  // Atualiza Valor do Item (SubTotal)
	      aIteNot[ni,8] := aIteNot[ni,6] * aIteNot[ni,23]
	      //Limpa o descto
	      //nDescAux := aIteNot[ni,7]
	      aIteNot[ni,13] := 0
	      // Verifica/aplica a regra de desconto para o item
	      RGAplDescIte(aCabNot[3,1], aCabNot[4,1], aCabNot[7,1], aCabNot[7,1], "", aIteNot, ni, aColIte)
	      
	      // Recalcula total da Nota
	      
	      if aIteNot[ni,13] > 0
			  nVlrItem := PVCalcDescto(aColIte,aIteNot,ni,.F.)
			  aCabNot[15,1] := aCabNot[15,1] + nVlrItem
		  else
	    	  aCabNot[15,1] := aCabNot[15,1] + aIteNot[ni,8]
		  endif
	      aCabNot[35,1] := Round(aCabNot[15,1],2)	

	  Next                             
	  
	  ClearStatus()
	  SetArray(aObj[3,1],aIteNot)		//Browse de itens
	  SetText(aObj[1,4],aCabNot[35,1]) //Total
	Endif
Endif

Return nil

  
//Efetua a validacao da Tab. de precos (cabecalho) de acordo com a condicao fixada a ela
Function NFVldTab(aCabNot)
Local lRet  := .t.
Local cCond := aCabNot[6,1]
Local cTab  := aCabNot[7,1]
                           
If !Empty(cTab) .And. !Empty(cCond)
	dbSelectArea("HTC")
	dbSetOrder(1)
	dbSeek(cTab) 
	//Alert("Tab. " + cTab + " Cond. " + HTC->TC_COND)
	If !Empty(HTC->TC_COND) .And. (HTC->TC_COND <> cCond)
		MsgStop(STR0010 + HTC->TC_COND,STR0011) //"Condição de Pagto. inválida para esta tabela de preços. A condição válida é: "###"Aviso"
	 	//aCabNot[7,1] := HTC->TC_COND	//atualiza condicao pagto.
		lRet := .f.
	Endif
Endif
Return lRet

//Controla a troca da cond. de pagto
Function NFCond(aCabNot,aObj,aCmpPag,aIndPag,aColIteNf,aIteNot,cCondInt)
Local cCondAnt := aCabNot[6,1]
Local cTabAnt  := aCabNot[7,1]
Local nTelaPed := 1, nTelaNot:=1

SFConsPadrao("HE4",aCabNot[6,1],aObj[2,1],aCmpPag,aIndPag,)
If cCondAnt <> aCabNot[6,1]
    //Condicao inteligente
    If cCondInt == "T"
	    aCabNot[7,1] := RGCondInt(aCabNot[3,1],aCabNot[4,1],aCabNot[6,1])
	    SetText(aObj[2,3],aCabNot[7,1])
	    If cTabAnt <> aCabNot[7,1]
			HCF->( dbSeek("MV_SFATPED") )
			If HCF->(Found()) 
				If AllTrim(HCF->CF_VALOR) == "2"
					nTelaNot:=2
				Else
					nTelaNot:=1
				Endif
		    Endif
		    //Atualizar itens/precos
	     	NFRecalcula(aCabNot,aObj,aColItenf,aIteNot,nTelaNot) 
	    Endif
	Else   
		If !PVVldTab(aCabNot)             
			aCabNot[6,1] := cCondAnt
			SetText(aObj[2,1],aCabNot[6,1])
		Endif	
	Endif
Endif

Return nil
