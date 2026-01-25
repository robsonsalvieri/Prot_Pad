#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"   
#INCLUDE "STWNEXTSALEDISCOUNT.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} STWNxtSalD
Function Desconto na Próxima Venda

@param 	 cType		 			Tipo. I - Item , T - Total
@param 	 nItemLine			Numero do Item
@param 	 cItemCode				Código do produto
@param 	 nValue		  			Valor. Para I - Valor Total do Item , Para T - Valor Total
@param 	 nAmount				Quantidade
@param 	 cCodReg		  		Código da Regra
@param 	 nPerDiscount			Valor percentual do Desconto
@param 	 nValDiscount			Valor do Desconto
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lRet				Retorna se foi concedido desconto na próxima venda
@obs     					
@sample
/*/
//-------------------------------------------------------------------
Function STWNxtSalD( 	cType			, 	nItemLine 	, cItemCode		, nValue			, ;
							nAmount		, 	cCodReg		, nPerDiscount	, nValDiscount 		) 
											
Local lRet		   		:= .T.			// Foi concedido o desconto na próxima venda?								
Local nDiscount	   		:= 0			// Valor do desconto da Regra a ser gerada NCC
Local dEndDate	   		:= CTOD("")		// Data de validade da Regra. Mesma da NCC a ser gerada

Default cType  	   		:= ""	
Default nItemLine  		:= 0	
Default cItemCode 		:= ""
Default nValue	 		:= 0
Default nAmount  		:= 1
Default cCodReg   		:= ""
Default nPerDiscount  	:= 0
Default nValDiscount  	:= 0

ParamType 0 var  cType 			As Character	Default ""
ParamType 1 var  nItemLine 		As Numeric		Default 0
ParamType 2 var  cItemCode 		As Character	Default ""
ParamType 3 var  nValue 		As Numeric		Default 0
ParamType 4 var  nAmount  		As Numeric		Default 1
ParamType 5 var  cCodReg  		As Character	Default ""
ParamType 6 var  nPerDiscount	As Numeric		Default 0
ParamType 7 var  nValDiscount	As Numeric		Default 0
							
/*/	
	Verifica se a regra eh para desconto na proxima venda
/*/
lRet := STDNextSale( cCodReg )

If lRet
	
	dEndDate := STDRuleDate( cCodReg ) // Data de Validade Regra/NCC a gerar
	
	Do Case
	
		Case cType == "I"

  			If Empty(cItemCode)
				cItemCode	:= STBTaxRet( nItemLine , "IT_PRODUTO"	)		
			EndIf
			
			If Empty(nValue)
				nValue 		:= STBTaxRet( nItemLine , "IT_TOTAL"	)			
			EndIf
			
			If Empty(nAmount)
				nAmount 	:= STBTaxRet( nItemLine , "IT_QUANT"  	)
			EndIf			

			/*
  				Tratamento para buscar o valor do Desconto. ( Valor que sera gerada NCC )
  			*/
			Do Case
				Case nPerDiscount > 0 // PERCENTUAL
												
					nDiscount := STBArred( nValue * ( nPerDiscount / 100 ) )

				Case nValDiscount > 0 // VALOR
				
					nDiscount := nValDiscount * nAmount

				OtherWise 
					
					lRet := .F.					
	    	EndCase
	    
	    Case cType == "T" // TOTAL

			If Empty(nValue)
				nValue		:= STFSaleTotal()			
			EndIf

			/*
  				Tratamento para buscar o valor do Desconto. ( Valor que sera gerada NCC )
  			*/
			Do Case
				Case nPerDiscount > 0 // PERCENTUAL
												
					nDiscount := nValue * ( nPerDiscount / 100 )

				Case nValDiscount > 0 // VALOR
				
					nDiscount := nValDiscount

				OtherWise 
					
					lRet := .F.					
	    	EndCase
	    	
	    OtherWise 	    
	    	lRet := .F.
	    		    		    	
	EndCase
	
EndIf	    	

lRet := lRet .AND. ( nDiscount > 0 )

If lRet
	// Chamada armazenar no model o desconto na proxima venda
	If STDNxtSalAdd( 	cType 		, nItemLine , cItemCode , nValue , ;
	   					nDiscount 	, dEndDate	) 
		STFMessage("STNxtSalD","ALERT", STR0001 ) //"Adicionado Desconto na Próxima venda"
		STFMessage("STNxtSalD","ALERT", STR0002 ) // "Ao Finalizar a venda será gerada NCC"
		STFMessage("STNxtSalD","ALERT", STR0003 + cValToChar(nDiscount) )  //"Valor: "
		STFMessage("STNxtSalD","ALERT", STR0004 + DToC(dEndDate) ) //"Validade: "
	Else
		lRet := .F.
	EndIf
EndIf

STFShowMessage("STNxtSalD")

Return lRet 
   
