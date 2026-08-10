#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH" 
#INCLUDE "STPOS.CH"    
#INCLUDE "STBRULESDISCOUNTTOTAL.CH"

Static ldescreg 	:= .F.
Static lVerReg		:= .T. //Variavel responsavel em fazer o controle de validacao da regra de desconto no momento que inclui o pagamento no model de pagamentos
Static lContCart	:= .T. //Variavel de controle para aplicar o desconto quando for CC ou CD
Static cFormaPg		:= ""

//-------------------------------------------------------------------
/*/{Protheus.doc} STBTotRlDi
Function Regra de Desconto Total

@param 	 nValueTotal		Valor Total da Venda
@param 	 cCliCode			Codigo do Cliente
@param 	 cCliStore			Loja do Cliente
@author  Varejo
@version P11.8
@since   29/03/2012
@return  aRet[1]	   		LRULETOTAP		   			1 // Alguma regra foi aplicada?
@return  aRet[2]	   		NNEWTOTAL			 		2 // Valor total despois da aplicada(s) a(s) regra(s)
@return  aRet[3]	  		NPERDESCTO					3 // Percentual de desconto total aplicado em relacao ao valor total antigo
@return  aRet[4]	  		NOLDTOTAL					4 // Valor total antes da aplicada(s) a(s) regra(s) 
@obs     					
@sample
/*/
//-------------------------------------------------------------------
Function STBTotRlDi( nValueTotal, cCliCode, cCliStore, lPgto,;
									 cForma, oPnlAdconal)
                                                                          
Local aRet				:= {}			// Retorno da Funcao
Local lApplyRule		:= .F.			// Aplicou alguma Regra de Desconto?  
Local nNewValueTotal	:= 0			// Novo Total. Desconto aplicado
Local nValueDiscount	:= 0			// Valor do desconto que foi aplicado
Local nDiscPerTotal		:= 0			// Percentual total do desconto pela(s) regras(s). Pode ocorrer mais de uma regra.
Local nTotValueDiscount	:= 0			// Valor total dos descontos aplicados acumulados
Local nValSuggestion	:= 0			// Valor que falta para alcancao o inicial do range da regra
Local aRules			:= {}			// Regras de Desconto no Total 
Local aRange			:= {}			// Range de valores da regra
Local aAppRules			:= {}			// Armazena Informacoes das Regras Aplicadas
Local aSuggestion		:= {}			// Armazena Sugestoes de regra de desconto
Local nJ				:= 0			// Contador
Local nI				:= 0 			// Contador
Local nX				:= 0 			// Contador
Local nK				:= 0			// Contador
Local cSimbMoeda  		:= SuperGetMV( "MV_SIMB" + Str( STBGetCurrency(),1 ) ) 
Local oModelCesta   	:= STDGPBModel()// Model da cesta
Local cREFGRD           := ""           // Chave ref. a posicao da grid para a tabela MGB - Brindes
Local aProduto 			:= {}           // Array com as informações do produto a ser consultado se existe estoque 
Local aLocal   			:= {}			// Array com as informações sobre a loja do produto que devera ser consultado se existe estoque
Local aBrindes          := {}           // Array com os brindes disponiveis em estoque
Local aSldEst           := {}			// Array de retorno da função "Lj7SldEst" que consta as informações sobre o estoque 
Local nCont 			:= 0            // Contador do array que armazena o brindes disponiveis no estoque
Local aBonificados      := {} 			// Array com os produtos bonificados disponiveis 
Local nValor            := 0            // Valor de checagem para carregar a tela de selecao de produtos bonificados
Local lGrava            := .T.          // Controle sobre a gravacao do brinde
Local lProdDA1			:= ExistFunc("STDProdDA1") //Verifica se existe a funcao STDProdDA1
Local oCesta		 	:= Nil 			//Recuperando o model da cesta de produto
Local lCodTab			:= .F. 			//Responsavel em verificar se o campo L2_CODTAB existe no model da cesta de produtos
Local nPgtos			:= STBGetPgto() //Guarda a quantidade de pagamentos informado na venda
Local cMsg 				:= ""
Local lDescGrp 			:= .F.
Local oModelMaster		:= STFGetTot()	//Estrutura dos campos da SL1 virtuais. 
Local aForms			:= {}  			// Array que retorna as formas de pagamento da função STDPayForms

