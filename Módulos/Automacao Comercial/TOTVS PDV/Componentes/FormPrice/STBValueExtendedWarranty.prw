#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

Static nPercItem			:= 0
Static nPricItem			:= 0
Static nWarraPercItem	:= 0
Static nReturnPrice		:= 0

//--------------------------------------------------------
/*/{Protheus.doc} STBValExtW
Calcula valor da garantia

@param 	nPercentItem 			Porcentagem do item
@param 	nPriceItem 				Preco do item
@param 	nWarrantyPercentItem 	Porcentagem da garantia
@author  	Varejo
@version 	P11.8
@since   	30/03/2012
@return  	nReturnPrice Preco
@obs     
@sample
/*/
//--------------------------------------------------------
Function STBValExtW( nPercentItem, nPriceItem, nWarrantyPercentItem )
	
Default nPercentItem 			:= 0
Default nPriceItem 				:= 0
Default nWarrantyPercentItem 	:= 0

ParamType 0 Var 	nPercentItem 					As Numeric	 	Default 	0
ParamType 1 Var 	nPriceItem 					As Numeric 	Default 	0
ParamType 2 Var 	nWarrantyPercentItem 		As Numeric 	Default 	0

nPercItem			:= nPercentItem
nPricItem			:= nPriceItem
nWarraPercItem 	:= nWarrantyPercentItem

STBValWar()
	 
Return nReturnPrice


//--------------------------------------------------------
/*/{Protheus.doc} STBValWar
Calcula o valor do preco de garantia estendida.

@param   	
@author  	Varejo
@version 	P11.8
@since   	30/03/2012
@return  	nReturnPrice  Preco
@obs     
@sample
/*/
//--------------------------------------------------------
Function STBValWar()

Local nValueRisco := 0 //Valor 

nValueRisco 	:= a410arred(nPricItem + (nPricItem  * nPercItem / 100), "L2_VRUNIT")
nReturnPrice	:= a410arred(nValueRisco * nWarraPercItem / 100 + (nPricItem * nPercItem / 100), "L2_VRUNIT")
	
Return nReturnPrice