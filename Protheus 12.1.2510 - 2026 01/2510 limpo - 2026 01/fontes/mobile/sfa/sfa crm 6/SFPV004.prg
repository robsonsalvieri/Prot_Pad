#INCLUDE "SFPV004.ch"
Function PVQTde(oTxtQtde,aColIte,aCabPed,oPreco)
Local cProd    := aColIte[1,1]
Local cTabela  := aCabPed[8,1]
Local nQtde    := aColIte[4,1]
Local nPreco   := 0, nTam:=0, ni:=0
Local nFaixAnt := 0 
Local aFaixPrec:= {} 			//Faixa de Preco 
Keyboard(1,oTxtQtde)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se a base criada ja possui tratamento de preco por faixa     ³    
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("HPR")
dbSetOrder(1)
	   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se utiliza tabela precos por faixa de quantidade      ³	
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If HPR->(FieldPos("PR_QTDLOT")) <> 0    
   If DbSeek( cProd + cTabela )    
	   While HPR->(!EOF()) .And. HPR->PR_PROD=cProd .And. HPR->PR_TAB=cTabela    
       	     AADD( aFaixPrec,{ HPR->PR_QTDLOT,HPR->PR_UNI } )
	         HPR->(dbSkip())       
	   Enddo                                                           
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ordena o Array para ter certeza de pegar a faixa certa³	
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   nTam:=Len(aFaixPrec)
	   SortArray(aFaixPrec,1,nTam,.t.,1 )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Procura no array aFaixaPrec a faixa de preco equivalente a quantidade digitada ³	
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  	   for  ni:=1 to nTam        
  	        if  nQtde <= aFaixPrec[ni,1] 
                nPreco := aFaixPrec[ni,2]
                exit
            endif
	   next 
	  
   endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atiualiza o objeto preço com o preco designado na faixa					      ³	
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SetText(oPreco,nPreco)	          
	
endif
Return Nil

Function PVPrc(oTxtPrc)
Keyboard(1,oTxtPrc)
SetFocus(oTxtPrc)
Return Nil

Function PVDesc(oTxtDesc)
Keyboard(1,oTxtDesc)
SetFocus(oTxtDesc)
Return Nil

Function PVObs(cObs)
Local oObs
Local oTxtObs, oBtnRet

DEFINE DIALOG oObs TITLE STR0001 //"Obs. do Pedido"
@ 15,15 GET oTxtObs VAR cObs MULTILINE VSCROLL SIZE 156,125 of oObs
@ 142,5 BUTTON oBtnRet CAPTION STR0002 SIZE 154,12 ACTION CloseDialog() of oObs //"OK"

ACTIVATE DIALOG oObs

Return Nil


//Controla a troca da cond. de pagto
Function PVCond(aCabPed,aObj,aCmpPag,aIndPag,aColIte,aItePed,cCondInt,oFldCN)
Local cCondAnt := aCabPed[7,1]
Local cTabAnt  := aCabPed[8,1]
Local nTelaPed := 1      
Local cCondNeg := GetMV("MV_NUMPARC","4") 
Local cTipoCnd := ""

HA1->( dbSetOrder(1) )
HA1->( dbSeek(aCabPed[3,1]+aCabPed[4,1]) )
If HA1->(FieldPos("A1_CNDFIX")) <> 0
	If HA1->A1_CNDFIX == 0 .And. HA1->A1_STATUS <> "N"
		MsgAlert(STR0003,STR0004) //"A condição de pagto do cliente não poderá ser alterada"###"Condição Fixa"
		Return nil	
	Endif
Endif

SFConsPadrao("HE4",aCabPed[7,1],aObj[2,1],aCmpPag,aIndPag,)
HE4->( dbseek(aCabPed[7,1])) 
cTipoCnd := If(HE4->(FieldPos("E4_TIPO")) > 0, HE4->E4_TIPO, "")

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
Function PVTrocaTab(aCabPed,aObj,aCmpTab,aIndTab,aColIte,aItePed,cCondInt,nTelaPed,cA1GrpVen)

Local ni := 1, nItePed := 0
Local cTabAnt := aCabPed[8,1]
Local cResp:="Nao", cTabFix:=""
Local nVlrItem := 0

If cCondInt == "T"//Cond. Inteligente
	MsgAlert(STR0005,STR0006) //"A tabela não poderá ser alterada!"###"Condição Inteligente"
	return nil
Endif         

HCF->(dbSetOrder(1))
If HCF->(dbSeek("MV_SFATAB"))
	cTabFix := AllTrim(HCF->CF_VALOR)
Else 
	cTabFix := "F"
EndIf	

If cTabFix == "T" .And. !Empty(aCabPed[8,1])
	MsgAlert("A tabela padrão do cliente não poderá ser alterada!","Tabela Fixa")
	return nil
Endif

// Bops 82.671 07/06/05
dbSelectArea("HCO")      
HCO->(dbGotop())
While HCO->(!EOF())  
      IF Alltrim(HCO->ACO_GRPVEN)==Alltrim(cA1GrpVen) .And. !Empty(HCO->ACO_CODTAB)        
         MsgAlert("A tabela padrão do cliente não poderá ser alterada!","Regra Negocio")
         aCabPed[8,1] := HCO->ACO_CODTAB  
         SetText(aObj[2,3],aCabPed[8,1])
         Return 
      ENDIF

	  HCO->( dbSkip() )	
enddo
SFConsPadrao("HTC",aCabPed[8,1],aObj[2,3],aCmpTab,aIndTab,)

If cTabAnt <> aCabPed[8,1]
	If !PVVldTab(aCabPed)
		aCabPed[8,1] := cTabAnt 
	    SetText(aObj[2,3],aCabPed[8,1])
	Endif
Endif    

If Len(aItePed) > 0 .And. cTabAnt <> aCabPed[8,1]
	cResp:=if(MsgYesOrNo(STR0007,STR0008),STR0009,STR0010) //"Esta operação irá recalcular os itens do pedido. Deseja continuar?"###"Atenção"###"Sim"###"Não"
	If cResp == STR0010 //"Não"
    	aCabPed[8,1] := cTabAnt  
	    SetText(aObj[2,3],aCabPed[8,1])
	Else
	  MsgStatus(STR0011) //"Alterando pedido, aguarde..."
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
		  aItePed[ni,5] := aCabPed[8,1]
     	  // Atualiza Valor do Item (SubTotal)
	      aItePed[ni,9] := aItePed[ni,4] * aItePed[ni,6]
	      //Limpa o descto
	      //nDescAux := aItePed[ni,7]
	      aItePed[ni,7] := 0
	      // Verifica/aplica a regra de desconto para o item
	      RGAplDescIte(aCabPed[3,1], aCabPed[4,1], aCabPed[7,1], aCabPed[8,1], "", aItePed, ni, aColIte, 0)
	                
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
		MsgStop(STR0012 + HTC->TC_COND,STR0013) //"Condição de Pagto. inválida para esta tabela de preços. A condição válida é: "###"Aviso"
	 	//aCabPed[7,1] := HTC->TC_COND	//atualiza condicao pagto.
		lRet := .f.
	Endif
Endif
Return lRet
