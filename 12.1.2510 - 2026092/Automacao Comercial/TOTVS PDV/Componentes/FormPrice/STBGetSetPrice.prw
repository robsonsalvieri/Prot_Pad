#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

Static nPrice := 0

//-------------------------------------------------------------------
/*/{Protheus.doc} STBSetPric
Seta o preço do item

@param		nValue - Preço
@author  	Varejo
@version 	P11.8
@since   	15/05/2012
@return  	Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBSetPric(nValue)
	
Default nValue := 0

ParamType 0 Var nValue As Numeric Default 0	

nPrice := nValue	
	
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STBGetPric
Retorna o preço do item na variavel static

@param		
@author  	Varejo
@version 	P11.8
@since   	15/05/2012
@return  	nPrice - Preco
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBGetPric()
Return nPrice