// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : SigaDW
// Fonte  : Cube - Objeto TCube, contem definição e acesso ao cubo
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 01.06.01 | 0548-Alan Candido |
// 17.11.05 |2481-Paulo R Vieira| Fase 3 - Ajustes para novo layout
// --------------------------------------------------------------------------------------

#include "dwincs.ch"

/*
--------------------------------------------------------------------------------------
Classe: TCube
Uso   : Contem definição e acesso ao cubo
--------------------------------------------------------------------------------------
*/
class TCube from TDWObject

	data fnID
	data faFields
	data foFact
	data faDimension 
	data faPropNome
	data faPropID
	data faKeyList
	data faIndicadores
	data faIndVirtual
	data fcName
	data fcDescricao
  data foQuery
  
	method New(anCubeID) constructor
	method Free()
 	
	method Fact(aoValue)
	method Dimension()
	method DimProp(acName)
	method DimFields(axValue)
	method DimObj(axValue)
	method AddDimension(aoDimension, acName)
	method Fields(aaValue)
	method GetIndicadores()
	method SetIndicadores(aaIndList)
	method SetIndVirtual(aaIndList)
	method GetIndVirtual()
	method _CubeID()
	method ID()
	method Name()	
	method ResetWorkfiles()
	method RecCount()
	method Close()
	method Descricao()
  method Query()
endclass

/*
--------------------------------------------------------------------------------------
Construtor e destrutor da classe
Args: 
--------------------------------------------------------------------------------------
*/
method New(anCubeID) class TCube
   
	local oCube := InitTable(TAB_CUBESLIST)
	
	_Super:New()

	::fnID := anCubeID	
	::foFact := NIL
	::faDimension := {}
	::faPropNome := {}
	::faPropID := {}
	::faKeyList := {}
	::faFields := {}
	::faIndicadores := {}
	::faIndVirtual := {}
   if oCube:Seek(1, { anCubeID })
  		::fcName := oCube:value('nome', .t.)
  		::fcDescricao := oCube:value("descricao", .t.)
  	else                                       
  		::fcName := ""
  		::fcDescricao := ""
  	endif

return

method Free() class TCube

	_Super:Free()

return

/*
--------------------------------------------------------------------------------------
Propriedade Fact
--------------------------------------------------------------------------------------
*/                         
method Fact(aoValue) class TCube
	
	property ::foFact := aoValue
		
return ::foFact

/*
--------------------------------------------------------------------------------------
Propriedade Fields
--------------------------------------------------------------------------------------
*/                         
method Fields(aaValue) class TCube
	
	property ::faFields := aaValue
		
return ::faFields

/*
--------------------------------------------------------------------------------------
Propriedade Dimension
--------------------------------------------------------------------------------------
*/                         
method Dimension(anInd) class TCube
	local xRet := nil
	local nPos
	
	if valType(anInd) == "U"
		xRet := ::faDimension
	else         
		nPos := ascan(::DimProp("ID"), { |x| x == anInd })
		if nPos > 0
			xRet := ::faDimension[nPos]
		endif
	endif	

return xRet 

method DimProp(acPropname, anInd) class TCube
	local xRet

	acPropname := upper(acPropname)
	if valType(anInd) == "U"
		if acPropname == "NOME"
			xRet := ::faPropNome
		elseif acPropname == "KEYLIST"
			xRet := ::faKeyList 
		elseif acPropname == "ID"
			xRet := ::faPropID
		else
			xRet := ::Fields()
		endif         
	else
		if acPropname == "NOME"
			xRet := ::faPropNome[anInd]
		elseif acPropname == "KEYLIST"
			xRet := ::faKeyList[anInd]
		elseif acPropname == "ID"
			xRet := ::faPropID[anInd]
		else
			xRet := ::Dimension(::faPropID[anInd]):Fields()
		endif         
	endif
	
return xRet

/*
--------------------------------------------------------------------------------------
Retorna a lista de campos de uma dimensão
Arg: axValue -> string|integer, nome ou ID da dimensão a processar
Ret: aRet -> array, lista de campos da dimensão
--------------------------------------------------------------------------------------
*/                         
method DimFields(axValue) class TCube
	local nID
	
	if valType(axValue) == "C"                              
		axValue := upper(axValue)
		nID := ascan(::faPropNome, { |x| upper(x) == axValue } )
		nID := ::faPropID[nID]
	else
		nID := axValue
	endif
	
return ::Dimension(nID):Fields()

/*
--------------------------------------------------------------------------------------
Retorna a a dimensão
Arg: axValue -> string|integer, nome ou ID da dimensão a processar
Ret: aRet -> array, lista de campos da dimensão
--------------------------------------------------------------------------------------
*/                         
method DimObj(axValue) class TCube
	local nID
	
	if valType(axValue) == "C"                              
		axValue := upper(axValue)
		nID := ascan(::faPropNome, { |x| upper(x) == axValue } )
		nID := ::faPropID[nID]
	else
		nID := axValue
	endif
	
