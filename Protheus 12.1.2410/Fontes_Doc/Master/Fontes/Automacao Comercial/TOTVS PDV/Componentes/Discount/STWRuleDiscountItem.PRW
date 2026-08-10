#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"   


//-------------------------------------------------------------------
/*/{Protheus.doc} STWRuleItem
Function Regra de Desconto Item

@param 	 nItemLine			Número do Item
@param 	 cItemCode			Codigo Produto
@param 	 nValueItem			Valor
@param 	 nAmount				Quantidade
@param 	 cTypeProd			Tipo do Produto Mostruario/Saldao
@param 	 cCliCode			Código do Cliente
@param 	 cCliStore			Codigo da Loja
@author  Varejo
@version P11.8
@since   29/03/2012
@return  aRet					Retorna informações da Regra
@obs     					
@sample
/*/
//-------------------------------------------------------------------
Function STWRuleItem( 	nItemLine	, cItemCode 	, nValueItem 	, nAmount 		, ;
							cTypeProd	, cCliCode		, cCliStore					)
						
Local aArea	  		:= GetArea()			// Armazena area corrente
Local aRet	 		:= {}					// Retorno funcao
Local nItemTotal		:= 0					// Valor Unitário * Quantidade

Default nItemLine 	:= 0	
Default cItemCode 	:= ""	
Default nValueItem 	:= 0
Default nAmount 		:= 0
Default cTypeProd 	:= ""
Default cCliCode 	:= ""
Default cCliStore 	:= ""

ParamType 0 Var  nItemLine 	As Numeric		Default 0
ParamType 1 Var  cItemCode 	As Character	Default ""
ParamType 2 Var  nValueItem 	As Numeric		Default 0
ParamType 3 Var  nAmount		As Numeric		Default 0
ParamType 4 Var  cTypeProd		As Character	Default ""
ParamType 5 Var  cCliCode		As Character	Default ""
ParamType 6 Var  cCliStore		As Character	Default ""

/*/
	Get das variáveis
/*/
If Empty(cItemCode)
	cItemCode 	:= STBTaxRet( nItemLine , "IT_PRODUTO"	)
EndIf

If Empty(nValueItem)
	nValueItem 	:= STBTaxRet( nItemLine , "IT_PRCUNI"	)
EndIf

If Empty(nAmount)
	nAmount 	:= STBTaxRet( nItemLine , "IT_QUANT"  	)
EndIf

If Empty(nItemTotal)
  nItemTotal 	:= STBTaxRet( nItemLine , "IT_TOTAL"	) 
EndIf

If Empty(cTypeProd)
	// TODO: Pegar se o produto é mostruário/Saldão. Nao foi feito ainda nessa fase
EndIf

If Empty(cCliCode)
	cCliCode := STDGPBasket( "SL1" , "L1_CLIENTE" )
EndIf

If Empty(cCliStore)
	cCliStore := STDGPBasket( "SL1" , "L1_LOJA" )
EndIf

If SuperGetMv("MV_LJRGDES",,.F.) // "Nova" Regra de Desconto ( Regra do LOJA )
 				 
	aRet := STBItemRlDi( 	nItemLine	, cItemCode 	, nValueItem 	, nAmount , ;
								cTypeProd	, cCliCode		, cCliStore				)

Else

	AADD( aRet , .F. )
		
EndIf

RestArea( aArea )

Return aRet



