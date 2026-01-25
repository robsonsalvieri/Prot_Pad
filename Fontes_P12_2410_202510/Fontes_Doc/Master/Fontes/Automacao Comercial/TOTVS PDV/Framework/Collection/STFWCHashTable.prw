#INCLUDE "PROTHEUS.CH" 
#INCLUDE "MSOBJECT.CH"

User Function STFWCHashT ; Return  // "dummy" function - Internal Use 

//--------------------------------------------------------
/*/{Protheus.doc} STFWCHashTable
Classe responsavel em guardar uma colecao de objetos.

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

Class STFWCHashTable From STFWACollection
	
	Method STFWCHashTable()                    	//Metodo construtor
	Method Add(oKey, oObject)  	        		//Metodo que ira adicionar um objeto na Colecao
	Method Contains(oKey)						//Metodo que ira verificar se existe um determinado elemento na Colecao
	Method Remove(oKey)	    					//Metodo para remover um objeto da Colecao
	Method ElementKey(oKey)						//Metodo que ira retornar um elemento da Colecao
	Method Elements(nIndice)					//Metodo que ira retornar um elemento de um determinado indice
	Method ElementPar(nIndice)					
 	Method ToArray()							//Metodo que retorna os elementos da colecao em um array
	Method Clonar()								//Metodo que ira fazer um clone do objeto LJCHashTable usando recursividade
				
EndClass

//--------------------------------------------------------
/*/{Protheus.doc} STFWCHashTable
Construtor da classe STFWCHashTable

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

Method STFWCHashTable() Class STFWCHashTable

    _Super:STFWACollection()

Return Self

//--------------------------------------------------------
/*/{Protheus.doc} Add
Adiciona um elemento a colecao.

@param   ExpV1 (1 - oKey)    - Chave da colecao.
@param	  ExpO1 (2 - oObject) - Elemento da colecao.
@author  Varejo
@version P11.8
@see     Veja tambem a classe STFWACollection
@since   02/04/2012
@return  Self
@todo    
@obs	  Metodo da classe STFWCHashTable
@sample
/*/
//--------------------------------------------------------

Method Add(oKey, oObject) Class STFWCHashTable

    //Verifica se o elemento ja existe na colecao, se sim, remove
    If Self:Contains(oKey)
    	Self:Remove(oKey)
    EndIf
    
    //Adiciona um elemento na colecao
    AADD(Self:aColecao, {oKey, oObject})

Return Nil

//--------------------------------------------------------
/*/{Protheus.doc} Contains
Verifica se existe um determinado elemento na colecao.

@param   ExpV1 (1 - oKey)    - Chave da colecao.
@author  Varejo
@version P11.8
@see     Veja tambem a classe STFWACollection
@since   02/04/2012
@return  Logico se encontro um elemento
@todo    
@obs	  Metodo da classe STFWCHashTable
@sample
/*/
//--------------------------------------------------------

Method Contains(oKey) Class STFWCHashTable
	
	Local lRetorno 	:= .F.				//Variavel de retorno do metodo
	Local nPosicao 	:= 0				//Posicao do array
		
	//Verifica se possui algum elemento na colecao
	If Self:Count() > 0
		Begin Sequence
			//Procura o elemento na colecao
			nPosicao := Ascan(Self:aColecao, {|x| x[1] == oKey})
			
			//Verifica se encontrou o elemento
			If nPosicao > 0 
				lRetorno := .T.	
			EndIf
		Recover
			lRetorno := .F.			
		End Sequence
	EndIf
	
Return lRetorno

//--------------------------------------------------------
/*/{Protheus.doc} Remove
Remove um elemento da colecao.

@param   ExpV1 (1 - oKey)    - Chave da colecao.
@author  Varejo
@version P11.8
@see     Veja tambem a classe STFWACollection
@since   02/04/2012
@return  
@todo    
@obs	  Metodo da classe STFWCHashTable
@sample
/*/
//--------------------------------------------------------

Method Remove(oKey) Class STFWCHashTable
	
	Local nPosicao 	:= 0				//Posicao do produto no array
	
	//Procura o elemento na colecao
	nPosicao := Ascan(Self:aColecao, {|x| x[1] == oKey})
	//Apaga o elemento da colecao
	ADel(Self:aColecao, nPosicao)
	//Redimensiona a colecao		
	ASize(Self:aColecao, Self:Count() - 1)
	
