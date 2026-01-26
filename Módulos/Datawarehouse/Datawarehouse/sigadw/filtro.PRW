// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : SigaDW
// Fonte  : Filtro - Objeto TFiltro, contem definição de filtro
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 01.06.01 | 0548-Alan Candido |
// 06.01.06 |2481-Paulo R Vieira| DW Fase 3
// --------------------------------------------------------------------------------------

#include "dwincs.ch"
#include "filtro.ch"

/*
--------------------------------------------------------------------------------------
Classe: TFiltro
Uso   : Contem definição de indicador
--------------------------------------------------------------------------------------
*/
class TFiltro from TFilAlm
	data flApplySecure
	data faPrompts			                    
	data fcTipo
	data fcTableWhere
	data fcKeyTableWhere
	data flCubeFilter
	
	method New(anID, aoOwner, acTabWhere, ackeyTabWhere) constructor
	method Free()
	method NewFiltro(anID, aoOwner, acTabWhere, ackeyTabWhere)
 	
	method Clear()
	method TableWhere(acValue)
	method KeyTableWhere(acValue)
	method DoLoad()
	method DoSave()
	method DoCleanExpr()
	method ExpSQL(aaInd, alInd, alHaving)
	method Selected(alValue)
	method Tipo(alValue)
	method ApplySecure(alValue)
	method Prompts()
	method isTemporal(aaDateFields)
	method isCubeFilter(alValue) 
	method getTipo()
endclass

/*
--------------------------------------------------------------------------------------
Construtor e destrutor da classe
Args: 
--------------------------------------------------------------------------------------
*/
method New(anID, aoOwner, acTabWhere, ackeyTabWhere) class TFiltro
	
	::NewFiltro(anID, aoOwner, acTabWhere, ackeyTabWhere)
	
return

method Free() class TFiltro

	_Super:Free()

return

method NewFiltro(anID, aoOwner, acTabWhere, ackeyTabWhere) class TFiltro
	
	// repassa o id do objeto para o super como NIL,
	// pois têm que realizar configurações TableWhere e KeyTableWhere
	// antes do DoLoad() (que é realizado pelo método ID)
	_Super:New(, aoOwner)
	
	default acTabWhere := InitTable(TAB_WHERE)
	default ackeyTabWhere	:= "id_cons"
	
	::TableWhere(acTabWhere)
	::KeyTableWhere(ackeyTabWhere)
	::ID(anID)
	
return
              
/*
--------------------------------------------------------------------------------------
Inicialia as propriedades
--------------------------------------------------------------------------------------
*/                         
method Clear() class TFiltro

	_Super:Clear()

	::fcTipo := FILTER_NORMAL
	::flApplySecure := .t.	
	::faPrompts := {}
	::flCubeFilter := .F.
	
return

/*
--------------------------------------------------------------------------------------
Define/recupera a tabela utilizada como Filtro
--------------------------------------------------------------------------------------
*/
method TableWhere(acValue) class TFiltro
	property ::fcTableWhere := acValue
return ::fcTableWhere

/*
--------------------------------------------------------------------------------------
Define/recupera a tabela utilizada como Filtro
--------------------------------------------------------------------------------------
*/
method KeyTableWhere(acValue) class TFiltro
	property ::fcKeyTableWhere := acValue
return ::fcKeyTableWhere

/*
--------------------------------------------------------------------------------------
Le o Filtro
--------------------------------------------------------------------------------------
*/                         
method DoLoad() class TFiltro
	local oWhere := ::TableWhere()
	local oWhereCond := InitTable(TAB_WHERE_COND)
	local aWhere := {}, cFieldname, cCaption
	local aFields, nPos, cTipo, cAlias

	::Clear()
	if ::ID() <> 0 .and. oWhere:Seek( 1, { ::ID() } )
		::Name(oWhere:value("nome", .t.))
		::Desc(oWhere:value("descricao", .t.))
		if empty(::Desc())
			::Desc(oWhere:value("nome", .t.))
		endif
		::isCubeFilter(oWhere:value("virtual"))
		::Tipo(oWhere:value("tipo"))
		::IDExpr(oWhere:value("id_expr"))
		if ::IDExpr() <> 0
			::Expressao( { oWhere:value("expressao", .t.) })
			::IsSQL(oWhere:value("issql"))
			::IsQBE(.F.)
		else
			oWhereCond:Seek(3, { ::ID(), 0, 0 } )
			aWhere := {}
			while !oWhereCond:Eof() .and. oWhereCond:value("id_where") == ::ID()
				if oWhereCond:value("id_dim") == 0
					aFields := ::Cube():GetIndicadores()
					nPos := aScan(aFields, { |x| x[1] == oWhereCond:value("id_field") })
					if nPos == 0
						oWhereCond:_Next()
						loop
					endif						
					cFieldname := aFields[nPos, 2]
					cCaption := aFields[nPos, 5]
					cTipo := aFields[nPos, 7]
					cAlias := "I" + DWInt2Hex(aFields[nPos, 1], 3)
					nTam := aFields[nPos, 3]
					nDec := aFields[nPos, 4]
				else
					aFields := oSigaDW:OpenDim(oWhereCond:value("id_dim")):Fields()
					nPos := aScan(aFields, { |x| x[12] == oWhereCond:value("id_field") })
					cFieldname := aFields[nPos, 1]
					cCaption := aFields[nPos, 9]
					cTipo := aFields[nPos, 2]
					nTam := aFields[nPos, 3]
					nDec := aFields[nPos, 4]
					cAlias := "D" + DWInt2Hex(aFields[nPos, 12], 3)
				endif
				// id_dim, id_field, cFieldname, tipo, exp_qbe, caption , alias, seq
				aAdd(aWhere, { oWhereCond:value("id_dim"), oWhereCond:value("id_field"), alltrim(cFieldname), cTipo , ;
                       dwToken(oWhereCond:value("qbe"), ",", .f.), allTrim(cCaption), allTrim(cAlias), oWhereCond:value("seq"), nTam, nDec })
				aEval(PromptExtract(oWhere:value("nome"), oWhereCond:value("qbe"), oWhereCond:value("last_value")),;
							 { |x| aAdd(::faPrompts, x[1]) })
				oWhereCond:_Next()			
			enddo			
			::Expressao(aWhere)
			::IsSQL(.T.)
			::IsQBE(.T.)
		endif
	endif
	
