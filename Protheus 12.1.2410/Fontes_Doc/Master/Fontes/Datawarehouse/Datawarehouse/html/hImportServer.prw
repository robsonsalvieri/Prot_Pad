// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : Main
// Fonte  : Object - contém os resultados de uma importação de um conexão/server
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 14.02.06 | Paulo R Vieira	| Fase 3
// --------------------------------------------------------------------------------------

#include "dwincs.ch"

/*
--------------------------------------------------------------------------------------
Classe responsável por conter os resultados pela importação de uma conexão
--------------------------------------------------------------------------------------
*/
Class TDWImportServer from TDWObject
	
	data fnID
	data fcName
	data flIgnored
	data flSucess
	
	method New(anID)
	method Free()
	method Clean()
	
	method ID(anID)
	method Name(acValue)
	method Ignored(alValue)
	method Sucess(alValue)
	
EndClass

/*
--------------------------------------------------------------------------------------
Construtor
--------------------------------------------------------------------------------------
*/
method New(anID) class TDWImportServer
	_Super:New()
	::Clean()
	::ID(anID)
return

/*
--------------------------------------------------------------------------------------
Destrutor
--------------------------------------------------------------------------------------
*/
method Free() class TDWImportServer
	::Clean()
	_Super:Free()
return

/*
--------------------------------------------------------------------------------------
Método responsável pela limpeza para o objeto
--------------------------------------------------------------------------------------
*/
method Clean() class TDWImportServer
	::fnID			:= 0
	::fcName		:= ""
	::flIgnored 	:= .F.
	::flSucess		:= .T.
return

/*
--------------------------------------------------------------------------------------
Método responsável pela definição do id da conexão
--------------------------------------------------------------------------------------
*/
method ID(anValue) class TDWImportServer
	property ::fnID := anValue
return ::fnID

/*
--------------------------------------------------------------------------------------
Método responsável pela definição do nome da conexão
--------------------------------------------------------------------------------------
*/
method Name(acValue) class TDWImportServer
	property ::fcName := acValue
return ::fcName

/*
--------------------------------------------------------------------------------------
Método responsável pela definição de remoção/sobrescrita de uma conexão
--------------------------------------------------------------------------------------
*/
method Ignored(alValue) class TDWImportServer
	property ::flIgnored := alValue
return ::flIgnored

/*
--------------------------------------------------------------------------------------
Método responsável pela definição de sucesso de uma importação de uma conexão
--------------------------------------------------------------------------------------
*/
method Sucess(alValue) class TDWImportServer
	property ::flSucess := alValue
return ::flSucess