Return Nil

//--------------------------------------------------------
/*/{Protheus.doc} ElementKey
Retorna um elemento da colecao atraves da chave.

@param   ExpV1 (1 - oKey)    - Chave da colecao.
@author  Varejo
@version P11.8
@see     Veja tambem a classe STFWACollection
@since   02/04/2012
@return  Objeto oElement
@todo    
@obs	  Metodo da classe STFWCHashTable
@sample
/*/
//--------------------------------------------------------

Method ElementKey(oKey) Class STFWCHashTable

	Local oElement  := Nil				//Objeto que sera retornado na funcao
	Local nPosicao 	:= 0				//Posicao do elemento no array

	//Procura o elemento na colecao
	nPosicao := Ascan(Self:aColecao, {|x| x[1] == oKey})

	//Pega o elemento
	oElement := Self:Elements(nPosicao)
		
Return oElement

//--------------------------------------------------------
/*/{Protheus.doc} Elements
Retorna um elemento da colecao atraves de um indice.

@param   ExpV1 (1 - oKey)    - Chave da colecao.
@author  Varejo
@version P11.8
@see     Veja tambem a classe STFWACollection
@since   02/04/2012
@return  Objeto oElement
@todo    
@obs	  Metodo da classe STFWCHashTable
@sample
/*/
//--------------------------------------------------------

Method Elements(nIndice) Class STFWCHashTable

	Local oElement := Nil				//Objeto que sera retornado na funcao
	
	oElement := Self:aColecao[nIndice, 2]
	
Return oElement

//--------------------------------------------------------
/*/{Protheus.doc} ElementPar
Retorna um elemento da colecao atraves de um indice.

@param   Indice de busca dentro do elemento.
@author  Varejo
@version P11.8
@see     Veja tambem a classe STFWACollection e a classe STFWCKeyValuePar 
@since   02/04/2012
@return  Objeto oPar
@todo    
@obs	  Metodo da classe STFWCHashTable
@sample
/*/
//--------------------------------------------------------

Method ElementPar(nIndice) Class STFWCHashTable

	Local oPar := Nil				//Objeto que sera retornado na funcao
	
	oPar := STFWCKeyValuePar():STFWCKeyValuePar(Self:aColecao[nIndice, 1], Self:aColecao[nIndice, 2])

Return oPar

//--------------------------------------------------------
/*/{Protheus.doc} Clonar
Responsavel em clonar o objeto STFWCHashTable

@param   
@author  Varejo
@version P11.8
@see     Veja tambem a classe STFWACollection 
@since   02/04/2012
@return  
@todo    
@obs	  Metodo da classe STFWCHashTable
@sample
/*/
//--------------------------------------------------------

Method Clonar() Class STFWCHashTable

	Local oRetorno := Nil				//Retorno do metodo
	Local nCount   := 0
	
	//Estancia o objeto STFWCColecao (recursividade)
	oRetorno := STFWCHashTable():STFWCHashTable()
	
	//Atribui ao array do novo objeto um clone do array original
	For nCount := 1 To Self:Count()
		If Valtype(Self:Elements(nCount)) == "O"
			oRetorno:ADD(Self:aColecao[nCount, 1], Self:Elements(nCount):Clonar())
		Else
			oRetorno:ADD(Self:aColecao[nCount, 1], Self:Elements(nCount))
		EndIf
	Next
	
Return oRetorno

//--------------------------------------------------------
/*/{Protheus.doc} ToArray
Responsavel em retornar o conteudo da colecao em um array

@param   
@author  Varejo
@version P11.8
@see     Veja tambem a classe STFWACollection 
@since   02/04/2012
@return  Array
@todo    
@obs	  Metodo da classe STFWCHashTable
@sample
/*/
//--------------------------------------------------------

Method ToArray() Class STFWCHashTable

	Local aRetorno := {}				//Retorno do metodo
	Local nCount   := 0
	
	//Atribui ao array o conteudo do objeto
	For nCount := 1 To Self:Count()
		AADD(aRetorno, Self:aColecao[nCount, 2])
	Next
	
Return aRetorno
