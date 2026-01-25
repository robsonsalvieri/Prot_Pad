// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : SigaDW
// Fonte  : Cubes - Objeto TCubes, lista de Cubos
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 01.06.01 | 0548-Alan Candido |
// 01.11.05 |2481-Paulo Vieira  | Versão 3
// --------------------------------------------------------------------------------------

#include "dwincs.ch"

/*
--------------------------------------------------------------------------------------
Classe: TCubes
Uso   : Lista de cubos
--------------------------------------------------------------------------------------
*/
class TCubes from TDWObject
	               
	method New(aoOwner) constructor
	method Free()               
	method CubeList()
	
endclass

/*
--------------------------------------------------------------------------------------
Construtor e destrutor da classe
Args: aoOwner -> objeto, objeto "proprietário"
--------------------------------------------------------------------------------------
*/
method New(aoOwner) class TCubes
               
	_Super:New(aoOwner)
	
return

method Free() class TCubes

	_Super:Free()

return

/*
--------------------------------------------------------------------------------------
Propriedade CubeList
--------------------------------------------------------------------------------------
*/                         
method CubeList() class TCubes
	
return InitTable(TAB_CUBESLIST)

