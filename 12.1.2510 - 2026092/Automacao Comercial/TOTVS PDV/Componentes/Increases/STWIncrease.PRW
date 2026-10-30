#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "STWINCREASE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} STWAddIncrease
Adiciona acréscimo

@param 	 nIncrease			Valor do Acréscimo
@param 	 nPercIncrease		Percentual do Juros Aplicado
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lRet - Indica se adicionou acrescimo
@sample
/*/
//-------------------------------------------------------------------
Function STWAddIncrease( nIncrease , nPercIncrease)  

Local lRet 				:= .F.																								// Indica se adicionou acrescimo
Local nTemAcrs			:= Iif(STIGetMult() .And. STBTaxRet(,"NF_ACRESCI") > 0, STBTaxRet(,"NF_ACRESCI") + nIncrease,0)		// Armazena o valor de acrescimo se já atribuido
Local nL1JUROS			:= 0 																								// Percentual de juros quando tem acrescimo já atribuido

Default nIncrease  		:= 0	
Default nPercIncrease  	:= 0	

ParamType 0 Var  nIncrease 		As Numeric	 Default 0
ParamType 1 Var  nPercIncrease		As Numeric	 Default 0

lRet :=  STBTaxAlt(	"NF_ACRESCI", Iif( nTemAcrs > 0, nTemAcrs, nIncrease))

If nTemAcrs > 0 
	nL1JUROS := STDGPBasket("SL1","L1_JUROS") + nPercIncrease
EndIf

STFSetTot( "L1_JUROS"        , 	Iif( nL1JUROS > 0, nL1JUROS, nPercIncrease))
STDSPBasket("SL1","L1_VLRJUR", 	Iif( nTemAcrs > 0, nTemAcrs, nIncrease	  ))

STFRefTot()

Return lRet 


//-------------------------------------------------------------------
/*/{Protheus.doc} STWGetIncrease
Busca Valor do acréscimo da venda

@param 	 
@author  Varejo
@version P11.8
@since   29/03/2012
@return  nIncrease			Retorna valor do acréscimo da venda
@sample
/*/
//-------------------------------------------------------------------
Function STWGetIncrease()  

Local nIncrease 		:= .F.					// Retorna valor acrescimo
Local oTotal 			:= STFGetTot()		// Model totalizador

nIncrease := oTotal:GetValue("L1_ACRSFIN")

Return nIncrease


//-------------------------------------------------------------------
/*/{Protheus.doc} STWPrintIncrease
Impressao do acréscimo

@param   nIncrease		Valor do acrescimo		 
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lRet			Retorna se registrou o acréscimo na impressora
@sample
/*/
//-------------------------------------------------------------------
Function STWPrintIncrease( nIncrease )  

Local lRet				:= .T.					// Retorna se registro acréscimo na impressora
Local aRetPrinter		:= {}					// Armazena retorno da impressora
Local oTotal 			:= STFGetTot()			// Totalizador
Local lItEntrega		:= STBTemEntr()			// Indica se a venda tem item de entrega

Default nIncrease  		:= 0	

ParamType 0 Var  nIncrease 		As Numeric	 Default 0

If STFUseFiscalPrinter()    

	If STWGetIsOpenReceipt() // Cupom Aberto?
		
		If nIncrease <= 0
		
			nIncrease :=	oTotal:GetValue(	"L1_ACRSFIN"	)	+ 	oTotal:GetValue(	"L1_FRETE"		)	+ ;
							oTotal:GetValue(	"L1_SEGURO"		)	+ 	oTotal:GetValue(	"L1_DESPESA"	)
							
		EndIf
		
		If nIncrease > 0

			If lItEntrega				
				nIncrease := STBNoRound( nIncrease * STBFactor(.F.)[1] )
			EndIf

			aRetPrinter := STFFireEvent(	ProcName(0)						,;		// Nome do processo
						   					"STPrintIncrease"				,;		// Nome do evento
						   					{AllTrim(Str(nIncrease,14,2))	})		// 01 - VALOR ACRESCIMO
						   					
			If Len(aRetPrinter) > 0 .AND. ValType(aRetPrinter[1]) == "N"
				
				If aRetPrinter[1] == 0					
					lRet := .T.					
				Else					
					lRet := .F.
					STFMessage("STIncrease","STOP",STR0001) //"Não foi possível registrar o Acréscimo no Total do Cupom. Operação não efetuada."					
				EndIf     
			
			Else 			    
				lRet := .F.
				STFMessage("STIncrease","STOP",STR0001) //"Não foi possível registrar o Acréscimo no Total do Cupom. Operação não efetuada."				
			EndIf
						
		Else		
			lRet := .T.			
		EndIf
		
	Else	
		lRet := .T.		
	EndIf
	
Else
	lRet := .T.
EndIf 			   					

STFShowMessage("STIncrease")

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWAddFreight
Adiciona Frete, Seguro e Despesa no totalizador

@author  Varejo
@version P11.8
@since   29/03/2012
@return  Nil
@sample
/*/
//-------------------------------------------------------------------
Function STWAddFreight(aSL2)

