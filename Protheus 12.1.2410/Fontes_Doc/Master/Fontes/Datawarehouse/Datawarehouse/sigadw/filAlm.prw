// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : SigaDW
// Fonte  : FilAlm - Objeto TFilAlm, contem a base de FilAlms e alertas
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 01.06.01 | 0548-Alan Candido |
// 06.01.06 |2481-Paulo R Vieira| DW Fase 3
// 19.02.10 | 0548-Alan Candido | FNC 00000003657/2010 (9.12) e 00000001971/2010 (11)
//          |                   | Implementação de visual para P11 e adequação para o 'dashboard'
// --------------------------------------------------------------------------------------

#include "dwincs.ch"
#include "filAlm.ch"
#include "dwfilalm.ch"

/*
--------------------------------------------------------------------------------------
Classe: TFilAlm
Uso   : Contem definição basica de filtros e alertas
--------------------------------------------------------------------------------------
*/
class TFilAlm from TDWObject

	method New(anID, aoOwner) constructor
	method Free()
	                
 	method Clear()
	method DoLoad()
	method DoSave()
		
	method ID(anValue, alLoad)
	method Desc(acValue)	
	method Name(acValue)	
	method Selected(alValue)
	method CBExpr() 
	method IDExpr(anValue)
	method Expressao(axValue)
	method IsSQL(alValue)
	method IsQBE(alValue)
	method ExpAdvpl()
	method ExpSQL()
	method ExpHtml(alChecked, alCheckBox, oPageLinks, alMeta)
	method ExpHtml2()
	method ExpHtml3()
	method ExpDsh()
	method IsInd()
	method asString(alMacro)
	method putOper(paInd, pcValue)
	method Cube()
	method HtmlID()
endclass

/*
--------------------------------------------------------------------------------------
Construtor e destrutor da classe
Args: 
--------------------------------------------------------------------------------------
*/
method New(anID, aoOwner) class TFilAlm
	
	default aoOwner := self
	
	_Super:New(aoOwner,ID_SIZE)
    ::ID(anID)
    
return

method Free() class TFilAlm

	_Super:Free()

return

/*
--------------------------------------------------------------------------------------
Propriedade ID
--------------------------------------------------------------------------------------
*/                         
method ID(anValue, alLoad) class TFilAlm
   local nRet := ::Props(ID_ID, anValue)
	default alLoad := .t.	

	if valType(anValue) == "N" 
		if alLoad
			::doLoad()
	   endif
   endif
   
return nRet

/*
--------------------------------------------------------------------------------------
Propriedade Desc
--------------------------------------------------------------------------------------
*/                         
method Desc(acValue) class TFilAlm
	
return ::Props(ID_DESC, acValue)

/*
--------------------------------------------------------------------------------------
Propriedade Name
--------------------------------------------------------------------------------------
*/                         
method Name(acValue) class TFilAlm
	
return ::Props(ID_NAME, acValue)

/*
--------------------------------------------------------------------------------------
Propriedade Selected
--------------------------------------------------------------------------------------
*/                         
method Selected(alValue) class TFilAlm
	
return ::Props(ID_SELECTED, alValue)

/*
--------------------------------------------------------------------------------------
Propriedade IDExpr
--------------------------------------------------------------------------------------
*/                         
method IDExpr(anValue) class TFilAlm

return ::Props(ID_ID_EXPR, anValue)

/*
--------------------------------------------------------------------------------------
Propriedade Expressao
--------------------------------------------------------------------------------------
*/                         
method Expressao(axValue) class TFilAlm
		
return ::Props(ID_EXPRESSAO, axValue)

/*
--------------------------------------------------------------------------------------
Gera o Code-block de uma expressão
--------------------------------------------------------------------------------------
*/                         
method CBExpr() class TFilAlm
	local cRet := ::Expressao()
  local aFields := ::Owner():Fields()

	aEval(aFields, { |x| cRet := strTran(cRet,upper(x:Name()),x:Alias()),;
								cRet := strTran(cRet,lower(x:Name()),x:Alias())})
	cRet := "{ || " + cRet + " }"
			
return &(cRet)