Default nValueTotal 	:= 0					
Default cCliCode 		:= ""					
Default cCliStore 		:= ""	
Default cForma          := ""           // Forma de pagamento obrigatoria     
Default lPgto           := .F.          // Checa Forma de pagamento 
Default oPnlAdconal     := Nil          // Objeto do Resumo de Pagamento

oCesta := oModelCesta:GetModel('SL2DETAIL') //Recupera do modelo de dados a cesta de itens (SL2)
lCodTab := oCesta:HasField("L2_CODTAB") //Verifica se o campo virtual L2_CODTAB existe no model da SL2

// Indica que teve desconto no Total da venda sem ser pela regra de desconto. 
If oModelMaster:HasField("L1_ARMDESC") .And. oModelMaster:GetValue("L1_ARMDESC") > 0 
	nTotValueDiscount := oModelMaster:GetValue("L1_ARMDESC") 
EndIf

If !STIGetRecTit() .And. Empty(STIGetPgOr()) .And. Iif(ExistFunc("STIGetImp"), !STIGetImp(), .T.)

	If (FWIsInCallStack("STIADDNEWPAN") .OR. FWIsInCallStack("STIADDPAY")) .AND. nPgtos == 0
		STIClearDisc(.T.)		
	ElseIf nPgtos == 1 .AND. IsMoney(cFormaPg) .AND. IsMoney(cForma)
		STIZeraPay()
		STIClearDisc(.T.)
	EndIf 

	cFormaPg := ""

	If nValueTotal == 0 
		nValueTotal := STFSaleTotal() 
	EndIf 

	If Empty(cCliCode)
		cCliCode := STDGPBasket( "SL1" , "L1_CLIENTE" )
	EndIf

	If Empty(cCliStore)
		cCliStore := STDGPBasket( "SL1" , "L1_LOJA" )
	EndIf      

	
	ParamType 0 Var nValueTotal	AS Numeric		Default 0
	ParamType 1 Var cCliCode 	AS Character	Default ""
	ParamType 2 Var cCliStore 	AS Character	Default ""
		
	/*/	
		Valor total da venda for 0,01 a regra total nao tem como ser aplicada, a venda deve ter no minimo o valor 0,01    		
	/*/  

	nNewValueTotal := nValueTotal
		
	If nValueTotal >= 0.01
		
		aRules := STDTotRlDi( cCliCode	, cCliStore,, lPgto )
		
		If Len(aRules) > 0 
		
			/*/	
				Ordena o array pelo segundo campo MEJ->MEJ_PRINUM
			/*/ 
			aRules 		:= aSort(aRules,,,{|x,y| x[MEJ_PRINUM] < y[MEJ_PRINUM]}) 
			lDescGrp 	:= ExistFunc("STDGetGrp") .AND. STDGetGrp()

			For nI := 1 To Len(aRules)
			
				//Verifica se a regra de desconto tem tabela de preco associado
				//Caso exista tabela de preco, precisamos analisar quais os produtos da venda esta contido nessa tabela de preco
				If lProdDA1 .AND. lCodTab .AND. Len(aRules[nI]) >= 5 .AND. !Empty(aRules[nI][5])
					nValueTotal := STDProdDA1(aRules[nI][5],oCesta)
					nNewValueTotal := nValueTotal
				EndIf

				//Valida se o grupo de cliente é o mesmo da regra de desconto
				If lDescGrp .AND. Len(aRules) > 0
					If !STBConfReg(cCliCode, cCliStore, aRules[nI][MEI_CODREG])
						Loop
					EndIf
				EndIf

				/*/	
					Busca o Range da Regra
				/*/ 
				If lDescGrp .Or. (!Empty(cForma) .And. Len(aRules) > 0 )
					aForms := STDPayForms(aRules[nI][MEI_CODREG], cForma)
					If !Empty(aForms) //Buscamos o range de acordo com a forma de pagamento informada na venda, pois antes estava pegando sempre o primeiro.
						For nK := 1 To Len(aForms)
							If AllTrim(aForms[nK]) == AllTrim(cForma) .OR. cForma == "CP" 
								aRange := STDRangRul( aRules[nI][MEI_CODREG] )
							EndIf	
						Next
					Else 
							aRange := STDRangRul( aRules[nI][MEI_CODREG] ) // Quando tem a regra de desconto somente por grupo de clientes
					EndIf			
				EndIf 
				For nJ:= 1 To Len( aRange )	
					
					If nValueTotal >= aRange[nJ][1] .AND. nValueTotal <= aRange[nJ][2] // Valida Range
											
						Do Case

							Case aRange[nJ][6] = '1' .OR. Empty( aRange[nJ][6] )//DESCONTO - Caso o campo MB2_TPREGR nao estiver preenchido será tratado como desconto
								/*/	
									Calculo dos valores da regra. (Acumulativo para mais de uma regra)
								/*/ 											
								Do Case
									Case aRange[nJ][nMB2_PDESC] > 0 // PERCENTUAL
																	
										If !((nNewValueTotal - (nNewValueTotal * (aRange[nJ][nMB2_PDESC] / 100 ))) < 0.01)
											/*/	
												Chamada Desconto na Proxima Venda
											/*/ 
											If STWNxtSalD( 	"T"		, NIL 		   					, NIL						, nNewValueTotal 	, ;
																NIL		, aRules[nI][MEI_CODREG] 	, aRange[nJ][nMB2_PDESC]	, NIL				)
											
											Else                  
											
												lApplyRule := .T. 							   			
												/*/	
													Realizar calculos sempre por valor						   			
												/*/ 

												If FWIsInCallStack("STIADDNEWPAN")
													//Quando clica 2x na lista de pagamentos, entra no IF
													If nPgtos == 0
														//Quando não existe nenhuma forma de pagamento já lançada na venda, então considera para
														//calculo do desconto o total de mercadorias
														nNewValueTotal := STFSaleTotal("L1_VALMERC")
													Else
														//Considera para o calculo do desconto o saldo a pagar da venda, isso quando já existe uma
														//forma de pagamento lançada na venda
														nNewValueTotal := IIF(STFSaleTotal("L1_VALMERC") - STBCalcSald("1") == 0, STFSaleTotal("L1_VALMERC"), STBCalcSald("1") + STDGPBasket( "SL1", "L1_DESCONT"))
													EndIf
												ElseIf !FWIsInCallStack("STIADDPAY")
													//Ao entrar na tela de pagamento, considera o valor total para calculo do desconto
													nNewValueTotal := STFSaleTotal("L1_VALMERC")
												EndIf

												nValueDiscount 		:= nNewValueTotal * ( aRange[nJ][nMB2_PDESC] / 100 )
												nTotValueDiscount 	:= nTotValueDiscount + nValueDiscount
												nNewValueTotal 		:= nNewValueTotal - nValueDiscount
												
												AADD( aAppRules , { aRules[nI] , aRange[nJ] } )
											
											EndIf
											
										EndIf
										
									Case aRange[nJ][nMB2_VLRFX] > 0 // VALOR
									
										If !(aRange[nJ][nMB2_VLRFX] > nNewValueTotal) .AND. !((nNewValueTotal - aRange[nJ][nMB2_VLRFX]) < 0.01)
											/*/	
												Chamada Desconto na Proxima Venda
											/*/ 
											If STWNxtSalD( 	"T"   	, NIL 		   					, NIL	, nNewValueTotal 			, ;
																NIL		, aRules[nI][MEI_CODREG] 	, NIL	, aRange[nJ][nMB2_VLRFX]	)
												
											Else 
												
												lApplyRule := .T.
												/*/	
													Realizar calculos sempre por valor						   			
												/*/ 						   			
												nValueDiscount 		:= aRange[nJ][nMB2_VLRFX]
												nTotValueDiscount	:= nTotValueDiscount + nValueDiscount
												nNewValueTotal 		:= nNewValueTotal - nValueDiscount						   			
												
												AADD( aAppRules , { aRules[nI] , aRange[nJ] } )
												
											EndIf
											
										EndIf
										
								EndCase
								
							Case aRange[nJ][6] = '2' .AND. AliasIndic("MGB") //BONIFICACAO     

								cREFGRD := aRange[nJ][7]
								
								DbSelectArea("MGB")
								MGB->(DbSetOrder(1)) //MGB_FILIAL+MGB_CODREG+MGB_IDPROD
								If MGB->(DbSeek(xFilial("MGB")+aRules[nI][1]+cREFGRD))      
									While MGB->(!BOF() .And. MGB->MGB_FILIAL+MGB->MGB_CODREG+MGB->MGB_IDPROD = xFilial("MGB")+aRules[nI][1]+cREFGRD)		
										nPrice := STBSearchPrice(MGB->MGB_CODPRO)
										
										If !Empty(MGB->MGB_DESCPR)//Valor do produto possui desconto em Porcentagem
												nValor := nPrice - ((nPrice / 100) * MGB->MGB_DESCPR)
												
											Else
												If !Empty(MGB->MGB_DESCVL)//Valor do produto possui desconto em Valor
													nValor := (nPrice - MGB->MGB_DESCVL)
												Else
													//valor cheio do produto
													nValor := nPrice 		    
												Endif									
										Endif									
										
										If nValor > 0								
											
											If len(aBonificados) > 0
												For nX := 1 to len(aBonificados) 
													If alltrim(substr(aBonificados[nX][1],1,at('-', aBonificados[nX][1])-1))  == alltrim(MGB->MGB_CODPRO )  
														lGrava := .F.
													Endif
												Next nX
											Endif
														
											If lGrava
												aAdd(aBonificados,{AllTrim(MGB->MGB_CODPRO)+" - ";
															+AllTrim(Posicione( "SB1",1,xFilial( "SB1" )+alltrim(MGB->MGB_CODPRO),"SB1->B1_DESC" )),;
															MGB->MGB_DESCPR, MGB->MGB_DESCVL,nPrice}) 					
											Endif	
											
											nValor := 0
										Endif								
																			
										MGB->(DbSkip())
									EndDo	
								Endif	

								//Executa a tela para selecionar a bonificação
								If !Empty(aBonificados) .AND. FindFunction("STIBONIFSelection")
									STIBONIFSelection( ,aRules[nI][1], cREFGRD, MB8->MB8_CODPROD,;
													aBonificados, .T., cForma, oPnlAdconal)//Importante: NAO usar STIExchangePanel porque ocorre erro de PANEL
								Endif	
						
							Case aRange[nJ][6] = '3' .AND. AliasIndic("MGB") //BRINDE	
							
								cREFGRD := aRange[nJ][7]
							
								//Consistencia para exibir os brindes por Total
								DbSelectArea("MGB")
								MGB->(DbSetOrder(1))  //MGB_FILIAL+MGB_CODREG+MGB_IDPROD
								If MGB->(DbSeek(xFilial("MGB")+aRules[nI][1]+cREFGRD ))     
									
									nCont := 1
									
									While MGB->(!BOF() .And. MGB->MGB_FILIAL+MGB->MGB_CODREG+MGB->MGB_IDPROD = xFilial("MGB")+aRules[nI][1]+ cREFGRD )		
										
										aadd( aProduto , { .T.,alltrim(oModelCesta:GetValue("SL1MASTER" , "L1_LOJA")), MGB->MGB_CODPRO ,AllTrim(Posicione( "SB1",1,xFilial( "SB1" )+alltrim(MGB->MGB_CODPRO),"SB1->B1_DESC" )), MGB->MGB_QTDPRO })
										aAdd( aLocal, alltrim(oModelCesta:GetValue("SL1MASTER" , "L1_LOJA")))
										
										lContinua := STBRemoteExecute("Lj7SldEst" , { aProduto , aLocaL} , NIL, .F. , @aSldEst )
									
										If lContinua
											If aSldEst[nCont][5][nCont][2] > 0 //Produtos disponiveis em estoque
												If len(aBrindes) > 0 
													For nX := 1 to len(aBrindes) 
														If alltrim(substr(aBrindes[nX],1,at('-', aBrindes[nX])-1))  == alltrim(MGB->MGB_CODPRO )
															lGrava := .F.
														Endif
													Next nX
												Endif

												If lGrava
													aAdd(aBrindes,AllTrim(MGB->MGB_CODPRO)+" - "+;
														AllTrim(Posicione( "SB1",1,xFilial( "SB1" )+alltrim(MGB->MGB_CODPRO),"SB1->B1_DESC" ))) 
												Endif	
											Endif		
										Endif

										MGB->(DbSkip())

										nCont := nCont +1
									EndDo	
								Endif	
							
								//Executa a tela para selecionar as opções de brinde
								If !Empty(aBrindes)
									STIPanBrindeSelection(aRules[nI][1], cREFGRD, MB8->MB8_CODPROD, aBrindes,;
										.F., cForma, oPnlAdconal)//Importante: NAO usar STIExchangePanel porque ocorre erro de PANEL   							    
								Endif	

						EndCase  
					// SUGESTAO DE REGRA DE DESCONTO	
					ElseIf !(lApplyRule) .AND. STFGetCfg("lSugRuleDisc") //Sugestao de Desconto por regra  

						// Valor da venda + Valor de margem para apresentar sugestao de regra de desconto para alcancar  valor inicial do range 
						If nValueTotal + STFGetCfg("nVlrRngSugRD") >= aRange[nJ][nMB2_VLRINI]
							
							/*/	
								Armazena Sugestao
							/*/ 						
							nValSuggestion := aRange[nJ][nMB2_VLRINI] - nValueTotal // Valor que deve ser adicionado para alcancar a regra
							
							AADD( aSuggestion , cSimbMoeda + " " + cValToChar(nValSuggestion) ) 
																			
							Do Case 
																
								Case aRange[nJ][nMB2_PDESC] > 0 // PERCENTUAL							 									
																
									AADD( aSuggestion , cValToChar( aRange[nJ][nMB2_PDESC] ) + "%" )
									
								Case aRange[nJ][nMB2_VLRFX] > 0 // VALOR
										
									If 	!(aRange[nJ][nMB2_VLRFX] > nNewValueTotal) .AND. !((nNewValueTotal - aRange[nJ][nMB2_VLRFX]) < 0.01)								
										AADD( aSuggestion , cSimbMoeda + " " + cValToChar( aRange[nJ][nMB2_VLRFX] ) ) 									
									Else								
										aSuggestion := {}								
									EndIf
									
							EndCase       
							
						EndIf
					EndIf
				Next nJ                                                   	
				
				// Se acumulativo nao verifica as demais				
				If lApplyRule .AND. aRules[nI][MEI_ACUMUL] == "N"
					Exit
				EndIf
				
			Next nI
		EndIf
	EndIf	

	If !lApplyRule 			
		lApplyRule := STBPromPgto(cForma) //nova verificação com desconto pela forma de pagamento
		if !lApplyRule
			nValueDiscount 		:= 0
			nTotValueDiscount 	:= 0
			nNewValueTotal 		:= 0
		EndIf
	EndIf

	If lApplyRule
					
			nDiscPerTotal := ( nTotValueDiscount * 100 ) / nValueTotal // Percentual total depois da(s) regras(s) aplicadas 					
			
			If STFGetCfg("lRuleDiscShow")// Se mostra regras aplicadas 

				For nI:=1 To Len(aAppRules)			
					cMsg += aAppRules[nI][1][4] +"; "		
				Next nI
				cMsg:= SUBSTR(cMsg,1, len(Alltrim(cMsg))-1)

				STFMessage("STBTotRlDi","ALERT", STR0001 + cMsg) //Regra(s) de Desconto(s) Aplicado(s):
					
			EndIf
			
			STWTotDisc( nTotValueDiscount , "V" , "RULEDISC", ( nPgtos > 0 .AND. !FWIsInCallStack("STIADDPAY")) )
			
			// Sinaliza que teve desconto no total vindo de alguma regra cadastrada
			ldescreg := .T.

			If cForma == "CP"
				STIPayCdPg(oPnlAdconal) //Tela da condicao de pagamento 
			EndIf
	Else
		
		If STFGetCfg("lSugRuleDisc") //Sugestao de Desconto por regra  
			
			If Len(aSuggestion) > 0
				
				STFMessage(	"STBTotRlDi","ALERT", STR0003 + cValToChar(aSuggestion[1]) + ;
								STR0004 + STR0005 + aSuggestion[2])  // "Sugestão de Regra de Desconto: Adicionando mais: será concedido desconto de: 													
			EndIf
		
		EndIf
			
	EndIf

