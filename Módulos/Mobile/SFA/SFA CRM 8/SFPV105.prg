#INCLUDE "sfpv105.ch"
/*   
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Regra de Negocio     ³Autor - Paulo Lima   ³ Data ³10/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Verifica se o Pedido esta obedecendo a Regra de Negocio    ³±±
±±³			 ³ 												 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SFA CRM 6.0.1                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cCliente   -> Cod. do Cliente								  ´±±
±±³			 ³cLoja      -> Loja do Cliente	 	     		   			  ´±±
±±³			 ³cCond      -> Cond. de Pagto. 				   			  ´±±
±±³			 ³cTab       -> Tabela de Preco					   			  ´±±
±±³			 ³cFormPg    -> Forma de Pagto (nao esta sendo usado)		  ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista    ³ Data   ³Motivo da Alteracao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function RGVrfNeg(cCliente, cLoja, cCond, cTab, cFormPg)
Local lRegra := .T. 
Local lExce := .F. 
Local cTable := "HCS"
Local lContinua := .T.
Local lGrpVen	:= .F.
Local cMsg := ""
If !(Select("HCS")>0)
	//MsgStop(STR0001 + cTable + STR0002,STR0003) //"Tabela de Regras de Negócio "###" não encontrada!"###"Aviso"
	return .T.
EndIf

lGrpVen	:= HCS->(FieldPos("HCS_GRPVEN")) > 0

dbSelectArea("HCS")
dbSetOrder(1)
dbSeek(RetFilial("HCS"))
//dbGoTop()
dbSelectArea("HA1")
HA1->(dbSetOrder(1))
HA1->(dbSeek( RetFilial("HA1") + cCliente + cLoja ))
While !HCS->(Eof()) .And. lContinua //.And. lRegra .And. !lExce 
	If 	(HCS->HCS_CODCLI = cCliente .Or. Empty(HCS->HCS_CODCLI) ).And.;
		(Iif(lGrpVen,HCS->HCS_GRPVEN = HA1->HA1_GRPVEN,.T.) .Or. Iif(lGrpVen,Empty(HCS->HCS_GRPVEN),.T.) ).And.;
		(HCS->HCS_LOJA = cLoja .Or. Empty(HCS->HCS_LOJA) )
		//Alert("Entrou...")
		dbSelectArea("HCT")
		dbSetOrder(1)
		dbSeek(RetFilial("HCT") + HCS->HCS_CODREG)
		While !Eof() .And. HCT->HCT_CODREG = HCS->HCS_CODREG
			//Alert(HCT->HCT_ITEM)
			If HCT->HCT_TPRGNG = "1"
				If (HCT->HCT_CODTAB = cTab .Or. Empty(HCT->HCT_CODTAB)) .And.;
				(HCT->HCT_CONDPG = cCond .Or. Empty(HCT->HCT_CONDPG)) 
				//.And.;(HCT->HCT_FORMPG = cFormPg .Or. Empty(HCT->HCT_FORMPG))
					lRegra:=.T.
					//Alert("1")
					lContinua := .F.
					Break //sair do loop
				Else
					If (HCT->HCT_CODTAB = cTab .Or. Empty(HCT->HCT_CODTAB))
						If (HCT->HCT_CONDPG <> cCond .And. !Empty(HCT->HCT_CONDPG)) 
						//.Or.;	(HCT->HCT_FORMPG <> cFormPg .And. !Empty(HCT->HCT_FORMPG))
							cMsg := STR0007 //"Condição de pagamento inválida para o cliente e/ou Grupo de cliente."
							lRegra := .F.
							//Alert("2")
							dbskip()
							Loop
						Endif
					Else
						If (HCT->HCT_CONDPG = cCond .Or. Empty(HCT->HCT_CONDPG))
							If (HCT->HCT_CODTAB <> cTab .And. !Empty(HCT->HCT_CODTAB))
						//if (HCT->HCT_CONDPG = cCond .And. Empty(HCT->HCT_CONDPG)) .Or.;
						//(HCT->HCT_FORMPG = cFormPg .And. Empty(HCT->HCT_FORMPG))
								cMsg := STR0008 // "Tabela de preço inválida para o cliente e/ou Grupo de cliente."
								lRegra := .F.
								//Alert("3")
								dbskip()
								Loop
							Endif
						Else
							lRegra := .F.
							//Alert("2 Diferentes!")
							dbskip()
							Loop
						Endif
					EndIf
					
					lRegra:= .T.
					//Alert("4")
					//Alert(lRegra)      
					lContinua := .F.
					Break //sair do loop
				EndIf	
			Else
				If (HCT->HCT_CODTAB = cTab .Or. Empty(HCT->HCT_CODTAB)) .And.;
				(HCT->HCT_CONDPG = cCond .Or. Empty(HCT->HCT_CONDPG)) 
				//.And.;(HCT->HCT_FORMPG = cFormPg .Or. Empty(HCT->HCT_FORMPG))
					lExce:=.T.
					//Alert("5")
					lContinua := .F.
					Break //sair do loop
				Else
					If (HCT->HCT_CODTAB = cTab .Or. Empty(HCT->HCT_CODTAB))
						If (HCT->HCT_CONDPG <> cCond .And. !Empty(HCT->HCT_CONDPG)) 
						//.Or.;(HCT->HCT_FORMPG <> cFormPg .And. !Empty(HCT->HCT_FORMPG))
							cMsg := STR0007 //"Condição de pagamento inválida para o cliente e/ou Grupo de cliente."
							lExce := .F.  
							//Alert("6")
							dbskip()
							Loop
						Endif
					Else  
						If (HCT->HCT_CONDPG = cCond .Or. Empty(HCT->HCT_CONDPG))
							If (HCT->HCT_CODTAB <> cTab .And. !Empty(HCT->HCT_CODTAB))
						//if (HCT->HCT_CONDPG = cCond .And. Empty(HCT->HCT_CONDPG)) .Or.;
						//(HCT->HCT_FORMPG = cFormPg .And. Empty(HCT->HCT_FORMPG))
								cMsg := STR0008 // "Tabela de preço inválida para o cliente e/ou Grupo de cliente."
								lExce := .F.
								//Alert("7")
								dbskip()
								Loop
							Endif
						Else
							lExce := .F.
							//Alert("2 Diferentes!")
							dbskip()
							Loop
						Endif					
					EndIf
					
					lExce:= .T.        
					//Alert("8")
					lContinua := .F.
					Break//sair do loop
				EndIf	
			Endif
			dbSelectArea("HCT")
			dbSkip()
		Enddo
	Endif
	dbSelectArea("HCS")
	dbSkip()
Enddo

//Alert("Fim...")
//Alert(lRegra)
//Alert(lExce)

if lRegra .And. !lExce
	Return .T.     
Else
	MsgStop(cMsg,STR0005)
   //MsgStop(STR0004,STR0005)  //"Essa venda não pode ser efetuada, pois condições comerciais diferem das condições permitidas pela Regra de Negócio da Empresa"###"Regra de Negócio"
Endif

Return .F.

/*   
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Regra de Desconto    ³Autor - Paulo Lima   ³ Data ³10/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Aplica o descto no item caso o mesmo esteja dentro da regra ³±±
±±³			 ³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SFA CRM 6.01                                               ³±±
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
±±³			 ³nItePed	 -> Indice (elemento) do array aItePed		  	  ´±± 
±±³			 ³aColIte	 -> Array c/ dados do Item corrente				  ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista    ³ Data   ³Motivo da Alteracao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Cleber M.  ³28/04/03³		Melhorias								  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function RGAplDescIte(cCliente, cLoja, cCond, cTab, cFormPg, aColIte, aItePed, nItePed)
Local I:=0
Local lDesc := .F.
Local cTable := "HCO"
Local cGrpVen := ""
Local cCodProd := ""
Local cCodGrp  := ""
Local nQtde    := 0
Local nRevAtu := 0
Local nRelevancia := 0
Local nPercAtu := 0
Local nPercDesc := 0

DEFAULT aColIte := {}
DEFAULT aItePed := {}
DEFAULT nItePed := 1

If !(Select("HCO")>0)
	//MsgStop(STR0006 + cTable + STR0002,STR0003) //"Tabela de Regras de Desconto "###" não encontrada!"###"Aviso"
	return nil
EndIf

dbSelectArea("HA1")
dbSetOrder(1)
dbSeek(RetFilial("HA1") + cCliente + cLoja)
cGrpVen := HA1->HA1_GRPVEN

If len(aItePed) > 0 .And. nItePed > 0
	cCodProd := aItePed[nItePed,1]
	cCodGrp  := aItePed[nItePed,3]
	nQtde    := aItePed[nItePed,4]
ElseIf len(aColIte) > 0
	cCodProd := aColIte[1,1]
	cCodGrp  := aColIte[3,1]
	nQtde    := aColIte[4,1]
EndIf

dbSelectArea("HCO")
dbSetOrder(1)
dbSeek(RetFilial("HCO"))

While !Eof()

	If ((HCO->HCO_CODCLI = cCliente .Or. Empty(HCO->HCO_CODCLI) ).And.;
			(HCO->HCO_LOJA = cLoja .Or. Empty(HCO->HCO_LOJA) ) .And.;
			(HCO->HCO_CODTAB = cTab .Or. Empty(HCO->HCO_CODTAB) ) .And.;
			(HCO->HCO_CONDPG = cCond .Or. Empty(HCO->HCO_CONDPG) ) .And.; 
			(HCO->HCO_FORMPG = cFormPg .Or. Empty(HCO->HCO_FORMPG) ) .And.; 
			(HCO->HCO_GRPVEN = cGrpVen .Or. Empty(HCO->HCO_GRPVEN) ) )

	   	dbSelectArea("HCP")
	   	dbSetOrder(2)
		dbSeek(RetFilial("HCP") + HCO->HCO_CODREG)

  		lDesc       := .F.
  		nPercDesc    := 0
  		nRelevancia := 0
  		
  		While !Eof() .And. HCP->HCP_CODREG = HCO->HCO_CODREG
			If (HCP->HCP_GRUPO = cCodGrp) .Or. (HCP->HCP_CODPRO = cCodProd)
				//Regra sera aplicada no preco de tabela

				If ( HCP->HCP_FAIXA >= nQtde)
					//Grava descto
					nPercDesc   := HCP->HCP_PERDES
					nRelevancia := 1
					lDesc       := .T.
					If (HCP->HCP_CODPRO = cCodProd) .Or.(HCP->HCP_GRUPO = cCodGrp)
						break
					EndIf
				Endif
	        Endif
			HCP->(dbSkip())
		Enddo

		If lDesc
			//Define relevancia do desconto aplicado
			nRelevancia += Iif(Empty(HCO->HCO_CODCLI),0,10)
			nRelevancia += Iif(Empty(HCO->HCO_GRPVEN),0,5)
			nRelevancia += Iif(Empty(HCO->HCO_CODTAB),0,1)
			nRelevancia += Iif(Empty(HCO->HCO_CONDPG),0,1)
			nRelevancia += Iif(Empty(HCO->HCO_FORMPG),0,1)
			
			//A regra mais relevante sera considerada
			If nRelevancia > nRevAtu
				nRevAtu	 := nRelevancia
				nPercAtu := nPercDesc
			EndIf
		EndIf
		
    Endif
    dbSelectArea("HCO")
    dbSkip()
Enddo

//Aplica percentual no pedido
If len(aItePed) > 0 .And. nItePed > 0
	aItePed[nItePed,7] := nPercAtu
	aItePed[nItePed,6] := Round(aItePed[nItePed,16] - (aItePed[nItePed,16] * (aItePed[nItePed,7] / 100) ),TamADVC("HC6_PRCVEN",2))
ElseIf len(aColIte) > 0
	aColIte[7,1] := nPercAtu
	aColIte[6,1] := Round(aColIte[16,1] - (aColIte[16,1] * (aColIte[7,1] / 100) ),TamADVC("HC6_PRCVEN",2))
EndIf

Return Nil


//Aplica regra de desconto por faixa (total) de pedido
Function RGDescTotPed(cCliente, cLoja, cCond, cTab, cFormPg, nTotPed, nDescReg, nPrDscRg)

Local cTable := "HCO"
Local cGrpVen := ""

If !(Select("HCO")>0)
	//MsgStop(STR0006 + cTable + STR0002,STR0003) //"Tabela de Regras de Desconto "###" não encontrada!"###"Aviso"
	return nil
EndIf

dbSelectArea("HCO")
dbSetOrder(1)
dbSeek(RetFilial("HCO"))
//dbGoTop()

dbSelectArea("HA1")
dbSetOrder(1)
dbSeek(RetFilial("HA1") + cCliente + cLoja)
cGrpVen := HA1->HA1_GRPVEN

While !Eof()

	If ((HCO->HCO_CODCLI = cCliente .Or. Empty(HCO->HCO_CODCLI) ).And.;
			(HCO->HCO_LOJA = cLoja .Or. Empty(HCO->HCO_LOJA) ) .And.;
			(HCO->HCO_CODTAB = cTab .Or. Empty(HCO->HCO_CODTAB) ) .And.;
			(HCO->HCO_CONDPG = cCond .Or. Empty(HCO->HCO_CONDPG) ).And.; 
			(HCO->HCO_FORMPG = cFormPg .Or. Empty(HCO->HCO_FORMPG) ) .And.;
			(HCO->HCO_GRPVEN = cGrpVen .Or. Empty(HCO->HCO_GRPVEN) ) .And.;
			(nTotPed >= HCO->HCO_FAIXA ) ) // Se o total do pedido for maior que o valor, aplica o desconto
			
			nPrDscRg := HCO->HCO_PERDES
			nDescReg := nTotPed * (HCO->HCO_PERDES / 100)
			
         	break
	Endif
  	dbSkip()
Enddo

Return Nil