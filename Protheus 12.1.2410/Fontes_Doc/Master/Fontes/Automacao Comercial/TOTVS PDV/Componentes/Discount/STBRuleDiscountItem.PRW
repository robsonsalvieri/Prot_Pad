#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "STPOS.CH"   
#INCLUDE "STBRULESDISCOUNTITEM.CH"

Static lLimpRegra 	:= .F.
Static aProdsVda	:= {} //Array contendo os produtos da venda e suas respectivas quantidades vendidas, utilizadas e nao utilizadas ainda para aplicacao das regras de desconto.

//-------------------------------------------------------------------
/*/{Protheus.doc} STBItemRlDi
Function Regra de Desconto

@param 	 nItemLine			Número do Item
@param 	 cItemCode			Codigo Produto
@param 	 nValueItem			Valor
@param 	 nAmount			Quantidade
@param 	 cTypeProd			Tipo do Produto Mostruario/Saldao
@param 	 cCliCode			Código do Cliente
@param 	 cCliStore			Codigo da Loja
@author  Varejo
@version P11.8 
@since   29/03/2012
@return  aRet[1]	   		LRULEAPPLY		   			1 // Alguma regra foi aplicada?
@return  aRet[2]	   		NNEWTOTAL			 		2 // Valor total despois da aplicada(s) a(s) regra(s)
@return  aRet[3]	  		NPERDESCTO					3 // Percentual de desconto total aplicado em relacao ao valor total antigo
@return  aRet[4]	  		NOLDTOTAL					4 // Valor total antes da aplicada(s) a(s) regra(s) 
@obs     					
@sample
/*/
//-------------------------------------------------------------------
Function STBItemRlDi( 	nItemLine	, cItemCode 	, nValueItem 	, nAmount , ;
							cTypeProd	, cCliCode		, cCliStore				)
                                                                          
Local aRet					:= {}			// Retorno da Funcao
Local lApplyRule			:= .F.			// Aplicou alguma Regra de Desconto?  
Local nNewValueItem			:= 0			// Novo valor do Item
Local nValueDiscount		:= 0			// Valor do desconto que foi aplicado
Local nDiscPerTotal			:= 0			// Percentual total do desconto pela(s) regras(s). Pode ocorrer mais de uma regra.
Local nTotValueDiscount		:= 0			// Valor total dos descontos aplicados acumulados
Local aRules				:= {}			// Regras de Desconto no Total 
Local aAppRules				:= {}			// Armazena Informacoes das Regras Aplicadas
Local nI					:= 0 			// Contador
Local oModelCesta   		:= STDGPBModel()// Model da cesta
Local nQuantBuy				:= 0            // Contador da quantidade de produtos já comprados e que estao na cesta
Local yI					:= 0 			// Contador
Local nX					:= 0 			// Contador
Local aProduto 				:= {}           // Array com as informações do produto a ser consultado se existe estoque 
Local aLocal   				:= {}			// Array com as informações sobre a loja do produto que devera ser consultado se existe estoque
Local aSldEst               := {}			// Array de retorno da função "Lj7SldEst" que consta as informações sobre o estoque 
Local aBrindes              := {}           // Array com os brindes disponiveis em estoque
Local aBonificados          := {}           // Array com as bonificacoes da regra
Local nReGRAQTDE            := 0            // Quantidade de produtos necessarios comprar para ganhar o brinde.
Local nCont 				:= 0            // Contador do array que armazena o brindes disponiveis no estoque
Local nPrice 				:= 0            // preco do item bonificado
Local cTPRegra              := ""           // Tipo de regra (Item ou Total)
Local cRefGrid              := ""           // referencia do item(produto ou regra do total) na grid
Local cProduto              := ""           // Produto da grid MB8
Local oTotal                := STFGetTot()  // Objeto ref. ao valor da venda para controle se exibe ou não as opções de brinde/bonificacao
Local nSumRegraQtde         := 0            // Variavel para controle de regra acumulativa por item - MB8
Local lOK                   := .T.          // Controla a aplicacao das regras de Desconto
Local lGrava           	    := .T.          // Controle sobre a gravacao do brinde
Local nPosQuant	   			:= 0			// Posição Quantidade (*)
Local nQuantLanc			:= 0			// Quantidade (*)
Local cGetProd 				:= ""         	// Código do Produto definido na quantidade
Local nRegMulti				:= 0			// Utilizado para verificar se regra é multipla
Local lDesQtdIte			:= .F.			// Indica se concede o desconto no item lançado caso a quantidade lançada for maior ou igual a "Qtd. Venda" configurada no campo MB8_QTDPRO
Local aSTItRlDisc			:= {}			// Retorno ponto de entrada
Local nQtdSaldo				:= 0			// Quantidade Saldo do produto para quantificar se atinge a Regra de Quantidade para conceder o desconto
Local nPosProd 				:= 0
Local lMultQtde				:= .F. 			// Indica se a regra é multiplo de quantidade
Local nQtdeApply			:= 1 			// Quantidade considerada para aplicação da Regra
Local nRecnoMB8 			:= 0
Local lAchouMB8	 			:= .F.
Local lSTBConstCt			:= ExistFunc("STBCONSTCT")			//Verifica se a função STBConstCt() existe
Local lBrinde				:= .F. //Variavel para não permitir a execução do Brinde até que seja homologada corretamente.

