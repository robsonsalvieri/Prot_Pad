#INCLUDE "PROTHEUS.CH"

User Function STFWCKeyValue ; Return  // "dummy" function - Internal Use

//--------------------------------------------------------
/*/{Protheus.doc} STFWCKeyValuePar
Classe responsavel em guardar uma colecao de objetos.

@param   
@author  Varejo
@version P11.8
@see                                                  
@since   02/04/2012
@return  Self
@todo    
@obs                                     
@sample
/*/
//--------------------------------------------------------

Class STFWCKeyValuePar
	Data oKey
	Data oValue
	
	Method STFWCKeyValuePar()
EndClass

Method STFWCKeyValuePar(oKey, oValue) Class STFWCKeyValuePar
	Self:oKey := oKey
	Self:oValue := oValue
Return