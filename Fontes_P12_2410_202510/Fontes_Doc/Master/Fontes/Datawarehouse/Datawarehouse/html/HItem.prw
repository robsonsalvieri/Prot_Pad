// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : Html
// Fonte  : HItem - Objeto THItem, definição um item HTML simples
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 01.06.01 | 0548-Alan Candido |
// --------------------------------------------------------------------------------------

#include "dwincs.ch"

/*
--------------------------------------------------------------------------------------
Classe: THItem
Uso   : Item HTM
--------------------------------------------------------------------------------------
*/
class THItem from THList
	data fnIndex
	data fcBuffer
		
	method New(aoPage, acBuffer) constructor
	method Free()
	method NewHItem(aoPage, acBuffer) 
	method FreeHItem()
               
	method Index(anIndex)
		
	method Buffer()

	method MakeSrc(aaBuffer)
	method Page()
			
endclass

/*
--------------------------------------------------------------------------------------
Construtor e destrutor da classe
Args: aoPage -> objeto, página "proprietária"
	   acBuffer -> string, texto HTML a ser colocado no buffer
--------------------------------------------------------------------------------------
*/
method New(aoPage, acBuffer) class THItem
               
	::NewHItem(acBuffer)
	
return

method Free() class THItem

	::FreeHItem()

return

method NewHItem(aoPage, acBuffer) class THItem

	default acBuffer := ""
	       
	::NewHList(aoPage)

	::fcBuffer := acBuffer

	if valtype(::Owner()) == "O"
		::Owner():AddItem(self)	
	endif
	
return

method FreeHItem() class THItem

	if valtype(::Owner()) == "O"
		::Owner():RemoveItem(self)	
	endif
	::FreeHList()

return

/*
--------------------------------------------------------------------------------------
Código HTML do item
Arg: aaBuffer -> array, local de geração do HTML
Ret: cRet -> string, caso o buffer não seja especificado, retorna o código HTML
--------------------------------------------------------------------------------------
*/                         
method MakeSrc(aaBuffer) class THItem
	local cRet := ""
	local nPos := 99

	cRet := ::Buffer()
	if len(cRet) > 100
		while nPos < len(cRet)
			nPos := nPos + at(">", substr(cRet, nPos))
			cRet := stuff(cRet, nPos, 1, ">"+CRLF)
		enddo
	endif

	if valType(aaBuffer) != "U"
		aAdd(aaBuffer, cRet)
	endif

return cRet

/*
--------------------------------------------------------------------------------------
Propriedade Buffer
--------------------------------------------------------------------------------------
*/                         
method Buffer(acValue) class THItem

	property ::fcBuffer := acValue

return (::fcBuffer)

/*
--------------------------------------------------------------------------------------
Propriedade Index
--------------------------------------------------------------------------------------
*/                         
method Index(anIndex) class THItem
	
	property ::fnIndex := anIndex
	
return ::fnIndex

/*
--------------------------------------------------------------------------------------
Propriedade Page
--------------------------------------------------------------------------------------
*/                         
method Page() class THItem
	local oOwner := ::Owner()	

	while valType(oOwner) != "U" .and. oOwner:className() != "THPAGE"
		oOwner := oOwner:Owner()
	enddo	
	
return oOwner 