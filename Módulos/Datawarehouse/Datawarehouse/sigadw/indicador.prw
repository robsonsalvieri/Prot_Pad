// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : SigaDW
// Fonte  : Indicador - Objeto TFieldInfo, contem definição de indicador
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 01.06.01 | 0548-Alan Candido |
// 19.01.05 | 0548-Alan Candido | Versão 3
// 06.03.08 | 0548-Alan Candido | BOPS 141436 - Tratamento de marcador {#$} (utilizado na
//          |                   | exportação com DD
// --------------------------------------------------------------------------------------

#include "dwincs.ch"  
#include "indicado.ch"
#include "indicad1.ch"
      
/*
--------------------------------------------------------------------------------------
Classe: TFieldInfo
Uso   : Contem definição de indicador
--------------------------------------------------------------------------------------
*/
class TFieldInfo from TDWObject
	data flValid
	
	method New(anIndicadorID, aoOwner, alDimField, anCubeID) constructor
	method Free()
	method NewIndicador(anIndicadorID, aoOwner, alDimField, anCubeID) 
	method FreeIndicador()
               
	method DoLoad()
	                                  	
	method ID(anValue, alLoad)
	method Desc(acValue)	
	method Name(acValue)	
	method Tipo(acValue) 
	method Tam(acValue) 
	method NDec(acValue)
	method Classe(acValue)
	method Dimensao(acValue)
	method Mascara(acValue)
	method Expressao(acValue)
	method IsSQL(alValue)
	method Tablename(acValue)
	method Alias(acValue)
	method DimName(alValue)
	method Fullname()
	method CBExpr() 
 	method ExpSQL()
	method RealField(acValue)
	method DimField(alValue)
	method GraphColor(acValue)
	method IsSubtotal(alValue)
	method AggFunc(anValue)
	method AggFuncText(alSummary)
	method AggTit(anAggFunc, acTit, alMeta)
	method Temporal(anValue)
	method Eixo(acValue)
	method Ordem(anValue)
	method RowNumber(anValue)
	method ResetTotal(anValue)
	method SubTotal(anInd, anValue)
	method Show(anInd, alValue)
	method CharIndicador()	
	method CubeID(anValue)
	method DrillDown(alDrill)
	method AdjustValue(xValue)
	method RealValue(xValue)
	method asString(alMacro)
	method isValid()
	method ShowLevel(acLevel)
	method ShowInd(anLevel)
	method canTotalize()
	method ResultInPercentage()
endclass

/*
--------------------------------------------------------------------------------------
Construtor e destrutor da classe
Args: 
--------------------------------------------------------------------------------------
*/
method New(anIndicadorID, aoOwner, alDimField, anCubeID) class TFieldInfo
               
	::NewIndicador(anIndicadorID, aoOwner, alDimField, anCubeID)
	
return

method Free() class TFieldInfo

	::FreeIndicador()

return

method NewIndicador(anIndicadorID, aoOwner, alDimField, anCubeID) class TFieldInfo

	default alDimField := .f.
	
	::NewObject(aoOwner,ID_SIZE)
	::CubeID(anCubeID)
	::DimField(alDimField)               
	::ID(anIndicadorID)
	if valType(::IsSubtotal()) != "L"
		::IsSubtotal(.t.)
	endif
return

method FreeIndicador() class TFieldInfo

	::FreeObject()

return

/*
--------------------------------------------------------------------------------------
Propriedade ID
--------------------------------------------------------------------------------------
*/                         
method ID(anValue, alLoad) class TFieldInfo
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
method Desc(acValue) class TFieldInfo
	local cRet := ""

	if valType(acValue) == "U"
		if ::Temporal() <> 0
			cRet := DT_TITLES[::Temporal()+1]
			cRet := cRet + "(" + dwStr(::Props(ID_DESC, acValue)) + ")"
		else
			cRet := ::Props(ID_DESC, acValue)
		endif
	else
		cRet := ::Props(ID_DESC, acValue)
	endif		
return cRet

/*
--------------------------------------------------------------------------------------
Propriedade Drilldown
--------------------------------------------------------------------------------------
*/                         
method Drilldown(alValue) class TFieldInfo
	
return ::Props(ID_DRILLDOWN, alValue)