Default nItemLine  			:= 0
Default cItemCode  			:= ""
Default nValueItem 			:= 0
Default nAmount 			:= 1
Default cTypeProd  			:= ""
Default cCliCode   			:= ""
Default cCliStore  			:= ""

// Abaixo avalia a string digitada. Se na string cGetProd houver '*' sera setada quantidade
// Necessário para aplicar o desconto da regra de desconto varejo
cGetProd    := AllTrim(STIGetProd())
nPosQuant	:= AT("*",cGetProd)

If nPosQuant > 0
	nQuantLanc := STIComma(SubStr(cGetProd,1,nPosQuant-1))
Else
	nQuantLanc := nAmount
EndIf

nValueItem 		:= nValueItem * nAmount 
nNewValueItem 	:= nValueItem
	
aRules := STDItemRlDi( 	cItemCode 	, nValueItem , cTypeProd , cCliCode , ;
							cCliStore, "I"	)

If ExistBlock("STItRlDisc")
	aSTItRlDisc := ExecBlock("STItRlDisc",.F.,.F.,{cItemCode,nValueItem,nAmount})
	If Valtype(aSTItRlDisc) == "A" .And. Len(aSTItRlDisc) == 3
		lApplyRule			:= aSTItRlDisc[1] //Se aplica a regra de desconto customizado.
		nNewValueItem		:= aSTItRlDisc[2] //Novo valor total do item (valor unitario*quantidade) - desconto customizado.
		nTotValueDiscount	:= aSTItRlDisc[3] //Novo valor de desconto do item (valor total do desconto do item).
		LjGrvLog("Regra de desconto", "STItRlDisc - Desconto no item " + cItemCode + " no valor de:",nTotValueDiscount) //#"Regra de desconto"
		LjGrvLog("Regra de desconto", "STItRlDisc - Valor do item apos desconto: ",nNewValueItem) //#"Regra de desconto"
		If nNewValueItem + nTotValueDiscount <> nValueItem
			LjGrvLog("Regra de desconto", "STItRlDisc - Valor retornado difere do valor original: ",nValueItem) //#"Regra de desconto"
			lApplyRule := .F.
		Endif
	EndIf
EndIf

