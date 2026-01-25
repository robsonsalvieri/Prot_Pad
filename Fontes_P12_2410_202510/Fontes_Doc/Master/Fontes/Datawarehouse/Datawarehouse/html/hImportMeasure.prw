// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : Main
// Fonte  : Object - contém os resultados de uma importação de um indicador para uma
//						tabela OU gráfico de uma consulta
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 15.02.06 | Paulo R Vieira	| Fase 3
// --------------------------------------------------------------------------------------

#include "dwincs.ch"

/*
--------------------------------------------------------------------------------------
Classe responsável por conter os resultados pela importação de um indicador
--------------------------------------------------------------------------------------
*/
Class TDWImportMeasure from TDWObject
	
	data fnID
	data flIndExist
	data fcMeasField
	data fcMeasValue
	data flSucess
	
	method New(anID)	
	method ID(anID)
	method Free()
	method Clean()
	method Sucess(alValue)
	
	method IndExist(alValue)
	method MeasureField(acValue)
	method MeasureValue(acValue)
	
EndClass

/*
--------------------------------------------------------------------------------------
Construtor
--------------------------------------------------------------------------------------
*/
method New(anID) class TDWImportMeasure
	_Super:New()
	::Clean()
	::ID(anID)
return

/*
--------------------------------------------------------------------------------------
Destrutor
--------------------------------------------------------------------------------------
*/
method Free() class TDWImportMeasure
	::Clean()
	_Super:Free()
return

/*
--------------------------------------------------------------------------------------
Método responsável pela limpeza para o objeto
--------------------------------------------------------------------------------------
*/
method Clean() class TDWImportMeasure
	::fnID				:= 0
	::flSucess	   		:= .T.
return

/*
--------------------------------------------------------------------------------------
Método responsável pela definição do id
--------------------------------------------------------------------------------------
*/
method ID(anValue) class TDWImportMeasure
	property ::fnID := anValue
return ::fnID

/*
--------------------------------------------------------------------------------------
Método responsável por definir flag da existência ou não do indicador associado a esta medição
--------------------------------------------------------------------------------------
*/
method IndExist(alValue) class TDWImportMeasure
	property ::flIndExist := alValue
return ::flIndExist

/*
--------------------------------------------------------------------------------------
Método responsável pela definição do nome do campo associado a medição
--------------------------------------------------------------------------------------
*/
method MeasureField(acValue) class TDWImportMeasure
	property ::fcMeasField := acValue
return ::fcMeasField

/*
--------------------------------------------------------------------------------------
Método responsável pela definição do valor associado ao campo de medição
--------------------------------------------------------------------------------------
*/
method MeasureValue(acValue) class TDWImportMeasure
	property ::fcMeasValue := acValue
return ::fcMeasValue

/*
--------------------------------------------------------------------------------------
Método responsável pela definição de sucesso da importação
--------------------------------------------------------------------------------------
*/
method Sucess(alValue) class TDWImportMeasure
	property ::flSucess := alValue
return ::flSucess