/*
--------------------------------------------------------------------------------------
Propriedade Name
--------------------------------------------------------------------------------------
*/                         
method Name(acValue) class TFieldInfo
	
return ::Props(ID_NAME, acValue)

/*
--------------------------------------------------------------------------------------
Propriedade Tipo
--------------------------------------------------------------------------------------
*/                         
method Tipo(acValue) class TFieldInfo
	
return ::Props(ID_TIPO, acValue)

/*
--------------------------------------------------------------------------------------
Propriedade Tam
--------------------------------------------------------------------------------------
*/                         
method Tam(acValue) class TFieldInfo
	
return ::Props(ID_TAM, acValue)

/*
--------------------------------------------------------------------------------------
Propriedade NDec
--------------------------------------------------------------------------------------
*/                         
method NDec(acValue) class TFieldInfo
	
return ::Props(ID_NDEC, acValue)

/*
--------------------------------------------------------------------------------------
Propriedade Classe
--------------------------------------------------------------------------------------
*/                         
method Classe(acValue) class TFieldInfo
	
return ::Props(ID_CLASSE, acValue)

/*
--------------------------------------------------------------------------------------
Propriedade Dimensao
--------------------------------------------------------------------------------------
*/                         
method Dimensao(acValue) class TFieldInfo
	
return ::Props(ID_DIMENSAO, acValue)

/*
--------------------------------------------------------------------------------------
Propriedade AggFunc
--------------------------------------------------------------------------------------
*/                         
method AggFunc(anValue) class  TFieldInfo

return ::Props(ID_AGGFUNC, anValue)

/*
--------------------------------------------------------------------------------------
Propriedade Temporal
--------------------------------------------------------------------------------------
*/                         
method Temporal(anValue) class  TFieldInfo
	if valType(anValue) == "N"
		if anValue != 0 .and. ::Tipo() == "D"
			::NDec(0)
			::Tipo("N")
			if anValue == DT_ANO
				::Tam(4)
			elseif anValue == DT_PERIODO
				::Tipo("C")
				::Tam(15)
			elseif anValue == DT_ESTACAO .or. anValue == DT_MES .or. anValue == DT_DIA .or. anValue == DT_DOW .or. anValue == DT_SEQSEMANA
				::Tam(2)
			elseif anValue == DT_SEMESTRE .or. anValue == DT_QUADMESTRE .or. anValue == DT_TRIMESTRE .or. anValue == DT_BIMESTRE .or. ;
				 anValue == DT_QUINZENA .or. anValue == DT_SEMANA
				::Tam(1)
			elseif anValue == DT_DOY 
				::Tam(3)
			elseif anValue == DT_ANOMES      
				::Tam(7)
			else // Data cheia
				::Tipo("D")
				::Tam(8)
			endif				
		endif			
	endif
return ::Props(ID_TEMPORAL, anValue)

/*
--------------------------------------------------------------------------------------
Propriedade GraphColor
--------------------------------------------------------------------------------------
*/                         
method GraphColor(acValue) class  TFieldInfo

return ::Props(ID_COLOR, acValue)

/*
--------------------------------------------------------------------------------------
Propriedade IsSubTotal
--------------------------------------------------------------------------------------
*/                         
method IsSubtotal(alValue) class  TFieldInfo

return ::Props(ID_SUBTOTAL, alValue)

/*
--------------------------------------------------------------------------------------
Propriedade Mascara
--------------------------------------------------------------------------------------
*/                         
method Mascara(acValue) class TFieldInfo
	
return ::Props(ID_MASCARA, acValue)

/*
--------------------------------------------------------------------------------------
Propriedade Expressao
--------------------------------------------------------------------------------------
*/                         
method Expressao(acValue) class TFieldInfo
    
	if valType(acValue) == "C" .and. ::IsSQL()
		acValue := strTran(acValue, CRLF, " ")
	endif
		
return ::Props(ID_EXPRESSAO, acValue)

/*
--------------------------------------------------------------------------------------
Propriedade IsSQL
--------------------------------------------------------------------------------------
*/                         
method isSQL(alValue) class TFieldInfo
	
return ::Props(ID_ISSQL, alValue)

/*
--------------------------------------------------------------------------------------
Propriedade Eixo
--------------------------------------------------------------------------------------
*/                         
method Eixo(acValue) class TFieldInfo

