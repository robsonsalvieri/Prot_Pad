// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : Main
// Fonte  : Object - contém os resultados de uma importação de um attributo de uma dimensão ou cubo
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 14.02.06 | Paulo R Vieira	| Fase 3
// --------------------------------------------------------------------------------------

#include "dwincs.ch"

/*
--------------------------------------------------------------------------------------
Classe responsável por conter os resultados pela importação de um attributo de uma dimensão ou cubo
--------------------------------------------------------------------------------------
*/
Class TDWImportAttribute from TDWObject
	
	data fnID
	data fcName
	data fnKeySeq
	data fcClasse
	data fcDimName
	data flDimExist
	data flSucess
	
	method New(anID)
	method Free()
	method Clean()
	
	method ID(anID)
	method Name(acValue)
	method KeySeq(anValue)
	method Classe(acValue)
	method DimExist(alValue)
	method DimName(acValue)
	method Sucess(alValue)
	
EndClass

/*
--------------------------------------------------------------------------------------
Construtor
--------------------------------------------------------------------------------------
*/
method New(anID) class TDWImportAttribute
	_Super:New()
	::Clean()
	::ID(anID)
return

/*
--------------------------------------------------------------------------------------
Destrutor
--------------------------------------------------------------------------------------
*/
method Free() class TDWImportAttribute
	::Clean()
	_Super:Free()
return

/*
--------------------------------------------------------------------------------------
Método responsável pela limpeza para o objeto
--------------------------------------------------------------------------------------
*/
method Clean() class TDWImportAttribute
	::fnID			:= 0
	::fcName		:= ""
	::flSucess		:= .T.
return

/*
--------------------------------------------------------------------------------------
Método responsável pela definição do id do attributo
--------------------------------------------------------------------------------------
*/
method ID(anValue) class TDWImportAttribute
	property ::fnID := anValue
return ::fnID

/*
--------------------------------------------------------------------------------------
Método responsável pela definição do nome do attributo
--------------------------------------------------------------------------------------
*/
method Name(acValue) class TDWImportAttribute
	property ::fcName := acValue
return ::fcName

/*
--------------------------------------------------------------------------------------
Método responsável pela definição do nome do attributo
--------------------------------------------------------------------------------------
*/
method KeySeq(anValue) class TDWImportAttribute
	property ::fnKeySeq := anValue
return ::fnKeySeq

/*
--------------------------------------------------------------------------------------
Método responsável pela definição do nome do attributo
--------------------------------------------------------------------------------------
*/
method Classe(acValue) class TDWImportAttribute
	property ::fcClasse := acValue
return ::fcClasse

/*
--------------------------------------------------------------------------------------
Método responsável pela recuperação da flag se existe ou não a dimensõa para este atributo
--------------------------------------------------------------------------------------
*/
method DimExist(alValue) class TDWImportAttribute
	property ::flDimExist := alValue
return ::flDimExist

/*
--------------------------------------------------------------------------------------
Método responsável pela definição do nome da dimensão relacionada com este attributo
--------------------------------------------------------------------------------------
*/
method DimName(acValue) class TDWImportAttribute
	property ::fcDimName := acValue
return ::fcDimName

/*
--------------------------------------------------------------------------------------
Método responsável pela definição de sucesso de uma importação de um attributo de uma dimensão ou cubo
--------------------------------------------------------------------------------------
*/
method Sucess(alValue) class TDWImportAttribute
	property ::flSucess := alValue
return ::flSucess