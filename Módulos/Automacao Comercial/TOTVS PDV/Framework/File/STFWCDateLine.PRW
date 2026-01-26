#INCLUDE "MSOBJECT.CH" 

User Function STFWCDateLine ; Return  // "dummy" function - Internal Use 

//--------------------------------------------------------
/*/{Protheus.doc} STFWCDateLine
Classe responsavel em armazenar cada linha do arquivo.

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

Class STFWCDateLine
	
	Data cLine										//Linha de texto do arquivo
	
	Method STFWCDateLine()							//Metodo construtor
	Method Line()									//Metodo que ira retornar cada linha do arquivo
		
EndClass

//--------------------------------------------------------
/*/{Protheus.doc} STFWCDateLine
Construtor da classe STFWCDateLine

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

Method STFWCDateLine() Class STFWCDateLine

	Self:cLine := ""
	
Return Self

//--------------------------------------------------------
/*/{Protheus.doc} STFWCDateLine
Responsavel em retornar a linha de texto do arquivo.

@param   
@author  Varejo
@version P11.8
@see     
@since   02/04/2012
@return  Linha
@todo    
@obs	                                       
@sample
/*/
//--------------------------------------------------------

Method Line() Class STFWCDateLine

Return Self:cLine