return ::Props(ID_EIXO, acValue)

/*
--------------------------------------------------------------------------------------
Propriedade Ordem
--------------------------------------------------------------------------------------
*/                         
method Ordem(anValue) class TFieldInfo

return ::Props(ID_ORDEM, anValue)

/*
--------------------------------------------------------------------------------------
Propriedade RowNumber
--------------------------------------------------------------------------------------
*/                         
method RowNumber(anValue) class TFieldInfo

return ::Props(ID_ROWNUMBER, anValue)

/*
--------------------------------------------------------------------------------------
Indica se a coluna deve ser apresentada
--------------------------------------------------------------------------------------
*/
method Show(anInd, alValue) class TFieldInfo

	if valType(alValue) == "L"
		::Props(ID_SHOW)[anInd] := alValue
	endif
	
return ::Props(ID_SHOW)[anInd]

/*
--------------------------------------------------------------------------------------
Metodo ResetTotal(anValue)
Propriedade SubTotal(alnValue, anValue)
--------------------------------------------------------------------------------------
*/                         
method ResetTotal(anValue) class TFieldInfo

	::Props(ID_SUBTOTAL, array(anValue))
	::Props(ID_SHOW, array(anValue))
	
	aFill(::Props(ID_SUBTOTAL), 0)
	aFill(::Props(ID_SHOW), .F.)
	
return

method SubTotal(anInd, anValue) class TFieldInfo
	
	if valType(anValue) == "N"
		::Props(ID_SUBTOTAL)[anInd] := anValue
	endif
	
return ::Props(ID_SUBTOTAL)[anInd]

/*
--------------------------------------------------------------------------------------
Propriedade Tablename
--------------------------------------------------------------------------------------
*/                         
method Tablename(acValue) class TFieldInfo
	
return ::Props(ID_TABLENAME, acValue)

/*
--------------------------------------------------------------------------------------
Propriedade Alias
--------------------------------------------------------------------------------------
*/                         
method Alias(acValue) class TFieldInfo
	local cRet := ::Props(ID_ALIAS, acValue)

	if !empty(cRet) .and. !("_" $ cRet)
		if valType(::Temporal()) == "N" .and. ::Temporal() <> 0
			cRet := substr(cRet,1,1) + DWInt2Hex(::Temporal(), 1) + "_" + substr(cRet,2)
		elseif left(cRet, 1) $ "IV"
			cRet := substr(cRet,1,1) + DWInt2Hex(::AggFunc(), 1) + "_" + substr(cRet,2)
		endif
	endif
	
return cRet

/*
--------------------------------------------------------------------------------------
Propriedade Fullname
--------------------------------------------------------------------------------------
*/                         
method Fullname() class TFieldInfo

return iif(::Temporal() == 0, ::Tablename() + "." + ::RealField(), ;
				oSigaDW:Calend():Tablename() + "." +DT_FIELDS[::Temporal()+1])   

/*
--------------------------------------------------------------------------------------
Propriedade Dimname
--------------------------------------------------------------------------------------
*/                         
method Dimname(acValue) class TFieldInfo
	
return ::Props(ID_DIMNAME, iif(valtype(acValue)=="C", upper(acValue), acValue) )

/*
--------------------------------------------------------------------------------------
Propriedade DimField
--------------------------------------------------------------------------------------
*/                         
method DimField(alValue) class TFieldInfo
	
return ::Props(ID_DIMFIELD, alValue)

/*
--------------------------------------------------------------------------------------
Propriedade CubeID
--------------------------------------------------------------------------------------
*/                         
method CubeID(anValue) class TFieldInfo
	
return ::Props(ID_CUBEID, anValue)

/*
--------------------------------------------------------------------------------------
Propriedade RealField
--------------------------------------------------------------------------------------
*/                         
method RealField(acValue) class TFieldInfo
	local cRet := ::Props(ID_REALFIELD, acValue)
	
	if empty(cRet)
		cRet := ::Name()
	endif
	
return cRet

