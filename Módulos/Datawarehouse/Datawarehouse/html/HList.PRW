// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : Htm
// Fonte  : HList - Objeto THList, responsável pelo gerenciamento de itens HTM (lista)
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 01.06.01 | 0548-Alan Candido |
// --------------------------------------------------------------------------------------

#include "dwincs.ch"

/*
--------------------------------------------------------------------------------------
Classe: THList      
Uso   : Lista de Itens HTML
--------------------------------------------------------------------------------------
*/
class THList from TDWObject
	
	data faItems
		
	method New(aoOwner) constructor
	method Free()
	method NewHList(aoOwner)
	method FreeHList()
	
	method Items() 
           
	method Count()
	
	method AddItem(aoItem) 
	method RemoveItem(aoItem)
	method Swap(anIndexLeft, anIndexRight)
	method GetItem(anIndex)
	method GetCount()
   method Clear()

endclass

/*
--------------------------------------------------------------------------------------
Construtor e destrutor da classe
--------------------------------------------------------------------------------------
*/
method New(aoOwner) class THList

	::NewHList(aoOwner)

return
	 
method Free() class THList

	::FreeHList()   

return

method NewHList(aoOwner) class THList
	                      
	::NewObject(aoOwner)
   ::faItems := {}

return
	 
method FreeHList() class THList

//	::Clear()
	::FreeObject()
	
return

/*
--------------------------------------------------------------------------------------
Propriedade Items
--------------------------------------------------------------------------------------
*/                         
method Items() class THList

return ::faItems

/*
--------------------------------------------------------------------------------------
Adiciona itens a página
Args: aoItem -> objeto, item HTML
		alNoIndex -> lógico, indica para não atualizar Index
Ret: nRet -> numérico, posição do item na lista
--------------------------------------------------------------------------------------
*/                         
method AddItem(aoItem) class THList
	local nRet
	
	nRet := ascan(::Items(), { |x| valtype(x) == "U" })
	if nRet > 0
		::Items()[nRet] := aoItem
	else
		aAdd(::Items(), aoItem)
		nRet := ::GetCount()
	endif
	
	aoItem:Index(nRet)

return nRet

/*
--------------------------------------------------------------------------------------
Remove item  da página
Arg: aoItem -> objeto, item HTML
Ret: 
--------------------------------------------------------------------------------------
*/                         
method RemoveItem(aoItem) class THList
	
	::Items()[aoItem:Index()] := NIL
	aoItem:Index(-1)
	
return

/*
--------------------------------------------------------------------------------------
Inverte a posição dos objetos
Arg: anIndexLeft -> numérico, indice a ser trocado
     anIndexRight -> numérico, indice a ser trocado
Ret: 
--------------------------------------------------------------------------------------
*/
method Swap(anIndexLeft, anIndexRight) class THList
	local oAux
	
	oAux := ::GetItem(anIndexLeft)
	::Items()[anIndexLeft] := ::GetItem(anIndexRight)
	::Items()[anIndexRight] := oAux

	::GetItem(anIndexLeft):fnIndex := anIndexRight
	::GetItem(anIndexRight):fnIndex := anIndexRight

return

/*
--------------------------------------------------------------------------------------
Retorna um item da lista 
Arg: anIndext -> numérico, item desejado
Ret: oRet -> THtmItem, item de HTM
--------------------------------------------------------------------------------------
*/
method GetItem(anIndex) class THList

return ::Items()[anIndex]

/*
--------------------------------------------------------------------------------------
Retorna o numero de elementos 
Arg: 
Ret: nRet -> numérico, tamanho da lista 
--------------------------------------------------------------------------------------
*/
method Count() class THList
return ::GetCount()

method GetCount() class THList

return len(::Items())

/*
--------------------------------------------------------------------------------------
Limpa a lista liberando os objetos
Arg: 
Ret: 
--------------------------------------------------------------------------------------
*/
method Clear() class THList
  local nInd
  
  for nInd := 1 to ::GetCount()    
  	if valType(::GetItem(nInd)) != "U"
//		DWFreeObj(::GetItem(nInd))
	endif
  next               
  ::faItems := {}

return 

function _HList()
return
