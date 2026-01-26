#INCLUDE "FDPV004.ch"

Function PVQTde(oTxtQtde)
Keyboard(1,oTxtQtde)
Return Nil

Function PVPrc(oTxtPrc)
Keyboard(1,oTxtPrc)
Return Nil

Function PVDesc(oTxtDesc)
Keyboard(1,oTxtDesc)
Return Nil

Function PVObs(cObs)
Local oObs
Local oTxtObs, oBtnRet

DEFINE DIALOG oObs TITLE STR0001 //"Obs. do Pedido"
@ 15,15 GET oTxtObs VAR cObs MULTILINE VSCROLL SIZE 156,125 of oObs
#IFDEF __PALM__
  @ 142,5 BUTTON oBtnRet CAPTION BTN_BITMAP_OK SYMBOL SIZE 154,12 ACTION CloseDialog() of oObs
#ELSE 
  @ 142,5 BUTTON oBtnRet CAPTION STR0002 SIZE 154,12 ACTION CloseDialog() of oObs //"OK"
#ENDIF  

ACTIVATE DIALOG oObs

Return Nil


//Controla a troca da cond. de pagto
Function PVCond(aCabPed,aObj,aCmpPag,aIndPag,aColIte,aItePed,cCondInt)
Local cCondAnt := aCabPed[7,1]
Local cTabAnt  := aCabPed[8,1]
Local nTelaPed := 1

SFConsPadrao("HE4",aCabPed[7,1],aObj[2,1],aCmpPag,aIndPag,)
If cCondAnt <> aCabPed[7,1]
    //Condicao inteligente
    If cCondInt == "T"
	    aCabPed[8,1] := RGCondInt(aCabPed[3,1],aCabPed[4,1],aCabPed[7,1])
	    SetText(aObj[2,3],aCabPed[8,1])
	    If cTabAnt <> aCabPed[8,1]
			HCF->( dbSeek("MV_SFATPED") )
			If HCF->(Found()) 
				If AllTrim(HCF->CF_VALOR) == "2"
					nTelaPed:=2
				Else
					nTelaPed:=1
				Endif
		    Endif
		    //Atualizar itens/precos
	     	PVRecalcula(aCabPed,aObj,aColIte,aItePed,nTelaPed) 
	    Endif
	Else   
		If !PVVldTab(aCabPed)             
			aCabPed[7,1] := cCondAnt
			SetText(aObj[2,1],aCabPed[7,1])
		Endif	
	Endif
Endif

Return nil


//Controla a alteracao da Tabela de Precos (atualiza os itens)
Function PVTrocaTab(aCabPed,aObj,aCmpTab,aIndTab,aColIte,aItePed,cCondInt,nTelaPed)

Local ni := 1, nItePed := 0
Local cTabAnt := aCabPed[8,1]
Local cResp:="Nao"
Local nVlrItem := 0

If cCondInt == "T"//Cond. Inteligente
	MsgAlert(STR0003,STR0004) //"A tabela não poderá ser alterada!"###"Condição Inteligente"
	return nil
Endif         

SFConsPadrao("HTC",aCabPed[8,1],aObj[2,3],aCmpTab,aIndTab,)

If cTabAnt <> aCabPed[8,1]
	If !PVVldTab(aCabPed)
		aCabPed[8,1] := cTabAnt 
	    SetText(aObj[2,3],aCabPed[8,1])
	Endif
Endif    

If Len(aItePed) > 0 .And. cTabAnt <> aCabPed[8,1]
	cResp:=if(MsgYesOrNo(STR0005,STR0006),"Sim","Não") //"Esta operação irá recalcular os itens do pedido. Deseja continuar?"###"Atenção"
	If cResp == "Não"
    	aCabPed[8,1] := cTabAnt  
	    SetText(aObj[2,3],aCabPed[8,1])
	Else
	  MsgStatus(STR0007) //"Alterando pedido, aguarde..."
	  //aItePedBak := aClone(aItePed)                               
      //Limpa o array dos itens 
      //aSize(aItePed, 0)
      
      //Zera totais do cabec. do pedido 
      aCabPed[11,1] := 0
      aCabPed[12,1] := 0        
      nItePed:=Len(aItePed)

      For ni := 1 to Len(aItePed) 
	      
          dbSelectArea("HPR")
       	  dbSetOrder(1)
		  dbSeek(aItePed[ni,1]+aCabPed[8,1])	//Procura preço de venda usando a nova tabela
			
		  If !Eof()                        
		     aItePed[ni,6] := HPR->PR_UNI
		  Else           
			 dbSelectArea("HB1")
			 dbSetOrder(1)
			 dbSeek(aItePed[ni,1])     
			 aItePed[ni,6] := HB1->B1_PRV1
		  Endif                                 
		  // Atualiza tabela de preço
		  //aItePed[ni,5] := aCabPed[8,1]
     	  // Atualiza Valor do Item (SubTotal)
	      aItePed[ni,9] := aItePed[ni,4] * aItePed[ni,6]
	      //Limpa o descto
	      //nDescAux := aItePed[ni,7]
	      aItePed[ni,7] := 0
	      // Verifica/aplica a regra de desconto para o item
	      RGAplDescIte(aCabPed[3,1], aCabPed[4,1], aCabPed[7,1], aCabPed[8,1], "", aItePed, ni, aColIte)
	                
	      /*If (aItePed[ni,7] == 0) .And. (nDescAux > 0)
	      	aItePed[ni,7] := nDescAux
	      Endif*/
	      
	      // Recalcula total do pedido
	      if aItePed[ni,7] > 0
			  nVlrItem := PVCalcDescto(aColIte,aItePed,ni,.F.)
			  aCabPed[11,1] := aCabPed[11,1] + nVlrItem
		  else
	    	  aCabPed[11,1] := aCabPed[11,1] + aItePed[ni,9]
		  endif
	      aCabPed[12,1] := Round(aCabPed[11,1],2)	

	  Next                             
	  
	  ClearStatus()
	  If nTelaPed == 1
		  SetArray(aObj[3,1],aItePed)	//Browse de itens
	  Endif
	  SetText(aObj[1,4],aCabPed[12,1]) //Total
	Endif
Endif

Return nil

//Efetua a validacao da Tab. de precos (cabecalho) de acordo com a condicao fixada a ela
Function PVVldTab(aCabPed)
Local lRet  := .t.
Local cCond := aCabPed[7,1]
Local cTab  := aCabPed[8,1]
                           
If !Empty(cTab) .And. !Empty(cCond)
	dbSelectArea("HTC")
	dbSetOrder(1)
	dbSeek(cTab) 
	//Alert("Tab. " + cTab + " Cond. " + HTC->TC_COND)
	If !Empty(HTC->TC_COND) .And. (HTC->TC_COND <> cCond)
		MsgStop(STR0008 + HTC->TC_COND,STR0009) //"Condição de Pagto. inválida para esta tabela de preços. A condição válida é: "###"Aviso"
	 	//aCabPed[7,1] := HTC->TC_COND	//atualiza condicao pagto.
		lRet := .f.
	Endif
Endif
Return lRet