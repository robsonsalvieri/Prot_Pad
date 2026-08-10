#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} STBQuantity
Seta quantidade do item
@param   nItemQuant		Quantidade do Item
@author  Varejo
@version P11.8
@since   23/05/2012
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STWCurrency()

/*/
	Define a Moeda Padrão como Moeda Corrente
/*/
STBSetCurrency( STBDefCurrency() )

Return