EndIf	

AADD( aRet , lApplyRule )
AADD( aRet , nNewValueTotal )
AADD( aRet , nTotValueDiscount )
AADD( aRet , nDiscPerTotal )
AADD( aRet , nValueTotal ) 
Iif(ExistFunc("STISetImp"),STISetImp(.F.),Nil)

STFShowMessage("STBTotRlDi")																									
													
Return aRet							

//-------------------------------------------------------------------
/*/{Protheus.doc} STBPromPgto 
Function para verificar se existe promocao por forma de pagamento

@param 	 
@author  Varejo
@version P11.8
@since   24/07/2014
@return  
@obs     					
@sample
/*/
//-------------------------------------------------------------------
Function STBPromPgto(cForma,cTipo) 

Local aRules			:= {}					// Regras de Desconto no Total 
Local aRange			:= {}					// Range de valores da regra
Local nJ				:= 0					// Contador
Local nI				:= 0 					// Contador
Local nK				:= 0					// Contador
Local nValueTotal  		:= 0	        		// valor total da venda
Local cCliCode 	    	:= ""	        		// cliente da venda
Local cCliStore 		:= ""           		// loja da venda
Local aForms 			:= {} 					// recebe as formas de pagamento cadastrada na regra de desconto
Local lRet              := .F.          		// variavel de retorno
Local lStdAdmFn			:= ExistFunc("STDAdmFn")//retorna se existe a função STDAdmFn
Local aAdmFin			:= {}					//array com registro da tabela MB6  