Default aSL2 := {}

/*/
	Adiciona no totalizador frete do tipo FOB, que será tratado como acréscimo no CUPOM FISCAL.
	Tipo CIF não adiciona no totalizador, apenas na cesta
/*/
If STDGPBasket( "SL1" , "L1_TPFRET" ) $ "CFTRD" // Tipo de frete. "F" -> FOB , "C" -> CIF, "T" -> Terceiros, "R" -> Próprio Remetente, "D" -> Próprio Destinatário		
	// Realiza o Rateio do Frete para SL2 
	If STDGPBasket('SL1', 'L1_FRETE') > 0 .OR. STDGPBasket('SL1', 'L1_SEGURO') > 0 .OR. STDGPBasket('SL1', 'L1_DESPESA') > 0
	   STWRecFret(aSL2,STDGPBasket('SL1', 'L1_FRETE'), STDGPBasket('SL1', 'L1_DESPESA'), STDGPBasket('SL1', 'L1_SEGURO')) 	
	   STWFreightRefsh()
    EndIf    
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} STWFreightRefsh
Atualiza Frete, Seguro e Despesa no totalizador

@param 
@author  Varejo
@version P11.8
@since   29/03/2012
@return  Nil
@sample
/*/
//-------------------------------------------------------------------
Function STWFreightRefsh()

Local oTotal      := STFGetTot()	// Model totalizador 
Local nFreDesSeg  := 0				// Valor Frete, Seguro e Despesa

STFSetTot( "L1_FRETE"   , STDGPBasket( "SL1" , "L1_FRETE"   ) )
STFSetTot( "L1_SEGURO"  , STDGPBasket( "SL1" , "L1_SEGURO"  ) )
STFSetTot( "L1_DESPESA" , STDGPBasket( "SL1" , "L1_DESPESA" ) )

nFreDesSeg := oTotal:GetValue("L1_FRETE") + oTotal:GetValue("L1_SEGURO") +  oTotal:GetValue("L1_DESPESA")

STFSetTot( "L1_VLRLIQ"	, oTotal:GetValue("L1_VLRTOT") 	+ nFreDesSeg 	   			    )
STFSetTot( "L1_VALBRUT"	, oTotal:GetValue("L1_VALMERC") + oTotal:GetValue("L1_ACRSFIN")	)
STFSetTot( "L1_VLRTOT"	, oTotal:GetValue("L1_VLRTOT")	+ nFreDesSeg 	   				) // Adiciona no VLRTOT por ultimo para nao duplicar
STFSetTot( "L1_VALICM"  , STBTaxRet(Nil ,"NF_VALICM") )

// Atualiza Total           
STFRefTot()

Return Nil

//-------------------------------------------------------------------
/* {Protheus.doc} STWRecFret
Calculo o valor do Frete,Seguro e Despesa

@author  Varejo
@version P12114
@since   31/01/2017
@return  lRet	-	Ok ou não ok?
@obs
@sample
*/
//-------------------------------------------------------------------