/*
--------------------------------------------------------------------------------------
Le o Indicador
--------------------------------------------------------------------------------------
*/                         
method DoLoad() class TFieldInfo
	local oTab, oCube, oDim
	local nID, nPos, cAux

	nID := ::ID()
	if ::DimField() 
		oTab := InitTable(TAB_DIM_FIELDS)
	elseif nID > 0
		oTab := InitTable(TAB_FACTFIELDS)
	else
		oTab := InitTable(TAB_CALC)
	endif           

	::Name("")
	::Desc("")
	::Tipo("") 
	::Tam(0) 
	::NDec(0)
	::Classe("")
	::Dimensao(0)
	::Mascara("")
	::Expressao("")
	::IsSQL(.t.)
	::Alias("")
	::AggFunc(AGG_NONE)
	::Temporal(DT_DT)
	::Tablename("")
	::Eixo("")
	::RowNumber(-1)
	::DrillDown(.f.)
	::Showlevel("")
	::flValid := .t.
	if ::ID() <> 0 .and. oTab:Seek( 1, { abs(nID) } )
		::Name(oTab:value("nome"))
		::Desc(oTab:value("descricao"))
		::Tipo(oTab:value("tipo"))
		::Tam(oTab:value("tam"))
		::NDec(oTab:value("ndec"))
		::Mascara(oTab:value("mascara"))
		oCube := ::Owner():Cube()
		if ::ID() > 0
			if ::DimField() 
				::Classe("D")                
				::Dimensao(oTab:value("id_dim")) 
			else 
				::Classe(oTab:value("classe"))
				::Dimensao(0) 
			endif                    
			if ::Dimensao() == 0
				::Tablename(oCube:Fact():Tablename())
				::DimName("fato")
			else                                                        
				oDim := oCube:Dimension(::Dimensao())
				if valType(oDim) == "O"
					::Tablename(oDim:Tablename())
				for nPos := 1 to len(::Owner():Cube():DimProp("ID"))
					if oCube:DimProp("ID")[nPos] == ::Dimensao()
						::DimName(oCube:DimProp("NOME")[nPos])
						exit
					endif
				next
				else				        
					::flValid := .f.
				endif   
			endif           
		else
			::Classe("A")
			::Dimensao(0) 
			::Tablename(oCube:Fact():Tablename())
			::DimName("fato")                       
			::IsSQL(.t.) // todos os indicadores virtuais, obrigatoriamente são SQL
			cAux := oTab:value("expressao")
			::Expressao(cAux)
			cAux := upper(cAux)
			if "@ACUMHISTPERC" $ cAux
				::AggFunc(AGG_ACUMHIST)
			elseif "@ACUMHIST" $ cAux
				::AggFunc(AGG_ACUMHIST)
			elseif "@ACUMPERC" $ cAux
				::AggFunc(AGG_ACUM)
			elseif "@ACUM" $ cAux
				::AggFunc(AGG_ACUM)
			endif
		endif 
	else
		::flValid := .f.
	endif
	
return

/*
--------------------------------------------------------------------------------------
Gera o Code-block de uma expressão
--------------------------------------------------------------------------------------
*/                         
method CBExpr() class TFieldInfo
	local cRet := ::Expressao()
	local aFields := ::Owner():Fields()

	aEval(aFields, { |x| cRet := strTran(cRet, "FATO->"+upper(x:Name()), x:Alias()),;
								cRet := strTran(cRet, "Fato->"+upper(x:Name()), x:Alias()),;
								cRet := strTran(cRet, "fato->"+lower(x:Name()), x:Alias())})
	aEval(aFields, { |x| cRet := strTran(cRet, upper(x:Name()), x:Alias()),;
								cRet := strTran(cRet, lower(x:Name()), x:Alias())})
	cRet := "{ || " + cRet + " }"

return &(cRet)

/*
--------------------------------------------------------------------------------------
Gera a expressão em SQL
--------------------------------------------------------------------------------------
*/                         
method ExpSQL() class TFieldInfo
	
return ::Expressao()

/*
--------------------------------------------------------------------------------------
Propriedade AggFuncText
--------------------------------------------------------------------------------------
*/                         
method AggFuncText(alSummary) class  TFieldInfo
	default alSummary := .f.

return DWAggFuncText(::AggFunc(), alSummary) 

