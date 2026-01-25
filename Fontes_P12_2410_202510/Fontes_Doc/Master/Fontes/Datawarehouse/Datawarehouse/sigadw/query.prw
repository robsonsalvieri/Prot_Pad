// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : SigaDW
// Fonte  : Query - Objeto TQuery, acesso as tabelas da base de dados via comando SQL
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 01.06.01 | 0548-Alan Candido |
// 14.11.07 | 0548-Alan Candido | BOPS 135941 - Correção na deleção do indice primário em SGDB DB2
// 23.11.07 | 0548-Alan Candido | BOPS 136453 - Implementação de "rename table" (EX_REN_TABLE)
// 29.11.07 | 0548-Alan Candido | BOPS 137031 - Ajuste na execução do comando EX_REN_TABLE
//          |                   |   de forma a notificar o TC do procedimento, devido a erro na migração
// 18.01.08 | 0548-Alan Candido | BOPS 139342 - Implementação e adequação de código, 
//          |                   | em função de re-estruturação para compartilhamento de 
//          |                   | código.
// 26.02.08 | 0548-Alan Candido | BOPS 141024 - Ajuste na execução do comando EX_REN_TABLE
//          |                   |   para os SGDB Informix e DB2
// 10.04.08 | 0548-Alan Candido | BOPS 142154
//          |                   | Implementação do tratamento da macro @dwref
// --------------------------------------------------------------------------------------

#include "dwincs.ch"
#include "TopConn.ch"
#include "query.ch"

#define EXEC_SELECT 0
#define EXEC_DELETE 1

/*
--------------------------------------------------------------------------------------
Classe: TQuery
Uso   : Acesso a tabela de dados via comando SQL
--------------------------------------------------------------------------------------
*/
class TQuery from TTable

	data fcSQL
	data fbNext	               
	data fcFieldList
	data fcFromList
	data fcWhereClause          
	data fcHavingClause          
	data fcOrderBy
	data fcGroupBy          
	data flDistinct
	data fnTop
	data flWithDel
	data fnExecOper
	data faParams
 	data fnRecLimit
	data fnLastRec 
	data fnSubtype 
	data fcSQLInUse
	data flEmbeddedSQL
				 	
	method New(acQueryname, acAlias) constructor
	method Free()
	method SQL(ign,acSQL)
	method FieldList(acValue)
	method FromList(acValue)
	method WhereClause(acValue)
	method HavingClause(acValue)
	method OrderBy(acValue)
	method GroupBy(acValue)
	method MakeDistinct(alValue)
	method Filter(acValue)
	method WithDeleted(alValue)
	method Clear()
	method Exists()
	method Open(alResetFields, acSQL, alMacroAt)
	method Append(aaValues)
	method Update(aaFields, anRecno)
	method Value(acnField, alTrim)
	method RecCount(lCount, acFilename)
	method MaxRecno(acFilename)
	method ExecDel()
	method Execute(acTipo, acNome, acParam)
	method InsertInto(aaFieldList, acTablename, alTwoPhases, acSQL, alSortFields) 
	method SelectInto(aaFieldList, acTablename, acSQL) 
	method Select2(aaFieldList, acTablename, acSQL) 
	method Merge(aaFieldList, acTablename) 
	method ExecSQL(acSQL)
	method adjustField(aaFieldList)
	method params(anNumber, acValue)
	method AddParam(acName, acValue)
	method _Next()
	method _NextDist()
	method RecLimit(anValue)
	method Eof()              
	method SubType(anValue)
	method SaveCursor(acTablename, acSQL, aaStruc, alRenum)
	method SQLInUse()
	method EmbeddedSQL(alValue)
endclass

/*
--------------------------------------------------------------------------------------
Construtor e destrutor da classe
Args: acQueryname -> string, nome da tabela
--------------------------------------------------------------------------------------
*/
method New(acQueryname, acAlias) class TQuery
	_Super:New(acQueryname, acAlias)
	::Clear()
return

method Free() class TQuery
	_Super:Free()
return
   
/*
--------------------------------------------------------------------------------------
Limpa as propriedades
--------------------------------------------------------------------------------------
*/                         
method Clear() class TQuery
             
	::fcSQL := ""
	::fcFieldList := ""
	::fcFromList := ""
	::fcWhereClause := ""
	::fcHavingClause := ""
	::fcOrderBy := ""
	::fcGroupBy := ""
	::flDistinct := .f.
	::fbNext := { || _Super:_Next() }
	::faFields := {}
	::flWithDel := .F.
	::fnExecOper := EXEC_SELECT
	::faParams := {}
	::fnRecLimit := 0
	::fnLastRec := 0
	::fnSubtype  := ST_DEFAULT
	::flEmbeddedSQL := .f.

return

