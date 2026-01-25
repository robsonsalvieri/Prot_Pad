#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"   
#INCLUDE "STPOS.CH" 
#INCLUDE "STWRULEDISCOUNTTOTAL.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} STWRuleTotal
Function Regra de Desconto Total

@param 	 nValueTotal		Valor total da venda
@param 	 cCliCode			Codigo Cliente
@param 	 cCliStore			Loja Cliente
@author  Varejo
@version P11.8
@since   29/03/2012
@return  aRet[1]	   	 1 // Alguma regra foi aplicada?
@return  aRet[2]	   		2 // Valor total despois da aplicada(s) a(s) regra(s)
@return  aRet[3]	  		3 // Percentual de desconto total aplicado em relacao ao valor total antigo
@return  aRet[4]	  		4 // Valor total antes da aplicada(s) a(s) regra(s) 
@obs     					
@sample
/*/
//-------------------------------------------------------------------
Function STWRuleTotal( nValueTotal , cCliCode , cCliStore )

Local aRet	 		:= {}								// Retorno funcao
Local lRet			:= .F. 								// retorno do desconto por forma de pagamento
Local cMvCondPad	:= Iif (ExistFunc("STBCondPad"), STBCondPad(),SuperGetMv('MV_CONDPAD',.F.,''))	//Condicao de pagamento padrao
Local aArea			:= {}	
Local cForma		:= ""

Default nValueTotal := 0	
Default cCliCode 	:= ""	
Default cCliStore 	:= ""

ParamType 0 var  nValueTotal 	As Numeric	 Default 0
ParamType 1 var  cCliCode  		As Character Default ""
ParamType 2 var  cCliStore 		As Character Default ""

If nValueTotal == 0
	nValueTotal := STFSaleTotal()
EndIf 

If Empty(cCliCode)
	cCliCode := STDGPBasket( "SL1" , "L1_CLIENTE" )
EndIf

If Empty(cCliStore)
	cCliStore := STDGPBasket( "SL1" , "L1_LOJA" )
EndIf                                    

If SuperGetMv("MV_LJRGDES",,.F.)  // "Nova" Regra de Desconto 
	If Empty( STDGPBasket( "SL1" , "L1_NUMORIG" ) )  // Para importação de orçamento o desconto deve vir gravado
		
		/* Verifica a forma padrao, usada na entrada do primeiro pagamento */
		aArea	:= GetArea()
		DbSelectArea("SE4")
		SE4->(DbSetOrder(1))
		If SE4->(DbSeek(xFilial("SE4")+ cMvCondPad)) 
			cForma := Alltrim(SE4->E4_FORMA) 
		EndIf
		
		RestArea(aArea)

		If !Empty(cForma) .And. STBPromPgto(cForma)
			aRet := STBTotRlDi( nValueTotal , cCliCode	, cCliStore, .T., cForma )  
			lRet := aRet[LRULEAPPLY] //alguma regra foi aplicada ?  
		EndIf	

		If lRet //alguma regra foi aplicada ? 
			STWTotDisc( aRet[NPERDESCTO] , "V" , "RULEDISC")
			
			STWRsnDesc( 99999 ,  "REGRA DE DESCONTO"	,	"Regra de Desconto - TOTAL"	) // Motivo de Desconto
		EndIf	
	EndIf
EndIf

If Len(aRet) == 0
	// Retorno padrao
	aRet := { .F. , nValueTotal , 0 , 0 , nValueTotal } 
EndIf

Return aRet
