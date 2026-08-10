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
Class TDWImportScheduler from TDWObject
	
	data fnID
	data fdDtBeg
	data fhHrBeg
	data fdDtEnd
	data fhHrEnd
	data flSucess
	
	method New(anID)
	method Free()
	method Clean()
	
	method ID(anID)
	method DateBegin(acValue)
	method HourBegin(acValue)
	method DateEnd(acValue)
	method HourEnd(acValue)
	method Sucess(alValue)
	
EndClass

/*
--------------------------------------------------------------------------------------
Construtor
--------------------------------------------------------------------------------------
*/
method New(anID) class TDWImportScheduler
	_Super:New()
	::Clean()
	::ID(anID)
return

/*
--------------------------------------------------------------------------------------
Destrutor
--------------------------------------------------------------------------------------
*/
method Free() class TDWImportScheduler
	::Clean()
	_Super:Free()
return

/*
--------------------------------------------------------------------------------------
Método responsável pela limpeza para o objeto
--------------------------------------------------------------------------------------
*/
method Clean() class TDWImportScheduler
	::fnID			:= 0
	::flSucess		:= .T.
return

/*
--------------------------------------------------------------------------------------
Método responsável pela definição do id
--------------------------------------------------------------------------------------
*/
method ID(anValue) class TDWImportScheduler
	property ::fnID := anValue
return ::fnID

/*
--------------------------------------------------------------------------------------
Método responsável pela definição do Data de Início
--------------------------------------------------------------------------------------
*/
method DateBegin(acValue) class TDWImportScheduler
	property ::fdDtBeg := acValue
return ::fdDtBeg

/*
--------------------------------------------------------------------------------------
Método responsável pela definição do Hora de Início
--------------------------------------------------------------------------------------
*/
method HourBegin(acValue) class TDWImportScheduler
	property ::fhHrBeg := acValue
return ::fhHrBeg

/*
--------------------------------------------------------------------------------------
Método responsável pela definição do Data Final
--------------------------------------------------------------------------------------
*/
method DateEnd(acValue) class TDWImportScheduler
	property ::fdDtEnd := acValue
return ::fdDtEnd

/*
--------------------------------------------------------------------------------------
Método responsável pela definição do Hora Final
--------------------------------------------------------------------------------------
*/
method HourEnd(acValue) class TDWImportScheduler
	property ::fhHrEnd := acValue
return ::fhHrEnd

/*
--------------------------------------------------------------------------------------
Método responsável pela definição de sucesso de uma importação
--------------------------------------------------------------------------------------
*/
method Sucess(alValue) class TDWImportScheduler
	property ::flSucess := alValue
return ::flSucess