/*
--------------------------------------------------------------------------------------
Propriedade SQL
--------------------------------------------------------------------------------------
*/                         
method SQL(ign, acSQL) class TQuery
	local cRet, cFrom := ::FromList(), aWhere, aFrom, nInd, aAux
	local nPos, nPosF, cAux, cAux2, cAlvo, cFromList, x
	               
	default acSQL := ""
	
	if !empty(acSQL)
		::fcSQL := acSQL 
		cRet := ::fcSQL
	elseif !empty(::fcSQL)
		cRet := ::fcSQL
	else	
		if empty(cFrom)
			cFrom := ::Tablename()
		endif                             

		cFromList := cFrom
		
		if ::fnExecOper == EXEC_SELECT
			::fnLastRec := 0
			cRet := DWConcatWSep(" ", "select", iif(::MakeDistinct(), "distinct", ""), ;
						 iif(SGDB() $ DB_MSSQL_ALL .and. ::RecLimit()<>0,"top " + DWStr(::RecLimit()),""), ;
						 ::FieldList(), "from", cFrom)
		elseif ::fnExecOper == EXEC_DELETE
			aFrom := DWToken(alltrim(cFrom), ",", .f.)
			if SGDB() == DB_ORACLE
				cRet := DWConcatWSep(" ", "delete ", cFrom)
			else
				if len(aFrom) == 1 
					cRet := DWConcatWSep(" ", "delete from ", cFrom)
				else                          
					cRet := DWConcatWSep(" ", "delete", aFrom[1], "from", cFrom)
				endif
			endif
		else
			cRet := "( " + STR0001 + " )"  //"operacao invalida"
		endif	

		if !empty(::WhereClause())
			cRet := DWConcatWSep(" ", cRet, "where", ::WhereClause())
		endif
		if !empty(::Filter())
			if empty(::WhereClause())
				cRet := DWConcatWSep(" ", cRet, "where", ::Filter())
			else
				cRet := DWConcatWSep(" ", cRet, "and", ::Filter())
			endif
		endif
		if !::WithDeleted()
			aWhere := {}
			aFrom := DWToken(alltrim(cFromList), ",", .f.)
			for nInd := 1 to len(aFrom)
				aAux := DWToken(alltrim(aFrom[nInd]), " ", .f.)
				if len(aAux) == 1
					aAdd(aWhere, aAux[1] + "." + DWDelete() + " <> '*'")
				else	
					aAdd(aWhere, aAux[2] + "." + DWDelete() + " <> '*'")
				endif
			next
			if empty(::WhereClause())
				cRet := DWConcatWSep(" ", cRet, "where", DWConcatWSep(" and ", aWhere))
			else
				aWhere := aSize(aWhere, len(aWhere)+1)
				aWhere := aIns(aWhere, 1)            
				aWhere[1] := cRet
				cRet := DWConcatWSep(" and ", aWhere)
			endif              
		endif
		
    if right(cRet, 5) == " and "
			cRet := substr(cRet, 1, len(cRet)-4)      
		endif
		
		if ::fnExecOper == EXEC_SELECT
			if !empty(::GroupBy())
				cRet := DWConcatWSep(" ", cRet, "group by", ::GroupBy())
			endif  

			if !empty(::HavingClause())
				cRet := DWConcatWSep(" ", cRet, "having", ::HavingClause())
			endif                                                        

			if !empty(::OrderBy())
				cRet := DWConcatWSep(" ", cRet, "order by", ::OrderBy())
			endif  
			
			if SGDB() == DB_POSTGRES .and. ::RecLimit()<>0
			   cRet := DWConcatWSep(" ", cRet, "limit", ::RecLimit())
			endif
		endif  
	endif  

	if ::fnExecOper == EXEC_SELECT
		if SGDB() == DB_ORACLE .and. ::RecLimit()<>0
			cRet := "select * from (" + cRet + ") x where rownum <= "+DWStr(::RecLimit())
		endif
	endif
	
	for nInd := 1 to len(::faParams)
		x := ::faParams[nInd]
		cAux := x[2]
		if valtype(cAux) == "C"
			cAux := delAspasSimples(cAux) 
			if len(cAux) == 10 .and. ;
				((substr(cAux, 3,1) == "/" .and. substr(cAux, 6,1) == "/") .or.; // DD/MM/AAAA
				 (substr(cAux, 5,1) == "/" .and. substr(cAux, 8,1) == "/")) // AAAA/MM/DD
				cAux := "'" + dtos(ctod(cAux)) + "'"
			elseif left(cAux,1) == "&"
				cAux := &(substr(cAux,2))
			endif
		elseif valtype(cAux) == "N" .and. empty(cAux)
			cAux := 0
		elseif valtype(cAux) == "D"
			cAux := dtos(cAux)
		endif
		cRet := strTran(cRet, "[" + x[1] + "]", DWStr(cAux,.T.))
	next

	while (nPos := at("[", cRet)) > 0
		nPosF := at("]", substr(cRet, nPos)) 
		cAlvo := substr(cRet, nPos, nPosF)
		cAux := substr(cRet, nPos+1, nPosF-2)
		if !("RETURN" $ upper(cAux))
			cAux := "return(iif(valtype("+cAux+")=='U',0, dwStr("+cAux+")))"
		endif
		cAux2 := ""
		if execSintax(cAux, @cAux2, .f.)
			if len(cAux2) == 10 .and. ;
				((substr(cAux2, 3,1) == "/" .and. substr(cAux2, 6,1) == "/") .or.; // DD/MM/AAAA
				 (substr(cAux2, 5,1) == "/" .and. substr(cAux2, 8,1) == "/")) // AAAA/MM/DD
				cAux2 := "'" + dtos(ctod(cAux2)) + "'"
			endif
			cRet := strTran(cRet, cAlvo, cAux2)
		else
			cRet := strTran(cRet, cAlvo, '0')
		endif
	enddo

	if ::EmbeddedSQL()
		cRet := DWBuildEmbSQL(::Alias(), cRet, /*aaEmpComp*/, /*DWDIRINCLUDE(),*/ , DWDSEmp(), DWDSFil())
	endif
				
return cRet

/*
--------------------------------------------------------------------------------------
Verifica se a tabela existe
Args: 
Rets: lRet -> lógico, indica a existencia ou não da tabela
--------------------------------------------------------------------------------------
*/                         
method Exists() class TQuery

return !empty(::SQL())

/*
--------------------------------------------------------------------------------------
Abra a tabela para uso
Args: 
Rets: lRet -> lógico, indica se a abertura foi bem suscedida
--------------------------------------------------------------------------------------
*/                         
method Open(alResetFields, acSQL, alMacroAt) class TQuery
	local lRet := .t.
	local aFName, aTypes, aLen, aDec, nFCount, nInd
	local aFieldList, cSQL, x, cAux
	local cAlvo, cAux2, nPosF, nPos
		
	default alResetFields := .f.
	default acSQL := ::SQL()
	default alMacroAt := SGDB() <> DB_DB2400
	
	if ::IsOpen()	
		::Close()
	endif  

	if "[" $ acSQL
		for nInd := 1 to len(::faParams)
			x := ::faParams[nInd]
			cAux := x[2]
			if valtype(cAux) == "C"
				cAux := delAspasSimples(cAux) 
				if len(cAux) == 10 .and. ;
					((substr(cAux, 3,1) == "/" .and. substr(cAux, 6,1) == "/") .or.; // DD/MM/AAAA
					 (substr(cAux, 5,1) == "/" .and. substr(cAux, 8,1) == "/")) // AAAA/MM/DD
					cAux := "'" + dtos(ctod(cAux)) + "'"
				elseif left(cAux,1) == "&"
					cAux := &(substr(cAux,2))
				endif
			elseif valtype(cAux) == "D"
				cAux := dtos(cAux)
			elseif valtype(cAux) == "N" .and. empty(cAux)
				cAux := "0"
			endif
			acSQL := strTran(acSQL, "[" + x[1] + "]", DWStr(cAux))
		next

		while (nPos := at("[", acSQL)) > 0
			nPosF := at("]", substr(acSQL, nPos)) 
			cAlvo := substr(acSQL, nPos, nPosF)
			cAux := substr(acSQL, nPos+1, nPosF-2)
			if !("RETURN" $ upper(cAux))
				cAux := "return(iif(valtype("+cAux+")=='U',0, DWStr("+cAux+")))"
			endif
			cAux2 := ""
			if execSintax(cAux, @cAux2, .f.)
				if len(cAux2) == 10 .and. ;
					((substr(cAux2, 3,1) == "/" .and. substr(cAux2, 6,1) == "/") .or.; // DD/MM/AAAA
					 (substr(cAux2, 5,1) == "/" .and. substr(cAux2, 8,1) == "/")) // AAAA/MM/DD
					cAux2 := "'" + dtos(ctod(cAux2)) + "'"
				endif
				acSQL := strTran(acSQL, cAlvo, cAux2)
			else
				acSQL := strTran(acSQL, cAlvo, '0')
			endif
		enddo
	endif
	
	if alMacroAt
		cSQL := DWParseSQL(DWMacroAt2(acSQL,,,::SubType()))   
	else
		cSQL := DWParseSQL(acSQL)
	endif              
	
	                              
	tcquery (dwStripChr(cSQL)) alias (::Alias()) new
	::fcSQLInUse := cSQL
	
	if len(::Fields()) == 0 .or. alResetFields
		::ResetFields()
		nFCount := fCount()
		aFName := array(nFCount)
		aTypes := array(nFCount)
		aLen   := array(nFCount)
		aDec   := array(nFCount)
		aFields(aFName, aTypes, aLen, aDec)
		
		for nInd := 1 to nFCount
			::AddField(nil, aFName[nInd], aTypes[nInd], aLen[nInd], aDec[nInd])
		next
	else
		aFieldList := ::Fields()
		for nInd := 1 to len(aFieldList)
			if aFieldList[nInd, FLD_TYPE] <> "C"
				::setField(aFieldList[nInd, FLD_NAME], aFieldList[nInd, FLD_TYPE], aFieldList[nInd, FLD_LEN], aFieldList[nInd, FLD_DEC])
			endif
		next
	endif
	::fnLastRec := 0
return lRet

