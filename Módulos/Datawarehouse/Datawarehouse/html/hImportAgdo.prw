// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : Main
// Fonte  : Object - contém os resultados de uma importação de um agregado (coordenada X OU coordenada Y)
//						para uma tabela OU gráfico de uma consulta
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 15.02.06 | Paulo R Vieira	| Fase 3
// --------------------------------------------------------------------------------------

#include "dwincs.ch"

/*
--------------------------------------------------------------------------------------
Classe responsável por conter os resultados pela importação de um agregado Y
--------------------------------------------------------------------------------------
*/
Class TDWImportAgdo from TDWObject
	
	data fnID
	data flDimExist
	data fnDimID
	data fcDimName
	data fcFieldName
	data fcFieldValue
	data flSucess
	
	method New(anID)
	method DimExist(alValue)
	method DimID(anValue)
	method DimName(acValue)
	method FieldName(acValue)
	method FieldValue(acValue)
	method Free()
	method Clean()
	
	method ID(anID)
	method Sucess(alValue)
	
EndClass

/*
--------------------------------------------------------------------------------------
Construtor
--------------------------------------------------------------------------------------
*/
method New(anID) class TDWImportAgdo
	_Super:New()
	::Clean()
	::ID(anID)
return

/*
--------------------------------------------------------------------------------------
Destrutor
--------------------------------------------------------------------------------------
*/
method Free() class TDWImportAgdo
	::Clean()
	_Super:Free()
return

/*
--------------------------------------------------------------------------------------
Método responsável pela limpeza para o objeto
--------------------------------------------------------------------------------------
*/
method Clean() class TDWImportAgdo
	::fnID				:= 0
	::flSucess	   		:= .T.
return

/*
--------------------------------------------------------------------------------------
Método responsável pela definição do id
--------------------------------------------------------------------------------------
*/
method ID(anValue) class TDWImportAgdo
	property ::fnID := anValue
return ::fnID

/*
--------------------------------------------------------------------------------------
Método responsável por definir flag da existência ou não da dimensão associada a este agregado
--------------------------------------------------------------------------------------
*/
method DimExist(alValue) class TDWImportAgdo
	property ::flDimExist := alValue
return ::flDimExist

/*
--------------------------------------------------------------------------------------
Método responsável pela definição do id da dimensão
--------------------------------------------------------------------------------------
*/
method DimID(anValue) class TDWImportAgdo
	property ::fnDimID := anValue
return ::fnDimID

/*
--------------------------------------------------------------------------------------
Método responsável pela definição do nome da dimensão
--------------------------------------------------------------------------------------
*/
method DimName(acValue) class TDWImportAgdo
	property ::fcDimName := acValue
return ::fcDimName

/*
--------------------------------------------------------------------------------------
Método responsável pela definição do nome do campo
--------------------------------------------------------------------------------------
*/
method FieldName(acValue) class TDWImportAgdo
	property ::fcFieldName := acValue
return ::fcFieldName

/*
--------------------------------------------------------------------------------------
Método responsável pela definição do valor associado ao campo agregado
--------------------------------------------------------------------------------------
*/
method FieldValue(acValue) class TDWImportAgdo
	property ::fcFieldValue := acValue
return ::fcFieldValue

/*
--------------------------------------------------------------------------------------
Método responsável pela definição de sucesso da importação
--------------------------------------------------------------------------------------
*/
method Sucess(alValue) class TDWImportAgdo
	property ::flSucess := alValue
return ::flSucess