return ::Dimension(nID)

/*
--------------------------------------------------------------------------------------
Adiciona uma nova dimensão
--------------------------------------------------------------------------------------
*/                         
method AddDimension(aoDimension, acName, aaKeyNames, anID) class TCube
	
	aAdd(::faPropNome, acName)
	aAdd(::faKeyList, aaKeyNames)
	aAdd(::faPropID, anID)
	
return aAdd(::faDimension, aoDimension)

/*
--------------------------------------------------------------------------------------
Retorna os indicadores
--------------------------------------------------------------------------------------
*/                         
method SetIndicadores(aaIndList) class TCube

	::faIndicadores := aClone(aaIndList)
	
return 

method SetIndVirtual(aaIndList) class TCube

	::faIndVirtual := aClone(aaIndList)
	
return 

method GetIndicadores(acIndicador) class TCube
	local aRet := {}
	local nPos
	
	default acIndicador = ""

	if empty(acIndicador)
		aRet := ::faIndicadores
	else
		nPos := ascan(::faIndicadores, { |x| upper(X) == acIndicador})
		if nPos != 0
			aRet := ::faIndicadores[nPos]
		endif
	endif	

return aRet

method GetIndVirtual(acIndicador) class TCube
	local aRet := {}
	local nPos
	
	default acIndicador = ""

	if empty(acIndicador)
		aRet := ::faIndVirtual
	else
		nPos := ascan(::faIndVirtual, { |x| upper(X) == acIndicador})
		if nPos != 0
			aRet := ::faIndVirtual[nPos]
		endif
	endif	

return aRet


/*
--------------------------------------------------------------------------------------
Propriedade _CubeID
--------------------------------------------------------------------------------------
*/                         
method _CubeID() class TCube

return ::fnID

method ID() class TCube

return ::fnID

/*
--------------------------------------------------------------------------------------
Propriedade Name
--------------------------------------------------------------------------------------
*/                         
method Name() class TCube

return ::fcName

/*
--------------------------------------------------------------------------------------
Propriedade Descricao
--------------------------------------------------------------------------------------
*/                         
method Descricao() class TCube

return ::fcDescricao

/*
--------------------------------------------------------------------------------------
Elimina os arquivos de trabalhos gerados pelas consultas para que possam ser reconstruidos
--------------------------------------------------------------------------------------
*/                         
method ResetWorkfiles() class TCube
	local oQuery := TQuery():New("TRA")
	
	oQuery:FieldList("id_cons")
	oQuery:FromList(TAB_CONSULTAS)
	oQuery:MakeDistinct(.t.)
	oQuery:WhereClause("id_cube = " + DWStr(::ID()))
	oQuery:Open()

	while !oQuery:eof() 
		if  TCDelFile(DWSumName(oQuery:value("id_cons"),"X"))
			DWLog("ResetWorkfiles", "SQL error", tcSqlError())
		endif
		if  TCDelFile(DWSumName(oQuery:value("id_cons"),"Y"))
			DWLog("ResetWorkfiles", "SQL error", tcSqlError())
		endif
		oQuery:_Next()
	enddo

	oQuery:Close()

return

/*
--------------------------------------------------------------------------------------
Retorna o número de registros existentes no cubo
--------------------------------------------------------------------------------------
*/                         
method RecCount() class TCube
	local nRet, oQuery
	
	oQuery := TQuery():New("TRA")
	oQuery:FieldList("count(ID)")
	oQuery:FromList(DWCubename(::ID()))
	oQuery:Open()
	nRet := oQuery:value(1) 
	oQuery:Close()         
	
return nRet

/*
--------------------------------------------------------------------------------------
Fecha o cubo
--------------------------------------------------------------------------------------
*/                         
method Close() class TCube

	if valType(::Fact()) == "O"
		::Fact():Close()
	endif
	if valType(::Query()) == "O"
		::Query():Close()
	endif
	aEval(::DimObj(), { |x| x:Close() })
	
return

/*
--------------------------------------------------------------------------------------
Monta query de leitura do cubo
--------------------------------------------------------------------------------------
*/                         
method Query() class TCube
	local aAux := {}  
  if valtype(::foQuery) == "U"
    ::foQuery := TQuery():New(,"Q_"+::Name())
    aEval(::Fact():Fields(), { |x| aAdd(aAux, x[FLD_NAME]), ;
                    ::foQuery:AddField(nil, x[FLD_NAME], x[FLD_TYPE], x[FLD_LEN], x[FLD_DEC]) })
    ::foQuery:FieldList(dwConcatWSep(",", aAux))
    ::foQuery:FromList(::Fact():TableName())
    ::foQuery:Open()
  endif
  
return ::foQuery

