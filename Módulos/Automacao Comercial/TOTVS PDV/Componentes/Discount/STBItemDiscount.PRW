#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "STPOS.CH"   
#INCLUDE "STBITEMDISCOUNT.CH"
Static lDescOK := .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} STBIDUser
Desconto via usuário

@param   nItemLine		Linha do item
@param   cTime			Indica momento de realizar o desconto
@param   lItemFiscal	Indica se o item pertence ao cupom fiscal
@author  Varejo
@version P11.8
@since   23/05/2012
@return  lRet				Retorna se o desconto pode ser concedido
@obs						
@sample
/*/
//-------------------------------------------------------------------
Function STBIDUser( nItemLine , cTime , lItemFiscal, cCodSup )

Local lRet				:= .F.			// Retorna se efetuou desconto
Local aDiscount			:= {}			// Armazena Valor e tipo de desconto via usuário
Local lContinue			:= .T.			// Fluxo função

Default nItemLine 		:= 0
Default cTime		 		:= ""
Default lItemFiscal 		:= .F.

ParamType 0	Var  nItemLine	As Numeric 	Default 0
ParamType 1	Var  cTime			As Character 	Default ""
ParamType 2	Var  lItemFiscal 	As Logical 	Default .F.

If Empty(cTime)
	cTime := STDIDTime()
EndIf

Do Case
	/*/
		Desconto Antes/Junto do Item
	/*/
	Case cTime == "A"
	
		/*/
			Get do desconto dado via usuário
		/*/
		aDiscount := STBGetItDiscount()
					
		/*/
			Validação
		/*/
		If lContinue
							
			lContinue 	:= STBIDValid( nItemLine , aDiscount[1] , aDiscount[2] , .T. ,; 
										 "A" 	, ,  				@cCodSup )
							
		EndIf
		
		
		/*/
			Aplicar desconto
		/*/
		If lContinue
			
			lRet := STBIDApply( nItemLine , aDiscount[1] , aDiscount[2] , lItemFiscal ,; 
									"A" )
								
		EndIf
		
	/*/
		Desconto depois de registrado o Item
	/*/
	Case cTime == "D"

		/*/
			Get do desconto dado via usuário
		/*/
		aDiscount := STBGetItDiscount()
		
		/*/
			Validação
		/*/
		lContinue 	:= STBIDValid( nItemLine , aDiscount[1] , aDiscount[2] , .T. ,; 
									"D"		, , 			 @cCodSup )
		
		/*/
			Aplicar desconto
		/*/				
		If lContinue
			
			/*/
				Procura saber se o item é fiscal. Caso positivo deve mandar desconto para impressora fiscal
			/*/
			lItemFiscal := STDGPBasket( "SL2" , "L2_FISCAL" , nItemLine )
			
			lRet := STBIDApply( nItemLine , aDiscount[1] , aDiscount[2] , lItemFiscal ,; 
									"D" )
			
		EndIf					
	
EndCase
			
// Seta variavel de permissao de desconto
lDescOK := lRet
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBIDValid
Efetua validacao do desconto

@param   nItemLine		Linha do Item
@param   nValDesc			Valor do desconto 
@param   cTypeDesc		Tipo do desconto. P - Percentual, V - Valor 
@param   lValUser			Indica se valida permissões do caixa.
@param   cTime			Indica momento de realizar o desconto
@param   nItemTotal		Total do Item. Quantidade * Valor unitário 
@author  Varejo
@version P11.8
@since   23/05/2012
@return  lRet				Retorna se o desconto pode ser concedido
@obs						
@sample
/*/
//-------------------------------------------------------------------
Function STBIDValid( 	nItemLine 		, nValDesc 	 , cTypeDesc , lValUser	, ;
						cTime			, nItemTotal , cCodSup                ) 

Local lRet				:= .T.					// Retorna se o desconto pode ser concedido
Local nPercDesc			:= 0					// Percentual do desconto
Local nValueDisc		:= 0 					// Valor do desconto
Local nAux				:= 0					// Variavel auxiliar
Local aRet				:= {} 

Default nItemLine 		:= 0
Default nValDesc 		:= 0
Default cTypeDesc 		:= ""
Default lValUser 		:= .T.
Default cTime 			:= ""
Default nItemTotal 		:= 0

ParamType 0 Var nItemLine 		As Numeric   	Default 0 
ParamType 1 Var nValDesc 		As Numeric   	Default 0
ParamType 2 Var cTypeDesc 		As Character 	Default ""
ParamType 3 Var lValUser 		As Logical	 	Default .T.
ParamType 4 Var cTime 			As Character 	Default ""
ParamType 5 Var nItemTotal 		As Numeric 		Default 0

