#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//--------------------------------------------------------
/*/{Protheus.doc} STBLenReceipt
Function responsável por retornar o tamanho do numero do Cupom
@param   	
@author  	Varejo
@version 	P11.8
@since   	21/12/2012
@return  	Numero do cupom
@obs     
@sample
/*/
//--------------------------------------------------------
Function STBLenReceipt(cBuffer)

Local nNumCup :=0  //Numero do cupom

Default cBuffer := Space(6)

nNumCup := Len(cBuffer)

Return nNumCup