function DWAggFuncText(anAggFun, alSummary) 
	local aAgg
	if alSummary
		aAgg := { 'sum', 'sum', 'avg', 'min', 'max', 'sum', 'sum', 'sum', 'sum', 'sum', 'sum', 'sum', 'sum', 'sum', 'sum', 'sum' }
	else
		aAgg := { 'sum', 'count', 'avg', 'min', 'max', 'sum', 'sum', 'sum',  '',  'sum', 'sum', 'sum', 'sum', 'sum', 'sum', 'sum' }
	endif

	default anAggFun := 0
	
return aAgg[anAggFun+1]
			
/*
--------------------------------------------------------------------------------------
Retorna o titulo do agregador
--------------------------------------------------------------------------------------
*/                         
method AggTit(anAggFunc, acTit, alMeta) class TFieldInfo
	local cRet
	default alMeta := .f.
	default anAggFunc := ::aggFunc()
	default acTit := ::Desc()

	cRet := acTit	
	if !alMeta	
		do case 
			case anAggFunc == AGG_SUM
				cRet += '[S]'
			case anAggFunc == AGG_COUNT
				cRet += '[#]'
			case anAggFunc == AGG_AVG
				cRet += '[M]'
			case anAggFunc == AGG_MIN
				cRet += '[<]'
			case anAggFunc == AGG_MAX
				cRet += '[>]'
			case anAggFunc == AGG_PAR
				cRet += '[%]'
			case anAggFunc == AGG_PARTOT
				cRet += '[%T]'
			case anAggFunc == AGG_VAR
				cRet += '[V]'
			case anAggFunc == AGG_PARGLOB
				cRet += '[%G]'
			case anAggFunc == AGG_MEDINT
				cRet += '[§]'
			case anAggFunc == AGG_ACUM
				cRet += '[A]'
			case anAggFunc == AGG_ACUMHIST
				cRet += '[H]'
			case anAggFunc == AGG_ACUMPERC
				cRet += '[%A]'
			case anAggFunc == AGG_ACUMHISTPERC
				cRet += '[%H]'
			case anAggFunc == AGG_FORMULA
				cRet += '[f.]'
		endcase
   else
		do case 
			case anAggFunc == AGG_SUM
				cRet += ', ' + STR0001 //"somatória"
			case anAggFunc == AGG_COUNT
				cRet += ', ' + STR0002 //"contagem"
			case anAggFunc == AGG_AVG
				cRet += ', ' + STR0003 //"média"
			case anAggFunc == AGG_MIN
				cRet += ', ' + STR0004 //"minímo"
			case anAggFunc == AGG_MAX
				cRet += ', ' + STR0005 //"máximo"
			case anAggFunc == AGG_PAR
				cRet += ', ' + STR0006 //"participação"
			case anAggFunc == AGG_PARTOT
				cRet += ', ' + STR0007 //"participação total"
			case anAggFunc == AGG_VAR
				cRet += ', ' + STR0008 //"variação"
			case anAggFunc == AGG_FORMULA
				cRet += ', ' + STR0009 //"calculado"
			case anAggFunc == AGG_PARGLOB
				cRet += ', ' + STR0010 //"participação global"
			case anAggFunc == AGG_MEDINT
				cRet += ', ' + STR0011 //"média interna"
			case anAggFunc == AGG_ACUM
				cRet += ', ' + STR0012 //"acumulado"
			case anAggFunc == AGG_ACUMHIST
				cRet += ', ' + STR0013 //"acumulado histórico"
			case anAggFunc == AGG_ACUMPERC
				cRet += ', ' + STR0012 + '(%)'//"acumulado"
			case anAggFunc == AGG_ACUMHIST
				cRet += ', ' + STR0013 + '(%)'//"acumulado histórico"

		endcase
   endif
   
return cRet

/*
--------------------------------------------------------------------------------------
Retorna o caracter de tipo do indicador  (usado no applet "DWScriptDefinition")
--------------------------------------------------------------------------------------
*/
method CharIndicador() class TFieldInfo
return "(" + DWStr(::AggFunc()) + iif(!empty(::GraphColor()),"|"+::GraphColor(),"") + "|" + iif(!empty(::ShowLevel()),::ShowLevel(),"") + ")"

/*
--------------------------------------------------------------------------------------
Indica se o indicador é valido ou não
--------------------------------------------------------------------------------------
*/
method isValid() class TFieldInfo
return ::flValid