Do Case
	
	/*/
		Antes/junto com registro do item
	/*/
	Case cTime == "A" 

		If ( nValDesc <= 0 )	.OR. !( cTypeDesc $ "V|P" )
			
			lRet := .F.
		
		EndIf

		If lRet
			
			If nItemTotal <= 0
				nItemTotal := STBTaxRet( nItemLine , "IT_PRCUNI"	) * STBTaxRet( nItemLine , "IT_QUANT"	)
			EndIf
			
			If cTypeDesc == "V"
				If nValDesc >= nItemTotal		// Desconto maior que valor total do Item?						
					lRet := .F.
					STFMessage("STBIDValid","STOP", STR0001) //"Valor do desconto maior que o valor do Item. Desconto não concedido."							
				EndIf
			EndIf
			
		EndIf
		
		If lRet
			
			/*/
				Validacao usuario, permissao do caixa
			/*/
			If lValUser
			
				Do Case    
				                          
					Case cTypeDesc = "P"
						/*/
							Procura saber qual o VALOR do total corresponde ao PERCENTUAL desejado
						/*/
						nAux := nItemTotal * ( nValDesc / 100 )
						
						nValueDisc := nAux
						nPercDesc := nValDesc			
			
					Case cTypeDesc = "V"
						/*/
							Procura saber qual o PERCENTUAL do total corresponde ao VALOR desejado
						/*/
						nAux := ( nValDesc / nItemTotal ) * 100
						
						nValueDisc := nValDesc
						nPercDesc := nAux
					
				EndCase
			
			
				aRet := STFPROFILE(	11 			, NIL , nPercDesc , nValueDisc , ;
										"I"		 								)
				lRet 	:= aRet[1]
				cCodSup := aRet[3]

			EndIf
	
		EndIf
	
	/*/
		Depois do item registrado
	/*/
	Case cTime == "D" 
		
		If nItemTotal <= 0
			nItemTotal := STBTaxRet( nItemLine , "IT_PRCUNI"	) * STBTaxRet( nItemLine , "IT_QUANT"	)
		EndIf
		
		If nValDesc >= nItemTotal		// Desconto maior que valor total do Item?
				
			lRet := .F.
			STFMessage("STBIDValid","STOP", STR0001) //"Valor do desconto maior que o valor do Item. Desconto não concedido."
					
		EndIf
		
		If lRet
			
			Do Case
				
				/*/
					Indica que solicitou zerar o desconto
				/*/
				Case ( nValDesc == 0 )	.AND. ( cTypeDesc $ "V|P" )

					/*/
						Caso já teve desconto no Item, pode zerar
					/*/
					If STBTaxRet( nItemLine , "IT_DESCONTO" ) > 0
					
						lRet := .T.
						
						/*/
							Chamada Delecao do Motivo de Desconto
						/*/
						STDDelReason( nItemLine )
						
					Else					
						lRet := .F.						
					EndIf
				
				/*/
					Indica que nao informou desconto algum
				/*/	
				Case ( nValDesc <= 0 )	.AND. !( cTypeDesc $ "V|P" )
				
					lRet := .F.
				
				/*/
					Indica que informou desconto
				/*/					
				Case ( nValDesc > 0 )	.AND. ( cTypeDesc $ "V|P" )
			
					If lValUser
						
						Do Case    
						                          
							Case cTypeDesc = "P"
								/*/
									Procura saber qual o VALOR do total corresponde ao PERCENTUAL desejado
								/*/
								nAux := nItemTotal * ( nValDesc / 100 )
								
								nValueDisc := nAux
								nPercDesc := nValDesc			
					
							Case cTypeDesc = "V"
								/*/
									Procura saber qual o PERCENTUAL do total corresponde ao VALOR desejado
								/*/
								nAux := ( nValDesc / nItemTotal ) * 100
								
								nValueDisc := nValDesc
								nPercDesc := nAux
							
						EndCase
				
						aRet := STFPROFILE( 11 , NIL , nPercDesc , nValueDisc	, "I" )
						
						lRet 	:= aRet[1]
						cCodSup := aRet[3]

						
					EndIf
					
			EndCase
			
		EndIf

EndCase
	
STFShowMessage("STBIDValid")		
					 
Return lRet 


//-------------------------------------------------------------------
/*/{Protheus.doc} STBIDApply
Aplica desconto no Item

@param   nItemLine		Linha do Item
@param   nValDesc			Valor do desconto 
@param   cTypeDesc		Tipo do desconto. P - Percentual, V - Valor 
@param   lItemFiscal		Indica se registra o item na impressora fiscal
@param   cTime			Indica momento de realizar o desconto
@param   nItemTotal		Total do Item. Valor unitário * Quantidade 
@author  Varejo
@version P11.8
@since   23/05/2012
@return  lRet				Retorna se o desconto foi aplicado
@obs						
@sample
/*/
//-------------------------------------------------------------------
Function STBIDApply( 	nItemLine	, nValDesc 	, cTypeDesc , lItemFiscal, ; 
						cTime		, nItemTotal, lRgDescVrj )

