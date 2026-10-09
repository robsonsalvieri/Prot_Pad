#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOBJECT.CH"

User Function STFWCStack ; Return  // "dummy" function - Internal Use 

//--------------------------------------------------------
/*/{Protheus.doc} STFWCStack
Classe responsavel em guardar objetos em uma pilha. (First In Last Out).

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

Class STFWCStack From STFWACollection
	
	Method STFWCStack()                    		//Metodo construtor
	Method Clonar()								//Metodo que ira fazer um clone do objeto LJCStack usando recursividade
	Method Push(oObject)	  	        		//Metodo que ira adicionar um objeto na pilha
	Method Peek()		    					//Metodo que retorna o ultimo elemento da pilha
	Method Poop()		    					//Metodo para remover um objeto da pilha
				
EndClass

//--------------------------------------------------------
/*/{Protheus.doc} STFWCStack
Construtor da classe STFWCStack

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

Method STFWCStack() Class STFWCStack

    _Super:STFWACollection()

Return Self

//--------------------------------------------------------
/*/{Protheus.doc} Clonar
Responsavel em clonar o objeto STFWCStack

@param   
@author  Varejo
@version P11.8
@see     Veja tambem a classe STFWACollection
@since   02/04/2012
@return  oReturn contendo a quantidade de elementos.
@todo    
@obs	                                       
@sample
/*/
//--------------------------------------------------------

Method Clonar() Class STFWCStack

	Local oRetorno := Nil				//Retorno do metodo
	Local nCount   := 0
	
	//Instancia o objeto LJCStack (recursividade)
	oRetorno := STFWCStack():STFWCStack()
	
	//Atribui ao array do novo objeto um clone do array original
	For nCount := 1 To ::Count()
		If Valtype(Self:Elements(nCount)) == "O"
			oRetorno:ADD(Self:Elements(nCount):Clonar())
		Else
			oRetorno:ADD(Self:Elements(nCount))
		EndIf
	Next
	
Return oRetorno

//--------------------------------------------------------
/*/{Protheus.doc} Push
Adiciona um elemento na pilha.

@param   ExpO1 (2 - oObject) - Elemento da pilha.
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

Method Push(oObject) Class STFWCStack
   
    //Adiciona um elemento na colecao
    AADD(Self:aColecao, oObject)

Return Nil

//--------------------------------------------------------
/*/{Protheus.doc} Peek
Retorna o ultimo elemento da pilha.

@param   
@author  Varejo
@version P11.8
@see     Veja tambem a classe STFWACollection
@since   02/04/2012
@return  Retorna o ultimo elemento da pilha
@todo    
@obs	                                       
@sample
/*/
//--------------------------------------------------------

Method Peek() Class STFWCStack

	Local oElement := Nil				//Objeto que sera retornado na funcao
	
	//Retorna o ultimo elemento da pilha
	oElement := Self:Elements(::Count())
		
Return oElement

//--------------------------------------------------------
/*/{Protheus.doc} Poop
Remove um elemento da pilha.

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

Method Poop() Class STFWCStack

	//Apaga o elemento da colecao
	ADel(Self:aColecao, Self:Count())

	//Redimensiona a colecao		
	ASize(Self:aColecao, Self:Count() - 1)
	
Return Nil