/*
--------------------------------------------------------------------------------------
Executa um update na base
Args: aaFields -> array, lista de campos a atualizar
		anRecno -> numérico, recno a ser atualizado
Rets: lRet -> lógico, indica se a execução foi OK
--------------------------------------------------------------------------------------
*/                         
method Update(aaFields, anRecno) class TQuery
	local lRet := .t., cSQL := "", nInd
	local cTablename := ::Tablename()
	
	if empty(cTablename)
		cTablename := ::FromList()
	endif
	
	cSQL += "update " +  cTablename + " set "
	for nInd := 1 to len(aaFields)
		cSQL += upper(aaFields[nInd,1]) + " = "
		if left(dwStr(aaFields[nInd,2]),1) == "&"
			cSQL += substr(aaFields[nInd,2],2)
		elseif valtype(aaFields[nInd,2]) == "C"
			cSQL += DWStr(aaFields[nInd,2],.t.)
		elseif valtype(aaFields[nInd,2]) == "D"
			cSQL += DWStr(dtos(aaFields[nInd,2]),.t.)
		elseif valtype(aaFields[nInd,2]) == "L"
			cSQL += iif(aaFields[nInd,2], "'T'", "'F'")
		else
			cSQL += DWStr(aaFields[nInd,2])
		endif				
		cSQL += ","
	next                                                        
	cSQL := left(cSQL, len(cSQL) - 1)

	if valType(anRecno) == "U"
		cSQL += " where ID = " + DWStr(::value("id"))
	elseif valType(anRecno) == "N"
		if anRecno < 0
			if !empty(::WhereClause())
				cSQL := DWConcatWSep(" ", cSQL, "where", ::WhereClause())
			endif
		else
			cSQL += " where R_E_C_N_O_ = " + DWStr(anRecno)
		endif
	endif
		
	if ::ExecSQL(cSQL) != 0
		DWLog(STR0008, cSQL, ::Msg())  //"Erro SQL"
		lRet := .f.
	endif

return lRet

/*
--------------------------------------------------------------------------------------
Propriedade FieldList
Args: acValue -> string, lista de campos
Rets: CRet -> string, lista de campos
--------------------------------------------------------------------------------------
*/                         
method FieldList(acValue) class TQuery
	
	property ::fcFieldList := acValue
	
return ::fcFieldList
           
/*
--------------------------------------------------------------------------------------
Metodo SQLInUse
--------------------------------------------------------------------------------------
*/                         
method SQLInUse() class TQuery
	
return ::fcSQLInUse
               
/*
--------------------------------------------------------------------------------------
Metodo SQLInUse
--------------------------------------------------------------------------------------
*/                         
method EmbeddedSQL(alValue) class TQuery
                      
	property ::flEmbeddedSQL := alValue

return ::flEmbeddedSQL

/*
--------------------------------------------------------------------------------------
Propriedade FromList
Args: acValue -> string, lista de from
Rets: cRet -> string, lista de from
--------------------------------------------------------------------------------------
*/                         
method FromList(acValue) class TQuery

	property ::fcFromList := acValue

return ::fcFromList

/*
--------------------------------------------------------------------------------------
Propriedade WhereClause
Args: acValue -> string, clausula where
Rets: cRet -> string, clausula where
--------------------------------------------------------------------------------------
*/                         
method WhereClause(acValue) class TQuery

	property ::fcWhereClause := acValue

return ::fcWhereClause

/*
--------------------------------------------------------------------------------------
Propriedade HavingClause
Args: acValue -> string, clausula where
Rets: cRet -> string, clausula where
--------------------------------------------------------------------------------------
*/                         
method HavingClause(acValue) class TQuery

	property ::fcHavingClause := acValue

return ::fcHavingClause

/*
--------------------------------------------------------------------------------------
Propriedade OrderBy
Args: acValue -> string, clausula OrderBy
Rets: cRet -> string, clausula OrderBy
--------------------------------------------------------------------------------------
*/                         
method OrderBy(acValue) class TQuery

	property ::fcOrderBy := acValue

return ::fcOrderBy

/*
--------------------------------------------------------------------------------------
Propriedade Distinct
Args: alValue -> logico, ativa/desativa clausula Distinct
Rets: lRet -> logico, status da clausula Distinct
--------------------------------------------------------------------------------------
*/                         
method MakeDistinct(alValue) class TQuery
                                    
	property ::flDistinct := alValue
	if valType(alValue) == "L" 
		::fbNext := iif(alValue, { || ::_NextDist() }, { || _Super:_Next() })
	endif

return ::flDistinct

/*
--------------------------------------------------------------------------------------
Propriedade GroupBy
Args: acValue -> string, clausula GroupBy
Rets: cRet -> string, clausula GroupBy
--------------------------------------------------------------------------------------
*/                         
method GroupBy(acValue) class TQuery

	property ::fcGroupBy := acValue

return ::fcGroupBy

/*
--------------------------------------------------------------------------------------
Propriedade Filter
Args: acValue -> string, clausula do filtro
Rets: cRet -> string, clausula do filtro
--------------------------------------------------------------------------------------
*/                         
method Filter(acValue) class TQuery
	local oldValue := ::fcFilter

	property ::fcFilter := acValue
   if oldValue != ::fcFilter
		if ::IsOpen()
			::Close()
			::Open()
		endif   	
   endif  
   
return ::fcFilter

/*
--------------------------------------------------------------------------------------
Propriedade WithDeleted
Args: alValue -> logico, liga/desliga registros deletados
Rets: lRet -> logico, estado atual
--------------------------------------------------------------------------------------
*/                         
method WithDeleted(alValue) class TQuery

	property ::flWithDel := alValue
	
return ::flWithDel

/*
--------------------------------------------------------------------------------------
Retorna o valor de um campo
Args: acnField -> string ou numerico, nome ou posição do campo
Rets: xRet -> , valor do campo
--------------------------------------------------------------------------------------
*/                         
method Value(acnField, alTrim) class TQuery
	local xRet := _Super:Value(acnField)

	default alTrim := .T.
	
	if valType(acnField) == "C"
		acnField := upper(acnField)
		xRet := DWConvTo(::Fields(acnField)[2], xRet)
	endif	
	if valType(xRet) == "C" .and. alTrim		
		xRet := Trim(xRet)
	endif

return xRet

/*
--------------------------------------------------------------------------------------
Adiciona um novo registro
Args: aaValues -> array, lista de campos a anexar
Rets: lRet -> lógico, insersão bem suscedida ou não
--------------------------------------------------------------------------------------
*/                         
method Append(aaValues) class TQuery

	local lRet  := .F.
	local nInd  := 0
	local nPos  := 0
	local cSQL  := ""
	
	for nInd := 1 to len(::Fields())	
		if aScan(aaValues, { |x| x[1] == ::Fields()[nInd, 1] }) == 0
			aAdd(aaValues, { ::Fields()[nInd, 1], ::Fields()[nInd, 5]})
		endif
	next

	for nInd := 1 to len(aaValues)	
		aaValues[nInd, 2] := DWConvTo(::Fields(aaValues[nInd,1])[2], aaValues[nInd, 2])
		aaValues[nInd, 2] := DWStr(aaValues[nInd, 2],.t.)
	next

	if select(::Tablename()) == 0
		InitTable(TAB_LOG)
	endif
		dbSelectArea(::Tablename())
		dbAppend(.f.)
		for nInd := 1 to len(aaValues)	               
			FieldPut(aaValues[nInd, 1], aaValues[nInd, 2])
		next
      dbrUnlock()
	
return lRet

