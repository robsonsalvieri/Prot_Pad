// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : Main
// Fonte  : Object - contém os resultados de uma importação de um data source
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 14.02.06 | Paulo R Vieira	| Fase 3
// --------------------------------------------------------------------------------------

#include "dwincs.ch"

/*
--------------------------------------------------------------------------------------
Classe responsável por conter os resultados pela importação de um data source
--------------------------------------------------------------------------------------
*/
Class TDWImportDS from TDWObject
	
	data fnID
	data fcName
	data fcType
	data faScripts
	data faScheduler
	data flSucess
	
	method New(anID)
	method Free()
	method Clean()
	
	method ID(anID)
	method Name(acValue)
	method TypeConn(acValue)
	method Scripts(aaValue)
	method Schedulers(aaValue)
	method Sucess(alValue)
	
EndClass

/*
--------------------------------------------------------------------------------------
Construtor
--------------------------------------------------------------------------------------
*/
method New(anID) class TDWImportDS
	_Super:New()
	::Clean()
	::ID(anID)
return

/*
--------------------------------------------------------------------------------------
Destrutor
--------------------------------------------------------------------------------------
*/
method Free() class TDWImportDS
	::Clean()
	_Super:Free()
return

/*
--------------------------------------------------------------------------------------
Método responsável pela limpeza para o objeto
--------------------------------------------------------------------------------------
*/
method Clean() class TDWImportDS
	::fnID			:= 0
	::fcName		:= ""
	::flSucess		:= .T.
return

/*
--------------------------------------------------------------------------------------
Método responsável pela definição do id do data source
--------------------------------------------------------------------------------------
*/
method ID(anValue) class TDWImportDS
	property ::fnID := anValue
return ::fnID

/*
--------------------------------------------------------------------------------------
Método responsável pela definição do nome do data source
--------------------------------------------------------------------------------------
*/
method Name(acValue) class TDWImportDS
	property ::fcName := acValue
return ::fcName

/*
--------------------------------------------------------------------------------------
Método responsável pela definição do tipo de conexão do data source
--------------------------------------------------------------------------------------
*/
method TypeConn(acValue) class TDWImportDS
	property ::fcType := acValue 
return ::fcType

/*
--------------------------------------------------------------------------------------
Método responsável pela definição dos scripts do data source
--------------------------------------------------------------------------------------
*/
method Scripts(aaValue) class TDWImportDS
	property ::faScripts := aaValue
return ::faScripts

/*
--------------------------------------------------------------------------------------
Método responsável pela definição dos agendamentos do data source
--------------------------------------------------------------------------------------
*/
method Schedulers(aaValue) class TDWImportDS
	property ::faScheduler := aaValue
return ::faScheduler

/*
--------------------------------------------------------------------------------------
Método responsável pela definição de sucesso de uma importação de um data source
--------------------------------------------------------------------------------------
*/
method Sucess(alValue) class TDWImportDS
	property ::flSucess := alValue
return ::flSucess