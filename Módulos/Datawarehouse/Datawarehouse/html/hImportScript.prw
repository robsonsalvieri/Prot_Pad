// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : Main
// Fonte  : Object - contém os resultados de uma importação de um script/roteiro
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 14.02.06 | Paulo R Vieira	| Fase 3
// --------------------------------------------------------------------------------------

#include "dwincs.ch"

/*
--------------------------------------------------------------------------------------
Classe responsável por conter os resultados pela importação de um script/roteiro
--------------------------------------------------------------------------------------
*/
Class TDWImportScript from TDWObject
	
	data fnID
	data fcName
	data fcField
	data fcCpoorig
	data fcExpression
	data flSucess
	
	method New(anID)
	method Free()
	method Clean()
	
	method ID(anID)
	method Name(acValue)
	method Field(acValue)
	method Cpoorig(acValue)
	method Expression(acValue)
	method Sucess(alValue)
	
EndClass

/*
--------------------------------------------------------------------------------------
Construtor
--------------------------------------------------------------------------------------
*/
method New(anID) class TDWImportScript
	_Super:New()
	::Clean()
	::ID(anID)
return

/*
--------------------------------------------------------------------------------------
Destrutor
--------------------------------------------------------------------------------------
*/
method Free() class TDWImportScript
	::Clean()
	_Super:Free()
return

/*
--------------------------------------------------------------------------------------
Método responsável pela limpeza para o objeto
--------------------------------------------------------------------------------------
*/
method Clean() class TDWImportScript
	::fnID			:= 0
	::fcName		:= ""
	::flSucess		:= .T.
return

/*
--------------------------------------------------------------------------------------
Método responsável pela definição do id
--------------------------------------------------------------------------------------
*/
method ID(anValue) class TDWImportScript
	property ::fnID := anValue
return ::fnID

/*
--------------------------------------------------------------------------------------
Método responsável pela definição do nome
--------------------------------------------------------------------------------------
*/
method Name(acValue) class TDWImportScript
	property ::fcName := acValue
return ::fcName

/*
--------------------------------------------------------------------------------------
Método responsável pela definição do campo utilizado no roteiro
--------------------------------------------------------------------------------------
*/
method Field(acValue) class TDWImportScript
	property ::fcField := acValue
return ::fcField

/*
--------------------------------------------------------------------------------------
Método responsável pela definição da propriedade Cpoorig
--------------------------------------------------------------------------------------
*/
method Cpoorig(acValue) class TDWImportScript
	property ::fcCpoorig := acValue
return ::fcCpoorig

/*
--------------------------------------------------------------------------------------
Método responsável pela definição da propriedade Expression
--------------------------------------------------------------------------------------
*/
method Expression(acValue) class TDWImportScript
	property ::fcExpression := acValue
return ::fcExpression

/*
--------------------------------------------------------------------------------------
Método responsável pela definição de sucesso de uma importação
--------------------------------------------------------------------------------------
*/
method Sucess(alValue) class TDWImportScript
	property ::flSucess := alValue
return ::flSucess