/*
--------------------------------------------------------------------------------------
Retorna numero de registros
Args: lCount -> logico, executa um MAX via comando SQL
Rets: nRet -> numerico, numero de registros da tabela
--------------------------------------------------------------------------------------
*/                         
method RecCount(lCount, acFilename) class TQuery
	local nRet := 0
	local cOrder := ""
	local cOldAlias := ""
	local nPos := 0
	local oQuery
	
	default acFilename := ""
	
	cOldAlias := alias()
	cOrder := ::OrderBy()
	::OrderBy("")
	oQuery := TQuery():New(DWMakeName("TRA"))
	oQuery:subType(::subType())
	
	if !empty(acFilename) 
	
		if ("select" $ lower(acFilename))
			cSQL := acFilename
		else
			cSQL := "select count(*) from " + acFilename
		endif
	elseif ::isOpen()  
	
		cSQL := ::sqlInUse()		
		nPos := at("ORDER BY", upper(cSQL))
		
		if nPos > 0
			cSQL := substr(cSQL, 1, nPos - 1 )
		endif
	else
		cSQL := ::sql()
	endif   
	
	if SGDB() == DB_INFORMIX
		cSQL := "select count(*) from table ( multiset ( " + cSQL + ") ) x"
	else
		cSQL := "select count(*) from (" + cSQL + ") x"
	endif  
	
	oQuery:SQL(, StrTran(cSQL, '"', "'") )
	oQuery:Open()
	nRet := oQuery:value(1)
	oQuery:Close()
	
	if !empty(cOldAlias)
		dbSelectArea(cOldAlias)
	endif            
	
	::OrderBy(cOrder)
	
return nRet


/*
--------------------------------------------------------------------------------------
Retorna o maior R_E_C_N_O_ 
--------------------------------------------------------------------------------------
*/                         
method MaxRecno(acFilename) class TQuery
	local nRet := 0
	local cOldAlias := ""
	local oQuery

	cOldAlias := alias()  

 	oQuery := TQuery():New(DWMakeName("TRA"))
 	oQuery:FieldList("max(R_E_C_N_O_)")
	oQuery:FromList(acFilename)
	oQuery:WithDeleted(.t.)
	oQuery:Open()
	nRet := oQuery:value(1)
	oQuery:Close()

	if !empty(cOldAlias)
		dbSelectArea(cOldAlias)
	endif

return nRet

/*
--------------------------------------------------------------------------------------
Monta comando SQL para insert into
--------------------------------------------------------------------------------------
*/                         
method InsertInto(aaFieldList, acTablename, alTwoPhases, acSQL, alSortFields) class TQuery

local cRet   := ""
local cOrder := ""
local cAux   := ""
local nInd   := 0
local nPos   := 0
local aGroup := {}
local aRet   := {}
local aAux   := {}
local aAux2  := {}
local aAux3  := {}

default alSortFields := .T.
default alTwoPhases  := .F.
default acSQL        := ::SQL(.T.)


cOrder := ::OrderBy()
::OrderBy("")

if alSortField
	aAux := dwTokenAdv(::FieldList(), ",", { "()" }) //aspas são ignoradas automaticamente
	aAux3 := array(len(aaFieldList))

	for nInd := 1 to len(aAux)
		nPos := rat(" ", aAux[nInd])
		if nPos == 0
			aAux2 := { aAux[nInd], aAux[nInd] }
		else
			aAux2 := { substr(aAux[nInd], 1, nPos - 1), substr(aAux[nInd] , nPos + 1)}
		endif
		if (nPos := at(".", aAux2[2])) <> 0
			aAux2[2] := substr(aAux2[2], nPos + 1)
		endif
		nPos := ascan(aaFieldList, { |x| x==aAux2[2]})
		aAux3[nPos] := dwStr(aAux2[1]) + " " + dwStr(aAux2[2])
	next
	::FieldList(dwConcatWSep(",", aAux3) )
endif

if !alTwoPhases
	if SGDB() = DB_ORACLE .and. ( nPos := ascan(aaFieldList, { |x| x == 'R_E_C_N_O_'})) <> 0
		aDel(aaFieldList, nPos)
		aaFieldList[len(aaFieldList)] := 'R_E_C_N_O_'
		acSQL := strTran(acSQL, "0 R_E_C_N_O_,", "")
		acSQL := strTran(acSQL, "R_E_C_N_O_,", "")
		                                    
		cRet := "insert into " + acTablename + " (" + DWConcatWSep(",",	aaFieldList) + ") " + ;
				"select X.*, ("+dwStr(::MaxRecno(acTablename))+"+rownum) R_E_C_N_O_ from ( " + acSQL + ") X"
	else
		cRet := "insert into " + acTablename + " (" + DWConcatWSep(",",	aaFieldList) + ") " + acSQL
	endif
else
	aGroup := {}
	aRet := array(8)
	
	if SGDB() $ DB_MSSQL_ALL	
		aRet[1] := "if object_id('V_" + acTablename+"') > 0 then drop view V_" + acTablename
	else
		aRet[1] := "drop view V_" + acTablename
	endif
	aRet[2] := "go"
	aRet[3] := "create view V_" + acTablename + " (" + DWConcatWSep(",", aaFieldList) + ") as " + acSQL
	aRet[4] := "go"
	cRet := "insert into " + acTablename + " (" + DWConcatWSep(",",	aaFieldList) + ") select" + CRLF
	for nInd := 1 to len(aaFieldList)
		if left(aaFieldList[nInd], 1) == "I"
			cRet += DWAggFuncText(dwVal(substr(aaFieldList[nInd],2,1)), .f.) +	"(" +aaFieldList[nInd] + ")"
		elseif aaFieldList[nInd] == "R_E_C_N_O_"
			cRet += "max(R_E_C_N_O_)"
		else
			cRet += aaFieldList[nInd]
			aAdd(aGroup, aaFieldList[nInd])
		endif
		if nInd < len(aaFieldList)
			cRet += ","
		endif
	next
	cRet += " from V_" + acTablename + CRLF
	cRet += "group by " + dwConcatWSep(",", aGroup)
	aRet[5] := cRet
	aRet[6] := "go"
	if SGDB() $ DB_MSSQL_ALL	
		aRet[7] := "if object_id('V_" + acTablename+"') > 0 then drop view V_" + acTablename
	else
		aRet[7] := "drop view V_" + acTablename
	endif
	aRet[8] := "go"
	cRet := aRet
endif
::OrderBy(cOrder)

return cRet

/*
--------------------------------------------------------------------------------------
Monta comando SQL para MERGE (somente Oracle)
--------------------------------------------------------------------------------------
*/                         
method Merge(aaFieldList, acTablename, aaKeys) class TQuery
	local cRet := "", cOrder := "", nInd, aGroup, aRet
	local aAux, aAux2, cAux, aAux3, nPos, aAux4 
    local cSQL
    
	cOrder := ::OrderBy()
	::OrderBy("")

	aAux := dwTokenAdv(::FieldList(), ",", { "()" }) //aspas são ignoradas automaticamente
	aAux3 := array(len(aaFieldList))
	aAux4 := array(len(aaFieldList))
	
	for nInd := 1 to len(aAux)
		nPos := rat(" ", aAux[nInd])
		if nPos == 0
			aAux2 := { aAux[nInd], aAux[nInd] }
		else
			aAux2 := { substr(aAux[nInd], 1, nPos - 1), substr(aAux[nInd] , nPos + 1)}
		endif
		if (nPos := at(".", aAux2[2])) <> 0
			aAux2[2] := substr(aAux2[2], nPos + 1)
		endif
		nPos := ascan(aaFieldList, { |x| x==aAux2[2]})
		aAux3[nPos] := dwStr(aAux2[1]) + " " + dwStr(aAux2[2])
		aAdd(aAux4, dwStr(aAux2[2]))
	next
	::FieldList(dwConcatWSep(",", aAux3) )

	cSQL := ::SQL(.t.)

	aDel(aaFieldList, nPos)
	aaFieldList[len(aaFieldList)] := 'R_E_C_N_O_'
	cSQL := strTran(cSQL, "0 R_E_C_N_O_,", "")
	cSQL := strTran(cSQL, "R_E_C_N_O_,", "")

	aAux := {}
	aEval(aaKeys, { |x| aAdd(aAux, "D." + x + "=S."+ x)})

	cRet := "merge into " + acTablename + " D using (" + ;
			"select X.*, rownum R_E_C_N_O_ from ( " + cSQL + ") X ) S ON (" + ;
			dwConcatWSep(" and ", aAux) + ") " +;
			"when matched then update set D.R_E_C_N_O_ = 0 " + ;
			"when not matched then insert ( D." +; 
			dwConcatWSep(",D.", aAux4) + ")" + ;
			"values( S." +; 
			dwConcatWSep(",S.", aAux4) + ")"

	::OrderBy(cOrder)