If Len(aRules) > 0

	//----------------------------------------------------------------------------
	// Ordena o array pela ordem de priorizacao no qual serao aplicadas as regras
	//----------------------------------------------------------------------------
	aRules := STBOrdRegra(aRules)
	
	oModelSL2 := oModelCesta:GetModel("SL2DETAIL")			
	
	If oModelSL2:Length() == 0 .Or. oModelSL2:IsEmpty()
		aProdsVda := {} //Limpa o array caso seja o primeiro item que esteja sendo lançado
	EndIf

	/*/	
		Checando a quantidade já comprada do produto
	/*/	
   	For yI := 1 To oModelSL2:Length()
	    If !oModelSL2:IsEmpty()
			oModelSL2:GoLine(yI)
			If AllTrim(oModelSL2:GetValue("L2_PRODUTO")) == AllTrim(cItemCode)
				If !oModelSL2:IsDeleted(yI)
					nQuantBuy += oModelSL2:GetValue("L2_QUANT")
				EndIf
			EndIf
		Endif	
	Next yI


	nPosProd := aScan( aProdsVda, { |x| x[1] == AllTrim(cItemCode) } )
	If nPosProd > 0
		nQtdSaldo := aProdsVda[nPosProd][3]

		aProdsVda[nPosProd][2] += nQuantLanc
		aProdsVda[nPosProd][3] += nQuantLanc
	Else
		aAdd( aProdsVda, {	AllTrim(cItemCode)	,;	//01-Codigo do Produto
							nQuantLanc			,;	//02-Quantidade Vendida
							nQuantLanc			,;	//03-Saldo de Quantidade
							{} 					})	//04-Regras Aplicadas
		
		nPosProd := Len(aProdsVda)
	EndIf

	nQuantBuy := nQuantBuy + nQuantLanc //Quantidade Total Comprada do Produto
	nQtdSaldo := nQtdSaldo + nQuantLanc //Quantidade Saldo do produto que ainda nao foi aplicada nenhuma regra

	For nI := 1 To Len(aRules)
		
		//Reinicializa variaveis
		lOK 		:= .T.
		nQtdeApply 	:= 1
		cTPRegra	:= ""
		cRefGrid 	:= ""
		cProduto 	:= ""
		nRecnoMB8	:= 0
		lAchouMB8	:= .F.

		If Len(aRules[nI]) >= 14
			nRecnoMB8 := aRules[nI][14]
		EndIf

		If aRules[nI][8] == "PRO"
			DbSelectArea("MB8")

			If nRecnoMB8 > 0
				MB8->(DbGoTo(nRecnoMB8))
				lAchouMB8 := MB8->(!EoF())
			Else
				MB8->(DbSetOrder(4)) //MB8_FILIAL+MB8_CODREG+MB8_CODPRO
				//Tenta buscar por Produto
				lAchouMB8 := MB8->(DbSeek(xFilial("MB8")+aRules[nI][1]+aRules[nI][7]))
				If !lAchouMB8
					//Tenta buscar por Categoria
					MB8->(DbSetOrder(1)) //MB8_FILIAL+MB8_CODREG+MB8_REFGRD
					lAchouMB8 := MB8->(DbSeek(xFilial("MB8")+aRules[nI][1])) 
				EndIf
			EndIf
			
			If lAchouMB8
				cTPRegra := MB8->MB8_TPREGR //1=Desconto;2=Bonificacao;3=Brinde
				cRefGrid := PADL(MB8->MB8_REFGRD, TamSX3("MB8_REFGRD")[1], "0")+"MB8"

				If Empty(cProduto)
					cProduto:= MB8->MB8_CODPRO
				Endif

				If Empty(alltrim(cProduto)) .And. (aRules[nI][12] == .T.)//Produto de Categoria
					cProduto := alltrim(cItemCode)
				Endif
			Endif
		Else
			
			cTPRegra := aRules[nI][9]  			// que corresponde ao campo MB2_TPREGR
			cRefGrid := aRules[nI][10]+"MB2" 	// que corresponde ao campo MB2_REFGRD
			cProduto := ""						// quando a regra for por total nao existe produto
		
		EndIf
		// Verifica campo MB8_DESCTO
		/*
		Sobre o campo MB8_DESCTO:	MB8_DESCTO == "1"
		Ex: Item: 002 --- Preço: R$ 200,00 --- Desconto %: 10% --- Qtd Venda: 5 --- Desc Total = Sim
		Ao adicionar 5 vezes o item 002 separadamente na tela de atendimento o sistema não irá conceder o desconto. Para esta funcionalidade ser aplicada é preciso lançar 5*002. 
		Assim, o sistema irá aplicar o desconto de 10% (R$ 100,00), sendo R$ 20,00 em cada item. O total da venda será de R$ 900,00.
		Esta regra é aplicada toda vez que a quantidade de itens lançados for igual ou superior ao campo Qtd Venda. Esta regra não é cumulativa, 
		o desconto somente será aplicado quando a quantidade do item atingir a quantidade de venda estabelecida na regra.
		Fonte: http://tdn.totvs.com/pages/viewpage.action?pageId=215483464
		*/
		
		//Verifica se concede o desconto no item lançado caso a quantidade lançada for maior ou igual a "Qtd. Venda" configurada no campo MB8_QTDPRO
		lDesQtdIte := MB8->MB8_DESCTO == "1" //1=Sim
		
		/*
		SObre o campo MB8_QTDMUL ( Multiplo de quantidade )
		Para uma regra configurada com o campo Múltiplo Qtd = Não, o sistema fornece o desconto apenas uma vez na venda, assim que a quantidade de itens for igual ou superior ao campo de Qtd. Venda (MB8_QTDPRO). 
		Caso o campo Múltiplo Qtd (MB8_QTDMUL) = SIM o desconto é aplicado toda vez que a quantidade atingir o campo de Qtd. Venda. O desconto é aplicado somente no último item da venda.

		Ex: Item: 001 --- Preço: R$ 100,00 --- Desconto %: 50% --- Multiplo Qtd: Sim --- Qtd Venda: 5
		Ao adicionar 5 vezes o item 001 na tela de atendimento o sistema irá conceder o desconto de 50% (R$ 50,00) no último item, sendo assim, o total da venda será de R$ 450,00. 
		Esta regra é cumulativa e o sistema verifica o total de itens na tela para verificar se pode ou não aplicar a regra de desconto.
		*/

		lMultQtde := MB8->MB8_QTDMUL == "1" //1=Sim 

		Do Case
			Case cTPRegra = '1'//DESCONTO     

				//--------------------------
				// Validacao por Quantidade
				//--------------------------
				If MB8->MB8_QTDPRO > 0

					lOK := .F.

					If lDesQtdIte // Concede o desconto no item lançado caso a quantidade lançada for maior ou igual a "Qtd. Venda" configurada no campo MB8_QTDPRO
						//Verifica se a Quantidade Lançada do Item Atinge a quantidade configurada para conceder o desconto
						If nQuantLanc >= MB8->MB8_QTDPRO
							lOK := .T.
							nQtdeApply := nQuantLanc
						Endif
					Else
						// Regra por Compra acumulativa do mesmo produto, verifica se a quantidade comprada atinge a "Qtd. Venda" configurada no campo MB8_QTDPRO
						If nQtdSaldo >= MB8->MB8_QTDPRO
							lOK := .T.
							nQtdeApply := nQtdSaldo
						Endif
					Endif 
				Endif

				If lOK

					If MB8->MB8_QTDPRO == 0
						nRegMulti := Int(nQtdeApply / 1)
					Else
						nRegMulti := Int(nQtdeApply / MB8->MB8_QTDPRO)
					EndIf

						nQtdSaldo := nQtdSaldo - (MB8->MB8_QTDPRO * nRegMulti) //Atualiza o Saldo da Qdade do Produto

					Do Case
						Case aRules[nI][MB8_DESCPR] > 0 // PERCENTUAL

							If lMultQtde
								nValueDiscount := ( ( nNewValueItem / nQuantLanc ) * ( aRules[nI][MB8_DESCPR] / 100 ) ) * nRegMulti
							Else
								nValueDiscount := ( ( nNewValueItem ) * ( aRules[nI][MB8_DESCPR] / 100 ) )
							EndIf
	
							LjGrvLog("Regra de desconto", "STItRlDisc - Aplicado a regra: " + MB8->MB8_CODREG, cProduto)
							LjGrvLog("Regra de desconto", "STItRlDisc - Percentual do Desconto: " + STR(aRules[nI][MB8_DESCPR]) , cProduto)
							LjGrvLog("Regra de desconto", "STItRlDisc - Valor do Desconto: " + STR( nValueDiscount ) , cProduto)

							If (nNewValueItem - nValueDiscount) >= 0.01
								/*/	                                                                  
									Chamada Desconto na Proxima Venda
								/*/ 
								If  STWNxtSalD( 	"I" 	  	, nItemLine    				, cItemCode					, nNewValueItem , ;
													nAmount		, aRules[nI][MEI_CODREG] 	, aRules[nI][MB8_DESCPR]	, NIL			)
								
								Else
									
									lApplyRule := .T.
									
									nTotValueDiscount 	:= nTotValueDiscount + nValueDiscount
									nNewValueItem 		:= nNewValueItem - nValueDiscount
												
									AADD( aAppRules , { aRules[nI] } ) 

									aAdd( aProdsVda[nPosProd][4], MB8->MB8_CODREG+MB8->MB8_REFGRD ) //Adiciona no array a Regra aplicada
									aProdsVda[nPosProd][3] := nQtdSaldo  //Atualiza o Saldo de Quantidade do Produto que ainda nao foi aplicado Regra de Desconto
									
								EndIf
								
							EndIf
			
						Case aRules[nI][MB8_DESCVL] > 0 // VALOR

							If lMultQtde
								nValueDiscount := aRules[nI][MB8_DESCVL] * nRegMulti
							Else
								nValueDiscount := aRules[nI][MB8_DESCVL]
							EndIf	

							LjGrvLog("Regra de desconto", "STItRlDisc - Aplicado a regra: " + MB8->MB8_CODREG, cProduto)
							LjGrvLog("Regra de desconto", "STItRlDisc - Valor do Desconto: " + STR( aRules[nI][MB8_DESCVL] ) , cProduto)						

							If (nNewValueItem - nValueDiscount) >= 0.01
								/*/	
									Chamada Desconto na Proxima Venda
								/*/ 
								If STWNxtSalD( 	"I" 	  	, nItemLine    				, cItemCode		, nNewValueItem 			, ;
												nAmount		, aRules[nI][MEI_CODREG] 	, NIL			, aRules[nI][MB8_DESCVL]	)
															
								Else
								
									lApplyRule := .T.
									
									nTotValueDiscount	:= nTotValueDiscount + nValueDiscount
									nNewValueItem 		:= nNewValueItem - nValueDiscount
									
									AADD( aAppRules , { aRules[nI] } )

									aAdd( aProdsVda[nPosProd][4], MB8->MB8_CODREG+MB8->MB8_REFGRD ) //Adiciona no array a Regra aplicada
									aProdsVda[nPosProd][3] := nQtdSaldo  //Atualiza o Saldo de Quantidade do Produto que ainda nao foi aplicado Regra de Desconto
									
								EndIf
								
							EndIf
							
					EndCase                                
				Endif
		
			Case cTPRegra = '2'//BONIFICACAO     

				/*/
					Verifica a quantidade necessaria de compra do produto para ganhar a Bonificacao
				/*/
				
				//Deve-se considerar o While porque o usuario pode ter o mesmo produto cadastrado varias vezes dentro da MB8 para 
				//atender a quantidade diferentes
				If aRules[nI][8] == "PRO" // Ira executar somente se a regra for por item
					while MB8->(!BOF() .And. MB8->MB8_FILIAL+MB8->MB8_CODREG = xFilial("MB8")+aRules[nI][1]) //Regra com regra 
						If (MB8->MB8_TPREGR = '2')//Bonificacao    
							If lSTBConstCt .AND. aRules[nI][12]										//por Categoria
								If STBConstCt(MB8->MB8_CATEGO, cItemCode)
									nRegraQtde := MB8->MB8_QTDPRO		//Quantidade necessaria de Produtos para comprar
									If nQuantBuy >= nRegraQtde			//Aqui fica assegurado que o sistema trata a regra do mesmo produto qdo o mesmo atingir a qtde necessaria de compra. 
										Exit
									Endif 
								EndIf
							ElseIf (MB8->MB8_CODPRO =  alltrim(cItemCode))			//por Produto
								nRegraQtde := MB8->MB8_QTDPRO		//Quantidade necessaria de Produtos para comprar
								If nQuantBuy >= nRegraQtde			//Aqui fica assegurado que o sistema trata a regra do mesmo produto qdo o mesmo atingir a qtde necessaria de compra. 
									Exit
								Endif 
							Else
								nRegraQtde := MB8->MB8_QTDPRO		//Quantidade necessaria de Produtos para comprar
							Endif
						EndIf
							
						MB8->(DbSkip())
					EndDo	
				Else
					nRegraQtde:= 0// LEANDRO TESTAR ESSE TRECHO PQ SE É POR TOTAL NAO TEM QUE EXIBIR BONIFICACAO QDO A REGRA(aRules[nI][8] == "PRO") É IGUAL A TOT
				Endif
				
				//Bonificacao 
				If nQuantBuy >= nRegraQtde
						
					DbSelectArea("MGB")
					MGB->(DbSetOrder(1))
					If MGB->(DbSeek(xFilial("MGB")+aRules[nI][1]+cRefGrid)) //MGB_FILIAL+MGB_CODREG+MGB_IDPROD     
						While MGB->(!BOF() .And. MGB->MGB_FILIAL+MGB->MGB_CODREG+MGB->MGB_IDPROD = xFilial("MGB")+aRules[nI][1]+cRefGrid)		
							nPrice := STBSearchPrice(MGB->MGB_CODPRO)
							
							If len(aBonificados) > 0 
								For nX := 1 to len(aBonificados) 
									If alltrim(aBonificados[nX][5])  == alltrim(MGB->MGB_CODPRO )  
										lGrava := .F.
									Endif
								Next nX
							Endif
										
							If lGrava				
								aAdd(aBonificados,{AllTrim(MGB->MGB_CODPRO)+" - "+AllTrim(Posicione( "SB1",1,xFilial( "SB1" )+alltrim(MGB->MGB_CODPRO),"SB1->B1_DESC" )),;
													MGB->MGB_DESCPR, ;
													MGB->MGB_DESCVL,;
													nPrice, ;
													MGB->MGB_CODPRO,;
													.F.})
							EndIf
										
							MGB->(DbSkip())
						EndDo	
					Endif	
				
				Endif
			Case cTPRegra = '3' .AND. lBrinde //BRINDE	
		
				/*/
					Verifica a quantidade necessaria de compra do produto para ganhar o Brinde
				/*/
				If aRules[nI][8] == "PRO" // somente ira executar se a regra for por item
					while MB8->(!BOF() .And. MB8->MB8_FILIAL+MB8->MB8_CODREG = xFilial("MB8")+aRules[nI][1]) //Regra com regra 
						If (cProduto =  alltrim(cItemCode)) .And. (MB8->MB8_TPREGR = '3')//Brinde    
							nRegraQtde := MB8->MB8_QTDPRO 
							If nRegraQtde == (nQuantBuy +1)//Aqui fica assegurado que o sistema trata a regra do mesmo produto qdo o mesmo atingir a qtde necessaria de compra. 
								If !lMultQtde // se a regra não for acumulativa, deve-se sair do loop 
									Exit
								Endif 
							Else
								If lMultQtde
									//Regra para exibir as opções de brinde por Compra acumulativa do mesmo produto
									nSumRegraQtde := nRegraQtde
									If nQuantBuy <> 0
										While !(nSumRegraQtde > (nQuantBuy+1)) 
											If ((nQuantBuy+1) == nSumRegraQtde)
												Exit
											Endif
											nSumRegraQtde := nSumRegraQtde + nRegraQtde 
										EndDo
										nRegraQtde := nSumRegraQtde
									Endif								  
								Endif
							Endif 
						Endif        
						MB8->(DbSkip())
						EndDo	
				Else
					//Quando a regra for Brinde por Total
					If oTotal:GetValue("L1_VALBRUT") < aRules[nI][11] 
						DbSelectArea("MB4")
						MB4->(DbSetOrder(1))
						If MB4->(DbSeek(xFilial("MB4")+aRules[nI][1]))
							nRegraQtde:= 0 // Nao podera exibir as opções de brinde
						Else
							nRegraQtde:= 1 // Para poder exibir as opções de brinde porque esta asssociada a  Forma de Pagamento
						Endif	
					Else
						nRegraQtde:= 0 // Nao ira exibir as opções de brinde porque o valor da compra ultrapassou o intervalo que merece o brinde
					Endif                                             
					
				Endif
				//Brinde 
				If nRegraQtde == (nQuantBuy +1)
						
					DbSelectArea("MGB")
					MGB->(DbSetOrder(1))
					If MGB->(DbSeek(xFilial("MGB")+aRules[nI][1]+cRefGrid)) //MGB_FILIAL+MGB_CODREG+MGB_IDPROD     
						nCont := 1
						While MGB->(!BOF() .And. MGB->MGB_FILIAL+MGB->MGB_CODREG+MGB->MGB_IDPROD = xFilial("MGB")+aRules[nI][1]+cRefGrid)		
		
							aadd( aProduto , { .T.,alltrim(oModelCesta:GetValue("SL1MASTER" , "L1_LOJA")), MGB->MGB_CODPRO ,AllTrim(Posicione( "SB1",1,xFilial( "SB1" )+alltrim(MGB->MGB_CODPRO),"SB1->B1_DESC" )), MGB->MGB_QTDPRO })
							aAdd( aLocal, alltrim(oModelCesta:GetValue("SL1MASTER" , "L1_LOJA")))
							
							//lContinua := STBRemoteExecute("Lj7SldEst" , { aProduto , aLocaL} , NIL, .F. , @aSldEst )
						
							//If lContinua
								//If aSldEst[nCont][5][nCont][2] > 0 //Produtos disponiveis em estoque.
									If len(aBrindes) > 0 
										For nX := 1 to len(aBrindes) 
											If alltrim(substr(aBrindes[nX],1,at('-', aBrindes[nX])-1))  == alltrim(MGB->MGB_CODPRO )  
												lGrava := .F.
											Endif
										Next nX
									Endif
											
									If lGrava									
										aAdd(aBrindes,AllTrim(MGB->MGB_CODPRO)+" - "+AllTrim(Posicione( "SB1",1,xFilial( "SB1" )+alltrim(MGB->MGB_CODPRO),"SB1->B1_DESC" ))) 
									Endif	
								//Endif		
							//Endif	
					
							MGB->(DbSkip())
							
							nCont := nCont +1
							
						EndDo	
					Endif	
				
					//Executa a tela para selecionar as opções de brinde
					If !Empty(aBrindes)
						STIPanBrindeSelection(aRules[nI][1],cRefGrid,cProduto,aBrindes, .T.)
					Endif	
		
				Endif
		EndCase
		
		// Se acumulativo verifica as demais regras, ou seja, casa exista mais de uma regra para o mesmo produto sera executado, 
		//caso não seja acumulativo ira executar somente a primeira regra				
		If lApplyRule .AND. aRules[nI][MEI_ACUMUL] == "N"
			Exit
		EndIf
	Next nI
