#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOBJECT.CH"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³O Protheus necessita ter ao menos uma funcao para que o    ³
//³fonte seja exibido na inspecao de fontes do RPO.           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
User Function STFWACollec ; Return 

//--------------------------------------------------------
/*/{Protheus.doc} STFWACollection
Classe abstrata responsavel em guardar os metodos comuns das colecoes esta classe nao pode ser 
instanciada, somente herdada

@param   
@author  Varejo
@version P11.8
@see     Veja tambem as classes STFWCHashTable, STFWCList, STFWCStack, STFWCQueue.                                             
@since   02/04/2012
@return  Self
@todo    
@obs                                     
@sample
/*/
//--------------------------------------------------------

Class STFWACollection
	
	Data aColecao								//Array que ira armazenar os dados
	
	Method STFWACollection()                  	//Metodo construtor	
	Method Count()								//Metodos que ira retornar o numero de objetos da Colecao
	Method Erase()								//Limpa o array aColecao (Inicializa)
	Method Elements(nIndex)						//Metodo que ira retornar um elemento de um determinado indice    
 	Method ToArray()							//Metodo que retorna os elementos da colecao em um array
	Method Clonar()								//Metodo abstrato que ira fazer um clone de um objeto, tem que ser sobrescrito pelas classes filhos
				
EndClass

//--------------------------------------------------------
/*/{Protheus.doc} STFWACollection
Construtor da classe STFWACollection.

@param   
@author  Varejo
@version P11.8
@see     Veja tambem as classes STFWCHashTable, STFWCList, STFWCStack, STFWCQueue.
@since   02/04/2012
@return  Self
@todo    
@obs                                     
@sample
/*/
//--------------------------------------------------------

Method STFWACollection() Class STFWACollection

    Self:aColecao := {}

Return Self

//--------------------------------------------------------
/*/{Protheus.doc} Count
Retorna a quantidade de elementos da colecao.

@param   
@author  Varejo
@version P11.8
@see     Veja tambem as classes STFWCHashTable, STFWCList, STFWCStack, STFWCQueue.
@since   02/04/2012
@return  Conta a quantidade de registros no aColecao.
@todo    
@obs                                     
@sample
/*/
//--------------------------------------------------------

Method Count() Class STFWACollection
	
	Local nRetorno 	:= 0				//Variavel de retorno do metodo
		
	nRetorno := Len(Self:aColecao)
	
Return nRetorno

//--------------------------------------------------------
/*/{Protheus.doc} Erase
Limpa o array aColecao (Inicializa).

@param   
@author  Varejo
@version P11.8
@see     Veja tambem as classes STFWCHashTable, STFWCList, STFWCStack, STFWCQueue.
@since   02/04/2012
@return  Conta a quantidade de registros no aColecao.
@todo    
@obs                                     
@sample
/*/
//--------------------------------------------------------

Method Erase() Class STFWACollection
	
	//Inicializa o array 
	::aColecao := {}
	
Return Nil

//--------------------------------------------------------
/*/{Protheus.doc} Elements
Retorna um elemento da colecao atraves de um indice.

@param   ExpN1 (1 - nIndex) - Posicao do array.
@author  Varejo
@version P11.8
@see     Veja tambem as classes STFWCHashTable, STFWCList, STFWCStack, STFWCQueue.
@since   02/04/2012
@return  Objeto oElement
@todo    
@obs                                     
@sample
/*/
//--------------------------------------------------------

Method Elements(nIndex) Class STFWACollection

	Local oElement := Nil				//Objeto que sera retornado na funcao
	
	oElement := Self:aColecao[nIndex]
	
Return oElement

//--------------------------------------------------------
/*/{Protheus.doc} ToArray
Responsavel em retornar o conteudo da colecao em um array

@param   
@author  Varejo
@version P11.8
@see     Veja tambem as classes STFWCHashTable, STFWCList, STFWCStack, STFWCQueue.
@since   02/04/2012
@return  aRetorno com o conteudo do objeto
@todo    
@obs                                     
@sample
/*/
//--------------------------------------------------------

Method ToArray() Class STFWACollection

	Local aRetorno := {}				//Retorno do metodo
	Local nCount   := 0               	//Variavel auxiliar contador
	
	//Atribui ao array o conteudo do objeto
	For nCount := 1 To Self:Count()
		AADD(aRetorno, Self:aColecao[nCount])
	Next
	
Return aRetorno

//--------------------------------------------------------
/*/{Protheus.doc} Clonar
Metodo abstrato que ira fazer um clone de um objeto, tem que ser sobrescrito pelas classes filhos

@param   
@author  Varejo
@version P11.8
@see     Veja tambem as classes STFWCHashTable, STFWCList, STFWCStack, STFWCQueue.
@since   02/04/2012
@return  Objeto oReturn
@todo    
@obs                                     
@sample
/*/
//--------------------------------------------------------

Method Clonar() Class STFWACollection

	Local oRetorno := Nil				//Retorno do metodo
		
Return oRetorno