return cRet

/*
--------------------------------------------------------------------------------------
Monta comando SQL para select into
--------------------------------------------------------------------------------------
*/                         
method SelectInto(aaFieldList, acTablename, acSQL) class TQuery
	local cRet := "", cOrder := "", nInd, aGroup, aRet
	local aAux, aAux2, cAux, aAux3, nPos
	default acSQL := ::SQL(.T.)

	cOrder := ::OrderBy()
	::OrderBy("")

	aAux := dwTokenAdv(::FieldList(), ",", { "()" }) //aspas são ignoradas automaticamente
	aAux3 := array(len(aaFieldList))

	for nInd := 1 to len(aAux)
		nPos := rat(" ", aAux[nInd])
		if nPos == 0
			aAux2 := { aAux[nInd], aAux[nInd] }
		else
			aAux2 := { substr(aAux[nInd], 1, nPos - 1), substr(aAux[nInd] , nPos + 1)}
		endif
		if (nPos := at(".", aAux2[2])) <> 0
			aAux2[2] := substr(aAux2[2], nPos + 1)
		endif
		nPos := ascan(aaFieldList, { |x| x==aAux2[2]})
		aAux3[nPos] := dwStr(aAux2[1]) + " " + dwStr(aAux2[2])
	next
	::FieldList(dwConcatWSep(",", aAux3) )

	nPos := at("FROM ", upper(acSQL))
	cRet := substr(acSQL, 1, nPos-1) + " into " + acTablename + " " + substr(acSQL, nPos)
	
	::OrderBy(cOrder)

return cRet

method Select2(aaFieldList, acTablename, acSQL) class TQuery
	local cRet := "", cOrder := "", nInd, aGroup, aRet
	local aAux, aAux2, cAux, aAux3, nPos
	default acSQL := ::SQL(.T.)

	cOrder := ::OrderBy()
	::OrderBy("")

	aAux := dwTokenAdv(::FieldList(), ",", { "()" }) //aspas são ignoradas automaticamente
	aAux3 := array(len(aaFieldList))

	for nInd := 1 to len(aAux)
		nPos := rat(" ", aAux[nInd])
		if nPos == 0
			aAux2 := { aAux[nInd], aAux[nInd] }
		else
			aAux2 := { substr(aAux[nInd], 1, nPos - 1), substr(aAux[nInd] , nPos + 1)}
		endif
		if (nPos := at(".", aAux2[2])) <> 0
			aAux2[2] := substr(aAux2[2], nPos + 1)
		endif
		nPos := ascan(aaFieldList, { |x| x==aAux2[2]})
		aAux3[nPos] := dwStr(aAux2[1]) + " " + dwStr(aAux2[2])
	next
	::FieldList(dwConcatWSep(",", aAux3) )

	nPos := at("FROM ", upper(acSQL))
	cRet := substr(acSQL, 1, nPos-1) + " into #" + acTablename + " " + substr(acSQL, nPos)
	
	::OrderBy(cOrder)

return cRet

/*
--------------------------------------------------------------------------------------
Emite um comando "delete" para a base
--------------------------------------------------------------------------------------
*/                         
method ExecDel() class TQuery
	local cSQL, old := ::fnExecOper
	
	::fnExecOper := EXEC_DELETE
	cSQL := ::SQL()
	if ::EmbeddedSQL() .and. left(cSQL, 10) == "__execSql("
		cSQL := substr(cSQL, at("delete ", cSQL))
		cSQL := substr(cSQL, 1, at(",{", cSQL)-2)
		cSQL := '"' + cSQL + '"'
		cSQL := &(cSQL)
	endif
		
	lRet := ::ExecSQL(cSQL) == 0
	if  !lRet
		DWLog(STR0008, cSQL, ::Msg())  //"Erro SQL"
	endif
	::fnExecOper := old

return lRet

/*
--------------------------------------------------------------------------------------
Executa comandos SQL
--------------------------------------------------------------------------------------
*/                         
method ExecSQL(acSQL) class TQuery
	local nRet := 0
	
	nRet := DWSqlExec(acSQL)

	if nRet != 0
		::fcMsg := tcSqlError()
	else
		::fcMsg := ""
	endif
	
return nRet

/*
--------------------------------------------------------------------------------------
Executa comandos SQL
--------------------------------------------------------------------------------------
*/                         
method Execute(acTipo, acNome, acParam) class TQuery
	local nRet := 0, cSufixo, oTable
	local cSQL := "", aFields := {}, oQueryAux

	::fcMsg := ""

	if acTipo == EX_CREATE_INDEX //"CI"
		cSQL := "create index ["+ acNome +"] on [" + acNome + "](" + acParam + ") ON [PRIMARY]"
	elseif acTipo == EX_CREATE_VIEW //"CV"
    if sgdb() == DB_INFORMIX
      oQueryAux := TQuery():New()
      oQueryAux:open(, acParam)
      aFields := aClone(oQueryAux:Fields())
      oQueryAux:Close()                                              
      aEval(aFields, { |x,i| aFields[i] := x[FLD_NAME] })
		  cSQL := "create view " + acNome + "(" + dwConcatWSep(",", aFields) + ") as " + acParam
    else
		  cSQL := "create view " + acNome + " as " + acParam
    endif
	elseif acTipo == EX_SELECT_INTO //"SI"
		if sgdb() == DB_ORACLE
			cSQL := "create table " + acParam + " as select * from " + acNome
		else
			cSQL := "select * into " + acParam + " from " + acNome
		endif
	elseif acTipo == EX_DROP_PK //"AT"
	  if DWTopVersion() == TC_VER_32
	    cSufixo := "_RECNO"
	  else
	    cSufixo := "_PK"
	  endif

		if SGDB() == DB_POSTGRES
			cSQL := "alter table "+ acNome +" drop constraint " + acNome + cSufixo + " restrict"
		elseif SGDB() == DB_DB2
			cSQL := "alter table "+ acNome +" drop primary key"
		else
			cSQL := "alter table "+ acNome +" drop constraint " + acNome + cSufixo
		endif
	elseif acTipo == EX_CREATE_PK //"AT_PK"
	  if DWTopVersion() == TC_VER_32
	    cSufixo := "_RECNO"
	  else
	    cSufixo := "_PK"
	  endif          
	  if SGDB() == DB_INFORMIX
	    cSQL := "alter table "+ acNome +" add constraint ( primary key (r_e_c_n_o_) constraint " + lower(acNome + cSufixo) + ")"
	  elseif SGDB() $ DB_MSSQL_ALL
	    cSQL := "alter table "+ acNome +" add constraint '"+ acNome + cSufixo + "' primary key ('R_E_C_N_O_')"
	  elseif SGDB() $ DB_DB2
	    cSQL := "alter table "+ acNome +" add constraint "+ acNome + cSufixo + " primary key (R_E_C_N_O_)"
	  elseif SGDB() $ DB_ORACLE
		cSQL := "alter table "+ acNome +" add constraint "+ acNome + cSufixo + " primary key (R_E_C_N_O_)"  
    else
    	conout("******", "****** " + STR0003 + " 'add primary key ' " + STR0004 + SGDB(), "******")  //"AVISO: Comando"  //" não suportado para "
		endif
	elseif acTipo == EX_DROP_INDEX //"DI"
		if SGDB() == DB_INFORMIX
			cSQL := "drop index " + acNome + acParam
		elseif SGDB() == DB_DB2
			cSQL := "drop index " + DWDBOwner() + "." + acNome + acParam
		else
			cSQL := "drop index " + acNome + "." + acNome + acParam
		endif
	elseif acTipo == EX_DROP_PROCEDURE //"DP"
		cSQL := "drop procedure " + acNome
	elseif acTipo == EX_DROP_VIEW //"DV"
		cSQL := "drop view " + acNome
		if SGDB() $ DB_MSSQL_ALL
			cSQL := "if object_id('"+acNome+"') > 0 " + cSQL
		endif
	elseif acTipo == EX_DROP_TABLE //"DT"
		cSQL := "drop table " + acNome
		if SGDB() $ DB_MSSQL_ALL
			cSQL := "if object_id('"+acNome+"') > 0 " + cSQL
		endif
	elseif acTipo == EX_UPDATE_STAT //"US"
		if SGDB() = DB_INFORMIX
			cSQL := "update statistics high for table " + lower(acNome)
		elseif SGDB() = DB_ORACLE
			cSQL := "analyze table "+ lower(acNome)+" compute statistics"
		elseif SGDB() $ DB_MSSQL_ALL
			cSQL := "update statistics "+ upper(acNome)
		elseif SGDB() $ DB_DB2
