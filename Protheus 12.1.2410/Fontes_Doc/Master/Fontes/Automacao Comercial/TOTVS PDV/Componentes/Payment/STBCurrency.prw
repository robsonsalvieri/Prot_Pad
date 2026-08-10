#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

Static nCurrency := 1			// Moeda Corrente

//-------------------------------------------------------------------
/*/{Protheus.doc} STBGetCurrency
Retorna a Moeda Corrente
@param   	
@author  Varejo
@version P11.8
@since   23/05/2012
@return  nCurrency Retorna a Moeda Corrente
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBGetCurrency()
Return nCurrency


//-------------------------------------------------------------------
/*/{Protheus.doc} STBSetCurrency
Define a Moeda Corrente
@param   nSetCurrency	Moeda Corrente
@author  Varejo
@version P11.8
@since   23/05/2012
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBSetCurrency( nSetCurrency )

nCurrency := nSetCurrency

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STBCurrency
Retorna a Moeda Corrente Padrão
@param   
@author  Varejo
@version P11.8
@since   23/05/2012
@return  nDefCurrency Retorna a Moeda Corrente Padrão
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBDefCurrency()

Local nDefCurrency	:= 1		// Retorna a Moeda Corrente padrão

/*/
	Define a moeda padrao a ser utilizada para a venda
/*/
If STFGetCfg("lMultCoin") // Se usa Multimoeda
	nDefCurrency	:= SuperGetMV("MV_LJMDORC",,1)
Else
	nDefCurrency := 1
EndIf

Return nDefCurrency 



