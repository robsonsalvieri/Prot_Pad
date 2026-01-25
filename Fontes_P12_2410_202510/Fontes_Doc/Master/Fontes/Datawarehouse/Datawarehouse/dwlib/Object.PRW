// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : Ferramentas
// Fonte  : Object - Define o objeto básico tObject       
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 01.06.01 | 0548-Alan Candido |
// --------------------------------------------------------------------------------------

#include "dwincs.ch"

/*
--------------------------------------------------------------------------------------
Classe: TDWObject
Uso   : Objeto básico do sistema
--------------------------------------------------------------------------------------
*/
class TDWObject
	
	data foOwner        
	data faProps
	
	method New(aoOwner, anSize) constructor
	method Free()
	method NewObject(aoOwner, anSize)
	method FreeObject()

	method Owner()
	method ClassName()
    method Props(anIndex, axValue)
    method asString()
endclass

/*
--------------------------------------------------------------------------------------
Construtor e destrutor da classe
--------------------------------------------------------------------------------------
*/
method New(aoOwner, anSize) class TDWObject

	::NewObject(aoOwner, anSize)

return

method Free() class TDWObject

	::FreeObject()
	
return

method NewObject(aoOwner, anSize) class TDWObject
                        
	::foOwner := aoOwner
	
	if valType(anSize) == "N"
		::faProps := array(anSize)
	endif
	
return

method FreeObject() class TDWObject

return

/*
--------------------------------------------------------------------------------------
Propriedade Owner
--------------------------------------------------------------------------------------
*/                         
method Owner() class TDWObject
	
return ::foOwner

/*
--------------------------------------------------------------------------------------
Propriedade ClassName
--------------------------------------------------------------------------------------
*/                         
method ClassName() class TDWObject
	
return getClassName(self)

/*
--------------------------------------------------------------------------------------
Propriedade Props
Args: anIndex, numerico, indice da propriedade desejada
		axValue, valor a ser atibuido
--------------------------------------------------------------------------------------
*/                         
method Props(anIndex, axValue) class TDWObject

	property ::faProps[anIndex] := axValue
	
return ::faProps[anIndex]

/*
--------------------------------------------------------------------------------------
"Converte" a classe em uma string
--------------------------------------------------------------------------------------
*/                                            
method asString() class TDWObject

//####TODO - implementar transformação de objeto em string
// As funções "classDataArr" e "varInfo", trazem somente as propriedades
// da classe instanciada (herança é ignorada)

return dwConcatWSep(CRLF, aBuffer)