/*
--------------------------------------------------------------------------------------
Propriedade ExpHtml
--------------------------------------------------------------------------------------
*/
//####TODO - verificar a real necessidade do retorno ser um array
//####TODO - prepare link de edição de cada um dos filtros (acesso direto)
//           SigaDW 2.2 usa oPageLinks
//####TODO - verificar a real necessidade de anLimitSize
//           para testes anLimitSize esta sendo ignorado
method ExpHtml(alChecked, alCheckbox, oPageLinks, alMeta, anLimitSize, aaValue) class TFilAlm
	local aRet := {}, aRetFinal := {}, xWhere, xWhere2
	local cName := ::htmlID()
	local cDisable := "", nSeq := 1
  local aFields := ::Owner():Fields()
  local aIndicadores := ::Owner():Indicadores()
  local aDimFields := ::Owner():DimFields()
  local nPos, nPos2, nInd, nInd2, x
  local aDim, cDimName, cAux

  xWhere2 := ::Expressao()
	if valType(xWhere2) == "C"
		xWhere := xWhere2
	else
	  xWhere := aClone(xWhere2)
	endif
	
	default alChecked := ::Selected()
	default alCheckbox := .t.                            
	default alMeta := .f.
	default aaValue := {}
//####TODO - verificar a real necessidade de anLimitSize
//	default anLimitSize := 0
	anLimitSize := 0
	
	if valType(alChecked) == "C"
		if(alChecked=="disabled")
			alChecked := ::Selected()
			cDisable := "disabled"
		endif	
	endif	

	if ::IsQBE()
		// id_dim, id_field, cFieldname, tipo, exp_qbe, caption , alias, seq

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
          cAux := ::putOper(aIndicadores, QBE2Html(x[3], x[4], { x[5, nSeq] }, x[6], cName, aaValue, ,alMeta, !empty(cDisable),,x[9]))
          if !empty(cAux)
            aAdd(aRet[nSeq], cAux)
          endif
        endif
      next
    next

    aEval(aRet, { |x,i| aRet[i] := DWConcatWSep(" <span class='operAnd'>"+STR0001+"</span> ", x) } )  //"E"
    if len(aRet) > 1
      aRet := "((" + DWConcatWSep(") <span class='operOr'>"+STR0002+"</span> (", aRet) + "))"  //"OU"
    else
      aRet := DWConcatWSep(" ", aRet)
    endif
    aRetFinal := aRet
		cAux := DWStr(::Desc())
		if anLimitSize != 0
			if anLimitSize < len(cAux)
				nAux := int((anLimitSize - 3) / 2)
				cAux := left(cAux, nAux)+"..."+right(cAux, nAux)
			endif
		endif
		if alCheckbox		
			if !alMeta
				aRet := { cName, ;
					iif(valType(oPageLinks)=="O", oPageLinks:Link('showWhere('+dwStr(::Tipo())+','+DWStr(::ID())+');', cAux), ::Desc()) +;
					"<input class='chkbox' type='checkbox' value='on' name='" + cName + "' id='" + cName +;
					iif(alChecked,"' checked ", "' ")+cDisable+">", "\("+DWConcatWSep("\) <span class='operOr'>"+STR0002+"</span> \(", aRetFinal)+"\)" }  //"OU"
			else
				aRet := { cName, cAux, "\(" + DWConcatWSep("\) <span class='operOr'>"+STR0002+"</span> \(", aRetFinal)  + "\)"  }  //"OU"
			endif
		else                                                                              
			aRet := { cName, cAux, "\(" + DWConcatWSep("\) <span class='operOr':</span> \(", aRetFinal)  + "\)"  }
		endif
	else                                                
		if alCheckbox		
			if valType(xWhere) == "A"
				xWhere := DWConcatWSep(" <span class='operAnd'>"+STR0001+"</span> ", xWhere) //"E"
			endif
			if !alMeta
				aRet := { cName, ;
					iif(valType(oPageLinks)=="O", oPageLinks:Link('showWhere('+dwStr(::Tipo())+','+DWStr(::ID())+');', ::Desc()), ::Desc()) +;
					"<input class=inputCheckBox type=checkbox value=on name=" + cName + " id=" + cName +;
					iif(alChecked," checked ", " ")+cDisable+">", xWhere }
			else
				aRet := { cName, ::Desc() , xWhere }
			endif
		else
			if valType(xWhere) == "A"
				xWhere := DWConcatWSep(" <span class='operAnd'>"+STR0001+"</span> ", xWhere)  //"E"
			endif
			aRet := { cName, DWStr(::Desc()), xWhere }
		endif
	endif

	if alMeta
		aRet := { "[&nbsp;"+iif(alChecked,"X", "&nbsp;")+"&nbsp;]&nbsp;"+aRet[2], aRet[3]} 
	else
		aEval(aRet, {|x,i| aRet[i] := strTran(x, "\(", "<span class='declarFilter'>(</span>")})
		aEval(aRet, {|x,i| aRet[i] := strTran(x, "\)", "<span class='declarFilter'>)</span>")})
	endif
	             
	aEval(aRet, {|x,i| aRet[i] := strTran(x, CRLF+")", ")"+CRLF)})
	
