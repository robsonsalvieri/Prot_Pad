// ######################################################################################
// Projeto: DATAWAREHOUSE
// Modulo : Apoio
// Fonte  : DWList - Objeto TDWList, responsável pelo gerenciamento da lista de DW
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 01.06.01 | 0548-Alan Candido |
// --------------------------------------------------------------------------------------

#include "dwincs.ch"

/*
--------------------------------------------------------------------------------------
Classe: TDWList 
Uso   : Responsável pelo gerenciamento da lista de DW
--------------------------------------------------------------------------------------
*/
class TDWList from TDWObject
                    
	data faItems

	method New() constructor
	method Free()

	method AddItem(anID, acName, acDesc, acIcone, alDisp, adCriado)
	method RemoveItem(anID)
	method Items()
	method Count()
			
endclass

/*
--------------------------------------------------------------------------------------
Construtor e destrutor da classe
--------------------------------------------------------------------------------------
*/
method New() class TDWList

	_Super:New()
	::faItems := {}

return
	 
method Free() class TDWList

	_Super:Free()

return

/*
--------------------------------------------------------------------------------------
Adiciona um DW
Arg: 
Ret: lRet -> lógico, retorna se inclusão foi ou não OK
--------------------------------------------------------------------------------------
*/                         
method AddItem(anID, acName, acDesc, acIcone, alDisp, adCriado) class TDWList
	local lRet := .f., aAux 

	if ascan(::faItems, { |x| upper(x[2]) == upper(acName)}) == 0
		lRet := .t.         
		aAux := array(DW_INFOSIZE)
		aAux[DW_ID    ] := anID
		aAux[DW_NAME  ] := acName
		aAux[DW_DESC  ] := acDesc
		aAux[DW_CRIADO] := adCriado
		aAux[DW_DISP  ] := alDisp     
		aAux[DW_ICONE ] := acIcone

		aAdd(::faItems, aAux)
	endif

return lRet

/*
--------------------------------------------------------------------------------------
Remove um DW
Arg: anID
--------------------------------------------------------------------------------------
*/                         
method RemoveItem(anID) class TDWList
	local nPos := 0
	
	if (nPos := ascan(::faItems, { |x| x[1] == anID })) > 0
		::faItems[nPos] := NIL
	endif	      
	::faItems := PackArray(::faItems)
return

/*
--------------------------------------------------------------------------------------
Propriedade Items
--------------------------------------------------------------------------------------
*/                         
method Items() class TDWList

return ::faItems

/*
--------------------------------------------------------------------------------------
Propriedade Count
--------------------------------------------------------------------------------------
*/                         
method Count() class TDWList

return len(::faItems)

function __DWList()
return