Default cForma	:= ""
Default cTipo	:= ""

If nValueTotal == 0
	nValueTotal := STFSaleTotal() 
EndIf 

If Empty(cCliCode)
	cCliCode := STDGPBasket( "SL1" , "L1_CLIENTE" )
EndIf

If Empty(cCliStore)
	cCliStore := STDGPBasket( "SL1" , "L1_LOJA" )
EndIf      

aRules := STDTotRlDi( cCliCode	, cCliStore,,.T. )

If Len(aRules) > 0 

	/*/	              	
		Ordena o array pelo segundo campo MEJ->MEJ_PRINUM
	/*/ 
	aRules := aSort(aRules,,,{|x,y| x[MEJ_PRINUM] < y[MEJ_PRINUM]}) 
	
	For nI := 1 To Len(aRules)
	
		/*/	
			Busca o Range da Regra
		/*/ 
		aRange := STDRangRul( aRules[nI][MEI_CODREG],cTipo)//Filtra o tipo de promocao(desconto/bonificacao/brinde)
		
		For nJ:= 1 To Len( aRange )	
			
			If nValueTotal >= aRange[nJ][1] .AND. nValueTotal <= aRange[nJ][2] // Valida Range					
				/*/	
					Busca as Formas de Pagamento
				/*/
				aForms := STDPayForms( aRules[nI][MEI_CODREG],cForma )
				IF lStdAdmFn
					aAdmFin:= STDAdmFn (aRules[nI][MEI_CODREG])			
				Endif 
			Endif
			// Caso retorne mais de uma forma de pagamento por regra de desconto
			For nk := 1 To Len(aForms)
				If AllTrim(aForms[nK]) == Alltrim(cForma)
					nI := Len(aRules)+1 // Realizamos esse tratamento para sair do primeiro For nI 
				EndIf
			Next
		Next nJ
			
	Next nI	

