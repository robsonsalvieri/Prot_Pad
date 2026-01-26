#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"  
#INCLUDE "STPOS.CH"    
#INCLUDE "STBRULESDISCOUNTPAY.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} STBPayRlDi
Function Regra de Desconto Pagamento

@param 	nValueTotal		Valor Total da Venda
@param 	nValueBalancePay	Valor Pagamento
@param 	cFormPay			Forma Pagamento
@param		aAllPay			Array com todos pagamentos
@param 	cCliCode			Codigo do Cliente
@param 	cCliStore			Loja do Cliente        
@author  Varejo
@version P11.8
@since   29/03/2012
@return  Aret[1]  	lApplyRule				// Aplica regra
@return  Aret[2]	  nNewValueTotal			// Valor total
@return  Aret[2]    nTotValueDiscount 	// Valor Total de desconto
@return  Aret[2]   nDiscPerTotal 			// Percentual de desconto
@return  Aret[2]   nValueTotal 			// Valor Total
@return  Aret[2]   aNewAllPay 			// Array com todos pagamentos
@obs     					
@sample
/*/
//-------------------------------------------------------------------



Function STBPayRlDi( 	nValueTotal	, nValueBalancePay 	, cFormPay , aAllPay , ;
					 		cCliCode  		, cCliStore 		)
				 	
Local aRet					:= {}			// Retorno da Funcao
Local lApplyRule				:= .F.			// Aplicou alguma Regra de Desconto?  
Local lIsProportional		:= .F.			// Indica se a Regra eh proporcional
Local lFormsOk				:= .T.			// Verifica se TODAS as formas de pagamento da venda estao na regra (NAO PROPORCIONAL)
Local nNewValueTotal			:= 0			// Novo Total. Desconto aplicado
Local nValueDiscount			:= 0			// Valor do desconto que foi aplicado
Local nDiscPerTotal			:= 0			// Percentual total do desconto pela(s) regras(s). Pode ocorrer mais de uma regra.
Local nTotValueDiscount		:= 0			// Valor total dos descontos aplicados acumulados
Local nTotPay					:= 0			// Valor total dos pagamentos passados no aAllPay
Local aNewAllPay				:= {}			// Array de pagamentos baseado no passado por parâmetro com os valores modificados para o ultimo pagamento(coloca o desconto no ultimo)
Local aRules					:= {}			// Regras de Desconto no Total 
Local aRange					:= {}			// Range de valores da Regra
Local aForms					:= {}			// Formas de Pagamento da Regra
Local aFormsOK				:= {}			// Formas de pagamento utilizadas na venda que estao na regra e serao aplicadas
Local aAppRules				:= {}			// Armazena Informacoes das Regras Aplicadas
Local nPosForm				:= 0			// Armazena posicao da forma de pagamento
Local nJ						:= 0			// Contador
Local nI						:= 0 			// Contador
Local nX						:= 0			// Contador 
Local nY			  			:= 0			// Contador
				 
Default nValueTotal    	:= 0					
Default nValueBalancePay 	:= 0
Default cFormPay   	  		:= ""
Default aAllPay 	  			:= {}
Default cCliCode 	 		:= ""					
Default cCliStore 	 		:= ""	
   
ParamType 0 Var nValueTotal			AS Numeric		Default 0
ParamType 1 Var nValueBalancePay 	AS Numeric		Default 0
ParamType 2 Var cFormPay   		AS Character	Default ""
ParamType 3 Var aAllPay 			AS Array		Default {}
ParamType 4 Var cCliCode   		AS Character	Default ""
ParamType 5 Var cCliStore  		AS Character	Default ""
    
nNewValueTotal := nValueTotal

If nValueTotal >= 0.01
	
	aRules := STDTotRlDi( cCliCode	, cCliStore , .T. )
	
	If Len(aRules) > 0 
	
		/*/	
			Ordena o array pelo segundo campo MEJ->MEJ_PRINUM (Prioridades)
		/*/ 
		aRules := aSort(aRules,,,{|x,y| x[MEJ_PRINUM] < y[MEJ_PRINUM]}) 
		
		For nI := 1 To Len( aRules )
		
			/*/	
				Busca o Range da Regra
			/*/ 
		 	aRange := STDRangRul( aRules[nI][MEI_CODREG] )
		 	/*/	
				Busca as Formas de Pagamento
			/*/
			aForms := STDPayForms( aRules[nI][MEI_CODREG] )
			/*/	
				Verifica se eh proporcional
			/*/ 
		 	lIsProportional := STDPropForm( aRules[nI][MEI_CODREG] )			 	 	
		 	
		 	For nJ:= 1 To Len( aRange )						
				
				If nValueTotal >= aRange[nJ][MB2_VLRINI] .AND. nValueTotal <= aRange[nJ][MB2_VLRFIM] // Valida Range
					
					If lIsProportional // PROPORCIONAL
						
						/*/	
							Verifica se a forma de pagamento utilizada na venda pertence a regra
						/*/ 
						For nX:=1 To Len( aAllPay ) 
						   
					   		nPosForm := aScan( aForms, {|x| x == aAllPay[nX][2] }) 
					   		
					   		If nPosForm > 0 
					   		
					   			AADD( aFormsOK , aAllPay[nX][2] ) // Formas de pagamento que estao na venda e no cadastro da regra
					   		
					   		EndIf
					   		
					   	Next nX
					   	                      
					 	/*/	
							Aplicar a regra para as formas validas
						/*/ 						   		    
      					For nY:=1 To Len( aFormsOK )					   		
			   		        
							nPosForm := aScan( aAllPay, {|x| x[2] == aFormsOK[nY] })
			   		
							Do Case               
							
								Case aRange[nJ][MB2_PDESC] > 0 // PERCENTUAL																
									
						   			lApplyRule := .T. 
						   			/*/	
										Realizar calculos						   			
									/*/ 
									aAllPay[nPosForm][1] 	:= aAllPay[nPosForm][1]
						   			nValueDiscount 	   		:= aAllPay[nPosForm][1] * ( aRange[nJ][MB2_PDESC] / 100 )
						   			nTotValueDiscount 		:= nTotValueDiscount + nValueDiscount
						   			nNewValueTotal 	  		:= nNewValueTotal - nValueDiscount
						   			
						   			AADD( aAppRules , { aRules[nI] , aRange[nJ] } )							   			
									
								Case aRange[nJ][MB2_VLRFX] > 0 // VALOR
								
									If 	!((aAllPay[nPosForm][1] - aRange[nJ][MB2_VLRFX]) < 0.01)
									
										lApplyRule := .T.
							   			/*/	
											Realizar calculos						   			
										/*/ 						   			
							   			nValueDiscount 		:= aRange[nJ][MB2_VLRFX]
							   			nTotValueDiscount	:= nTotValueDiscount + nValueDiscount
							   			nNewValueTotal 		:= nNewValueTotal - nValueDiscount						   			
							   			
							   			AADD( aAppRules , { aRules[nI] , aRange[nJ] } )
							   			
									EndIf									
						   EndCase 
						    	
						Next nY						
						   		
								
               Else // NAO PROPORCIONAL
			  			/*/	
							Para Regra NAO PROPORCIONAL, TODAS as formas do pagamento da VENDA devem estar cadastradas na Regra
						/*/
						lFormsOk := .T. // Volta para o Default
						
						For nX:=1 To Len( aAllPay ) 
						   
					   		nPosForm := aScan( aForms, {|x| x == aAllPay[nX][2] }) 
					   		
					   		If nPosForm == 0 
					   		
								lFormsOk := .F.
								Exit
					   		  
					   		EndIf
					   		
					   	Next nX 
					   	
					   	If lFormsOk // Todas as formas estao na venda
					   		/*/	
								Calculo dos valores da regra. (Acumulativo para mais de uma regra)
							/*/ 											
							Do Case
								Case aRange[nJ][MB2_PDESC] > 0 // PERCENTUAL
																
									If !((nNewValueTotal - (nNewValueTotal * (aRange[nJ][MB2_PDESC] / 100 ))) < 0.01)
									
							   			lApplyRule := .T. 
							   			/*/	
											Realizar calculos sempre por valor						   			
										/*/ 
							   			nValueDiscount 		:= nNewValueTotal * ( aRange[nJ][MB2_PDESC] / 100 )
							   			nTotValueDiscount 	:= nTotValueDiscount + nValueDiscount
							   			nNewValueTotal 		:= nNewValueTotal - nValueDiscount
							   			
							   			AADD( aAppRules , { aRules[nI] , aRange[nJ] } )
							   			
						   			EndIf
									
								Case aRange[nJ][MB2_VLRFX] > 0 // VALOR
								
									If !(aRange[nJ][MB2_VLRFX] > nNewValueTotal) .AND. !((nNewValueTotal - aRange[nJ][MB2_VLRFX]) < 0.01)
									
										lApplyRule := .T.
							   			/*/	
											Realizar calculos sempre por valor						   			
										/*/ 						   			
							   			nValueDiscount 		:= aRange[nJ][MB2_VLRFX]
							   			nTotValueDiscount	:= nTotValueDiscount + nValueDiscount
							   			nNewValueTotal 		:= nNewValueTotal - nValueDiscount						   			
							   			
							   			AADD( aAppRules , { aRules[nI] , aRange[nJ] } )
							   			
									EndIf
									
					    	EndCase
					    	
					    EndIf					   		
					 	
					EndIf
					
				EndIF
				
			Next nJ
			
			// Se acumulativo nao verifica as demais				
			If lApplyRule .AND. aRules[nI][MEI_ACUMUL] == "N"
				Exit
			EndIf

        Next nI
	EndIf
EndIf

If lApplyRule
			
	nDiscPerTotal := ( nTotValueDiscount * 100 ) / nValueTotal // Percentual total depois da(s) regras(s) aplicadas 
	
	For nI:=1 To Len( aAllPay )
	
		nTotPay := nTotPay + aAllPay[nI][1]
		
	Next nI
			
	aNewAllPay := aClone(aAllPay)
	
	/*/	
		Joga a diferenca no ultimo pagamento informado
   	/*/ 
	aNewAllPay[Len(aNewAllPay)][1] := aNewAllPay[Len(aNewAllPay)][1] - (( nTotPay + nTotValueDiscount ) - nValueTotal		)				
	
	If STFGetCfg("lRuleDiscShow") //Se mostra regras aplicadas!!!
		
		STFMessage("STPayRlDi","ALERT", STR0001)  //"Regra de Desconto: Aplicado desconto no total segundo a(s)s seguinte(s) regra(s): "
		
		For nI:=1 To Len(aAppRules)
		
			STFMessage("STPayRlDi","ALERT",STR0002  + aAppRules[nI][1][4] ) // "Regra de Desconto: "
			
		Next nI
		
	EndIf
	
Else				

	//Se nao aplicou nenhuma regra, ver sugestao
		   		  
EndIf

AADD( aRet , lApplyRule 		)
AADD( aRet , nNewValueTotal 	)
AADD( aRet , nTotValueDiscount 	)
AADD( aRet , nDiscPerTotal 		)
AADD( aRet , nValueTotal 		)
AADD( aRet , aNewAllPay 		)	

STFShowMessage("STPayRlDi")	
	
Return  aRet 
