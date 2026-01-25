// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : Main
// Fonte  : Object - contém os resultados de uma importação de um filtro para uma consulta
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 15.02.06 | Paulo R Vieira	| Fase 3
// --------------------------------------------------------------------------------------

#include "dwincs.ch"

/*
--------------------------------------------------------------------------------------
Classe responsável por conter os resultados pela importação de um filtro para uma consulta
--------------------------------------------------------------------------------------
*/
Class TDWImportFilter from TDWObject
	
	data fnID
	data fcName
	data fcType
	data faExprs
	data flSucess
	
	method New(anID)
	method Free()
	method Clean()
	
	method ID(anID)
	method Name(acValue)
	method Type(acValue)
	method Expressions(aaValues)
	method Sucess(alValue)
	
EndClass

/*
--------------------------------------------------------------------------------------
Construtor
--------------------------------------------------------------------------------------
*/
method New(anID) class TDWImportFilter
	_Super:New()
	::Clean()
	::ID(anID)
return

/*
--------------------------------------------------------------------------------------
Destrutor
--------------------------------------------------------------------------------------
*/
method Free() class TDWImportFilter
	::Clean()
	_Super:Free()
return

/*
--------------------------------------------------------------------------------------
Método responsável pela limpeza para o objeto
--------------------------------------------------------------------------------------
*/
method Clean() class TDWImportFilter
	::fnID				:= 0
	::flSucess	   		:= .T.
return

/*
--------------------------------------------------------------------------------------
Método responsável pela definição do id deste filtro
--------------------------------------------------------------------------------------
*/
method ID(anValue) class TDWImportFilter
	property ::fnID := anValue
return ::fnID

/*
--------------------------------------------------------------------------------------
Método responsável pela definição do nome deste filtro
--------------------------------------------------------------------------------------
*/
method Name(acValue) class TDWImportFilter
	property ::fcName := acValue
return ::fcName

/*
--------------------------------------------------------------------------------------
Método responsável pela definição do tipo deste filtro
--------------------------------------------------------------------------------------
*/
method Type(acValue) class TDWImportFilter
	property ::fcType := acValue
return ::fcType

/*
--------------------------------------------------------------------------------------
Método responsável pela definição das expressões deste filtro
--------------------------------------------------------------------------------------
*/
method Expressions(aaValues) class TDWImportFilter
	property ::faExprs := aaValues
return ::faExprs

/*
--------------------------------------------------------------------------------------
Método responsável pela definição de sucesso de uma importação deste filtro
--------------------------------------------------------------------------------------
*/
method Sucess(alValue) class TDWImportFilter
	property ::flSucess := alValue
return ::flSucess