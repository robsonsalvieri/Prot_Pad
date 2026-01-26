// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : SigaDW
// Fonte  : TDWPrivOper - Define o objeto de operações básicas que o usuário poderá executar
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 21.02.06 |2481-Paulo R Vieira| Versão 3
// --------------------------------------------------------------------------------------

#include "dwincs.ch"

/*
--------------------------------------------------------------------------------------
Classe: TDWPrivileges
Uso   : Define o objeto de privilégios do usuário
--------------------------------------------------------------------------------------
*/
class TDWPrivOper from TDWObject
	
	data flInhDWAcess
	data flDWAcess
	data flInhCreat
	data flCreate
	data flInhMaint
	data flMaintenance
	data flInhAcess
	data flAcess
	data flInhExport
	data flExport
	
	method New() constructor
	method Free()
	method Clean()

	// privilégio de criação herdado
	method CreateInherited(alValue)
	
	// criação
	method Create(alValue)
	
	// privilégio de manutenção herdado
	method MaintInherited(alValue)
	
	// manutenção
	method Maintenance(alValue)
	
	// privilégio de acesso herdado
	method AcessInherited(alValue)
	
	// acesso
	method Acess(alValue)

	// privilégio de exportação herdado
	method ExportInherited(alValue)
	
	// exportação
	method Export(alValue)
	
endclass

/*
--------------------------------------------------------------------------------------
Construtor e destrutor da classe
Args:
--------------------------------------------------------------------------------------
*/
method New() class TDWPrivOper

	_Super:New()
	::Clean()
	
return

method Free() class TDWPrivOper
	
	::Clean()
	_Super:Free()

return

method Clean() class TDWPrivOper
	::flInhDWAcess	:= .F.
	::flDWAcess		:= .F.
    ::flInhCreat	:= .F.
	::flCreate		:= .F.
	::flInhAcess	:= .F.
	::flAcess		:= .F.
	::flInhMaint	:= .F.
	::flMaintenance	:= .F.
	::flInhExport	:= .F.
	::flExport		:= .F.
return

/*
--------------------------------------------------------------------------------------
Propriedade Create/criação herdada
Arg: alValue, lógico, define esta propriedade
Ret: lógico, recupera esta propriedade
--------------------------------------------------------------------------------------
*/
method CreateInherited(alValue) class TDWPrivOper
	property ::flInhCreat := alValue
return ::flInhCreat

/*
--------------------------------------------------------------------------------------
Propriedade Create/criação
Arg: alValue, lógico, define esta propriedade
Ret: lógico, recupera esta propriedade
--------------------------------------------------------------------------------------
*/
method Create(alValue) class TDWPrivOper
	property ::flCreate := alValue
return ::flCreate

/*
--------------------------------------------------------------------------------------
Propriedade Maintenance/manutenção herdada
Arg: alValue, lógico, define esta propriedade
Ret: lógico, recupera esta propriedade
--------------------------------------------------------------------------------------
*/
method MaintInherited(alValue) class TDWPrivOper
	property ::flInhMaint := alValue
return ::flInhMaint

/*
--------------------------------------------------------------------------------------
Propriedade Maintenance/manutenção
Arg: alValue, lógico, define esta propriedade
Ret: lógico, recupera esta propriedade
--------------------------------------------------------------------------------------
*/
method Maintenance(alValue) class TDWPrivOper
	property ::flMaintenance := alValue
return ::flMaintenance

/*
--------------------------------------------------------------------------------------
Propriedade Acess/acesso herdada
Arg: alValue, lógico, define esta propriedade
Ret: lógico, recupera esta propriedade
--------------------------------------------------------------------------------------
*/
method AcessInherited(alValue) class TDWPrivOper
	property ::flInhAcess := alValue
return ::flInhAcess

/*
--------------------------------------------------------------------------------------
Propriedade Acess/acesso
Arg: alValue, lógico, define esta propriedade
Ret: lógico, recupera esta propriedade
--------------------------------------------------------------------------------------
*/
method Acess(alValue) class TDWPrivOper
	property ::flAcess := alValue
return ::flAcess

/*
--------------------------------------------------------------------------------------
Propriedade Export/Exportação herdada
Arg: alValue, lógico, define esta propriedade
Ret: lógico, recupera esta propriedade
--------------------------------------------------------------------------------------
*/
method ExportInherited(alValue) class TDWPrivOper
	property ::flInhExport := alValue
return ::flInhExport

/*
--------------------------------------------------------------------------------------
Propriedade Export/Exportação
Arg: alValue, lógico, define esta propriedade
Ret: lógico, recupera esta propriedade
--------------------------------------------------------------------------------------
*/
method Export(alValue) class TDWPrivOper
	property ::flExport := alValue
return ::flExport