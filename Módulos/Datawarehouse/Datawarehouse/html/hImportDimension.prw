// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : Main
// Fonte  : Object - contém os resultados de uma importação de uma dimensão
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 14.02.06 | Paulo R Vieira	| Fase 3
// --------------------------------------------------------------------------------------

#include "dwincs.ch"

/*
--------------------------------------------------------------------------------------
Classe responsável por conter os resultados pela importação de uma dimensão
--------------------------------------------------------------------------------------
*/
Class TDWImportDimension from TDWObject
	
	data fnID
	data fcName
	data faAttributes
	data faVirtAttrib
	data faDataSources
	data flOverrided
	data flSucess
	
	method New(anID)
	method Free()
	method Clean()
	
	method ID(anID)
	method Name(acValue)
	method Attributes(aaValues)
	method VirtAttributes(aaValues)
	method DataSources(aaValues)
	method Overrided(alValue)
	method Sucess(alValue)
	
EndClass

/*
--------------------------------------------------------------------------------------
Construtor
--------------------------------------------------------------------------------------
*/
method New(anID) class TDWImportDimension
	_Super:New()
	::Clean()
	::ID(anID)
return

/*
--------------------------------------------------------------------------------------
Destrutor
--------------------------------------------------------------------------------------
*/
method Free() class TDWImportDimension
	::Clean()
	_Super:Free()
return

/*
--------------------------------------------------------------------------------------
Método responsável pela limpeza para o objeto
--------------------------------------------------------------------------------------
*/
method Clean() class TDWImportDimension
	::fnID			:= 0
	::fcName		:= ""
	::faAttributes	:= {}
	::faDataSources := {}
	::flOverrided 	:= .F.
	::flSucess		:= .T.
return

/*
--------------------------------------------------------------------------------------
Método responsável pela definição do id da dimensão
--------------------------------------------------------------------------------------
*/
method ID(anValue) class TDWImportDimension
	property ::fnID := anValue
return ::fnID

/*
--------------------------------------------------------------------------------------
Método responsável pela definição do nome da dimensão
--------------------------------------------------------------------------------------
*/
method Name(acValue) class TDWImportDimension
	property ::fcName := acValue
return ::fcName

/*
--------------------------------------------------------------------------------------
Método responsável pela definição dos attributos da dimensão
--------------------------------------------------------------------------------------
*/
method Attributes(aaValues) class TDWImportDimension
	property ::faAttributes := aaValues
return ::faAttributes

/*
--------------------------------------------------------------------------------------
Método responsável pela definição dos attributos virtuais da dimensão
--------------------------------------------------------------------------------------
*/
method VirtAttributes(aaValues) class TDWImportDimension
	property ::faAttributes := aaValues
return ::faAttributes

/*
--------------------------------------------------------------------------------------
Método responsável pela definição dos datasources da dimensão
--------------------------------------------------------------------------------------
*/
method DataSources(aaValues) class TDWImportDimension
	property ::faDataSources := aaValues
return ::faDataSources

/*
--------------------------------------------------------------------------------------
Método responsável pela definição de remoção/sobrescrita de uma dimensão
--------------------------------------------------------------------------------------
*/
method Overrided(alValue) class TDWImportDimension
	property ::flOverrided := alValue
return ::flOverrided

/*
--------------------------------------------------------------------------------------
Método responsável pela definição de sucesso de uma importação de uma dimensão
--------------------------------------------------------------------------------------
*/
method Sucess(alValue) class TDWImportDimension
	property ::flSucess := alValue
return ::flSucess