//			cSQL := "runstats on table DB2." + upper(acNome)+" on all columns with distribution on all columns and detailed indexes all allow write access"
//			cSQL := "runstats on table " + DS00024 + " on all columns allow write access"
    endif
	elseif acTipo == EX_REN_TABLE //"REN_TAB"
	  ::Execute(EX_DROP_TABLE, acParam)
		if SGDB() = DB_INFORMIX
			cSQL := {}
			aAdd(cSQL, "rename table " + lower(acNome) + " to " + lower(acParam))
		elseif SGDB() = DB_ORACLE
			cSQL := {}
			aAdd(cSQL, "alter table " + lower(acNome) + " rename to " + lower(acParam))
		elseif SGDB() $ DB_MSSQL_ALL
			cSQL := {}
			aAdd(cSQL, "exec sp_rename '" + upper(acNome) + "','" + upper(acParam) + "'")
			aAdd(cSQL, "go")
			aAdd(cSQL, "exec sp_rename '" + upper(acNome) + "_PK','" + upper(acParam) + "_PK', 'OBJECT'")
			aAdd(cSQL, "go")
	    oTable := TTable():New(acNome)
	    oTable:open()
      aEval(oTable:Fields(), { |x| aAdd(cSQL, "exec sp_rename '" + upper(acNome) + "_" + x[FLD_NAME] + "_DF','" + upper(acParam) + "_" + x[FLD_NAME] + "_DF', 'OBJECT'") ,;
                                   aAdd(cSQL, "go") })
      aAdd(cSQL, "exec sp_rename '" + upper(acNome) + "_D_E_L_E_T__DF','" + upper(acParam) + "_D_E_L_E_T__DF', 'OBJECT'")
			aAdd(cSQL, "go")
      aAdd(cSQL, "exec sp_rename '" + upper(acNome) + "_R_E_C_N_O__DF','" + upper(acParam) + "_R_E_C_N_O__DF', 'OBJECT'")
	    oTable:close()
		elseif SGDB() $ DB_DB2
			cSQL := {}
			aAdd(cSQL, "rename " + lower(acNome) + " to " + lower(acParam))
    endif
	endif

  if !empty(cSQL)
	  nRet := DWSqlExec(cSQL)
	  if nRet != 0
		  ::fcMsg := tcSqlError()
	  elseif acTipo == EX_REN_TABLE
      tcRefresh(acParam)
      tcRefresh(acNome)
	    oTable := TTable():New(acParam)
	    oTable:open()
	    oTable:createTable(acNome)
	    oTable:close()
	    oTable:dropIndexes()
	    oTable := TTable():New(acNome)
	    oTable:dropTable()
		elseif SGDB() == DB_DB2 .and. acTipo == EX_DROP_PK
      ::Execute(EX_DROP_INDEX, acNome, cSufixo)
	  endif
  elseif dwIsDebug()
    conout("**** " + STR0005)  //"AVISO"
    conout("     " + STR0006 + " TQuery():Execute " + STR0007)  //"Tentativa de executar "  //" com uma 'query' vazia"
    dwCallStack()
 endif
  	
return nRet


/*
--------------------------------------------------------------------------------------
Ajusta a estrutura de campos da query
--------------------------------------------------------------------------------------
*/                         
method adjustField(aaFieldList) class TQuery
	local nInd, aStruc := ::Fields()

	for nInd := 1 to len(aaFieldList)
		if ascan(aStruc, { |x| x[1] == aaFieldList[nInd]:Alias()}) > 0 
			if aaFieldList[nInd]:Tipo() <> "C" .and. empty(aaFieldList[nInd]:Expressao())               
				if aaFieldList[nInd]:AggFunc() == AGG_PAR .or. aaFieldList[nInd]:AggFunc() == AGG_PARTOT .or.;
					aaFieldList[nInd]:AggFunc() == AGG_PARGLOB 
					::setField(aaFieldList[nInd]:Alias(), aaFieldList[nInd]:Tipo(), aaFieldList[nInd]:Tam(), aaFieldList[nInd]:NDec()+1)
				elseif aaFieldList[nInd]:Temporal() == 0
					::setField(aaFieldList[nInd]:Alias(), aaFieldList[nInd]:Tipo(), aaFieldList[nInd]:Tam(), aaFieldList[nInd]:NDec())
				endif
			endif
		endif
	next

return

/*
--------------------------------------------------------------------------------------
Propriedade params
--------------------------------------------------------------------------------------
*/                         
method params(anNumber, acValue) class TQuery

return ::AddParam("P" + DWStr(anNumber), acValue)

/*
--------------------------------------------------------------------------------------
Recupera/adiciona params pelo nome
--------------------------------------------------------------------------------------
*/                         
method AddParam(acName, acValue) class TQuery
	local nPos := ascan(::faParams, { |x| x[1]==acName} )
		
	if valType(acValue) != "U"
		if nPos == 0
			aAdd(::faParams, { acName, NIL })
			nPos := len(::faParams)
		endif
		::faParams[nPos, 2] := acValue
	endif
	
return ::faParams[nPos, 2]

/*
--------------------------------------------------------------------------------------
Posiciona no próxima registro da tabela
Args: 
Rets: 
--------------------------------------------------------------------------------------
*/                         
method _Next() class TQuery
	local xRet := eval(::fbNext)
	
	if SGDB() == DB_DB2 .and. ::RecLimit() != 0
		::fnLastRec++
	endif
	