return

/*
--------------------------------------------------------------------------------------
Grava o Filtro
--------------------------------------------------------------------------------------
*/                         
method DoSave() class TFiltro
	local oWhere := ::TableWhere()
	local oWhereCond := InitTable(TAB_WHERE_COND)
	local aValues
	local aExp, nInd
	
	if !oWhere:Seek(1, { ::ID() } )
	//if !oWhere:Seek(1, { ::Owner():ID() } )
  	//if !oWhere:Seek( 2, { ::Owner():ID(), ::Tipo(), ::Name() } , .f.)
  		aValues := { { ::KeyTableWhere(), ::Owner():ID() } , { "nome", ::Name()} , { "descricao", ::Desc() }, {"tipo", ::Tipo() }, {"id_expr", ::IdExpr()} }
		oWhere:Append(aValues)
		::ID(oWhere:value("id"), .f.)
	endif
	
	if !::IsSQL()
		if oWhereCond:Seek(3, { oWhere:value("id"), 0, 0 } )
			oWhereCond:Update( { { "id_expr", ::IDExpr() } } )
		else
			//oWhereCond:Append( { { "id_where", ::ID() }, { "id_expr", ::IDExpr() },;
			oWhereCond:Append( { { "id_where", oWhere:value("id") }, { "id_expr", ::IDExpr() },;
                           { "id_dim", 0 } , { "id_field", 0 }, { "seq", 1 } } )
		endif
	else
		// id_dim, id_field, cFieldname, tipo, exp_qbe, caption , alias, seq
		aExp := ::Expressao()
		for nInd := 1 to len(aExp)
			//if oWhereCond:Seek(5, { oWhere:value("id"), aExp[nInd, 1], aExp[nInd, 2], aExp[nInd, 8] } )
			if oWhereCond:Seek(3, { oWhere:value("id"), aExp[nInd, 1], aExp[nInd, 8] } )
				oWhereCond:Update( { { "qbe", DWConcatWSep(",", aExp[nInd, 5]) } } )
			else
				oWhereCond:Append( { { "id_where", oWhere:value("id") }, ;
											{ "id_dim", aExp[nInd, 1] } , ;
											{ "id_field", aExp[nInd, 2] } ,;
											{ "seq", aExp[nInd, 8] } ,;
											{ "qbe", DWConcatWSep(",", aExp[nInd, 5]) } } )
   			endif
   		next
   	endif
   	
   	// atualiza sempre para validar os dados de expressão sql e expressão qbe no update da tabela de filtros
   	// IMPORTANTE para salvar as atualizações de expressões qbe
	oWhere:Seek(1, { ::ID() } )
	aValues := { {"id_expr", ::IdExpr()} }
	oWhere:Update(aValues)
	::Owner():Invalidate()	
	
return

/*
--------------------------------------------------------------------------------------
Limpa o Filtro
--------------------------------------------------------------------------------------
*/                         
method DoCleanExpr() class TFiltro
	local oWhere := ::TableWhere()
	local oWhereCond := InitTable(TAB_WHERE_COND)
	local aValues
	
	if oWhere:Seek(1, { ::ID() } )
	  	aValues := { { "id_expr", 0 } }
		oWhereCond:Seek(2, { oWhere:value("id") } )
		while !oWhereCond:EoF() .and. oWhereCond:value("id_where") == oWhere:value("id")
			oWhereCond:Delete()
			oWhereCond:_Next()
 		enddo
		oWhere:Update(aValues)
		::doLoad()
		::Owner():Invalidate()	
	endif
   
return

