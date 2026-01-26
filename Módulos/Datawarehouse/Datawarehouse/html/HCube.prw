// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : SigaDW
// Fonte  : Cube - Objeto TCube, contem definição e acesso ao cubo
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 01.06.01 | 0548-Alan Candido |
// 17.11.05 |2481-Paulo R Vieira| Fase 3 - Ajustes para novo layout
// 14.12.05 |2481-Paulo R Vieira| Fase 3 - Adicionado método Buffer
// --------------------------------------------------------------------------------------

#include "dwincs.ch"

/*
--------------------------------------------------------------------------------------
Classe: TCube
Uso   : Contem definição e acesso ao cubo
--------------------------------------------------------------------------------------
*/
class THCube from TCube

    data fcBackground
    data faCoord
    data fcURLFrame
	
	method New(anCubeID) constructor
	method Free()
 	
	// retorna uma string contendo a representação da lista de objetos adicionados
	method Buffer(aBuffer, alBottom)
	
	method Width(acValue)
	method Height(acValue)
	method Background(acImageFile)
	method urlFrame(acValue)
	
endclass

/*
--------------------------------------------------------------------------------------
Construtor e destrutor da classe
Args: 
--------------------------------------------------------------------------------------
*/
method New(anCubeID) class THCube
	_Super:New(anCubeID)
	
	::fcBackground	:= ""
	::faCoord 		:= { "", ""}
	::fcURLFrame	:= ""
return

method Free() class THCube
	_Super:Free()
return

/*
--------------------------------------------------------------------------------------
Método responsável por recuperar uma string contendo a representação do cube
Args: aBuffer, array, contém o array aonde será adicionada a string
      alBottom, lógico, contém o flag para a utilização do bottom
--------------------------------------------------------------------------------------
*/
method Buffer(aaBuffer, alBottom) class THCube

	local cAux := "", aAux
	local aStringNodes := {}, nCount, nInd
	local cSubTheme
	
	cAux := "<div id=" + ::Name() + " style='"
	if !empty(::fcBackground)
		if left(::fcBackground, 6) == "color:"
			cAux += "background:" + substr(::fcBackground,7)+";"
		else
			cAux += "background-image:url(" + urlImage(::fcBackground) + ");"
		endif	
	endif	         
	cAux += "width:"+::Width()+";"
	if !empty(::Height())
		cAux += "height:"+ ::Height() + ";"
	endif             
	cAux += "'>"
	aAdd(aaBuffer, cAux)
	aAdd(aaBuffer, tagJS())
	aAdd(aaBuffer, "var tree_tpl = {")
	if empty(::urlFrame())
		aAdd(aaBuffer, "	'target'  : '_self',")
	else
		aAdd(aaBuffer, "	'target'  : '"+::urlFrame()+"',")
	endif                                                         
	aAdd(aaBuffer, "var TREE_ITEMS = [")
	aEval(_Super:Fields(), {|x| aAdd(aaBuffer, x)})

	aAdd(aaBuffer, "new tree (TREE_ITEMS, tree_tpl);")
	aAdd(aaBuffer, "</script>")

	alBottom := .f.
	
return

/*
--------------------------------------------------------------------------------------
Propriedade Background
Arg: acImageFile -> string, path+nome do arquivo a ser colocado como background
--------------------------------------------------------------------------------------
*/                         
method Background(acImageFile) class THCube

	property ::fcBackground := acImageFile

return ::fcBackground

/*
--------------------------------------------------------------------------------------
Propriedade Width
--------------------------------------------------------------------------------------
*/                         
method Width(acValue) class THCube
               
	property ::faCoord[1] := acValue
	
return ::faCoord[1]

/*
--------------------------------------------------------------------------------------
Propriedade Height
--------------------------------------------------------------------------------------
*/                         
method Height(acValue) class THCube
               
	property ::faCoord[2] := acValue
	
return ::faCoord[2]

/*
--------------------------------------------------------------------------------------
Propriedade URLFrame
Arg: acURLFrame -> string, frame destino
--------------------------------------------------------------------------------------
*/                         
method urlFrame(acValue) class THCube

	property ::fcURLFrame := acValue
	
return ::fcURLFrame