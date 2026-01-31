#INCLUDE "SFPV006.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Detalhe do Item     ³Autor - Paulo Lima   ³ Data ³03/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Modulo de Pedidos        					 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SFA CRM 6.0.1 (Tela de Pedido V. 1)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aItePed, aObj 											  ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Objetivo: ³ Exibir em outro Dialog o Detalhe do Item 			      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista    ³ Data   ³Motivo da Alteracao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Cleber M.  ³22/03/04| Exibicao do SubTotal com Desconto               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/
Function PVDetIte(aItePed,aObj)
Local oDetIte, oBtnRet
Local oTxtDIProd, oTxtDIQtde, oTxtDIPrc, oTxtDIDesc, oTxtDITotIte
Local nItePed:=0, nSubTot:=0

if Len(aItePed) == 0
	Return Nil
Endif
nItePed := GridRow(aObj[3,1])

If cCalcProtheus == "T"	//Desconto Protheus
	nSubTot := aItePed[nItePed,4] * Round((aItePed[nItePed,6] - (aItePed[nItePed,6] * (aItePed[nItePed,7] / 100))),2)
Else
	nSubTot := aItePed[nItePed,9] - Round((aItePed[nItePed,9] * (aItePed[nItePed,7] / 100)),2)
Endif

DEFINE DIALOG oDetIte TITLE STR0001 //"Detalhe do Item"
@ 22,4 TO 135,157 CAPTION STR0002 OF oDetIte //"Descricao do Produto:"
@ 32,07 GET oTxtDIProd VAR aItePed[nItePed,2] MULTILINE READONLY SIZE 142,25 of oDetIte
@ 64,07 SAY STR0003 of oDetIte //"Qtde: "
@ 64,55 GET oTxtDIQtde VAR aItePed[nItePed,4] READONLY SIZE 50,12 of oDetIte
@ 78,07 SAY STR0004 of oDetIte //"Preço: "
@ 78,55 GET oTxtDIPrc VAR aItePed[nItePed,6] READONLY SIZE 50,12 of oDetIte
@ 92,07 SAY STR0005 of oDetIte //"Desconto: "
@ 92,55 GET oTxtDIDesc VAR aItePed[nItePed,7] READONLY SIZE 50,12 of oDetIte
@ 92,106 SAY "%" of oDetIte
@ 106,07 SAY STR0006 of oDetIte //"Total Item: "
@ 106,55 GET oTxtDITotIte VAR nSubTot READONLY SIZE 50,12 of oDetIte

@ 142,4 BUTTON oBtnRet CAPTION STR0007 SIZE 154,12 ACTION CloseDialog() of oDetIte //"OK"

ACTIVATE DIALOG oDetIte

Return Nil


//Recalcula os itens do pedido na troca da cond. de pagto (inteligente)
Function PVRecalcula(aCabPed,aObj,aColIte,aItePed,nTelaPed) 
Local ni := 1, nItePed := 0
Local nVlrItem := 0

If Len(aItePed) > 0 

	  MsgStatus(STR0008) //"Alterando pedido, aguarde..."
      
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
	      aItePed[ni,7] := 0
	      // Verifica/aplica a regra de desconto para o item
	      RGAplDescIte(aCabPed[3,1], aCabPed[4,1], aCabPed[7,1], aCabPed[8,1], "", aItePed, ni, aColIte, 0)
	                
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

Return nil         


/*   
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Condicao Inteligente ³Autor - Cleber M.    ³ Data ³21/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Preenche a tabela de preco de acordo com a cond. de pagto  ³±±
±±³			 ³ selecionada (usando a tab. de Regras de Neg.)			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SFA CRM 6.0.1                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cCliente   -> Cod. do Cliente								  ´±±
±±³			 ³cLoja      -> Loja do Cliente	 	     		   			  ´±±
±±³			 ³cCond      -> Cond. de Pagto. 				   			  ´±±
±±³			 ³(Retorna a tabela de preco encontrada)					  ´±±
±±³			 ³															  ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista    ³ Data   ³Motivo da Alteracao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function RGCondInt(cCliente,cLoja,cCond)
Local lContinua := .T.
Local cTab := ""

dbSelectArea("HCS")
dbSetOrder(1)
dbGoTop()

While !Eof() .And. lContinua

	If (HCS->ACS_CODCLI = cCliente .Or. Empty(HCS->ACS_CODCLI) ).And.;
			(HCS->ACS_LOJA = cLoja .Or. Empty(HCS->ACS_LOJA) )
			
			HCT->( dbSetOrder(3) )	//Cod. da Regra + Cond. Pagto.
			HCT->( dbSeek(HCS->ACS_CODREG+cCond) )
			If HCT->(Found())
				cTab := HCT->ACT_CODTAB
				lContinua := .F.
				break
			Endif
    Endif
    
    dbSelectArea("HCS")
    dbSkip()
Enddo

Return cTab


Function UpdTpFrete(aCabPed, aTpFrete, nOpcFre)
	aCabPed[16,1] := Substr(aTpFrete[nOpcFre],1,1)
Return Nil