/*
--------------------------------------------------------------------------------------
Monta a expressão SQL 
--------------------------------------------------------------------------------------
*/                         
method ExpSQL(aaInd, alInd, alHaving, alStruct) class TFiltro
  local aRet := {}
  local xWhere := aClone(::Expressao())
  local cName := ::htmlID()
  local aFields := ::Owner():Fields()
  local aIndicadores := ::Owner():Indicadores()
  local aDimFields := ::Owner():DimFields()
  local nPos, nPos2, nSeq := 1, nInd, x
  local aDim, cDimName, cAux
  
  default aaInd := {}
  default alInd := .f.
  default alHaving := .f.
  
  if ::IsQBE()
    if left(cName, 2) != 'cb'
      cName := 'cb'+cName
    endif
    
    xWhere := packArray(xWhere)
    aDim := { ::Cube():DimProp("ID"), ::Cube():DimProp("NOME") }
    
    nRow := 0
    aEval(xWhere, { |x| nRow := max(nRow, len(x[5])) })
    aRet := array(nRow)
    for nSeq := 1 to nRow
      aRet[nSeq] := {}
    next
    
    for nSeq := 1 to nRow
      for nInd := 1 to len(xWhere)
        x := xWhere[nInd]
        if nSeq <= len(x[5])
          nPos := ascan(aDim[1], {|z| z==x[1]})
          cDimName := iif(nPos != 0, aDim[2, nPos], "FATO")
          cAux := cDimName+"->"+x[3]
          if alInd
            cAux := ::putOper(aIndicadores, QBE2SQL(cAux, x[4], { x[5, nSeq] }, x[6], cName, ::Owner():Params()))
            if alHaving .and. !::owner():haveAggFunc(cAux)
              if !(nPos == 0)
                cAux := cDimName+"->"+x[3]
              else 
                cAux := "sum(" + cDimName+"->"+x[3] + ")"
              endif
              cAux := ::putOper(aIndicadores, QBE2SQL(cAux, x[4], { x[5, nSeq] }, x[6], cName, ::Owner():Params()))
            endif
          else
            cAux := QBE2SQL(cAux, x[4], { x[5, nSeq] }, x[6], cName, ::Owner():Params(),,alStruct)
          endif
          if !empty(cAux)
            aAdd(aRet[nSeq], cAux)
          endif
        endif
      next
    next

    aEval(aRet, { |x,i| aRet[i] := dwConcatWSep(" and ", x) } )
    if len(aRet) > 1
      aRet := "((" + DWConcatWSep(") or (", aRet) + "))"
    else
      aRet := DWConcatWSep(" ", aRet)
    endif
  else
    if valType(xWhere) == "A"
      aRet := "("+ DWConcatWSep(") and (", xWhere)+")"
    else
      aRet := "("+ xWhere+")"
    endif
  endif
  
  if ::Tipo() == FILTER_SEGTO
    aRet := strTran(aRet, "->", "$>")
  endif
  
  if valType(aRet) == "A"
    aEval(aRet, { |x,i| iif(empty(x), aRet[i] := nil, nil)})
    aRet := packArray(aRet)
  endif
  if !empty(aRet)
    aRet := { aRet }
  else
    aRet := {}
  endif

return aRet

/*
--------------------------------------------------------------------------------------
Propriedade Selected
--------------------------------------------------------------------------------------
*/                         
method Selected(alValue) class TFiltro
	local lRet := .t.

	if ::Tipo() == FILTER_SECURE
		lRet := ::ApplySecure()
	else
		lRet := _Super:Selected(alValue)
	endif

return lRet

/*
--------------------------------------------------------------------------------------
Propriedade Tipo
--------------------------------------------------------------------------------------
*/                         
method Tipo(acValue) class TFiltro

	property ::fcTipo := acValue

return ::fcTipo

/*
--------------------------------------------------------------------------------------
Propriedade ApplySecure
--------------------------------------------------------------------------------------
*/                         
method ApplySecure(alValue) class TFiltro

	property ::flApplySecure := alValue

return ::flApplySecure

/*
--------------------------------------------------------------------------------------
Retorna a lista de prompts
--------------------------------------------------------------------------------------
*/                         
method Prompts() class TFiltro
	
return ::faPrompts

/*
--------------------------------------------------------------------------------------
Verifica se na expressão há algum campo temporal
--------------------------------------------------------------------------------------
*/                         
method isTemporal(aaDateFields) class TFiltro
	local lRet := .f., cExpSQL := dwStr(self:expsql()), nInd

	if len(aaDateFields) <> 0
		for nInd := 1 to len(aaDateFields)
			if aaDateFields[nInd, 1] $ cExpSQL
				lRet := .t.
				exit
			endif
		next
	endif
	
return lRet

/*
--------------------------------------------------------------------------------------
Verifica se na expressão há algum campo temporal
--------------------------------------------------------------------------------------
*/
method isCubeFilter(alValue) class TFiltro
	
	property ::flCubeFilter := alValue

return ::flCubeFilter

/*
--------------------------------------------------------------------------------------
Retorna o tipo do filtro
Retorno:
 (Caracter)
 	FILTER_NORMAL    "0"
 	FILTER_SECURE    "1"
 	FILTER_SEGTO     "2"
--------------------------------------------------------------------------------------
*/
method getTipo() class TFiltro
return ::fcTipo