Local lRet				:= .T.		// Retorna se o desconto foi aplicado
Local nDiscount			:= 0		// Valor do Desconto
Local nPercDiscount		:= 0		// Percentual do Desconto
Local nAux				:= 0		// Variável auxiliar
Local aRetDiscPrint		:= {}		// Armazena retorno desconto na impressora
Local lCRdesItTt 		:= SuperGetMv("MV_LJRGDES",,.F.) .AND. SuperGetMV("MV_LJCRDPT",,"0") == "1" .AND. FindFunction("totvs.protheus.retail.desconto.RegraDescProdutoTotal.LjCallCalcRegDescProdTotal", .T.)	// Verifica se o calculo do desconto por item esta sendo feito no final da venda
Local lDesligaRD		:= .F.		// Desabilita a Regra de Desconto do Varejo

Default nItemLine 		:= 0
Default nValDesc 		:= 0
Default cTypeDesc 		:= ""
Default lItemFiscal 	:= .F.
Default cTime 			:= ""
Default nItemTotal 		:= 0
Default lRgDescVrj		:= .F.

ParamType 0 Var nItemLine 		As Numeric   	Default 0 
ParamType 1 Var nValDesc 		As Numeric   	Default 0
ParamType 2 Var cTypeDesc 		As Character 	Default ""
ParamType 3 Var lItemFiscal		As Logical	 	Default .F.
ParamType 4 Var cTime 			As Character 	Default ""
ParamType 5 Var nItemTotal		As Numeric 	Default 0

If nItemTotal <= 0
	nItemTotal := STBTaxRet( nItemLine , "IT_PRCUNI"	) * STBTaxRet( nItemLine , "IT_QUANT"	)	
EndIf 

If FindFunction("totvs.protheus.retail.desconto.RegraDescProdutoTotal.HasDescManu", .T.)
	lDesligaRD := totvs.protheus.retail.desconto.RegraDescProdutoTotal.HasDescManu("TOTVSPDV", STDGPBasket('SL1','L1_NUM'), STDGPBasket('SL1','L1_CLIENTE'), STDGPBasket('SL1','L1_LOJA'))
EndIf

Do Case    
				                          
	Case cTypeDesc = "P"
		/*/
			Procura saber qual o VALOR do total corresponde ao PERCENTUAL desejado
		/*/
		nAux := nItemTotal * ( nValDesc / 100 )
		
		nDiscount		:= STBArred(nAux)
		nPercDiscount	:= STBRound( nValDesc , 2 )

	Case cTypeDesc = "V"
		/*/
			Procura saber qual o PERCENTUAL do total corresponde ao VALOR desejado
		/*/
		nAux := ( STBArred(nValDesc) / nItemTotal ) * 100
		
		nDiscount		:= STBArred(nValDesc)
		nPercDiscount	:= STBRound( nAux , 2 )
	
EndCase

/*/
	Não realizar desconto no item 2 vezes pra item fiscal(impresso em cupom fiscal)
/*/
If lItemFiscal .AND. cTime == "D" .AND. STBTaxRet( nItemLine , "IT_DESCONTO" ) > 0	
	lRet := .F.
	STFMessage("STBIDApply","ALERT", STR0002) //"Só é possível aplicar desconto no item apenas uma vez"	
Else	
	lRet := .T.	
EndIf

/*/
	Aplica desconto
/*/
If lRet
				
	lRet := STBTaxAlt(	"IT_DESCONTO" ,	nDiscount ,	nItemLine )
	
EndIf

/*/
	Depois do item registrado, se o item for fiscal, registrar desconto na impressora
/*/
If lRet

	If cTime == "D"
	
		If lItemFiscal
		   	
		   	aRetDiscPrint := STFFireEvent(	ProcName(0)						,;		// Nome do processo
											"STItemReg"						,;		// Nome do evento
											{Nil							,;		// 01 - Codigo do Item
											Nil								,; 		// 02 - Descricao
											Nil								,;		// 03 - Quantidade
											Nil								,;		// 04 - Valor Unitario	
											AllTrim(STR(nDiscount))			,;		// 05 - Desconto do Item
											Nil 					    	,;		// 06 - Situacao tributaria
											Nil						  		,;		// 07 - Total do Item
											Nil 							,; 		// 08 - Unidade de Medida
											Nil 							} )		// 09 - TIPO TES ( 2 - Saida )
							
			/*/
				Valida Retorno da impressora
			/*/
			If ValType(aRetDiscPrint) == "A" .AND. Len(aRetDiscPrint) > 0 .AND. aRetDiscPrint[1] <> 0
			    
				lRet := .F.
				STBTaxAlt( "IT_DESCONTO" , 0 , nItemLine )
				STFMessage("STBIDApply","ALERT",STR0003 ) //"Não foi possível registrar o desconto no item na impressora, o desconto será desconsiderado."	
				
			EndIf
			
		EndIf
		
		/*/
			Atualizar valores da cesta se o item já foi registrado.
		/*/ 
		STBRefshItBasket( nItemLine, , lRgDescVrj ) // OBS: Caso for Antes de registrar já atualiza no registro de item
		
		If lCRdesItTt .AND. !lDesligaRD
			STDSaveSale(nItemLine)
		EndIf
	EndIf