return xRet

method _NextDist() class TQuery
	local xRet
	local cAnt := ::Record(2)

	xRet := _Super:_Next()
	while !::Eof() .and. cAnt == ::Record(2)
		xRet := _Super:_Next()
	enddo	
	
return xRet

/*
--------------------------------------------------------------------------------------
Limita o numero de registros
--------------------------------------------------------------------------------------
*/                         
method RecLimit(anValue) class TQuery

	property ::fnRecLimit := anValue
	
return ::fnRecLimit
   

/*
--------------------------------------------------------------------------------------
Sub-tipo da query, para processamentos especiais
--------------------------------------------------------------------------------------
*/                         
method SubType(anValue) class TQuery

	property ::fnSubType := anValue
	
return ::fnSubType

/*
--------------------------------------------------------------------------------------
Indica se esta ou não no fim de arquivos
Args: 
Rets: lRet -> lógico, fim de arquivo (EOF)
--------------------------------------------------------------------------------------
*/                         
method Eof() class TQuery
	local lRet := _Super:eof()
	
	if SGDB() == DB_DB2 .and. !lRet
		if (::RecLimit() <> 0) .and. !(::fnLastRec < ::RecLimit()-1)
			lRet := .t.
		endif
	endif	
                                   
return lRet
                   
/*
--------------------------------------------------------------------------------------
Salva o cursor atual em uma tabela fisica
Args: 
Rets: lRet -> lógico, processo ok
--------------------------------------------------------------------------------------
*/                         
method SaveCursor(acTablename, acSQL, aaStruc, alRenum, anCount) class TQuery
	local aField := {}, nInd, lOk := .f., cSQL, aStruc
	local lOpen := ::isOpen(), x, nPos
	local oTable := TTable():New(acTablename)
	local aProc := {}
	local i := 1
	local cCampos := ""
	local cpCampos := ""
	local nRnk := val(anCount)
	
	default acSQL := ::SQL()
	default aaStruc := {}
	default alRenum := .t.
	default anCount := 1
			
	if !lOpen
		::Open(,acSQL)
	endif

	if oTable:Exists()
		oTable:DropTable()
	endif
		                
	aStruc := ::Struct()
	for nInd := 1 to len(aStruc)
		x := aStruc[nInd]
		if !(x[1] == "R_E_C_N_O_") .and. !(x[1] == DWDelete())
			if (nPos := ascan(aaStruc, { |y| y[1] == x[1] })) == 0
				oTable:AddField(, x[1], x[2], x[3], x[4])
			else                    
				x := aaStruc[nPos]
				oTable:AddField(, x[1], x[2], x[3], x[4])
			endif
		endif
		aAdd(aField, x[1])
	next
	oTable:CreateTable()
	oTable:DropRecnoIndex()

	if ascan(aField, { |x| x == "R_E_C_N_O_"}) == 0
		aAdd(aField, "R_E_C_N_O_")
	endif
		    	
	if SGDB() == DB_INFORMIX
	  //criar procedure
	  aAdd(aProc, "create procedure insinto"/*_"+DWEmpresa()*/+"(")
	  aAdd(aProc, "in_ivalor integer )")
	  aAdd(aProc, "Returning CHAR( 01 );")
	  aAdd(aProc, "define out_resultado char( 01 ) ;")
	  aAdd(aProc, "define nrec integer;")
	  
	  for i := 1 to len(aStruc)
	  	if (trim(aStruc[i][2]) == "C")
		  	aAdd(aProc, "define p" + aStruc[i][1] + " char(" + dwstr(aStruc[i][3]) + ");")
		 elseif (trim(aStruc[i][2]) == "N") .and. (aStruc[i][4] == 0)
		  	aAdd(aProc, "define p" + aStruc[i][1] + " integer;")
		 elseif (trim(aStruc[i][2]) == "N") .and. (aStruc[i][4] > 1)
		  	aAdd(aProc, "define p" + aStruc[i][1] + " float;")
		 endif
		 cCampos := cCampos + aStruc[i][1] + ","
		 cpCampos := cpCampos + "p"+aStruc[i][1] + ","
	  next
	  
	  cCampos := substr(cCampos, 1, len(cCampos)-1)
	  cpCampos := substr(cpCampos, 1, len(cpCampos)-1)

  	  aAdd(aProc, "begin")
  	  aAdd(aProc, "let out_resultado  = '0' ;")
  	  aAdd(aProc, "let nrec = 1;")
  	  aAdd(aProc, "foreach rnk for")
  	  
 	  aAdd(aProc, substr(acSQL, 1, at(" from ", acSQL)))
 	  aAdd(aProc, " into " + cpCampos)
  	  aAdd(aProc, substr(acSQL, at(" from ", acSQL), (len(acSQL)-at(" from ", acSQL)+1)))

      aAdd(aProc, "if nrec <= in_ivalor then")
      aAdd(aProc, "insert into " + acTablename + " (" + cCampos + ") ")
      aAdd(aProc, "values (" + cpCampos + ");")
      aAdd(aProc, "let nrec = nrec + 1;")
      aAdd(aProc, "else")
      aAdd(aProc, "exit foreach;")
      aAdd(aProc, "end if")
      aAdd(aProc, "end foreach;")
      aAdd(aProc, "let out_resultado  = '1' ;")
      aAdd(aProc, "return out_resultado;")
      aAdd(aProc, "end;")
      aAdd(aProc, "end procedure")
      
    ::Execute(EX_DROP_PROCEDURE, "insinto")
	  ::ExecSQL(DWConcatWSep(LF, aProc))
	  
	  aSql := DWExecSP("insinto", nRnk)
	  if aSQL[1] != "1"
	    appRaise(ERR_009, SOL_009, STR0002 + " [" + acSPname + "]")  //"Ocorreu um erro durante a execução"
	  endif			

	else	
	  cSQL := ::InsertInto(aField, acTablename, .f., acSQL)
	endif
	
	if !lOpen
		::Close()
	endif

	lOk := ::ExecSQL(cSQL) == 0
	oTable:RebuildRecno(iif(alRenum, 1, nil))
	
return lOk

/*
--------------------------------------------------------------------------------------
Processa macros @
Args: 
Rets: lRet -> lógico, fim de arquivo (EOF)
--------------------------------------------------------------------------------------
*/                         
function DWMacroAt2(acMacro, alStruc, aaAllFields, anSubType)
	local cRet := {}, nInd, aLines 
	local cAux, aAux

	default alStruc := .F.
	default aaAllFields := {}
	
	if "@" $ acMacro
		cAux := strTran(acMacro, CRLF, " ")
		aAux := aaAllFields
		for nInd := 1 to len(aAux)     
			cAux := strTran(cAux, aAux[nInd, 1], aAux[nInd, 5])
		next                    

		aLines := dwToken(cAux, "@",,.f.)

		for nInd := 1 to len(aLines)
			if !empty(aLines[nInd])
				if left(aLines[nInd], 1) == "@"         
					cAux := left(aLines[nInd], at(")", aLines[nInd]))
					if alStruc
						aAdd(cRet, DWMacroAt(cAux, alStruc,,anSubType))  
					else
						aAdd(cRet, DWMacroAt(cAux, alStruc,,anSubType) + substr(aLines[nInd], len(cAux)+1))
					endif
				else
					aAdd(cRet, aLines[nInd])
				endif  
			endif  
		next             
	else 
		cRet := { acMacro }
	endif
	
return iif(alStruc, cRet, dwConcatWSep(" ", cRet))

