// ######################################################################################
// Projeto: DATAWAREHOUSE
// Modulo : ImpExp
// Fonte  : DoImpSQL - Classe para execução de importações SQL
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 01.06.01 | 0548-Alan Candido |
// 13.12.05 | 0548-Alan Candido | Versão 3
// --------------------------------------------------------------------------------------

#include "dwincs.ch"
#include "tbiconn.ch"
#include "protheus.ch"

/*
--------------------------------------------------------------------------------------
Classe: TDoImpSQL
Uso   : Execução de importações SQL
--------------------------------------------------------------------------------------
*/
class TDoImpSQL from TDoImpDBF

	data flDBOpened
	data fcSQL

	method New(aoMakeImp) constructor
	method Free()
	method NewDoImpSQL()
	method FreeDoImpSQL()

	method OpenDB()
	method CloseDB()

	method Open(acSQL)
	method SQL(acValue)
	method RecCount() 
endclass

/*
--------------------------------------------------------------------------------------
Construtor e destrutor da classe
--------------------------------------------------------------------------------------
*/
method New(aoMakeImp) class TDoImpSQL

	::NewDoImpSQL(aoMakeImp)

return
	 
method Free() class TDoImpSQL

	::FreeDoImpSQL()

return

method NewDoImpSQL(aoMakeImp) class TDoImpSQL
     
	::NewDoImpDBF(aoMakeImp)
	::flDBOpened := .f.
	::fcSQL := ""

return
	 
method FreeDoImpSQL() class TDoImpSQL

	::FreeMakeImpDBF()
	
return

/*
--------------------------------------------------------------------------------------
Abre a tabela
--------------------------------------------------------------------------------------
*/
method Open(acSQL) class TDoImpSQL
	local lRet := .f.

	if valType(::Owner()) == "U" .or. valType(::Owner():foRPC) == "U"
		::foSource := TQuery():New(DWMakeName("SQL"))
	else
		::foSource := TRPCTable():New(::Owner():foRPC, DWMakeName("SQL"))
		::OpenDB()
		::foSource:SQL(::SQL())
		lRet := ::foSource:Open()
	endif
	
return lRet

/*
--------------------------------------------------------------------------------------
Abre a base de dados
--------------------------------------------------------------------------------------
*/
method OpenDB() class TDoImpSQL

	if !::flDBOpened
		if SGDB() == DB_DB2400
			::flDBOpened := ::foSource:OpenDB(::Owner():TopServer(), ::Owner():TopTipo(), ;
														::Owner():TopBanco(), ::Owner():TopAlias())
		else
			::flDBOpened := ::foSource:OpenDB(::Owner():TopServer(), ::Owner():TopTipo(), ;
														"@!!@" + ::Owner():TopBanco(), ::Owner():TopAlias())		
		endif 
	endif
	
return ::flDBOpened

/*
--------------------------------------------------------------------------------------
Fecha a base de dados
--------------------------------------------------------------------------------------
*/
method closeDB() class TDoImpSQL

	if ::flDBOpened
		::foSource:closeDB()
		::flDBOpened := .f.
	endif
	
return 

/*
--------------------------------------------------------------------------------------
Propriedade SQL
--------------------------------------------------------------------------------------
*/
method SQL(acValue) class TDoImpSQL

	property ::fcSQL := acValue
		
return ::fcSQL

/*
--------------------------------------------------------------------------------------
Propriedade RecCount
--------------------------------------------------------------------------------------
*/
method RecCount() class TDoImpSQL

return ::foSource:recCount(::fcSQL)	
