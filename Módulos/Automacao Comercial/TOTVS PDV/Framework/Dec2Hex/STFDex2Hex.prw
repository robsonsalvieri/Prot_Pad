#INCLUDE "PROTHEUS.CH"

//--------------------------------------------------------
/*{Protheus.doc} STFDec2Hex
Converte um numero decimal ate' 255 para hexadecimal .
@author  	Varejo
@version 	P11.8
@since   	16/12/2013
@return  	cResult - Resultado da conversao
@obs     	STFDec2Hex
*/
//--------------------------------------------------------
Function STFDec2Hex(nVal)
Local cString:= "0123456789ABCDEF"
Local cRet	 := Substr(cString,Int(nVal/16)+1,1)+Substr(cString,nVal-(Int(nVal/16)*16)+1,1)
 
Return cRet