function DWMacroAt(acMacro, alStruct, pnTemporal, anSubType)
	local cRet := acMacro
	local cMacroname := upper(left(cRet, at("(", cRet) - 1))
	local cAux, aAux
	
	default alStruct := .F.
	default pnTemporal := 0
	default anSubType := ST_DEFAULT
	    
	cAux := substr(cRet, len(cMacroname) + 2)
	cAux := substr(cAux, 1, len(cAux) - 1)
	aAux := dwToken(cAux,,.f.)
	aEval(aAux, { |x,i| aAux[i] := alltrim(x)}) 
	if alStruct
		if cMacroname == "@DWREF"
      		if aAux[1] == "N"
				cRet := "0"  
			else
				cRet := "''"  
			endif				
		elseif cMacroname == "@ANO"
			pnTemporal := DT_ANO
			cRet := { left(aAux[1],1) + dwInt2Hex(pnTemporal, 1) + "_"+ substr(aAux[1],2), "N", 4, 0 }
		elseif cMacroname == "@ANOMES"
			pnTemporal := DT_ANOMES
			cRet := { left(aAux[1],1) + dwInt2Hex(pnTemporal, 1) + "_" + substr(aAux[1],2), "N", 6, 0 }    
	 // elseif cMacroname == "@MESDIA"     //new
	 //		pnTemporal := DT_DIA
	 //		cRet := { left(aAux[1],1) + dwInt2Hex(pnTemporal, 1) + "_" + substr(aAux[1],2), "N", 2, 0 } 
	 //	elseif cMacroname == "@ANODIA"     //new
	 //		pnTemporal := DT_DIA
	 //		cRet := { left(aAux[1],1) + dwInt2Hex(pnTemporal, 1) + "_" + substr(aAux[1],2), "N", 2, 0 } 
		elseif cMacroname == "@MES"
			pnTemporal := DT_MES
			cRet := { left(aAux[1],1) + dwInt2Hex(pnTemporal, 1) + "_" + substr(aAux[1],2), "N", 2, 0 }
		elseif cMacroname == "@DIA"
			pnTemporal := DT_DIA
			cRet := { left(aAux[1],1) + dwInt2Hex(pnTemporal, 1) + "_" + substr(aAux[1],2), "N", 2, 0 }  
		elseif cMacroname == "@ACUM"
			cRet := { left(aAux[1],1) + dwInt2Hex(AGG_ACUM, 1) + "_" + substr(aAux[1],2), "N", 16, 2 }
		elseif cMacroname == "@ACUMPERC"
			cRet := { left(aAux[1],1) + dwInt2Hex(AGG_ACUMPERC, 1) + "_" + substr(aAux[1],2), "N", 16, 2 }
		elseif cMacroname == "@ACUMHIST"
			cRet := { left(aAux[1],1) + dwInt2Hex(AGG_ACUMHIST, 1) + "_" + substr(aAux[1],2), "N", 16, 2 }
		elseif cMacroname == "@ACUMHISTPERC"
			cRet := { left(aAux[1],1) + dwInt2Hex(AGG_ACUMHISTPERC, 1) + "_" + substr(aAux[1],2), "N", 16, 2 }
		endif
	else
		if cMacroname == "@DWREF"   
	   		cRet := "[ptedDW_REF" + upper(aAux[2]) + "]"
		elseif cMacroname == "@ANO"
			if len(aAux) == 2
			//if anSubType == ST_DIMENSION .or. "." $ aAux[1]
					cRet := DWSQLFunc("SUBSTR", aAux[1], 1, 4) + "=" + DWRetVal(aAux[2],.t.)
			//	else
			//		pnTemporal := DT_ANO
			//		cRet := left(aAux[1],1) + dwInt2Hex(DT_ANO, 1) + "_" + substr(aAux[1],2) + "=" + DWRetVal(aAux[2],.t.) 
			//	endif
			endif 
		elseif cMacroname == "@ANOMES"
			if len(aAux) == 2
			//	if anSubType == ST_DIMENSION .or. "." $ aAux[1]
					cRet := DWSQLFunc("SUBSTR", aAux[1], 1, 6) + "=" + DWRetVal(aAux[2],.t.)
			//	else
			//		pnTemporal := DT_ANOMES
			//		cRet := left(aAux[1],1) + dwInt2Hex(pnTemporal, 1) + "_"+ substr(aAux[1],2) + "="  + DWRetVal(aAux[2],.t.)
			//	endif
			endif
		elseif cMacroname == "@MES" 
			if len(aAux) == 2
		     // if anSubType == ST_DIMENSION .or. "." $ aAux[1]
					cRet := DWSQLFunc("SUBSTR", aAux[1], 5, 2) + "=" + DWRetVal(aAux[2], .t.)
			 //	else
			 //		pnTemporal := DT_MES
			 //		cRet := left(aAux[1],1) + dwInt2Hex(pnTemporal, 1) + "_"+ substr(aAux[1],2) + "=" + DWRetVal(aAux[2], .t.)
			 //	endif
			endif
		elseif cMacroname == "@DIA" 
			if len(aAux) == 2
				cRet := DWSQLFunc("SUBSTR", aAux[1], 7, 2) + "=" + DWRetVal(aAux[2], .t.)
			endif
		elseif cMacroname == "@ACUM" .or. cMacroname == "@ACUMPERC"
			if len(aAux) == 1
				cRet := "sum(" + aAux[1] + ")
			endif
		elseif cMacroname == "@ACUMHIST" .or. cMacroname == "@ACUMHISTPERC"
			if len(aAux) == 1
				cRet := "sum(" + aAux[1] + ")"
			endif 
		elseif cMacroname == "@ANODIA" 
			if len(aAux) == 2  
				cRet := DWSQLFunc("SUBSTR", aAux[1], 1, 4) + "=" + DWSQLFunc("SUBSTR", DWRetVal(aAux[2], .t.), 1, 4) + " AND " +; 
						DWSQLFunc("SUBSTR", aAux[1], 7, 2) + "=" + DWSQLFunc("SUBSTR", DWRetVal(aAux[2], .t.), 5, 2)    
			endif
		elseif cMacroname == "@MESDIA" 
			if len(aAux) == 2
				cRet := DWSQLFunc("SUBSTR", aAux[1], 5, 4) + "=" + DWRetVal(aAux[2], .t.)  
			endif 
		endif                                                                          
	endif                                                                                  
return cRet

/*
--------------------------------------------------------------------------------------
Gera as funções conforme o SGDB em uso
Args: funcName, string, nome da função
Rets: cRet 
--------------------------------------------------------------------------------------
*/                         

function DWSQLFunc(acFuncName, axP1, axP2, axP3, axP4, axP5)
	local cRet := "@@ INVALID FUNCTION NAME @@"
	
	acFuncName := upper(acFuncName)
	if acFuncName == "SUBSTR"
		if SGDB() == DB_DB2
			cRet := dwconcat("substr(", axP1, ",", axP2, ",", axP3, ")")
		elseif SGDB() == DB_INFORMIX  
			cRet := dwconcat("substring(", axP1, " FROM ", axP2, " FOR ", axP3, ")")
		elseif SGDB() == DB_ORACLE
			cRet := dwconcat("substr(", axP1, ",", axP2, ",", axP3, ")")
		else                          
			cRet := dwconcat("substring(", axP1, ",", axP2, ",", axP3, ")")
		endif
	endif

return cRet

static function DWRetVal(acValor, alAspas)
    local cRet := ""
	default alAspas := .F.    
    
    
    if SGDB() == DB_DB2 .and. !alAspas
        cRet := acValor
    else
        cRet := "'" + acValor +"'" 
    endif

return cRet



