#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOBJECT.CH"

User Function STFWCQueue ; Return  // "dummy" function - Internal Use 

//--------------------------------------------------------
/*/{Protheus.doc} STFWCQueue
Classe responsavel em guardar objetos em uma fila (First in - First Out).

@param   
@author  Varejo
@version P11.8
@see     Veja tambem a classe STFWACollection
@since   02/04/2012
@return  Self
@todo    
@obs	                                       
@sample
/*/
//--------------------------------------------------------

Class STFWCQueue From STFWACollection
	
	Method STFWCQueue()                        	//Metodo construtor
	Method Clonar()								//Metodo que ira fazer um clone do objeto LJCQueue usando recursividade
	Method Enqueue(oObject)	  	        		//Metodo que ira adicionar um elemento na fila
	Method Peek()		    					//Metodo que retorna o primeiro elemento da fila
	Method Dequeue()	    					//Metodo para remover um elemento da fila
				
EndClass

//--------------------------------------------------------
/*/{Protheus.doc} STFWCQueue
Construtor da classe STFWCQueue

@param   
@author  Varejo
@version P11.8
@see     Veja tambem a classe STFWACollection
@since   02/04/2012
@return  Self
@todo    
@obs	                                       
@sample
/*/
//--------------------------------------------------------

Method STFWCQueue() Class STFWCQueue

    _Super:STFWACollection()

Return Self

//--------------------------------------------------------
/*/{Protheus.doc} Clonar
Responsavel em clonar o objeto STFWCQueue

@param   
@author  Varejo
@version P11.8
@see     Veja tambem a classe STFWACollection
@since   02/04/2012
@return  oRetorno - Contendo a quantidade de elementos 
@todo    
@obs	                                       
@sample
/*/
//--------------------------------------------------------

Method Clonar() Class STFWCQueue

	Local oRetorno := Nil				//Retorno do metodo
	Local nCount   := 0
	
	//Instancia o objeto LJCQueue (recursividade)
	oRetorno := STFWCQueue():STFWCQueue()
	
	//Atribui ao array do novo objeto um clone do array original
	For nCount := 1 To Self:Count()
		If Valtype(Self:Elements(nCount)) == "O"
			oRetorno:ADD(Self:Elements(nCount):Clonar())
		Else
			oRetorno:ADD(Self:Elements(nCount))
		EndIf
	Next
	
Return oRetorno

//--------------------------------------------------------
/*/{Protheus.doc} Enqueue
Adiciona um elemento na fila.

@param   ExpO1 (1 - oObject) - Elemento da fila.
@author  Varejo
@version P11.8
@see     Veja tambem a classe STFWACollection
@since   02/04/2012
@return  Self 
@todo    
@obs	                                       
@sample
/*/
//--------------------------------------------------------

Method Enqueue(oObject) Class STFWCQueue
   
    //Adiciona um elemento na colecao
    AADD(Self:aColecao, oObject)

Return Nil

//--------------------------------------------------------
/*/{Protheus.doc} Peek
Retorna o ultimo elemento da fila.

@param   
@author  Varejo
@version P11.8
@see     Veja tambem a classe STFWACollection
@since   02/04/2012
@return  Retorna o primeiro elemento da fila
@todo    
@obs	                                       
@sample
/*/
//--------------------------------------------------------

Method Peek() Class STFWCQueue
    
	Local oElement := Nil				//Objeto que sera retornado na funcao

	//Retorna o primeiro elemento da fila
	oElement := Self:Elements(1)
		
Return oElement

//--------------------------------------------------------
/*/{Protheus.doc} Dequeue
Remove o primeiro elemento da fila.

@param   
@author  Varejo
@version P11.8
@see     Veja tambem a classe STFWACollection
@since   02/04/2012
@return  
@todo    
@obs	                                       
@sample
/*/
//--------------------------------------------------------

Method Dequeue() Class STFWCQueue

	//Apaga o primeiro elemento da colecao
	ADel(Self:aColecao, 1)

	//Redimensiona a colecao		
	ASize(Self:aColecao, ::Count() - 1)
	
Return Nil