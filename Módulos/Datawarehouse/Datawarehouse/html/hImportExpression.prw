// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : Main
// Fonte  : Object - contém os resultados de uma importação de uma expressão de um filtro
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 15.02.06 | Paulo R Vieira	| Fase 3
// --------------------------------------------------------------------------------------

#include "dwincs.ch"

/*
--------------------------------------------------------------------------------------
Classe responsável por conter os resultados pela importação de uma expressão de um filtro
--------------------------------------------------------------------------------------
*/
Class TDWImportExpression from TDWObject
	
	data fnID
	data flIsSQL
	data flDimExist
	data fnDimID
	data fcDimName
	data flDimFldExist
	data fnDimFldID
	data fcDimFldName
	data flSucess
	
	method New(anID)
	method Free()
	method Clean()
	
	method ID(anID)
	method IsSQL(alValue)
	method DimExist(alVAlue)
	method DimID(anID)
	method DimName(acVAlue)
	method DimFldExist(alVAlue)
	method DimFldID(anID)
	method DimFldName(acVAlue)
	method Sucess(alValue)
	
EndClass

/*
--------------------------------------------------------------------------------------
Construtor
--------------------------------------------------------------------------------------
*/
method New(anID) class TDWImportExpression
	_Super:New()
	::Clean()
	::ID(anID)
return

/*
--------------------------------------------------------------------------------------
Destrutor
--------------------------------------------------------------------------------------
*/
method Free() class TDWImportExpression
	::Clean()
	_Super:Free()
return

/*
--------------------------------------------------------------------------------------
Método responsável pela limpeza para o objeto
--------------------------------------------------------------------------------------
*/
method Clean() class TDWImportExpression
	::fnID				:= 0
	::flSucess	   		:= .T.
return

/*
--------------------------------------------------------------------------------------
Método responsável pela definição do id deste filtro
--------------------------------------------------------------------------------------
*/
method ID(anValue) class TDWImportExpression
	property ::fnID := anValue
return ::fnID

/*
--------------------------------------------------------------------------------------
Método responsável por definir flag se esta expressão é SQL ou QBE
--------------------------------------------------------------------------------------
*/
method IsSQL(alValue) class TDWImportExpression
	property ::flIsSQL := alValue
return ::flIsSQL

/*
--------------------------------------------------------------------------------------
Método responsável por definir flag da existência ou não da dimensão associada
--------------------------------------------------------------------------------------
*/
method DimExist(alVAlue) class TDWImportExpression
	property ::flDimExist := alValue
return ::flDimExist

/*
--------------------------------------------------------------------------------------
Método responsável pela definição do id da dimensão associada
--------------------------------------------------------------------------------------
*/
method DimID(anValue) class TDWImportExpression
	property ::fnDimID := anValue
return ::fnDimID

/*
--------------------------------------------------------------------------------------
Método responsável pela definição do nome da dimensão associada
--------------------------------------------------------------------------------------
*/
method DimName(acValue) class TDWImportExpression
	property ::fcDimName := acValue
return ::fcDimName

/*
--------------------------------------------------------------------------------------
Método responsável por definir flag da existência ou não na dimensão do campo utilizado pela expressão
--------------------------------------------------------------------------------------
*/
method DimFldExist(alVAlue) class TDWImportExpression
	property ::flDimFldExist := alValue
return ::flDimFldExist

/*
--------------------------------------------------------------------------------------
Método responsável pela definição do id do campo da dimensão utilizada na expressão
--------------------------------------------------------------------------------------
*/
method DimFldID(anValue) class TDWImportExpression
	property ::fnDimFldID := anValue
return ::fnDimFldID

/*
--------------------------------------------------------------------------------------
Método responsável pela definição do nome do campo da dimensão utilizada na expressão
--------------------------------------------------------------------------------------
*/
method DimFldName(acValue) class TDWImportExpression
	property ::fcDimFldName := acValue
return ::fcDimFldName

/*
--------------------------------------------------------------------------------------
Método responsável pela definição de sucesso de uma importação desta expressão
--------------------------------------------------------------------------------------
*/
method Sucess(alValue) class TDWImportExpression
	property ::flSucess := alValue
return ::flSucess