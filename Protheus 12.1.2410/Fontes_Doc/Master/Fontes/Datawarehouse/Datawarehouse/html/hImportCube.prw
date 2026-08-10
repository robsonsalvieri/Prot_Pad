// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : Main
// Fonte  : Object - contém os resultados de uma importação de um cubo
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 14.02.06 | Paulo R Vieira	| Fase 3
// --------------------------------------------------------------------------------------

#include "dwincs.ch"

/*
--------------------------------------------------------------------------------------
Classe responsável por conter os resultados pela importação de um cubo
--------------------------------------------------------------------------------------
*/
Class TDWImportCube from TDWObject
	
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
method New(anID) class TDWImportCube
	_Super:New()
	::Clean()
	::ID(anID)
return

/*
--------------------------------------------------------------------------------------
Destrutor
--------------------------------------------------------------------------------------
*/
method Free() class TDWImportCube
	::Clean()
	_Super:Free()
return

/*
--------------------------------------------------------------------------------------
Método responsável pela limpeza para o objeto
--------------------------------------------------------------------------------------
*/
method Clean() class TDWImportCube
	::fnID			:= 0
	::fcName		:= ""
	::faAttributes	:= {}
	::faDataSources := {}
	::flOverrided 	:= .F.
	::flSucess		:= .T.
return

/*
--------------------------------------------------------------------------------------
Método responsável pela definição do id do cubo
--------------------------------------------------------------------------------------
*/
method ID(anValue) class TDWImportCube
	property ::fnID := anValue
return ::fnID

/*
--------------------------------------------------------------------------------------
Método responsável pela definição do nome do cubo
--------------------------------------------------------------------------------------
*/
method Name(acValue) class TDWImportCube
	property ::fcName := acValue
return ::fcName

/*
--------------------------------------------------------------------------------------
Método responsável pela definição dos attributos do cubo
--------------------------------------------------------------------------------------
*/
method Attributes(aaValues) class TDWImportCube
	property ::faAttributes := aaValues
return ::faAttributes

/*
--------------------------------------------------------------------------------------
Método responsável pela definição dos attributos virtuais da dimensão
--------------------------------------------------------------------------------------
*/
method VirtAttributes(aaValues) class TDWImportCube
	property ::faVirtAttrib := aaValues
return ::faVirtAttrib

/*
--------------------------------------------------------------------------------------
Método responsável pela definição dos datasources do cubo
--------------------------------------------------------------------------------------
*/
method DataSources(aaValues) class TDWImportCube
	property ::faDataSources := aaValues
return ::faDataSources

/*
--------------------------------------------------------------------------------------
Método responsável pela definição de remoção/sobrescrita de um cubo
--------------------------------------------------------------------------------------
*/
method Overrided(alValue) class TDWImportCube
	property ::flOverrided := alValue
return ::flOverrided

/*
--------------------------------------------------------------------------------------
Método responsável pela definição de sucesso de uma importação de um cubo
--------------------------------------------------------------------------------------
*/
method Sucess(alValue) class TDWImportCube
	property ::flSucess := alValue
return ::flSucess