Endif

If !Empty(aForms) 
	For nI := 1 To Len(aForms)
		If AllTrim( aForms[nI] ) == AllTrim( cForma ) .AND. Empty(aAdmFin)
			lRet := .T. 
		Endif
	Next nI	
Endif

If !lRet .AND. !Empty(cForma) .And. ExistFunc("STDGetGrp") .AND. STDGetGrp() .And. ExistFunc("STDGetFrm") .And. !STDGetFrm() 
	lRet := .T. 
EndIf

Return lRet
//-------------------------------------------------------------------
/*{Protheus.doc} STIDescRegVar
Verifica se teve desconto no total referente a alguma regra de desconto
varejo cadastrada.

@param   	lRet			.T. 
@author  	Vendas & CRM
@version 	P11
@since   	11/12/2015
@return  	ldescreg
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIDescRegVar(lRet)
DEFAULT lRet := .F.

lRet := ldescreg

Return lRet 


//-------------------------------------------------------------------
/*{Protheus.doc} STBVldDesc
Funcao responsavel em validar se aplica o desconto no total ou nao.
O Desconto sera aplicado somente se o pagamento for feito com uma das
formas de pagamento configurada na regra de desconto e com valor integral.

@param   	cType - Tipo de validacao
@author  	Bruno Almeida
@version 	P12
@since   	07/05/2019
@return  	lRet - Retorna .T. (aplica o desconto) ou .F. (nao aplica o desconto)
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBVldDesc(cType, oParcelas, nValor)

Local lRet 		:= .T. //Variavel de retorno
Local nTotDA1	:= IIF(ExistFunc('STDGetDA1'),STDGetDA1(),0) //Verifica se houve desconto no total atraves de uma regra de desconto

Default cType 	:= ""
Default nValor 	:= 0

If !Empty(cType)

	If cType == '1' .AND. nTotDA1 > 0 .AND. oParcelas:Length() >= 1 .AND. !Empty(oParcelas:GetValue('L4_FORMA')) .AND. STBCalcSald("1") > 0
		lRet := .F.
		lVerReg := .F.
		STFMessage("STBVldDesc","STOP", STR0006)  //"Regra de desconto não foi aplicada pois ja constava um ou mais pagamentos efetuados para essa venda. A regra de desconto por forma de pagamento, aceita apenas uma das formas de pagamento configurado no cadastro da regra de desconto."
		STFShowMessage("STBVldDesc")				
	ElseIf cType == '2' .AND. lVerReg
		If STBCalcSald('1') > nValor
			STFMessage("STBVldDesc","STOPPOPUP", STR0007 + Chr(13) +;
			            Chr(13) + STR0008 + AllTrim(Str(STBCalcSald('1'),12,2)) + Chr(13) + STR0009 + AllTrim(Str(nValor,12,2)) + Chr(13) + Chr(13) + STR0010)  //"O desconto aplicado na venda sera desconsiderado porque o valor digitado na forma de pagamento, não é o valor integral da venda. " # "Valor integral da venda R$ " # "Valor digitado R$ " # "Sera necessario realizar novamente o lançamento do pagamento!"
			STFShowMessage("STBVldDesc")
			STBSetCart(.F.)
			STIClearDisc(.T.)
		EndIf
	ElseIf cType == '3' .AND. ((nTotDA1 > 0 .AND. oParcelas:Length() >= 1 .AND. !Empty(oParcelas:GetValue('L4_FORMA'))) .OR. !SuperGetMV("MV_LJRGDES",,.F.) .OR. nTotDA1 == 0)
		lRet := .F.
	EndIf

EndIf

Return lRet 

//-------------------------------------------------------------------
/*{Protheus.doc} STBSetReg
Funcao para setar valor a variavel lVerReg

@param   	lReg - Recebe um valor logico
@author  	Bruno Almeida
@version 	P12
@since   	07/05/2019
@return  	.T.
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBSetReg(lReg)

Default lReg := .T.

lVerReg := lReg

Return .T.


//-------------------------------------------------------------------
/*{Protheus.doc} STBSetCart()
Funcao para setar valor a variavel lContCart

@param   	lReg - Recebe um valor logico
@author  	Bruno Almeida
@version 	P12
@since   	09/05/2019
@return  	.T.
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBSetCart(lReg)

Default lReg := .T.

lContCart := lReg

Return .T.

//-------------------------------------------------------------------
/*{Protheus.doc} STBGetCart()
Funcao para retornar o conteudo da variavel lContCart

@param   	
@author  	Bruno Almeida
@version 	P12
@since   	09/05/2019
@return  	lContCart - Retorna o conteudo da variavel 
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBGetCart()
Return lContCart


//-------------------------------------------------------------------
/*{Protheus.doc} STBGetPgto()
Função responsavel por verificar se existe alguma forma de pagamento
já lançada na venda

@author  	Varejo
@version 	P12
@since   	14/06/2022
@return  	nRet -> Retorna a quantidade de formas de pgto lançado na venda
/*/
//-------------------------------------------------------------------
Function STBGetPgto()