EndIf

If lApplyRule
			
	nDiscPerTotal := ( nTotValueDiscount * 100 ) / nValueItem // Percentual total depois da(s) regras(s) aplicadas 
	
	If STFGetCfg("lRuleDiscShow") //Se mostra regras aplicadas
		
		STFMessage("STItemRlDi","ALERT", STR0001 + AllTrim(Transform(nTotValueDiscount,PesqPict("SL2","L2_VALDESC"))) ) //"Regra de Desconto: Aplicado desconto no item de: "
		
		For nI := 1 To Len(aAppRules) 
		
			STFMessage("STItemRlDi","ALERT", STR0002 + aAppRules[nI][1][4] ) // "Regra de Desconto: "
			
		Next nI
		
	EndIf	
	
EndIf

AADD( aRet , lApplyRule 		)
AADD( aRet , nNewValueItem 		)
AADD( aRet , nTotValueDiscount 	)
AADD( aRet , nDiscPerTotal 		)
AADD( aRet , nValueItem 		)	
		
STFShowMessage("STItemRlDi")
																													
Return aRet		

//-------------------------------------------------------------------
/*/{Protheus.doc} STBLimpRegra
Limpa variavel de verificação da regra de desconto no item
Utilizado para validar se venda ja teve desconto no item.
Necessario quando regra de de desconto não é multipla
@param   	
@author  	Vendas & CRM
@version 	P12
@since   	27/11/2015
@return  	lRet
@obs
@sample
/*/
//-------------------------------------------------------------------