EndIf

STFShowMessage("STBIDApply")

Return lRet 


//-------------------------------------------------------------------
/*/{Protheus.doc} STBIDBothApply
Aplica Desconto de Regra de Desconto e de Usuário. Desconto sobre desconto

@param   nItemLine		Linha do Item
@param   aRuleDiscount	Array desconto via Regra de Desconto 
@param   aDiscount		Array Desconto via Usuário 
@param   lItemFiscal		Indica se registra o item na impressora fiscal
@param   cTime			Indica momento de realizar o desconto 
@author  Varejo
@version P11.8
@since   23/05/2012
@return  lRet				Retorna se o desconto foi aplicado
@obs						
@sample
/*/
//-------------------------------------------------------------------
Function STBIDBothApply( 	nItemLine , aRuleDiscount , aDiscount , lItemFiscal , ;
								cTime														)

Local lRet				:= .F.		// Retorna se o desconto foi aplicado
Local nDiscount			:= 0		// Valor do Desconto
Local nPercDiscount		:= 0		// Percentual do Desconto
Local nAux				:= 0		// Variável auxiliar
Local nBothDiscount		:= 0		// Armazena os valores de desconto de regra e de usuário somados
Local nValDesc 		:= 0


Default nItemLine 		:= 0
Default aRuleDiscount 	:= 0
Default aDiscount 		:= ""
Default lItemFiscal 		:= .F.
Default cTime 			:= ""

ParamType 0 Var nItemLine 		As Numeric   	Default 0 
ParamType 1 Var aRuleDiscount 	As Array	   	Default {}
ParamType 2 Var aDiscount 		As Array	 	Default {}
ParamType 3 Var lItemFiscal		As Logical	 	Default .F.
ParamType 4 Var cTime 			As Character 	Default ""


If 	aRuleDiscount[LRULEAPPLY] .AND. ( aDiscount[1] >= 0 	) .AND. ( aDiscount[2] $ "V|P" 	)
	/* Igual a zero pq pode ser que queira zerar o desconto de usuário */
	lRet := .T.
	
EndIf


If lRet
		
	/*/
		Calcular o desconto via usuário em relação ao desconto via regra
	/*/
	Do Case    
		                          
		Case aDiscount[2] = "P"
			/*/
				Procura saber qual o VALOR do total corresponde ao PERCENTUAL desejado
			/*/
			nAux := aRuleDiscount[NNEWTOTAL] * ( aDiscount[1] / 100 )
			
			nDiscount		:= nAux
			nPercDiscount	:= nValDesc
	
		Case aDiscount[2] = "V"
			/*/
				Procura saber qual o PERCENTUAL do total corresponde ao VALOR desejado
			/*/
			nAux := ( aDiscount[1] / aRuleDiscount[NNEWTOTAL] ) * 100
			
			nDiscount		:= aDiscount[1]
			nPercDiscount	:= nAux
		
	EndCase

	nBothDiscount := nDiscount + aRuleDiscount[NDESCTOTAL]
	
	If cTime == "D"
	
		/*/
			Procura saber se o item é fiscal. Caso positivo deve mandar desconto para impressora fiscal
		/*/
		lItemFiscal := STDGPBasket( "SL2" , "L2_FISCAL" , nItemLine )
		
	EndIf
	
	
	lRet := STBIDApply( 	nItemLine	, nBothDiscount 	, "V" , lItemFiscal	, ; 
							cTime		, 											)
	
EndIf


Return lRet 		
			
//-------------------------------------------------------------------
/*{Protheus.doc} STBValidDesc
Retorna se desconto pode ser concedido 

@param   	lRet			.T. 
@author  	Vendas & CRM
@version 	P11
@since   	14/12/2015
@return  	lRet
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBValidDesc(lRet)
DEFAULT lRet := .T.

lRet := lDescOK

Return lRet 	

//-------------------------------------------------------------------
/*{Protheus.doc} STBIDSet
Seta valor (.T. ou .F.) à variável lDescOK (default = .T.) 

@author  	Vendas
@version 	P12.1.23
@since   	30/04/2019
@sample
/*/
//-------------------------------------------------------------------
Function STBIDSet(lVal)
Default lVal :=.T. 

lDescOK := lVal

Return 

