// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : Main
// Fonte  : Object - contém os resultados de uma importação de agregados (coordenada X e Y)
//						e dos indicadores para uma tabela OU gráfico de uma consulta
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 15.02.06 | Paulo R Vieira	| Fase 3
// --------------------------------------------------------------------------------------

#include "dwincs.ch"

/*
--------------------------------------------------------------------------------------
Classe responsável por conter os resultados pela importação de um agregado
--------------------------------------------------------------------------------------
*/
Class TDWImportAgregados from TDWObject
	
	data fnID
	data faLevelX
	data faLevelY
	data faMeasures
	data flSucess
	
	method New(anID)
	method Free()
	method Clean()
	
	method ID(anID)
	method AgregX(aaValue)
	method AgregY(aaValue)
	method Measures(aaValue)
	method Sucess(alValue)
	
EndClass

/*
--------------------------------------------------------------------------------------
Construtor
--------------------------------------------------------------------------------------
*/
method New(anID) class TDWImportAgregados
	_Super:New()
	::Clean()
	::ID(anID)
return

/*
--------------------------------------------------------------------------------------
Destrutor
--------------------------------------------------------------------------------------
*/
method Free() class TDWImportAgregados
	::Clean()
	_Super:Free()
return

/*
--------------------------------------------------------------------------------------
Método responsável pela limpeza para o objeto
--------------------------------------------------------------------------------------
*/
method Clean() class TDWImportAgregados
	::fnID				:= 0
	::flSucess	   		:= .T.
return

/*
--------------------------------------------------------------------------------------
Método responsável pela definição do id
--------------------------------------------------------------------------------------
*/
method ID(anValue) class TDWImportAgregados
	property ::fnID := anValue
return ::fnID

/*
--------------------------------------------------------------------------------------
Método responsável pela definição do nome
--------------------------------------------------------------------------------------
*/
method AgregX(aaValue) class TDWImportAgregados
	property ::faLevelX := aaValue
return ::faLevelX

/*
--------------------------------------------------------------------------------------
Método responsável pela definição do Level/Coordernada Y
--------------------------------------------------------------------------------------
*/
method AgregY(aaValue) class TDWImportAgregados
	property ::faLevelY := aaValue
return ::faLevelY

/*
--------------------------------------------------------------------------------------
Método responsável pela definição do measures/indicadores
--------------------------------------------------------------------------------------
*/
method Measures(aaValue) class TDWImportAgregados
	property ::faMeasures := aaValue
return ::faMeasures

/*
--------------------------------------------------------------------------------------
Método responsável pela definição de sucesso da importação
--------------------------------------------------------------------------------------
*/
method Sucess(alValue) class TDWImportAgregados
	property ::flSucess := alValue
return ::flSucess