/*
--------------------------------------------------------------------------------------
Ajusta o valor em função de certas condições
--------------------------------------------------------------------------------------
*/
method AdjustValue(xValue) class TFieldInfo
	local xRet := xValue, nTemporal := ::Temporal()
             
 	if empty(xRet) 
 		if valtype(xRet) <> "N"
	 		xRet := VAZIO
	 	else
	 		xRet := "&nbsp;"
	 	endif
  elseif valType(xRet) == "C" .and. xRet == MAGIC_CHAR
		xRet := "&nbsp;"
  elseif valType(xRet) == "N" .and. xRet == MAGIC_NUMBER
		xRet := "&nbsp;"
  elseif valType(xRet) == "D" .and. xRet == MAGIC_DATE
		xRet := "&nbsp;"
 	elseif nTemporal <> 0 .and. left(dwStr(xRet),1) != "["
		//DT_ANO DT_PERIODO DT_DIA DT_DOY              
		if !empty(xValue) .and. dwStr(xValue) != "&nbsp;"
			if nTemporal == DT_ESTACAO
				if xRet == VERAO_R
					xRet := VERAO
				elseif xRet == OUTONO_R
					xRet := OUTONO
				elseif xRet == INVERNO_R
					xRet := INVERNO
				else //PRIMAVERA_R
					xRet := PRIMAVERA
				endif
			elseif nTemporal == DT_SEMESTRE .or. nTemporal == DT_QUADMESTRE .or.;
					nTemporal == DT_TRIMESTRE .or. nTemporal == DT_BIMESTRE 
					if ::owner():_type() <> TYPE_GRAPH
						xRet := dwStr(xRet)+"&ordm;"
					endif
			elseif nTemporal == DT_MES
				xRet := MesExtenso(ctod("01/"+DWStr(xRet)+"/02"))
			elseif nTemporal == DT_QUINZENA .or. nTemporal == DT_SEMANA .or. nTemporal == DT_SEQSEMANA
				if ::owner():_type() <> TYPE_GRAPH
					xRet := dwStr(xRet)+"&ordf;"
				endif
			elseif nTemporal == DT_DOW	
				xRet := dwStr(xRet)
				do case 
					case xRet == "1"
						xRet := "Dom"
					case xRet == "2"
						xRet := "Seg"
					case xRet == "3"
						xRet := "Ter"
					case xRet == "4"
						xRet := "Qua"
					case xRet == "5"
						xRet := "Qui"
					case xRet == "6"
						xRet := "Sex"
					case xRet == "7"
						xRet := "Sab"
				end case
			endif
		endif
	endif
	
return xRet

/*
--------------------------------------------------------------------------------------
Converte valor ajustado para valor real em função de certas condições
--------------------------------------------------------------------------------------
*/
static aMeses := {}
method RealValue(xValue) class TFieldInfo
	local xRet := xValue, nTemporal := ::Temporal(), nMes

 	if xRet == VAZIO
 	  xRet:= ""
 	elseif nTemporal <> 0 .and. left(dwStr(xRet),1) != "["
		//DT_ANO DT_PERIODO DT_DIA DT_DOY              
		if !empty(xValue) .and. dwStr(xValue) != "&nbsp;"
			if nTemporal == DT_ESTACAO
				if xRet == VERAO
					xRet := VERAO_R
				elseif xRet == OUTONO
					xRet := OUTONO_R
				elseif xRet == INVERNO
					xRet := INVERNO_R
				else //PRIMAVERA
					xRet := PRIMAVERA_R
				endif
			elseif nTemporal == DT_SEMESTRE .or. nTemporal == DT_QUADMESTRE .or.;
					nTemporal == DT_TRIMESTRE .or. nTemporal == DT_BIMESTRE
					if ::owner():_type() <> TYPE_GRAPH
						if rat(xRet, "&ordm;") <> 0
							xRet := dwVal(substr(xRet,1,rat(xRet, "&ordm;")-1))
						else
							xRet := dwVal(xRet)
						endif
					endif
			elseif nTemporal == DT_MES
				if len(aMeses) == 0
					for nMes := 1 to 12
						aAdd(aMeses, MesExtenso(ctod("01/"+DWStr(nMes)+"/02")))
					next
				endif   
				nMes := ascan(aMeses, { |x| x == xRet })
				if nMes <> 0
					xRet := nMes
				endif
			elseif nTemporal == DT_QUINZENA .or. nTemporal == DT_SEMANA
				if ::owner():_type() <> TYPE_GRAPH
					if rat(xRet, "&ordf;") <> 0
						xRet := dwVal(substr(xRet,1,rat(xRet, "&ordf;")-1))
					else
						xRet := dwVal(xRet)
					endif
				endif
			elseif nTemporal == DT_DOW	
				do case 
					case xRet == "Dom"
						xRet := 1
					case xRet == "Seg"
						xRet := 2
					case xRet == "Ter"
						xRet := 3
					case xRet == "Qua"
						xRet := 4
					case xRet == "Qui"
						xRet := 5
					case xRet == "Sex"
						xRet := 6
					case xRet == "Sab"
						xRet := 7
				end case
			endif
		endif
	endif
	
