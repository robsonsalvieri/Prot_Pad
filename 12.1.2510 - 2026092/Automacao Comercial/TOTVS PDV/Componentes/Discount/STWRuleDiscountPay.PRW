#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"   

//-------------------------------------------------------------------
/*/{Protheus.doc} STWPayRlDi
Function Regra de Desconto Total

@param 	 nValueTotal			Valor total da venda
@param 	 nValueBalancePay	Valor pagamento
@param		 cFormPay 			Forma de pagamento
@param 	 aAllPay				Array de Pagamentos
@param 	 cCliCode				Codigo Cliente
@param 	 cCliStore			Loja Cliente 
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
Function STWPayRlDi(nValueTotal	, nValueBalancePay	, cFormPay	, aAllPay	,;
					cCliCode	, cCliStore 		)

Local aRet					:= {}
					 
Default nValueTotal    		:= 0					
Default nValueBalancePay 	:= 0
Default cFormPay   	  		:= ""
Default aAllPay 	  		:= {}
Default cCliCode 	 		:= ""					
Default cCliStore 	 		:= ""	
   
ParamType 0 Var nValueTotal			AS Numeric		Default 0
ParamType 1 Var nValueBalancePay 	AS Numeric		Default 0
ParamType 2 Var cFormPay   			AS Character	Default ""
ParamType 3 Var aAllPay 			AS Array		Default {}
ParamType 4 Var cCliCode   			AS Character	Default ""
ParamType 5 Var cCliStore  			AS Character	Default ""
                                                  
// Valida total
If nValueTotal == 0
	nValueTotal := STFSaleTotal()
EndIf

If SuperGetMv("MV_LJRGDES",,.F.) // "Nova" Regra de Desconto 
	aRet := STBPayRlDi( nValueTotal		, nValueBalancePay 	, cFormPay , aAllPay , ;
						cCliCode  		, cCliStore 		)
	
	If aRet[LRULEAPPLY]                                                                              
		STWRsnDesc( 99999 ,  "REGRA DE DESCONTO"	,	"Regra de Desconto - TOTAL"	) // Motivo de Desconto
	EndIf
EndIf

If Len(aRet) == 0
	// Retorno padrao
	aRet := { .F. , nValueTotal , 0 , 0 , nValueTotal } 
EndIf

Return aRet					 