return aRet

/*
--------------------------------------------------------------------------------------
Método ExpHtml2 - Não retorna checkbox
--------------------------------------------------------------------------------------
*/                         
method ExpHtml2() class TFilAlm

return ::ExpHtml(, .F.)

/*
--------------------------------------------------------------------------------------
Método ExpHtml3 - Retorna formatado para o meta-dados
--------------------------------------------------------------------------------------
*/                         
method ExpHtml3() class TFilAlm

return ::ExpHtml("disabled",,, .t.)

/*
--------------------------------------------------------------------------------------
Método ExpDsh - Retorna formatado para o dashboard
--------------------------------------------------------------------------------------
*/                         
method ExpDsh() class TFilAlm
	local aRet := {}, aRetFinal := {}, xWhere, xWhere2
	local cName := ::htmlID()
	local cDisable := "", nSeq := 1
  local aFields := ::Owner():Fields()
  local aIndicadores := ::Owner():Indicadores()
  local aDimFields := ::Owner():DimFields()
  local nPos, nPos2, nInd, nInd2, x
  local aDim, cDimName, cAux

  xWhere2 := ::Expressao()
	if valType(xWhere2) == "C"
		xWhere := { xWhere2 }
	else
	  xWhere := aClone(xWhere2)
	endif
	
	if ::IsQBE()
		// id_dim, id_field, cFieldname, tipo, exp_qbe, caption , alias, seq

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
          cAux := ::putOper(aIndicadores, QBE2Html(x[3] /*acFieldName*/, x[4]/*acTipo*/, { x[5, nSeq] } /*aaQbeExpr*/,;
                                                   x[6] /*acCaption*/, cName/*acComp*/,;
                                                   {} /* aaParams*/, /*alAnd*/, /*alMeta*/, .f. /*alReadOnly*/, ;
                                                   /*alGraf*/, x[9] /*anTam*/,;
                                                   .t. /*alDashboard*/))
          if !empty(cAux)
            aRet[nSeq] := dwConcatWSep("", cAux)
          endif
        endif
      next
    next
    aEval(aRet, {|x,i| aRet[i] := strTran(x, CRLF+")", ")"+CRLF)})
	else
    aEval(xWhere, {|x| aAdd(aRet, x)})
    aEval(aRet, {|x,i| aRet[i] := strTran(x, CRLF+")", ")"+CRLF)})
	  aEval(aRet, {|x,i| aRet[i] := "<label>" + x + "</label>" })
	endif

	
return dwConcatWSep(CRLF, aRet)

/*
--------------------------------------------------------------------------------------
Propriedade ExpSQL
--------------------------------------------------------------------------------------
*/
method putOper(paInd, pcValue) class TFilAlm
	local nInd, cRet := pcValue
	
	for nInd := 1 to len(paInd)
		cRet := strTranIgnCase(cRet, paInd[nInd]:Dimname()+"->"+paInd[nInd]:Name(), paInd[nInd]:AggFuncText() + "(" + paInd[nInd]:Dimname()+"->"+paInd[nInd]:Name() + ")")
  next
   
return cRet
   