Function STBLimpRegra(lRet)
Default lRet := .F.

lLimpRegra := lRet
 
Return

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} STBOrdRegra
Ordena no array as regras de desconto por item.
Faz a ordenacao na sequencia em que serao analisadas cada regra.

@type 		function
@author  	Alberto Deviciente
@since   	27/12/2018
@version 	P12.1.17

@param aRegraItem, Array, Relacao de Regras de Desconto disponiveis/ativas para aplicacao

@return Array, 	Relacao de Regras de Desconto disponiveis/ativas para aplicacao ordenada 
				na sequencia em que serao analisadas cada regra.
/*/
//-----------------------------------------------------------------------------------
Static Function STBOrdRegra(aRegraItem)
Local nX 		:= 0
Local nY 		:= 0
Local cCodRegra := ""
Local nCount 	:= 0
Local nPosIni 	:= 0

//Primeiro ordena por Prioridade de Regra (MEJ_PRINUM)
aSort(aRegraItem,,,{|x,y| x[2]+[1] < y[2]+[1]})

//Agora, ordena por ordem decrescente, a quantidade minima de compra (MB8_QTDPRO) para aplicacao de desconto
If Len(aRegraItem) > 0 .And. Len(aRegraItem[1]) > 12
	For nX:=1 To Len(aRegraItem)
		cCodRegra := aRegraItem[nX][1]
		nCount := 0
		nPosIni := nX

		For nY := nX To Len(aRegraItem)
			If aRegraItem[nY][1] <> cCodRegra
				nY := nY-1
				Exit
			EndIf
			nCount++
		Next nY

		//Ordena por ordem decrescente a quantidade minima de compra para aplicacao de desconto de um determinado produto
		//Isso eh necessario para que seja comparada primeiramente se a maior quantidade vendida eh atingida, pois normalmente eh a que possui maior valor de desconto
		aSort( aRegraItem, nPosIni, nCount, { |x,y| x[13] > y[13] } )

		nX := nY

	Next nX
EndIf

Return aRegraItem