Static Function STWRecFret(aSl2,nTotFret,nTotDesp,nTotSegu)

Local nX            := 0
Local nPosEnt	    := 0    //Posicao campo entrega na SL2
Local nValItem      := 0    //Valor Item sem frete
Local nTotITEnt     := 0    //Total dos itens de entrega
Local nVlFrete      := 0    //Valor frete item
Local nVlDespe      := 0    //Valor despesas item
Local nVlSegur      := 0    //Valor seguro item
Local lEntrega      := .F.  //Flag para verificar se existe item de entrega
Local nDifFret      := 0    //Valor auxiliar de frete
Local nDifDesp      := 0    //Valor auxiliar de despesas
Local nDifSegu      := 0    //Valor auxiliar de seguro
Local nUltItEnt     := 0    //Ultimo item de entrega
Local nTotVenda     := 0    //Total da venda
Local nUltItVen     := 0    //Ultimo item da venda
Local nFreDesSeg    := 0    //Valor frete + despesas + seguro do item

If Len(aSL2) > 0 
	nPosEnt	:= AScan(aSL2[1] , {|x| x[1] == "L2_ENTREGA"})	
		
	//Verifico se nos itens possui algum item de entrega 
	If nPosEnt > 0 
		For nX := 1 to Len(aSL2)
            nFreDesSeg := STBTaxRet(nX,"IT_FRETE") + STBTaxRet(nX,"IT_SEGURO") + STBTaxRet(nX,"IT_DESPESA")
			
			If !LjIsTesISS(STDGPBasket("SL2", "L2_PRODUTO", nX), STDGPBasket("SL2", "L2_TES", nX)) //Nao rateia Frete/Seguro/Despesas para Servico			
				If aSL2[nX][nPosEnt][2] $ "3|5"
					lEntrega  := .T.
					nTotITEnt += STBTaxRet(nX,"IT_VALMERC") - nFreDesSeg
					nUltItEnt := nX
				Else
	                nTotVenda += STBTaxRet(nX,"IT_VALMERC") - nFreDesSeg
	                nUltItVen := nX
				EndIf
			EndIf	
		Next nX
	EndIf
		
	For nX := 1 to Len(aSL2)
    	nFreDesSeg := STBTaxRet(nX,"IT_FRETE") + STBTaxRet(nX,"IT_SEGURO") + STBTaxRet(nX,"IT_DESPESA")
    	nValItem := STBTaxRet(nX,"IT_VALMERC") - nFreDesSeg
    	    	
    	If !LjIsTesISS(STDGPBasket("SL2", "L2_PRODUTO", nX), STDGPBasket("SL2", "L2_TES", nX)) //Nao rateia Frete/Seguro/Despesas para Servico
	    	If lEntrega            
	            If aSL2[nX][nPosEnt][2] $ "1|2|4" //Se nao for entrega zero o valor do Frete, Seguro e Despesa
	    			STBTaxAlt("IT_FRETE"  , 0, nX)
	    			STBTaxAlt("IT_DESPESA", 0, nX)
	    			STBTaxAlt("IT_SEGURO" , 0, nX)
	    			
	    			Loop //Pula registro pois nao trata retira se houver itens de entrega
	            EndIf
	                        
	            nVlFrete := STBArred((nTotFret * (nValItem / nTotITEnt)))
	            nVlDespe := STBArred((nTotDesp * (nValItem / nTotITEnt)))
	            nVlSegur := STBArred((nTotSegu * (nValItem / nTotITEnt)))
	    	Else            
	            nVlFrete := STBArred((nTotFret * (nValItem / nTotVenda)))
	            nVlDespe := STBArred((nTotDesp * (nValItem / nTotVenda)))
	            nVlSegur := STBArred((nTotSegu * (nValItem / nTotVenda)))
	    	EndIf
					                				
			nDifFret += nVlFrete
			nDifDesp += nVlDespe
			nDifSegu += nVlSegur
		
			//Quando for o ultimo item, verifica se teve diferenca entre o valor total e o valor calculado		
			If (lEntrega .And. nX == nUltItEnt) .Or. (!lEntrega .And. nX == nUltItVen)  				
				nDifFret := nTotFret - nDifFret
				nDifDesp := nTotDesp - nDifDesp
				nDifSegu := nTotSegu - nDifSegu
				
				//Caso tenha diferença de arredondamento, é acertado no ultimo item.
				If nDifFret > 0 .And. Abs(nDifFret) <= 0.05 //Acumulado de frete maior que o conteudo armazenado na SL1, necessario diminuir  
	                nVlFrete += Abs(nDifFret) 
	            ElseIf nDifFret < 0 .And. Abs(nDifFret) <= 0.05 //Acumulado de frete menor que o conteudo armazenado na SL1, necessario aumentar
	                nVlFrete -= Abs(nDifFret)
	            EndIf
				
				If nDifDesp > 0 .And. Abs(nDifDesp) <= 0.05 //Acumulado de despesa maior que o conteudo armazenado na SL1, necessario diminuir  
	                nVlDespe += Abs(nDifDesp) 
	            ElseIf nDifDesp < 0 .And. Abs(nDifDesp) <= 0.05 //Acumulado de despesa menor que o conteudo armazenado na SL1, necessario aumentar
	                nVlDespe -= Abs(nDifDesp)
	            EndIf
				
				If nDifSegu > 0 .And. Abs(nDifSegu) <= 0.05 //Acumulado de seguro maior que o conteudo armazenado na SL1, necessario diminuir  
	                nVlSegur += Abs(nDifSegu) 
	            ElseIf nDifSegu < 0 .And. Abs(nDifSegu) <= 0.05 //Acumulado de seguro menor que o conteudo armazenado na SL1, necessario aumentar
	                nVlSegur -= Abs(nDifSegu)
	            EndIf																																					
			EndIf
				
			//Adiciona valores na Matxfis
			STBTaxAlt("IT_FRETE"  , nVlFrete ,nX)
	        STBTaxAlt("IT_DESPESA", nVlDespe ,nX)
	        STBTaxAlt("IT_SEGURO" , nVlSegur ,nX)                
			
			//Adiciona valores na cesta
			STDSPBasket("SL2", "L2_BASEICM", STBTaxRet(nX, "IT_BASEICM"), nX)
			STDSPBasket("SL2", "L2_VALICM" , STBTaxRet(nX, "IT_VALICM") , nX)
			STDSPBasket("SL2", "L2_VALFRE" , nVlFrete, nX)
	        STDSPBasket("SL2", "L2_DESPESA", nVlDespe, nX)
	        STDSPBasket("SL2", "L2_SEGURO" , nVlSegur, nX)
	        STDSaveSale(nX)
		EndIf                															
	Next nX	
	
	STDSPBasket("SL1", "L1_VALICM", STBTaxRet(, "NF_VALICM")) //Atualiza valor ICMS da SL1 na cesta												  
EndIf

Return Nil

//-------------------------------------------------------------------
/* {Protheus.doc} STWClearIncreaseMult
Zera o valor de acrescimo quando feita uma multinegociação.

@author  Nilson Sacchi Junior
@since   23/09/2025
@return  Nil
@obs
@sample
*/
//-------------------------------------------------------------------

Function STWClearIncreaseMult()

STBTaxAlt("NF_ACRESCI", 0)
STFSetTot("L1_JUROS",   0)
STDSPBasket("SL1","L1_VLRJUR", 0)

STFRefTot()

Return Nil
