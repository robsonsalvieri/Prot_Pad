// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : Main
// Fonte  : Object - contém os resultados de uma importação de uma consulta
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 14.02.06 | Paulo R Vieira	| Fase 3
// --------------------------------------------------------------------------------------

#include "dwincs.ch"

/*
--------------------------------------------------------------------------------------
Classe responsável por conter os resultados pela importação de uma consulta
--------------------------------------------------------------------------------------
*/
Class TDWImportQuery from TDWObject
	
	data fnID
	data fcName
	data fcCubeName
	data flCubeExist
	data faVirtIndicators
	data faTables
	data faGraphics
	data faFilters
	data faAlerts
	data faDoc
	data flOverrided
	data flSucess
	
	method New(anID)
	method Free()
	method Clean()
	
	method ID(anID)
	method Name(acValue)
	method CubeName(acVAlue)
	method CubeExist(alVAlue)
	method VirtIndicators(aaValues)
	method Tables(aaValues)
	method Graphics(aaValues)
	method Filters(aaValues)
	method Alerts(aaValues)  
	method Doc(aDoc)
	method Overrided(alValue)
	method Sucess(alValue)
	
EndClass

/*
--------------------------------------------------------------------------------------
Construtor
--------------------------------------------------------------------------------------
*/
method New(anID) class TDWImportQuery
	_Super:New()
	::Clean()
	::ID(anID)
return

/*
--------------------------------------------------------------------------------------
Destrutor
--------------------------------------------------------------------------------------
*/
method Free() class TDWImportQuery
	::Clean()
	_Super:Free()
return

/*
--------------------------------------------------------------------------------------
Método responsável pela limpeza para o objeto
--------------------------------------------------------------------------------------
*/
method Clean() class TDWImportQuery
	::fnID				:= 0
	::fcName			:= ""
	::fcCubeName		:= ""
	::flCubeExist		:= .T.
	::faVirtIndicators 	:= {}
	::faTables			:= {}
	::faGraphics		:= {}
	::faFilters			:= {}
	::faAlerts			:= {}
	::flOverrided 		:= .F.
	::flSucess	   		:= .T.
return

/*
--------------------------------------------------------------------------------------
Método responsável pela definição do id de uma consulta
--------------------------------------------------------------------------------------
*/
method ID(anValue) class TDWImportQuery
	property ::fnID := anValue
return ::fnID

/*
--------------------------------------------------------------------------------------
Método responsável pela definição do nome de uma consulta
--------------------------------------------------------------------------------------
*/
method Name(acValue) class TDWImportQuery
	property ::fcName := acValue
return ::fcName

/*
--------------------------------------------------------------------------------------
Método responsável pela definição do nome de uma consulta
--------------------------------------------------------------------------------------
*/
method CubeName(acValue) class TDWImportQuery
	property ::fcCubeName := acValue
return ::fcCubeName

/*
--------------------------------------------------------------------------------------
Método responsável por definir flag da existência ou não do cubo associado a esta consulta
--------------------------------------------------------------------------------------
*/
method CubeExist(alVAlue) class TDWImportQuery
	property ::flCubeExist := alValue
return ::flCubeExist

/*
--------------------------------------------------------------------------------------
Método responsável pela definição dos indicadores virtuais de uma consulta
--------------------------------------------------------------------------------------
*/
method VirtIndicators(aaValues) class TDWImportQuery
	property ::faVirtIndicators := aaValues
return ::faVirtIndicators

/*
--------------------------------------------------------------------------------------
Método responsável pela definição das tabelas de uma consulta
--------------------------------------------------------------------------------------
*/
method Tables(aaValues) class TDWImportQuery
	property ::faTables := aaValues
return ::faTables

/*
--------------------------------------------------------------------------------------
Método responsável pela definição dos gráficos de uma consulta
--------------------------------------------------------------------------------------
*/
method Graphics(aaValues) class TDWImportQuery
	property ::faGraphics := aaValues
return ::faGraphics

/*
--------------------------------------------------------------------------------------
Método responsável pela definição dos filtros de uma consulta
--------------------------------------------------------------------------------------
*/
method Filters(aaValues) class TDWImportQuery
	property ::faFilters := aaValues
return ::faFilters

/*
--------------------------------------------------------------------------------------
Método responsável pela definição dos alertas de uma consulta
--------------------------------------------------------------------------------------
*/
method Alerts(aaValues) class TDWImportQuery
	property ::faAlerts := aaValues
return ::faAlerts
               
/*
--------------------------------------------------------------------------------------
Método responsável pela definição da documentação de uma consulta
--------------------------------------------------------------------------------------
*/
method Doc(aDoc) class TDWImportQuery
	property ::faDoc := aDoc
return ::faDoc

/*
--------------------------------------------------------------------------------------
Método responsável pela definição de remoção/sobrescrita de uma consulta
--------------------------------------------------------------------------------------
*/
method Overrided(alValue) class TDWImportQuery
	property ::flOverrided := alValue
return ::flOverrided

/*
--------------------------------------------------------------------------------------
Método responsável pela definição de sucesso de uma importação de uma consulta
--------------------------------------------------------------------------------------
*/
method Sucess(alValue) class TDWImportQuery
	property ::flSucess := alValue
return ::flSucess