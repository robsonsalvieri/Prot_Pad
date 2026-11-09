#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

Static nItemDiscount := 0			// Valor do desconto
Static cTypeDiscount := ""			// Tipo de desconto. "V" - Valor , "P" - Percentual


//-------------------------------------------------------------------
/*/{Protheus.doc} STBQuantity
Set desconto do item

@param   nItemQuant			Quantidade do Item
@param   cTypeDiscount		Tipo de desconto. "V" - Valor , "P" - Percentual
@author  Varejo
@version P11.8
@since   23/05/2012
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBSetItDiscount( nValDiscount , cType )

Default  nValDiscount 	:= 0
Default  cType 			:= ""

ParamType 0 Var nValDiscount 	AS Numeric		Default 0
ParamType 1 Var cType 			AS Character	Default ""

nItemDiscount	:= nValDiscount
cTypeDiscount	:= cType 

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STBGetItDiscount
Get desconto do item

@param   
@author  Varejo
@version P11.8
@since   23/05/2012
@return  aRet[1]		nItemDiscount - Valor de desconto
@return  aRet[2]		cTypeDiscount - Tipo de desconto		
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBGetItDiscount()

Local aRet := {}			// Retorno Função

AADD( aRet , nItemDiscount )
AADD( aRet , cTypeDiscount )

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBDefItDiscount
Set default desconto do item

@param   
@author  Varejo
@version P11.8
@since   23/05/2012
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBDefItDiscount()

nItemDiscount := 0			// Valor do desconto
cTypeDiscount := ""			// Tipo de desconto. "V" - Valor , "P" - Percentual

Return Nil