Local oMdl		:= STISetMdlPay() 	//Retorna o model dos pagamentos
Local oModel	:= Nil 				//Pega o modelo de Parcelas
Local nRet		:= 0 				//Variavel de retorno
Local nX		:= 0 				//Variavel de loop

If ValType(oMdl) == "O"
	oModel := oMdl:GetModel('APAYMENTS') 
	For nX := 1 To oModel:Length()
		oModel:GoLine(nX)
		If !oModel:IsDeleted() .AND. !Empty(oModel:GetValue("L4_FORMA"))

			nRet++

			If IsMoney(oModel:GetValue("L4_FORMA"))
				cFormaPg := oModel:GetValue("L4_FORMA")
			EndIf

		EndIf
	Next nX

EndIf

Return nRet

/*/{Protheus.doc} STBSetDesc
	Reiniciar a variavel lDescReg depois da finalização da venda
	@type  Function
	@author Varejo
	@since 14/10/2022
	@version P12
	@param lValue, lógico, reinicia a variavel lDescReg
	@return
/*/
Function STBSetDesc(lValue)
Default lValue := .F.
lDescReg := lValue
Return

/*/{Protheus.doc} STBConfReg
	Função para confirmar se o grupo do cliente é o mesmo que esta na regra
	@type  Function
	@author Varejo
	@since 19/10/2022
	@version P12
	@param cCodCli, caractere, codigo do cliente
	@param cLojCli, caractere, loja do cliente
	@param cCodReg, caractere, codigo da regra de desconto
	@return lRet, lógico, .T. se caso o cliente e regra forem do mesmo grupo de vendas, e .F. se for diferente.
/*/
Static Function STBConfReg(cCodCli, cLojCli, cCodReg)
Local lRet := .F.
Local aArea := GetArea()

DbSelectArea("SA1")
SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
If SA1->(dbSeek(xFilial("SA1") + PadR(cCodCli, TamSX3("A1_COD")[1]) + PadR(cLojCli,TamSX3("A1_LOJA")[1])))

	DbSelectArea("MEI")
	MEI->(DbSetOrder(1)) //MEI_FILIAL+MEI_CODREG
	If MEI->(dbSeek(xFilial("MEI") + PadR(cCodReg, TamSX3("MEI_CODREG")[1])))

		If AllTrim(SA1->A1_GRPVEN) == AllTrim(MEI->MEI_GRPVEN)
			lRet := .T.
		EndIf

	EndIf
EndIf

RestArea(aArea)

Return lRet
