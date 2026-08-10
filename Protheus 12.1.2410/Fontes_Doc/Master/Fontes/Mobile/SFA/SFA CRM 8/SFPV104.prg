/*   
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Regra de Bonificacao ³Autor - Paulo Lima   ³ Data ³10/07/02 ³±±
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
±±³			 ³aItePed    -> Array dos Itens do Pedido					  ´±±
±±³			 ³       [1] -> Cod. do Produto do Item						  ´±±
±±³			 ³       [2] -> Descricao do Produto						  ´±±
±±³			 ³       [3] -> Grupo do Produto							  ´±±
±±³			 ³       [4] -> Qtde. de Produtos do Item  					  ´±±
±±³			 ³       [5] -> Cod. da Tabela de Preco 					  ´±±
±±³			 ³       [6] -> Preco do Produto 							  ´±±
±±³			 ³       [7] -> Desconto									  ´±±
±±³			 ³       [8] -> Tes											  ´±±
±±³			 ³       [9] -> Valor Total por Item						  ´±±
±±³			 ³       [10] -> Codigo da regra de bonficacao				  ´±±
±±³			 ³       [11] -> Bonificacao 								  ´±±
±±³			 ³       [12] -> Quantidade Liberada						  ´±±
±±³			 ³       [13] -> Quantidade Entregue						  ´±±
±±³			 ³       [14] -> Status										  ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista    ³ Data   ³Motivo da Alteracao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Cleber     |25/04/03| Alteracao na gravacao do preco de venda		  ³±±
±±³ Cleber     |27/02/04| Tratamento no conteudo do parametro MV_BONUSTS  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

#include "eADVPL.ch"

Function RGAdcBon(cCliente, cLoja, cCond, cTab, cFormPg, aItePed)
Local cTesBon:=""
Local lMulti := .T., lBonif := .F.
Local I:=0 , nPrc:=0.00, nQtdeBonif :=0.00 , nQtde:=0.00, nQtdePed :=0.00
Local aBonif:= {}, aAuxPed := {}

// ---------------------------------------------------------------------------------
//   						TES DO ITEM DE BONIFICACAO
// ---------------------------------------------------------------------------------
dbSelectArea("HCF")
dbSetOrder(1)
dbSeek(RetFilial("HCF") + "MV_BONUSTS")   
if !(HCF->(Found()))
// ------------------------------------------------------------------------------------
//	Caso nao exista o MV_BONUSTS, ele nao incluirah os itens de Bonificacao
// ------------------------------------------------------------------------------------
	Return Nil           
else
	cTesBon:=AllTrim(HCF->HCF_VALOR)
	If Len(cTesBon) == 5
	   cTesBon := Substr(cTesBon,2,3)
	Endif
	
	dbSelectArea("HF4")
	dbSetOrder(1)
	dbSeek(RetFilial("HF4") + cTesBon)
	if !(HF4->(Found()))
	// ------------------------------------------------------------------------------------
	//	Caso nao encontre o Tes de Bonus cadastrado, ele nao incluirah 
	//  os itens de Bonificacao
	// ------------------------------------------------------------------------------------
		Return Nil
	Endif

Endif          

dbSelectArea("HCQ")
dbSetOrder(1)
dbSeek(RetFilial("HCQ"))
//dbGoTop()

While !Eof()

	If ( (HCQ->HCQ_CODCLI = cCliente .Or. Empty(HCQ->HCQ_CODCLI) ).And.;
			(HCQ->HCQ_LOJA = cLoja .Or. Empty(HCQ->HCQ_LOJA) ) .And.;
			(HCQ->HCQ_CODTAB = cTab .Or. Empty(HCQ->HCQ_CODTAB) ) .And.;
			(HCQ->HCQ_CONDPG = cCond .Or. Empty(HCQ->HCQ_CONDPG) ) .And.; 
			(HCQ->HCQ_FORMPG = cFormPg .Or. Empty(HCQ->HCQ_FORMPG) ) )
       
	   dbSelectArea("HCR")
	   dbSetOrder(1)          
	   dbSeek(RetFilial("HCR") + HCQ->HCQ_CODREG) 
	   
// ------------------------------------------------------------------
//      Se a bonificacao for para Todos os Itens
// ------------------------------------------------------------------			
       If HCQ->HCQ_TPRGBN == "1"
			nQtde:=0
			nQtdePed:=0                                  
			nQtdeBonif :=0
			aSize(aAuxPed,0)
			lMulti:= .T.
			While !HCR->(Eof()) .And. HCR->HCR_CODREG = HCQ->HCQ_CODREG .And. lMulti
				//Alert("Entrou no Bonif. Item < Tipo 1> ")
				For I:=1 to Len(aItePed)
					If (HCR->HCR_CODPRO = aItePed[I,1] .Or.;
						HCR->HCR_GRUPO = aItePed[I,3]) .And.;
						HCR->HCR_LOTE <= aItePed[I,4] .And.;
						cTesBon <> aItePed[I,8] .And. Empty(aItePed[I,10])
						
						AADD(aAuxPed ,I)
						break
					Endif				  					
				Next
	
				If I > Len(aItePed)									
					// ----------------------------------------------------------------
					// Varremos todo o Pedido e nao encontramos esse item da Regra 
					// ----------------------------------------------------------------
					lMulti:=.F.
				else
					// ----------------------------------------------------------------
					// Encontrou a Condicao/Item da Regra, continuaremos a verificar 
					// outros itens da regra.
					// ----------------------------------------------------------------
					lMulti:=.T.
					          
					//Adiciona a qtde deste item a ser bonificada 
					nQtdeBonif += Int(aItePed[I,4] / HCR->HCR_LOTE) * HCQ->HCQ_QUANT
				EndIf				

				HCR->(dbSkip())
			Enddo

			if lMulti
				//nQtdeBonif  := Int(nQtdePed / nQtde) * HCQ->HCQ_QUANT
				AADD(aBonif,{HCQ->HCQ_CODPRO,nQtdeBonif, cTab, cTesBon, HCR->HCR_CODREG})	
				For I:=1 to Len(aAuxPed)
				 	aItePed[aAuxPed[I],10] := HCQ->HCQ_CODREG  
				Next
    		Endif

// -------------------------------------------------------------------------------------
//      Se a bonificacao for para Cada Item
// -------------------------------------------------------------------------------------			
	   Else
			lBonif:=.F.
			nQtdeBonif :=0

			While !HCR->(Eof()) .And. HCR->HCR_CODREG == HCQ->HCQ_CODREG //.And. !lBonif
				//Alert("Entrou no Bonif. Item < Tipo 2> ")				
				For I:=1 to Len(aItePed)
					// ----------------------------------------------------------
					//  Se encontrar a Condicao de Regra
					// ----------------------------------------------------------
					If ((HCR->HCR_CODPRO = aItePed[I,1] .Or.;
						HCR->HCR_GRUPO = aItePed[I,3]) .And.;
						HCR->HCR_LOTE <= aItePed[I,4] .And.;
						cTesBon <> aItePed[I,8] .And. Empty(aItePed[I,10]))

						nQtdeBonif += Int(aItePed[I,4] / HCR->HCR_LOTE) * HCQ->HCQ_QUANT
						//Alert("Bonif. de: " + str(nQtdeBonif))
						//lBonif:= .T.
						aItePed[I,10]:= HCQ->HCQ_CODREG
						break
					Endif				  					
				Next								
				HCR->(dbSkip())
			Enddo		
			If nQtdeBonif > 0
				AADD(aBonif,{HCQ->HCQ_CODPRO,nQtdeBonif, cTab, cTesBon,HCR->HCR_CODREG}) 
			Endif
	    EndIf      	
	EndIf
	dbSelectArea("HCQ")
	dbSkip()
Enddo  

if Len(aBonif) > 0 
	// Copia para o Array do Pedido    
//	Alert("Copia do aBonif para aItePed")  
	RGCpBonPed(aItePed,aBonif,cTab)	
EndIf

Return Nil


Function RGCpBonPed(aItePed, aBonif, cTab)
Local I:=1, nPrc:=0.00, nSubTotI := 0.00
	For I:=1 to Len(aBonif)
		dbSelectArea("HB1")
		dbSetOrder(1) 
		dbSeek(RetFilial("HB1") + Alltrim(aBonif[I,1]))                                                                     
		// Se Tab. de Preco estiver Vazia, coleta o Preco cadastrado no HB1
		If !Empty(cTab) //Tab. preco
			dbSelectArea("HPR")
			dbSetOrder(1)
			dbSeek(RetFilial("HPR") + aBonif[I,1] + cTab)
			
			If HPR->(Found())
				nPrc:=HPR->HPR_UNI
			Else
				nPrc:=HB1->HB1_PRV1			
			Endif
		Else
			nPrc:=HB1->HB1_PRV1			
        Endif
		nSubTotI:=nPrc * aBonif[I,2]

    	AADD(aItePed,{aBonif[i,1], AllTrim(HB1->HB1_DESC), HB1->HB1_GRUPO, aBonif[i,2], aBonif[i,3], nPrc, 0, aBonif[i,4], nSubTotI, aBonif[I,5],1,0,0,"N","",0,0,0})
	Next
Return Nil