method ExpSQL(aaInd) class TFilAlm
	local aRet := {}, aRetFinal := {}
	local xWhere := aClone(::Expressao())
	local nSeq := 1
	local cName := ::HTMLid() 
  local aFields := ::Owner():Fields()
	local aDim := ::Cube():Dimension()
	local cCubeName := ::Cube():Name()
	local aIndicadores := ::Owner():Indicadores()
	local nPos, nInd
	
	default aaInd := {}
			
	if ::IsQBE()
		// id_dim, id_field, cFieldname, tipo, exp_qbe, caption , alias, seq
		if left(cName, 2) != 'cb'
			cName := 'cb'+cName
		endif
					
		while len(xWhere) > 0 
			aRet := {}
//									aAdd(aRet, ::putOper(aIndicadores, QBE2SQL(x[3], x[4], { x[5] }, x[6], cName, ::Owner():Params()))),;
			aEval(xWhere, { |x| iif(x[8] == nSeq, ;
											aAdd(aRet, QBE2SQL(x[3], x[4], { x[5] }, x[6], cName, ::Owner():Params())),;
											nil) })
			aEval(xWhere, { |x,i | iif(x[8] == nSeq, ;
											xWhere[i] :=  nil,;
											nil) })
			aAdd(aRetFinal, { "(" + DWConcatWSep(" AND ", aRet) + ")" })
			xWhere := packArray(xWhere)
			nSeq++
		enddo
			
		aRet := "((" + DWConcatWSep(") or (", aRetFinal) + "))"
	else                                                
		if valType(xWhere) == "A"
			aRet := "(("+ DWConcatWSep(") and (", xWhere)+"))"
		else
			aRet := "("+ xWhere+")"
		endif
	endif

	aRet := { strTran(aRet, '"', "'") }

return aRet

/*
--------------------------------------------------------------------------------------
Propriedade IsInd
--------------------------------------------------------------------------------------
*/                         
method IsInd() class TFilAlm
	local lRet := .f.
	local nInd := 0, aAux := ::Expressao()

	if valType(aAux) == "A"
		for nInd := 1 to len(aAux)
			if "FATO->" $ upper(DWStr(aAux[nInd]))
				lRet := .t.
				exit  
			elseif valType(aAux[nInd]) == "A" 
				if !::IsSQL() .and. aAux[nInd, 1] == 0
					lRet := .t.
					exit  
				elseif ::IsQBE() .and. left(aAux[nInd, 7],1) == "I"
					lRet := .t.
					exit  
				endif
			endif
		next
	else
		lRet := .t.
	endif

return lRet 

/*
--------------------------------------------------------------------------------------
Propriedade IsSQL
--------------------------------------------------------------------------------------
*/                         
method IsSQL(alValue) class TFilAlm
	
return ::Props(ID_ISSQL, alValue) .or. ::IsQBE()

/*
--------------------------------------------------------------------------------------
Propriedade IsQBE
--------------------------------------------------------------------------------------
*/                         
method IsQBE(alValue) class TFilAlm
	
return ::Props(ID_ISQBE, alValue)


/*
--------------------------------------------------------------------------------------
Inicializa as propriedade
--------------------------------------------------------------------------------------
*/                         
method Clear() class TFilAlm

	::Name("")
	::Desc("")
	::Expressao("")
	::IsSQL(.T.)
	::IsQBE(.F.)
	::IDExpr(0)

return

/*
--------------------------------------------------------------------------------------
Gera a expressão em Advpl
--------------------------------------------------------------------------------------
*/                         
method ExpAdvpl() class TFilAlm

return ::Expressao()

/*
--------------------------------------------------------------------------------------
Retorna o objeto em formato string para ser utilizado em comparações
--------------------------------------------------------------------------------------
*/
method asString(alMacro) class TFilAlm
	local cRet := ""

	cRet += dwStr(::ExpHtml2(), alMacro)

return cRet

/*
--------------------------------------------------------------------------------------
Define ou Recupera o cubo para este objeto
--------------------------------------------------------------------------------------
*/     
method Cube() class TFilAlm

return ::Owner():Cube()

/*
--------------------------------------------------------------------------------------
Monta o ID para o HTML
--------------------------------------------------------------------------------------
*/
method htmlID() class TFilAlm

return "cb" + DWStr(::Name())