return xRet

/*
--------------------------------------------------------------------------------------
Retorna o objeto em formato string para ser utilizado em comparações
--------------------------------------------------------------------------------------
*/
method asString(alMacro) class TFieldInfo
	local cRet := ""

	cRet += dwStr(::ID(), alMacro)
	cRet += dwStr(::Desc(), alMacro)
	cRet += dwStr(::Name(), alMacro)
	cRet += dwStr(::Tipo(), alMacro)
	cRet += dwStr(::Tam(), alMacro)
	cRet += dwStr(::NDec(), alMacro)
	cRet += dwStr(::Classe(), alMacro)
	cRet += dwStr(::Dimensao(), alMacro)
	cRet += dwStr(::Mascara(), alMacro)
	cRet += dwStr(::Expressao(), alMacro)
	cRet += dwStr(::Tablename(), alMacro)
	cRet += dwStr(::Alias(), alMacro)
	cRet += dwStr(::DimName(), alMacro)
	cRet += dwStr(::Fullname(), alMacro)
	cRet += dwStr(::RealField(), alMacro)
	cRet += dwStr(::DimField(), alMacro)
	cRet += dwStr(::GraphColor(), alMacro)
	cRet += dwStr(::IsSubtotal(), alMacro)
	cRet += dwStr(::AggFunc(), alMacro)
	cRet += dwStr(::Temporal(), alMacro)
	cRet += dwStr(::Eixo(), alMacro)
//	cRet += dwStr(::Ordem(), alMacro)
	cRet += dwStr(::CharIndicador(), alMacro)
	cRet += dwStr(::CubeID(), alMacro)
	cRet += dwStr(::DrillDown(), alMacro)
	cRet += dwStr(::ShowLevel(), alMacro)
	
return cRet

method showLevel(acLevel) class TFieldInfo

return ::Props(ID_SHOWLEVEL, acLevel)

method ShowInd(anLevel) class TFieldInfo
	local lRet := .t.

	local aLevel := {}
	if !empty(::showLevel())
		aLevel := DWToken(::showLevel(), "§")
	
		if anLevel <= len(aLevel)
			if trim(DWStr(aLevel[anLevel])) == "0"
				lRet := .f.
			endif
		endif
	endif

return lRet

/*
--------------------------------------------------------------------------------------
Indica se o indicador por ou não ser totalizado
--------------------------------------------------------------------------------------
*/
static __aNotCanTotalize := { AGG_MEDINT, AGG_ACUM, AGG_ACUMHIST, AGG_ACUMPERC, AGG_ACUMHISTPERC }

method canTotalize() class TFieldInfo
	local nAggFunc := ::aggFunc()

return ascan(__aNotCanTotalize, { |x| x == nAggFunc } ) == 0
/*
--------------------------------------------------------------------------------------
Indica se o resultado é em percentual
--------------------------------------------------------------------------------------
*/
static __ResultInPercentage := { AGG_PAR, AGG_PARTOT, AGG_ACUMPERC, AGG_ACUMHISTPERC }

method ResultInPercentage() class TFieldInfo
	local nAggFunc := ::aggFunc()

return ascan(__ResultInPercentage, { |x| x == nAggFunc } ) == 0

function __indicador
return .f.

