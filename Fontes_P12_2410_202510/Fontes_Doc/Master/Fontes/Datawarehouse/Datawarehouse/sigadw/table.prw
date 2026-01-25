// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : SigaDW
// Fonte  : Table - Objeto TTable, acesso as tabelas da base de dados
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 01.06.01 | 0548-Alan Candido |
// 12.11.07 | 0548-Alan Candido | BOPS 135941, eliminação de código obsoleto no método DropRecnoIndex()
// 22.11.07 | 0548-Alan Candido | BOPS 136453 - Ajuste em procedimentos da migração 
//          |                   |   de versões anteriores a R4
// 18.01.08 | 0548-Alan Candido | BOPS 139342 - Implementação e adequação de código, 
//          |                   | em função de re-estruturação para compartilhamento de 
//          |                   | código.
// 18.03.08 | 0548-Alan Candido | BOPS 142638 - Adequação de código, para tratar a geração de
//          |                   | ID, quando este for tipo "C", no lugar do padrão, que é "N"
// 25.11.08 |0548-Alan Candido  | FNC 00000007374/2008 (10) e 00000007385/2008 (8.11)
//          |                   | Ajuste no layout de mensagem de tabela com estrutura modificada
// --------------------------------------------------------------------------------------

#include "dwincs.ch"
#include "topconn.ch"
#include "table.ch"

#define MSG_DPL_REG STR0026  //"Registro já existe. Verifique os campos chaves." 
#define FIELDS_LIMIT_INDEX 14

/*
--------------------------------------------------------------------------------------
Classe: TTable
Uso   : Tabela de dados
--------------------------------------------------------------------------------------
*/
class TTable from TDWObject
  data faParents
	data faStack
	data fcMsg
	data fnRefCount
	data fcAlias
	data fcTablename
	data faFields
	data faStruct
	data faIndexes
	data fcFilter
	data fbFilter
	data fcFilterSQL
	data faListVal
	data flIndexOn
	data flLocal
	data fcDescricao
	data foConsulta
	data flSX
	data fbEvents
	data fbValidate
	data flHaveDWField

	method New(acTablename, acAlias, alLocal) constructor
	method Free()
               
	method Alias()
	method Tablename()
	method Fields(acFieldName)
	method Indexes()
	method IndexOff()
	method IndexOn()
	
	method PutInUse()
	method Exists()
	method CreateTable(acTablename, alLocal, alStruct)
	method Open(alExclusive)
	method OpenIndexes()
	method OpenIndex(acIndice, acChave, alNew)
	method Close()
	method InitFieldsDef() 
	method AddField(acInitDef, acFieldname, acType, anLen, anDec, abGet, abSet)
	method AddFieldID()
	method AddFieldDW()
	method SetAttField(acFieldname, acTitle, acMask, acRealField, anID)
	method SetRealField(acFieldname, acRealField)
	method SetOrigField(acFieldname, acOrigField)
	method SetGetBlock(acFieldname, abGet)
	method SetRoteiro(acFieldname, abRoteiro)
	method GetRoteiro(acFieldname)
	method SetVisible(acFieldname, alValue)
	method SetReadOnly(acFieldname, alValue)
	method ResetFields()
	method setField(acFieldName, acType, acLen, acNDec)
	method AddIndex(acIndice, acChave, abChave, aaFieldList, alUnico)
	method AddIndex2(acIndexname, aaFieldList, alUnico)
	method Append(aaFieldValues, alIgnoreID)
	method Update(aaFieldValues, alIfnoreID, alUpdOnlyNeed)
	method Delete()
	method IsOpen()
	method GeraID()
	method GoTop()
	method GoTo()
	method _Next(anSkip)
	method Previous()
	method GoBottom()
	method _Bof()
	method Eof()
	method Lock()
	method Unlock()
	method RecCount(alSQL)
	method Value(acField, alTrim, alRPC)
	method ValByPos(anField)
	method ValTxt(acnField)
	method ListVal(acnField, axValue)
	method ListVal2(acnField, axValue)
	method ListVal3(acField, axValue)
	method AddListVal(acFieldname, aaValList)
	method Seek(anIndexNumber, aaKeyValue, alSoftseek)
	method Found()
	method RecNo()
	method Filter(acValue)
	method FilterSQL(acValue, aaParams)
	method ApplyFilter()
	method ClearFilter()
	method Record(anFormat, aaExcFields)
	method Record2(aaFields)
	method Zap()
	method Pack()
	method Reindex()
	method CreateIndex(anIndex)
	method DropTable()
	method Refresh(alRecord)
	method ChkStruct(alVerOnly, abNotify)
	method Msg(alCRLF)
	method SavePos()
	method RestPos()
	method AppSDF(acFilename)
	method CopyToSDF(acFilename)
	method FromCookies(aCookies, acAlias, aIgnFields)
	method FromPost(aPostParm, aIgnFields)
	method CopyTo(acTargetFile, abFilter, alLocal) 
  method Descricao(acValue)
	method FieldPos(acFieldName)   
	method FieldPut(anPos, axValue)
	method FieldGet(anPos)
	method Consulta(aoValue)
	method SX(alValue)
	method Events(abValue)
	method FireEvent(anMoment, anEvent, alCond, aaValues)
	method SearchIndex(aaFieldList, alCreate)
	method makeKeyExpr(aaFieldList)
	method makeKeyBlock(aaFieldList)
	method Validate(abValue)
	method isValid(aaValues)
	method indexKey(anOrder)
	method indexOrd()
	method EraseDD(acTipoInfo)
	method LoadDD()
	method SaveDD()      
	method Struct()
 	method DropRecnoIndex()
 	method CreateRecnoIndex()
 	method DropIndexes()
 	method updStat(acTable)
 	method SpaceUsed(acTablename)
 	method RebuildRecno(anInic, anPasso)
 	method syncronize()
	method HaveDWField()
	method completeList(aaValues)
  method validParents() 
  method addParent() 
endclass

/*
--------------------------------------------------------------------------------------
Construtor e destrutor da classe
Args: acTablename -> string, nome da tabela
--------------------------------------------------------------------------------------
*/
method New(acTablename, acAlias, alLocal) class TTable

	default acAlias := acTablename          
	default alLocal := .f.

	_Super:New()
                 
	::flSX := .f.
	::flLocal := alLocal
	::fcTablename := upper(alltrim(acTablename))
	::fcDescricao := ::fcTablename
	::faParents := {} 
	if	type("oSigaDW") == "O"
		if !empty(__DWPrefixo) .and. !DWTableShared(acTablename)
			::fcTablename := left(::fcTablename, 2) + __DWPrefixo + substr(::fcTablename, 4)
			acAlias := ::fcTablename
		endif
	endif
	::fcAlias := acAlias
	::faFields := {}
	::faIndexes := {}
	::fnRefCount := 0
	::fcFilter := ""
	::fcFilterSQL := ""
	::faListVal	:= {}
	::flIndexOn := .T.
	::fcMsg := ""
	::faStack := { NIL }    
	::faStruct := {}
	::flHaveDWField := .f.
	
return

method Free() class TTable

	if type("oSigaDW") == "O"
		oSigaDW:RemoveTable(self)
	endif

	_Super:Free()
	
return

/*
--------------------------------------------------------------------------------------
Propriedade Tablename
--------------------------------------------------------------------------------------
*/                         
method Tablename() class TTable
	
return ::fcTablename

/*
--------------------------------------------------------------------------------------
Propriedade Alias
--------------------------------------------------------------------------------------
*/                         
method Alias() class TTable
	
return ::fcAlias

/*
--------------------------------------------------------------------------------------
Propriedade Fields
Args: acFieldName -> string, nome do campo desejado. Se não especificao retorna todos
--------------------------------------------------------------------------------------
*/                         
method Fields(acFieldName) class TTable
	local nPos, aRet
	
	if valType(acFieldName) == "C"
		acFieldName := alltrim(upper(acFieldName))
		nPos := aScan( ::faFields, { |x| x[1] == acFieldName})
		if nPos > 0
			aRet := ::faFields[nPos]
		endif			
	else
		aRet := ::faFields
	endif
	
return aRet

/*
--------------------------------------------------------------------------------------
Propriedade indexes
--------------------------------------------------------------------------------------
*/                         
method Indexes() class TTable
	
return ::faIndexes

/*
--------------------------------------------------------------------------------------
Adiciona um novo registro
Args: aaValues -> array, lista de campos a anexar
		alIgnoreID -> logico, quando aaValues for do tipo "O", este param indica se é pa-
			ra ignorar ou não o ID da tabela origem
Rets: lRet -> lógico, insersão bem suscedida ou não
--------------------------------------------------------------------------------------
*/                         
method Append(aaValues, alIgnoreID, alInsBySql) class TTable
	local lRet := .f., nInd, nPos         
	local cFieldname, aFields := ::Fields(), aAux
	local lOk := .t.
	local aPesq := {}
	local x
	local cSQL := ""

	default alInsBySql := .f.
	
	::fcMsg := ""
	
	if valType(aaValues) == "O"    
		default alIgnoreID := .f.
		aAux := {}               
		aEval(aaValues:Fields(), { |x| iif(::FieldPos(upper(x[1]))<>0, aAdd(aAux, { x[1], aaValues:value(x[1]) }), nil)})
		if alIgnoreID 
			nPos := ascan(aAux, { |x| x[1] == "ID" })
			if nPos <> 0
				aAux[nPos] := nil
				aAux := packArray(aAux)
			endif
		endif  
		for nInd := 1 to len(aAux)
			nPos := ascan(aFields, { |x| upper(x[FLD_NAME]) == upper(aAux[nInd,1])})
			if nPos != 0 
				if !empty(aFields[nPos, FLD_ROTEIRO])
					aAux[nInd, 2] := eval(aFields[nPos, FLD_ROTEIRO])
				endif
				if valType(aAux[nInd, 2]) == "N"
					aAux[nInd, 2] := DWTrunc(aAux[nInd, 2], aFields[nPos, FLD_LEN], aFields[nPos, FLD_DEC])
				endif
			endif
		next
		if SGDB() $ DB_MSSQL_ALL
			lRet := ::Append(aAux,.f.,.t.)
		else
			lRet := ::Append(aAux)
		endif
	else      
		if ::isValid(aaValues)
			::FireEvent(FE_BEFORE, FE_APPEND,,aaValues)
			if alInsBySql
				nValor := ::GeraID()
				nPos := ascan(aaValues, { |x| x[1] == "ID" })
				if nPos == 0
					aAdd(aaValues, {"ID", nValor})
				endif
				nPos := ascan(aaValues, { |x| x[1] == "R_E_C_N_O_" })
				if nPos == 0
					aAdd(aaValues, {"R_E_C_N_O_", nValor})
				endif
				aFieldIns := {}
				aValueIns := {}				
				for nInd := 1 to len(aaValues)
					aAdd(aFieldIns, aaValues[nInd,1])
					aAdd(aValueIns, dwstr(aaValues[nInd,2], .t.))				
				next
				cSQL := "INSERT INTO " + ::fcAlias + " (" + dwConcatWSep(",", aFieldIns) + ") values (" + dwConcatWSep(",", aValueIns) + ")"
				DWSQLExec(cSQL)
				::Refresh()
			else
				dbSelectArea(::fcAlias)  
				for x=1 to len(::Indexes())
					if(::Indexes()[x][5] == .t.)
						aEval(::Indexes()[x][4], { |x| aAdd(aPesq, x) } )
						::Savepos()
						if(::Seek(x,RetPesq(aPesq, aaValues), .f.))
							lOk := .f.
							lRet := .f.
							::fcMsg := MSG_DPL_REG
						endif
						::RestPos()
					endif
				next
				if lOk
					for nInd := 1 to len(aFields)	
						cFieldname := upper(aFields[nInd, FLD_NAME])
						if aScan(aaValues, { |x| upper(x[1]) == cFieldname }) == 0
							aAdd(aaValues, { cFieldname, aFields[nInd, FLD_DEFAULT] } )
						endif
					next
					if ::Lock(.T.)
						for nInd := 1 to len(aaValues)	               
							aAux := ::Fields(aaValues[nInd, 1])
							if valType(aaValues[nInd, 2]) == "B"
								aaValues[nInd, 2] := eval(aaValues[nInd, 2])
							endif
							if valType(aAux) == "A" .and. valType(aAux[8]) == "B"
								eval(aAux[8], aaValues[nInd, 2])
							else                  
								nPos := ::FieldPos(aaValues[nInd,1])
								if nPos <> 0 .and. empty(::FieldGet(nPos))
									::FieldPut(nPos, aaValues[nInd, 2])
								endif
							endif
						next
						lRet := .t.	                             
						::Unlock()
					endif
				endif
			endif
			::FireEvent(FE_AFTER, FE_APPEND, lRet, aaValues)
		else
			lRet := .f.
		endif
	endif                                   
	
return lRet

/*
--------------------------------------------------------------------------------------
Atualiza o registro atual
Args: aaValues -> array, lista de campos a anexar
Rets: lRet -> lógico, atualização bem suscedida ou não
--------------------------------------------------------------------------------------
*/                         
method Update(aaValues, alIgnoreID, alUpdOnlyNeed) class TTable
	local lRet := .f., nInd, aAux, aValAnt
	local lOk := .t., aFields := ::Fields()
	local aPesq := {}, aAlvo
	local x, y
	
	default alUpdOnlyNeed := .f.
		
	if valType(aaValues) == "O"
		default alIgnoreID := .f.
		aAux := {}               
		aEval(aaValues:Fields(), { |x| iif(::FieldPos(upper(x[FLD_NAME]))<>0, aAdd(aAux, { x[1], aaValues:value(x[FLD_NAME]) }), nil)})
		if alIgnoreID
			nPos := ascan(aAux, { |x| x[FLD_NAME] == "ID" })
			if nPos <> 0
				aAux[nPos] := nil
				aAux := packArray(aAux)
			endif
		endif
		for nInd := 1 to len(aAux)
			nPos := ascan(aFields, { |x| upper(x[FLD_NAME]) == upper(aAux[nInd,1])})
			if nPos != 0 .and. !empty(aFields[nPos, FLD_ROTEIRO])
				aAux[nInd, 2] := eval(aFields[nPos, FLD_ROTEIRO])
				if valType(aAux[nInd, 2]) == "N"
					aAux[nInd, 2] := DWTrunc(aAux[nInd, 2], aFields[nPos, FLD_LEN], aFields[nPos, FLD_DEC])
				endif
			endif
		next
		lRet := ::Update(aAux, alIgnoreID, alUpdOnlyNeed)
	else
		if ::isValid(aaValues)
			::FireEvent(FE_BEFORE, FE_UPDATE,, aaValues)
			if alUpdOnlyNeed 
				lOk := .f.
				lRet := .t.
				aValAnt := ::Record(1)
				for nInd := 1 to len(aValAnt)
					nPos := ascan(aaValues,  { |x| x[1]==aValAnt[nInd,1] })
					if nPos <> 0 .and. DWStr(aValAnt[nInd, 2]) <> DWStr(aaValues[nPos, 2])
						lOk := .t.
						exit
					endif
				next
			endif
				
			if lOk
				dbSelectArea(::fcAlias)  
				y := ::value("id")
				::completeList(aaValues)
				for x=1 to len(::Indexes())
					if(::Indexes()[x][5] == .t.)
						aEval(::Indexes()[x][4], { |x| aAdd(aPesq, x) } )
						aAlvo := RetPesq(aPesq, aaValues)
						::Savepos()
						if len(aAlvo) > 0 .and. ::Seek(x, aAlvo)
							if (y <> ::Value("id"))
								lOk := .f.
								lRet := .f.
								::fcMsg := MSG_DPL_REG
								exit
							endif
						endif
						::RestPos()
					endif
				next
			endif
		
			if lOk
				if ::Lock()
					for nInd := 1 to len(aaValues)	
						if valType(::Fields(aaValues[nInd,1])) == "U"
							loop
						endif
						if valType(aaValues[nInd, 2]) == "B"
							aaValues[nInd, 2] := eval(aaValues[nInd, 2])
						endif
						if valType(::Fields(aaValues[nInd,1])[FLD_SET]) == "B"
							eval(::Fields(aaValues[nInd,1])[FLD_SET], aaValues[nInd, 2])
						else
							::FieldPut(::FieldPos(aaValues[nInd,1]), aaValues[nInd, 2])
						endif
					next
					lRet := .t.
					::Unlock()
				endif
			endif
			::FireEvent(FE_AFTER, FE_UPDATE, lRet, aaValues)
		else
			lRet := .f.
		endif
	endif
	
return lRet

method completeList(aaValues) class TTable
	local nInd := 0, aFields := ::Fields()
    local aAux := {}
    	
	for nInd := 1 to len(aFields)
		if (::fcAlias)->(FieldPos(aFields[nInd, FLD_NAME])) > 0 .and. ascan(aaValues, { |x| upper(x[1]) == aFields[nInd, FLD_NAME]}) == 0
			aAdd(aAux, { aFields[nInd, FLD_NAME], ::value(aFields[nInd, FLD_NAME])})
		endif
	next
	aEval(aaValues, { |x| aAdd(aAux, x) })
	aaValues := aAux
return


/*
--------------------------------------------------------------------------------------
Excluir registro atual
Args: 
Rets: lRet -> lógico, processo OK
--------------------------------------------------------------------------------------
*/                         
method Delete() class TTable
	local lRet
	          
	::FireEvent(FE_BEFORE, FE_DELETE)
	lRet := ::Lock()		
	if lRet
		dbDelete()
		::Unlock()
	endif
	::FireEvent(FE_AFTER, FE_DELETE, lRet)
	
return lRet
                 
/*
--------------------------------------------------------------------------------------
Informa ao TC como o campo deve ser tratado
Args: acFieldname -> string, nome do campo
		acType -> string, tipo do campo
		anLen -> numerico, tamanho do campo
		anDec -> numerico, numero de decimais
Rets: nil
--------------------------------------------------------------------------------------
*/                         
method setField(acFieldname, acType, anLen, anDec) class TTable

#ifdef TOP     
	if ascan(::Struct(), { |x| acFieldname == x[1]}) <> 0
		if anLen > 15  //#####PROBLEMA NO TOP
			anLen := 15
		endif
		tcSetField(::Alias(), acFieldname, acType, anLen, anDec)
	endif
#endif
return

/*
--------------------------------------------------------------------------------------
Adiciona um novo campo
Args: acFieldname -> string, nome do campo
		acType -> string, tipo do campo
		anLen -> numerico, tamanho do campo
		anDec -> numerico, numero de decimais
Rets: lRet -> lógico, insersão bem suscedida ou não
--------------------------------------------------------------------------------------
*/                         
method ResetFields() class TTable

	::faFields := {}
	
return

method AddField(acInitDef, acFieldname, acType, anLen, anDec, abGet, abSet) class TTable
	local lRet := .f., bInitDef //, aField
	
	default anDec := 0                                                  
	acFieldName := upper(alltrim(acFieldName))
	if aScan( ::Fields(), { |x| x[FLD_NAME] == acFieldName }) == 0
		lRet := .T.   
		if acType == "C"			
			default anLen := 30
		elseif acType == "N"			
			default anLen := 10
		elseif acType == "D"
			anLen := 8
		elseif acType == "M"
			anLen := 10
		else 
			anLen := 1
		endif

		if valType(acInitDef) == "U"
			if acType == "C"
				bInitDef := {|| ""}
			elseif acType == "D"
				bInitDef := {|| ctod("  /  /  ") }
			elseif acType == "L"
				bInitDef := {|| .f.}
			elseif acType == "N"
				bInitDef := {|| 0}
			elseif acType == "M"
				bInitDef := {|| ""}
			else
				bInitDef := NIL
			endif
		else
			if valType(acInitDef) == "B"
				bInitDef := acInitDef
			else
				bInitDef := &("{|| " + acInitDef + " }")
			endif
		endif

		aField := array(FLD_ARRAY_SIZE)
		aField[FLD_NAME] := upper(alltrim(acFieldname)) 
		aField[FLD_TYPE] := acType
		aField[FLD_LEN] := anLen
		aField[FLD_DEC] := anDec
		aField[FLD_DEFAULT] := bInitDef
		aField[FLD_GETINFO] := nil // não esta mais em uso no SigaDW3
		aField[FLD_SET] := abSet
		aField[FLD_GET] := abGet
		aField[FLD_REALNAME] := alltrim(acFieldname)
		aField[FLD_TITLE] := ""
		aField[FLD_MASK] := ""
		aField[FLD_ID] := -(len(::Fields())+1)
		aField[FLD_VISIBLE] := .T.
		aField[FLD_ROTEIRO] := nil
		aField[FLD_BLANK] := .F.
		aField[FLD_COLSPAM] := .F.
		aField[FLD_READONLY] := .F.

		aAdd(::Fields(), aField )

		::SetAttField(acFieldname, acFieldname, , , , len(::Fields()))
	endif
	                             
return lRet

/*
--------------------------------------------------------------------------------------
Adiciona a definição do campo ID
Args:
Rets:
--------------------------------------------------------------------------------------
*/                         
method addFieldID() class TTable

	::AddField({|| ::GeraID() }, "id", "N")
	::AddIndex2(nil, { "id" } )
	::setVisible("ID", .f.)

return

/*
--------------------------------------------------------------------------------------
Adiciona a definição do campo ID_DW (para ligação com TAB_DW)
Args:
Rets:
--------------------------------------------------------------------------------------
*/                         
method addFieldDW() class TTable

	::AddField({|| oSigaDW:DWCurrID() }, "id_dw", "N")
	::setVisible("id_dw", .f.)
	::flHaveDWField := .t.
  ::addParent(TAB_DW, "ID_DW")

return

/*
--------------------------------------------------------------------------------------
Ajusta atributos de campos
Args: acFieldname -> string, nome do campo
		acTitle -> string, titulo do campo
		acMask -> string, mascara de formatação                     
		anID -> numerico, ID de identificação
Rets: lRet -> lógico, ajuste bem suscedido ou não
--------------------------------------------------------------------------------------
*/                         
method SetAttField(acFieldname, acTitle, acMask, acRealField, anID, anIndex) class TTable
	local nPos
	local lBlank := .f.
	local lColSpam := .f.

	default acTitle := acFieldname
	default acMask := ""
	default anIndex := -1
	
	nPos := at("|", acTitle)
	if nPos > 0
		lBlank := .t.
		lColSpam := at(">", acTitle) <> 0
		acTitle := substr(acTitle, 1, nPos - 1)
	endif
	
	acFieldname := upper(alltrim(acFieldName))	
	if anIndex == -1
		nPos := aScan( ::Fields(), { |x| upper(alltrim(x[FLD_NAME])) == acFieldName})
	else
		nPos := anIndex
	endif
	if nPos <> 0
		::Fields()[nPos, FLD_TITLE] := acTitle
		::Fields()[nPos, FLD_MASK]  := acMask
		if valType(anID) == "N"
			::Fields()[nPos, FLD_ID] := anID
		endif
		::SetRealField(acFieldname, acRealField)
		::Fields()[nPos, FLD_BLANK] := lBlank
		::Fields()[nPos, FLD_COLSPAM] := lColSpam
	endif
	                             
return (nPos <> 0)

/*
--------------------------------------------------------------------------------------
Ajusta o nome real do campo 
Args: acFieldname -> string, nome do campo
		acRealField -> string, nome real do campo
Rets: lRet -> lógico, ajuste bem suscedido ou não
--------------------------------------------------------------------------------------
*/                         
method SetRealField(acFieldname, acRealField) class TTable
	local nPos

	default acRealField := ""

	acFieldname := upper(alltrim(acFieldName))	
	nPos := aScan( ::Fields(), { |x| upper(alltrim(x[FLD_NAME])) == acFieldName})
	if nPos <> 0
		::Fields()[nPos, FLD_REALNAME] := acRealField
	endif
	                             
return (nPos <> 0)

/*
--------------------------------------------------------------------------------------
Ajusta o bloco Get
Args: acFieldname -> string, nome do campo
		abGet -> codeblock, associado a leitura do campo
Rets: lRet -> lógico, ajuste bem suscedido ou não
--------------------------------------------------------------------------------------
*/        
method SetGetBlock(acFieldname, abGet) class TTable
	local nPos

	acFieldname := upper(alltrim(acFieldName))	
	nPos := aScan( ::Fields(), { |x| upper(alltrim(x[FLD_NAME])) == acFieldName})
	if nPos <> 0
		::Fields()[nPos, FLD_GET] := abGet
	endif
	                             
return (nPos <> 0)

/*
--------------------------------------------------------------------------------------
Ajusta o nome do campo origem
Args: acFieldname -> string, nome do campo
		acRealField -> string, nome do campo de origem
Rets: lRet -> lógico, ajuste bem suscedido ou não
--------------------------------------------------------------------------------------
*/                         
method SetOrigField(acFieldname, acOrigField) class TTable
	local nPos                                      
	
	default acOrigField := ""

	acFieldname := upper(alltrim(acFieldName))	
	nPos := aScan( ::Fields(), { |x| upper(alltrim(x[FLD_NAME])) == acFieldName})
	if nPos <> 0
		::Fields()[nPos, FLD_ORIGNAME] := acOrigField
	endif
	                             
return (nPos <> 0)

/*
--------------------------------------------------------------------------------------
Roteiro do field
Args: acFieldname -> string, nome do campo
		abRoteiro -> code-block, roteiro de importação
Rets: lRet -> lógico, ajuste bem suscedido ou não
--------------------------------------------------------------------------------------
*/                         
method SetRoteiro(acFieldname, abRoteiro) class TTable
	local nPos

	acFieldname := upper(alltrim(acFieldName))	
	nPos := aScan( ::Fields(), { |x| upper(alltrim(x[FLD_NAME])) == acFieldName})
	if nPos <> 0    
		__Roteiro := abRoteiro                    
		::Fields()[nPos, FLD_ROTEIRO] := __Roteiro
	endif
	                             
return (nPos <> 0)

method getRoteiro(acFieldname) class TTable
	local nPos, cbRet := NIL

	acFieldname := upper(alltrim(acFieldName))	
	nPos := aScan( ::Fields(), { |x| upper(alltrim(x[FLD_NAME])) == acFieldName})
	if nPos <> 0                        
		cbRet := ::Fields()[nPos, FLD_ROTEIRO]
	endif
	                             
return cbRet

/*
--------------------------------------------------------------------------------------
Ajusta a visibilidade de um campo
Args: acFieldname -> string, nome do campo
		alValue -> logico, visibilidade
Rets: lRet -> lógico, ajuste bem suscedido ou não
--------------------------------------------------------------------------------------
*/                         
method SetVisible(acFieldname, alValue) class TTable
	local nPos
	
	acFieldName :=	upper(alltrim(acFieldName))	
	nPos := aScan( ::Fields(), { |x| upper(alltrim(x[FLD_NAME])) == acFieldName})
	if nPos <> 0
		::Fields()[nPos, FLD_VISIBLE] := alValue
	endif
	                             
return (nPos <> 0)

/*
--------------------------------------------------------------------------------------
Ajusta a disponibilidade de um campo para edição
Args: acFieldname -> string, nome do campo
		alValue -> logico, disponibilidade 
Rets: lRet -> lógico, ajuste bem suscedido ou não
--------------------------------------------------------------------------------------
*/                         
method SetReadOnly(acFieldname, alValue) class TTable
	local nPos
	
	acFieldName :=	upper(alltrim(acFieldName))	
	nPos := aScan( ::Fields(), { |x| upper(alltrim(x[FLD_NAME])) == acFieldName})
	if nPos <> 0
		::Fields()[nPos, FLD_READONLY] := alValue
	endif
	                             
return (nPos <> 0)

/*
--------------------------------------------------------------------------------------
Adiciona um novo indice
Args: acIndexname -> string, nome do indice
		aaFieldList -> array, lista de campos que compoem o indice
Rets: lRet -> lógico, insersão bem suscedida ou não
--------------------------------------------------------------------------------------
*/                         
method AddIndex2(acIndexname, aaFieldList, alUnico) class TTable
	local cExpChave := "", cbExpBlock, nRet := -1

	aEval(aaFieldList, { |x,i| aaFieldList[i] := upper(x) })
	
	cExpChave := ::makeKeyExp(aaFieldList)
	cbExpBlock := ::makeKeyBlock(aaFieldList)
	                          
	if valType(acIndexname) != "C"
		acIndexName := "I" + DWint2hex(len(::Indexes()),2)
	endif
	nRet := ::AddIndex(acIndexname, cExpChave, cbExpBlock, aaFieldList, alUnico)
	
return nRet

/*
--------------------------------------------------------------------------------------
Adiciona um novo indice
Args: acIndexname -> string, nome do indice
		acChave -> string, expressão chave
		abChave -> code-block, code-block que monta a chave  
		aaFieldList -> array, nome dos campos que compoem a chave
Rets: lRet -> lógico, insersão bem suscedida ou não
--------------------------------------------------------------------------------------
*/                         
method AddIndex(acIndexname, acChave, abChave, aaFieldList, alUnico) class TTable
	local lRet := .f., nPos
	default alUnico := .f.
	
	if len(aaFieldList) > FIELDS_LIMIT_INDEX
		aSize(aaFieldList, FIELDS_LIMIT_INDEX)                               
		acChave := ::makeKeyExpr(aaFieldList)
		abChave :=  ::makeKeyBlock(aaFieldList)
		DWLog(STR0027, STR0004 + ::Descricao() + "(" + ::Tablename() + ")") //"Aviso: Indice com mais de 14 campos."  //"   Tabela: "
	endif

	if aScan( ::Indexes(), { |x| upper(x[1]) == upper(acIndexname)}) == 0
		nPos := len(acChave)
		if aScan( ::Indexes(), { |x| left(upper(x[2]), nPos) == upper(acChave)}) == 0
			lRet := .T.   
			aAdd(::Indexes(), { acIndexname, acChave, abChave, aclone(aaFieldList), alUnico } )
		endif
	endif
	                             
return lRet

/*
--------------------------------------------------------------------------------------
Verifica se a tabela existe
Args: 
Rets: lRet -> lógico, indica a existencia ou não da tabela
--------------------------------------------------------------------------------------
*/                         
method Exists() class TTable

return TCCanOpen(::Tablename())

/*
--------------------------------------------------------------------------------------
Cria fisicamente a tabela
Args: acTablename -> string, nome da nova tabela
Rets: lRet -> lógico, indica se a criação foi bem suscedida
--------------------------------------------------------------------------------------
*/                         
method CreateTable(acTablename, alLocal, alStruct) class TTable
	local lRet := .f., aFields := {}
	default acTablename := ::Tablename()
	default alLocal := .f.
    default alStruct := .f.
    
    if alStruct
		aEval(::Struct(), { |x| iif(!empty(x[1]), aAdd(aFields, { x[1], x[2], x[3], x[4]}), NIL)})	
	else
 		aEval(::Fields(), { |x| iif(valType(x[7]) == "U", aAdd(aFields, { x[1], x[2], x[3], x[4]}), NIL)})
	endif

	dbCreate(acTablename, aFields, iif(alLocal, "DBFCDX", "TOPCONN"))
	::faStruct := {}
	lRet := .t.
	
return lRet

/*
--------------------------------------------------------------------------------------
Indica se a tabela esta aberta
Args: 
Rets: lRet -> lógico, indica se arquivo esta aberto
--------------------------------------------------------------------------------------
*/                         
method IsOpen() class TTable
                                   
return (select(::fcAlias) != 0)

/*
--------------------------------------------------------------------------------------
Abra a tabela para uso
Args: alExclusive -> logico, indica se a abertura é exclusive
Rets: lRet -> lógico, indica se a abertura foi bem suscedida
--------------------------------------------------------------------------------------
*/                         
method Open(alExclusive) class TTable
	local lRet := .t.
	        
	if !::SX()
		default alExclusive := .f.
		
		if !isDWOpenDB()
			DWOpenDB()
		endif
		
		if !::IsOpen()	
			::fnRefCount := 0

			if ::flLocal
				use (::Tablename()) alias (::fcAlias) shared new via "TOPCONN"
			elseif alExclusive
				use (::Tablename()) alias (::fcAlias) exclusive new via "TOPCONN"
			else
				use (::Tablename()) alias (::fcAlias) shared new via "TOPCONN"
			endif   
		else
			::fnRefCount++             
			dbSelectArea(::fcAlias)  
			dbgoto(recno())
		endif

		if neterr()    
			lRet := .F.
		else
			::OpenIndexes()
		   ::InitFieldsDef()
		endif
	else
		chkFile(::Alias())
	   ::InitFieldsDef()
	endif	
	        
	::faStruct := {}

return lRet

/*
--------------------------------------------------------------------------------------
Fecha a tabela 
Args: 
Rets: lRet -> lógico, indica se o fechamento foi bem suscedido
--------------------------------------------------------------------------------------
*/                         
method Close() class TTable
   local lRet := .t.        
	
	if ::isOpen()
		if ::fnRefCount == 0
			dbSelectArea(::fcAlias)
			dbCloseArea()
		else
			::fnRefCount--
			lRet := .f.
		endif
	endif

return lRet

/*
--------------------------------------------------------------------------------------
Inicializa a lista de definição de campos
Args: 
Rets: 
--------------------------------------------------------------------------------------
*/                         
method InitFieldsDef() class TTable

	if len(::Fields()) == 0
		aEval(::Struct(), { |x| ::AddField(nil, x[1], x[2], x[3], x[4]) })
	endif
	
return

/*
--------------------------------------------------------------------------------------
Liga/Desliga o uso de indices
--------------------------------------------------------------------------------------
*/                         
method IndexOff() class TTable
	     
	if ::isOpen()
		dbSelectArea(::fcAlias)  
		dbClearIndex()
	endif
	::flIndexOn := .f.

return

method IndexOn() class TTable
	     
	::flIndexOn := .t.
	if ::isOpen()
		::Close() 
		::Open()
	endif

return
	
/*
--------------------------------------------------------------------------------------
Abre os arquivos de indices e se necessários cria-os
Args: 
Rets: lRet -> lógico, indica se o processo foi bem suscedido
--------------------------------------------------------------------------------------
*/                         
method OpenIndexes() class TTable
   local nInd, lNew := .f.
              
	if ::flIndexOn .and. len(::Indexes()) >  0
	   for nInd := 1 to len(::Indexes())
   		if empty(indexKey(nInd))
			   ::OpenIndex(::Indexes()[nInd, 1], ::Indexes()[nInd, 2], @lNew)
			endif 
		next
		if lNew
			dbClearIndex()
			::OpenIndexes()
		elseif empty(indexKey(1))
			ordSetFocus(1) // Assume como indice padrão o 1o.
		endif
	endif
	
return .t.

method OpenIndex(acIndice, acChave, alNew) class TTable
	local lOpen,cAlias,cDriver, cArquivo
   local	bBlock := "{||" + acChave + "}"

	dbSelectArea(::fcAlias)  
	if !::flLocal
		acIndice	:= ::Tablename() + acIndice
		cDriver := "TOPCONN"
	else
		cDriver := RddName()
		acIndice	:= RetArq(cDriver, acIndice, .F.)
	endif
	
	cArquivo := ::Tablename()
	if ::flLocal
		lOpen 	:= MSFILE(::Tablename(), acIndice, cDriver)
	else
		lOpen 	:= tcCanOpen(::Tablename(), acIndice)
	endif        

	if !lOpen // Se cria Indice
		dbCreateIndex(acIndice, acChave, &bBlock)
//		index on &acChave to &acIndice
		alNew := .t.

		if TCSRVTYPE() == "AS/400" .and. cDriver == "TOPCONN"
			TCSYSEXE("CHGOBJOWN OBJ("+acIndice+") OBJTYPE(*FILE) NEWOWN(QUSER)")
		endif
		dbcommit()
		dbSetIndex( acIndice )
	elseif !("CDX" $ cDriver )  // Seta Indice
		dbSetIndex( acIndice )
	EndIf

return .t.

/*
--------------------------------------------------------------------------------------
Gera ID único
Args: 
Rets: nRet -> numérico, ID do registro
--------------------------------------------------------------------------------------
*/                         
method GeraID() class TTable
	local nRet, cSql, cOldAlias, nCont := 50
	local lLock := GetGlbValue('DWFirstStart') == 'T'
              
	if !lLock
		while !GlbLock() .and. !DWKillApp() //GlbLock(::TableName())
			sleep(100)                           
			nCont--
			if nCont == 0
				nCont := 50
			endif
		enddo
	endif
	
	nRet := val(GetGlbValue(::TableName()))
	IF nRet == 0               
		cOldAlias := alias()
		cSql := "select max(ID) maxid from "+::TableName()
		dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"__TRB",.f.,.t.)
		nRet := dwVal(FieldGet(1))
		dbCloseArea()
		dbSelectArea(cOldAlias)
	Endif
	nRet++

	PutGlbValue(::TableName(), strZero(nRet, 10, 0))
	
	if !lLock
		GlbUnlock() //GlbUnlock(::TableName())
	endif
	
return nRet

/*
--------------------------------------------------------------------------------------
Posiciona no ínicio da tabela
Args: 
Rets: 
--------------------------------------------------------------------------------------
*/                         
method GoTop() class TTable

	dbSelectArea(::fcAlias)  
	dbGoTop()
	
	if !empty(::fbFilter)
		while !eof() .and. !eval(::fbFilter)
			dbSkip()
		enddo
	endif

return 

/*
--------------------------------------------------------------------------------------
Posiciona em um registro especifico
--------------------------------------------------------------------------------------
*/                         
method GoTo(anRecno) class TTable

	dbSelectArea(::fcAlias)

return dbgoto(anRecno)

/*
--------------------------------------------------------------------------------------
Posiciona no próxima registro da tabela
Args: 
Rets: 
--------------------------------------------------------------------------------------
*/                         
method _Next(anSkip) class TTable
	default anSkip := 1
	                   
	if anSkip < 0
		appRaise(err_00,sol_00, "_next")
	endif
	
	dbSelectArea(::fcAlias)  
	
	if !empty(::fbFilter)
		while !eof() .and. anSkip > 0
			dbSkip()
			if eval(::fbFilter)
				anSkip--
			endif
		enddo
	else
		dbSkip(anSkip)
	endif   
	
return 

/*
--------------------------------------------------------------------------------------
Posiciona no registro anterior da tabela
Args: 
Rets: 
--------------------------------------------------------------------------------------
*/                         
method Previous(anSkip) class TTable
	default anSkip := -1
	
	if anSkip > 0
		appRaise(err_00,sol_00, "previous")
	endif

	dbSelectArea(::fcAlias)  

	if !empty(::fbFilter)
		while !bof() .and. anSkip < 0
			dbSkip(-1)
			if eval(::fbFilter)
				anSkip++
			endif
		enddo   
		if bof()
			::goTop()
			if eof()
				dbGoBottom()
				dbskip(-1)
			endif
		endif				
	else
		dbSkip(anSkip)
	endif   

return 

/*
--------------------------------------------------------------------------------------
Posiciona no final da tabela
Args: 
Rets: 
--------------------------------------------------------------------------------------
*/                         
method GoBottom() class TTable

	dbSelectArea(::fcAlias)  

	dbGoBottom() 

	if !empty(::fbFilter)
		while !bof() .and. !eval(::fbFilter)
			dbSkip(-1)
		enddo
	endif

return 

/*
--------------------------------------------------------------------------------------
Indica se esta ou não no fim de arquivos
Args: 
Rets: lRet -> lógico, fim de arquivo (EOF)
--------------------------------------------------------------------------------------
*/                         
method Eof() class TTable
                                   
return (::fcAlias)->(eof())

/*
--------------------------------------------------------------------------------------
Indica se esta ou não no inicio de arquivos
Args: 
Rets: lRet -> lógico, fim de arquivo (BOF)
--------------------------------------------------------------------------------------
*/                         
method _Bof() class TTable

return (::fcAlias)->(bof())

/*
--------------------------------------------------------------------------------------
Trava um registro
Args: alAppend -> lógico, indica que é lock com append
Rets: lRet -> lógico, travado 
--------------------------------------------------------------------------------------
*/                         
method Lock(alAppend) class TTable
	local lRet

	default alAppend := .f.                         

	dbSelectArea(::fcAlias)	
	::FireEvent(FE_BEFORE, FE_LOCK)
	if alAppend      
   		dbAppend(.t.)
   		lRet := !NetErr()
	else          
	   	lRet := dbRlock()
	endif
	::FireEvent(FE_AFTER, FE_LOCK, lRet)

return lRet

/*
--------------------------------------------------------------------------------------
Libera um registro travado
Args: 
Rets: lRet -> lógico, liberado 	
--------------------------------------------------------------------------------------
*/                         
method Unlock() class TTable
    
	::FireEvent(FE_BEFORE, FE_UNLOCK)
	if !DWInTransaction()
		(::fcAlias)->(dbrUnlock())
	endif
	::FireEvent(FE_AFTER, FE_UNLOCK)

return .t.

/*
--------------------------------------------------------------------------------------
Coloca a tabela como sendo a correndo
Args: 
Rets: 
--------------------------------------------------------------------------------------
*/                         
method PutInUse() class TTable
	local xRet := ::fcAlias
		                  
	if xRet <> alias(select())
		if !::isOpen()
			::Open()
		endif     
		xRet := dbSelectArea(::fcAlias)
//		::Refresh()
	endif
	
return xRet

/*
--------------------------------------------------------------------------------------
Retorna numero de registros
Args: 
Rets: nRet -> numerico, numero de registros da tabela
--------------------------------------------------------------------------------------
*/                         
method RecCount(alSQL, acWhere) class TTable
	local nRet, cOldAlias, oQuery

	default alSQL := .f.
		
	if alSQL
		cOldAlias := alias()
	 	oQuery := TQuery():New(DWMakeName("TRA"))
	 	oQuery:FieldList("count(*)")
		oQuery:FromList(::Tablename())
		if !empty(acWhere)
			oQuery:WhereClause(acWhere)			
		endif
		oQuery:Open()
		nRet := oQuery:value(1)
		oQuery:Close()
		if !empty(cOldAlias)
			dbSelectArea(cOldAlias)
		endif
	else
		nRet := (::fcAlias)->(recCount())	
	endif
	
return nRet 

/*
--------------------------------------------------------------------------------------
Retorna o numero do registro corrente
Args: 
Rets: nRet -> numerico, numero de registros da tabela
--------------------------------------------------------------------------------------
*/                         
method RecNo() class TTable
	
return (::fcAlias)->(recno())

/*
--------------------------------------------------------------------------------------
Retorna o valor de um campo
Args: acnField -> string ou numerico, nome ou posição do campo
Rets: xRet -> , valor do campo
--------------------------------------------------------------------------------------
*/                         
method Value(acField, alTrim, alRPC) class TTable
	local xRet := nil, nPos, aAux
	
	default alTrim := .t.
	default alRPC := .f.

	if valType(acField) == "N"
		xRet := ::ValByPos(acField)
     	if valType(xRet) == "C" .and. alTrim
     		xRet := trim(xRet)
     	endif
	else
		acField := upper(acField)
		if !alRPC
			dbSelectArea(::fcAlias)  
		endif
		aAux := ::Fields(acField)   
		if valType(aAux) == "A" .and. valType(aAux[FLD_GET]) == "B"
			xRet := eval(aAux[FLD_GET])
		else
			nPos := ::FieldPos(acField)
			if nPos != 0
	      	xRet := ::FieldGet(nPos)
	  		endif
  		endif
     	if valType(xRet) == "C" .and. alTrim
     		xRet := trim(xRet)
     	endif
  endif

return xRet

method ValByPos(anField) class TTable

return ::Value(::Fields()[anField, 1])

method ValTxt(acnField) class TTable
	local cField

	if valType(acnField) == "N"
		cField := ::Fields()[acnField,1]
	else
		cField := acnField
	endif	

return ::ListVal3(cField, ::Value(acnField))

/*
--------------------------------------------------------------------------------------
Retorna o valor de um campo a partir de uma lista
Args: acnField -> string ou numerico, nome ou posição do campo
Rets: xRet -> , valor do campo
--------------------------------------------------------------------------------------
*/                         
method ListVal(acnField, axValue) class TTable
	local xValue, cFieldname, aAux, nPos

	if valType(axValue) == "U"
		xValue := ::Value(acnField)
	else
		xValue := axValue
	endif

	if valType(acnField) == "C"
		cFieldname := upper(acnField)
	else
		cFieldname := upper(::Fields()[acnField,1])
	endif
	cFieldname := upper(cFieldname)
	nPos := ascan(::faListVal, { |x| x[1] == cFieldname})

	if nPos <> 0
		aAux := ::faListVal[nPos]                                
		nPos := ascan(aAux[2], { |x| dwStr(x[1]) == dwStr(xValue)})
		if nPos <> 0
			xValue := aAux[2, nPos, 2]		
		endif
	endif
return xValue 

method ListVal2(acnField, axValue) class TTable
	local xValue, cFieldname, aAux, nPos
	                             
	if valType(axValue) == "U"
		xValue := ::Value(acnField)
	else
		xValue := axValue
	endif

	if valType(acnField) == "C"
		cFieldname := upper(acnField)
	else
		cFieldname := upper(::Fields()[acnField,1])
	endif

	nPos := ascan(::faListVal, { |x| x[1] == cFieldname})
	if nPos <> 0
		aAux := ::faListVal[nPos]
		nPos := ascan(aAux[2], { |x| x[2] == xValue})
		if nPos <> 0
			xValue := aAux[2, nPos, 1]		
		endif
	endif
	
return xValue 

method ListVal3(acField, axValue) class TTable
	local aValue := {}, aAux, nPos, nInd                   
	
	acField := upper(acField)
	nPos := ascan(::faListVal, { |x| x[1] == acField })

	if nPos <> 0
		aAux := ::faListVal[nPos] 
		for nInd := 1 to len(axValue)
			nPos := ascan(aAux[2], { |x| x[2] == substr(axValue, nInd, 1) })
			if nPos <> 0
				aAdd(aValue, aAux[2, nPos, 1])
			endif
		next
	endif
	
return iif(len(aValue) == 0, axValue, DWConcatWSep(",", aValue))

/*
--------------------------------------------------------------------------------------
Adiciona lista de valores para tradução
Args: acFieldname -> string, nome do campo
		aaValList -> array, com elementos para tradução de valor { valor, descricao}
Rets: 
--------------------------------------------------------------------------------------
*/                         
method AddListVal(acFieldname, aaValList) class TTable

	aAdd(::faListVal, { upper(acFieldname), aaValList })

return

/*
--------------------------------------------------------------------------------------
Localiza um registro a partir de um indice especifico
Args: anIndexNumber -> numerico, numero do indice a ser utilizado
		aaKeyValue -> array, valores de composição da chave
		alSoftseek -> lógico, indica usa softseek               
		Caso anIndexNumber seja 0, aaKeyValue deverá ser um numérico com 
		o numero fisico do registro
Rets: xRet -> logico, indica se o seek foi bem suscedido ou não
--------------------------------------------------------------------------------------
*/                         
method Seek(anIndexNumber, aaKeyValue, alSoftseek) class TTable
	local cKey, nLen, lOk := .f., xAux
	local aKeyValue := {}

	default alSoftseek := .t. //set(_SET_SOFTSEEK)
	
	dbSelectArea(::fcAlias)  
	dbSetOrder(anIndexNumber)
	if valType(aaKeyValue) != "U"
		if anIndexNumber == 0
			dbGoto(aaKeyValue)
			lOk := .t.
		elseif valtype(aaKeyValue) == "N" .and. aaKeyValue == 0
			dbGoTop()
			lOk := .t.
		else      
			if ::HaveDWField() .and. anIndexNumber <> 1 
				if __DWIDTemp <> -1 
					 if substr(::alias(), 3, 1) == "0"
						aAdd(aKeyValue, __DWIDTemp)
					 else
						aAdd(aKeyValue, 0)
					endif
				elseif oSigaDW:DWCurrID() == -1
					aAdd(aKeyValue, 0)
				else
					aAdd(aKeyValue, oSigaDW:DWCurrID())
				endif
				aEval(aaKeyValue, { |x| aAdd(aKeyValue, x) })
			else
				aKeyValue := aClone(aaKeyValue)
			endif
			if valType(::Indexes()[anIndexNumber][3]) == "U"
				cKey := aKeyValue[1]
			else
				aSize(aKeyValue, 16)
				cKey := eval(::Indexes()[anIndexNumber][3], aKeyValue[1], aKeyValue[2], aKeyValue[3], ;
                aKeyValue[4], aKeyValue[5], aKeyValue[6], aKeyValue[7], aKeyValue[8], ;
                aKeyValue[9], aKeyValue[10], aKeyValue[11], aKeyValue[12], aKeyValue[13], ;
                aKeyValue[14], aKeyValue[15], aKeyValue[16])
    	endif
			xAux := &(indexkey())
			if valType(xAux) == "C"
				if alSoftSeek
					cKey := Trim( cBIStr( cKey ) )
				else                
					nLen := len(xAux)
					cKey := PadR( cBIStr( cKey ) , nLen, " ")
				endif
			endif
			dbSeek(cKey, alSoftseek)
		endif		
	else
		if ::HaveDWField() .and. anIndexNumber <> 1
			lOk := ::seek(anIndexNumber, {}, alSoftseek) 			
		else
			lOk := .t.
		endif
	endif				

return lOk .or. ::Found()

/*
--------------------------------------------------------------------------------------
Indica se uma pesquisa prévia foi ou não bem suscedida
Args: 
Rets: lRet -> lógico, indica se pesquisa foi OK
--------------------------------------------------------------------------------------
*/                         
method Found() class TTable

return (::fcAlias)->(found())

/*
--------------------------------------------------------------------------------------
Propriedade Filter
Args: acValue -> string, clausula do filtro
Rets: cRet -> string, clausula do filtro
--------------------------------------------------------------------------------------
*/                         
method Filter(acValue)  class TTable
	
	property ::fcFilter := acValue
	if valType(acValue) != "U"
		::ApplyFilter()
   endif
   
return ::fcFilter

/*
--------------------------------------------------------------------------------------
Propriedade HaveDWField
--------------------------------------------------------------------------------------
*/                         
method HaveDWField()  class TTable
	
return ::flHaveDWField

/*
--------------------------------------------------------------------------------------
Propriedade FilterSQL
Args: acValue -> string, clausula do filtro
		aaParams -> array, lista de parametros para complemento do filtro
Rets: cRet -> string, clausula do filtro
--------------------------------------------------------------------------------------
*/                         
method FilterSQL(acValue, aaParams)  class TTable
	local cFilter, nInd, cAux

	if valType(acValue) == "C"
		if valType(aaParams) == "A"
			for nInd := 1 to len(aaParams) 
				cAux := delAspasSimples(aaParams[nInd, 2]) 
				if left(cAux,1) == "&"
					aaParams[nInd, 2] := substr(cAux,2)
					acValue := strTran(acValue, "["+aaParams[nInd, 1]+"]", dwStr(&(aaParams[nInd, 2]),.t.))
				elseif len(cAux) == 10 .and. ;
						((substr(cAux, 3,1) == "/" .and. substr(cAux, 6,1) == "/") .or.; // DD/MM/AAAA
						 (substr(cAux, 5,1) == "/" .and. substr(cAux, 8,1) == "/")) // AAAA/MM/DD
					cAux := "'" + dtos(ctod(cAux)) + "'"
					acValue := strTran(acValue, "["+aaParams[nInd, 1]+"]", cAux)
				else
					acValue := strTran(acValue, "["+aaParams[nInd, 1]+"]", &(aaParams[nInd, 2]))
				endif
			next
		endif
		
		property ::fcFilterSQL := acValue
		::ApplyFilter()
	endif		

return ::fcFilterSQL

/*
--------------------------------------------------------------------------------------
Aplica o filtro FilterSQL e Filter (advpl)
Args: acValue -> string, clausula do filtro
		aaParams -> array, lista de parametros para complemento do filtro
Rets: cRet -> string, clausula do filtro
--------------------------------------------------------------------------------------
*/                         
method ApplyFilter()  class TTable
   local cFilter
                
	::ClearFilter()
   
  	if !empty(::fcFilterSQL)       
		cFilter := "@"+::fcFilterSQL
		if !empty(::fcFilter)
			::fbFilter := &("{||"+::fcFilter+"}")
		else 
			::fbFilter := nil
		endif
	else
		cFilter := ::fcFilter
	endif 
	
	if !empty(cFilter)      
		set filter to &cFilter
	endif
	
	::GoTop()

return

/*
--------------------------------------------------------------------------------------
Desativa filtros
Args:
Rets:
--------------------------------------------------------------------------------------
*/                         
method ClearFilter()  class TTable

	(::fcAlias)->(dbClearFilter())

return

/*
--------------------------------------------------------------------------------------
Formata os campos do registro atual, conforme o formatado solicitado
Args: acValue -> string, clausula do filtro
		aaExcFields -> array, com a lista de campos que devem ser ignorados
Rets: cRet -> string, clausula do filtro
--------------------------------------------------------------------------------------
*/                         
method Record(anFormat, aaExcFields) class TTable
	local aRet := {}, xRet, nInd, aAux :={}, lIgnID := .f.

	default anFormat := 0           
	default aaExcFields := {}

	if len(aaExcFields) == 0
		aAux := ::Fields()
	else
		lIgnID := upper(aaExcFields[1]) == "ID*"
		for nInd := 1 to len(::Fields())                
			if !lIgnID .or. left(::Fields()[nInd, FLD_NAME],2) != "ID"
				if ascan(aaExcFields, { |y| ::Fields()[nInd, FLD_NAME]==upper(y) })==0
					aAdd(aAux, ::Fields()[nInd])
				endif
			endif
		next
	endif

	if anFormat == 0 // www-url-encode
		xRet := ""
		aSize(aRet, len(aAux))
		for nInd := 1 to len(aRet)
			if valType(::Value(nInd)) == "L"
				aRet[nInd] := URLEncode(aAux[nInd, 1]) + if(::Value(nInd), "=true", "=false")
			elseif !empty(::Value(nInd))
				aRet[nInd] := StrTran(URLEncode(aAux[nInd, 1]) + "=" + URLEncode(Trim(DWStr(::Value(nInd,.t.)))),"+"," ")
			endif
		next
		xRet := DWConcatWSep("&", aRet)
	elseif anFormat == 1 .or. anFormat == 7 // array para importação/exportação de dimensões
		xRet := array(len(aAux))            
		if anFormat == 1
			aEval(xRet, { |x,i| xRet[i] := { aAux[i, FLD_NAME] , ::Value(aAux[i, FLD_NAME], .t.) } } )
		else
			aEval(xRet, { |x,i| iif(empty(aAux[i, FLD_GET]), xRet[i] := { lower(aAux[i, FLD_NAME]) , ::Value(aAux[i, FLD_NAME], .t.) }, nil) } )
			xRet := packArray(xRet)
		endif                                           
	elseif anFormat == 2 // texto com os valores separados por "\t"
		xRet := array(len(aAux))
		aEval(xRet, { |x,i| xRet[i] := ::Value(aAux[i, FLD_NAME], .t.)})
		xRet := DWConcatWSep(COL_SEP, xRet)
	elseif anFormat == 3 // array de nomes de campos
		xRet := array(len(aAux))
		for nInd := 1 to len(xRet)
			xRet[nInd] := aAux[nInd, FLD_NAME]
		next	
	elseif anFormat == 4 // array para importação/exportação de valores (texto puro)
		xRet := array(len(aAux))
		for nInd := 1 to len(xRet)
			if(aAux[nInd, FLD_TYPE]=="N")
				xRet[nInd] := padl(Str(::Value(nInd), aAux[nInd, FLD_LEN]+aAux[nInd, FLD_DEC]+1,aAux[nInd, FLD_DEC]))
			else
				xRet[nInd] := padr(::Value(nInd), max(aAux[nInd, FLD_LEN],10))
			endif	
		next	
	elseif anFormat == 5 // retorna um array, com pares os objetos de definição
								  // a 1a linha conterá o número de campos e o campo ID será ignorado
		xRet := {}
		aEval(aAux, { |x, i| ;
				aAdd(xRet, "OBJECT=FIELD"), ;
				aAdd(xRet, "FIELDNAME=" + aAux[i, FLD_NAME]), ;
				aAdd(xRet, "VALUE=" + DWStr(::Value(aAux[i, FLD_NAME],.t.))), ;
				aAdd(xRet, "END") } )
	elseif anFormat == 6 // array para documentação
		xRet := array(len(aAux))
		aEval(xRet, { |x,i| xRet[i] := { aAux[i, FLD_TITLE] , ::Value(aAux[i, FLD_NAME],.t.) } } )
	elseif anFormat == 8 // array para importação/exportação de valores (xml/xls)
		xRet := array(len(aAux))
		for nInd := 1 to len(xRet)
			if(aAux[nInd, FLD_TYPE]=="N")
				xRet[nInd] := alltrim(Str(::Value(nInd), aAux[nInd, FLD_LEN]+aAux[nInd, FLD_DEC]+1,aAux[nInd, FLD_DEC]))
			else
				xRet[nInd] := ::Value(nInd)
			endif	
		next	
	elseif anFormat == 9 .or. anFormat == 10 // array com valores brutos
		xRet := array(len(aAux))
		for nInd := 1 to len(xRet)
			xRet[nInd] := ::Value(nInd, anFormat == 9)
		next	
	endif

return xRet

method Record2(aaFields) class TTable
	local aAux := ::Fields()
	
	aEval(aaFields, { |x,i| aaFields[i, 2] := ::Value(x[1]) } )

return aaFields

/*
--------------------------------------------------------------------------------------
Efetua um zap na tabela
Args: 
Rets: 
--------------------------------------------------------------------------------------
*/                         
method Zap() class TTable
	local lOpen := ::IsOpen()
	local oQuery
             
	if SGDB() == DB_ORACLE
		DWSQLExec("truncate table " + ::Tablename())
		::refresh()
	else
		if lOpen
			::Close()
		endif

	   oQuery := TQuery():New("DELTRA")
		oQuery:FromList(::Tablename())
		oQuery:withDelete(.t.)   
		lRet := oQuery:ExecDel()
		oQuery:Close()

		if lOpen
			::Open()
			::Refresh()         // Refresh do TopConnect
			::Refresh(.t.)      // Refresh do registro
		endif
	endif
	
return

/*
--------------------------------------------------------------------------------------
Efetua um pack na tabela
Args: 
Rets: 
--------------------------------------------------------------------------------------
*/                         
method Pack(acTable) class TTable
                
	default acTable := ::Tablename()
	
	DWDelAllRec(acTable, "D_E_L_E_T_ = '*'")

  ::updStat(acTable)
  
	if ::isOpen()
		::refresh()
	endif

return

/*
--------------------------------------------------------------------------------------
Valida se os registros possuem registro "pai" nas tabelas relacionadas e caso estejam
orfãos, são eliminados fisicamente.
--------------------------------------------------------------------------------------
*/                         
method validParents(anDel) class TTable
	local nInd
  local cSQL := ""
  local oQuery := TQuery():New(,"valPar")
  local oAux, lDel
  
  anDel := 0
      
  for nInd := 1 to len(::faParents)
    oAux := initTable(::faParents[nInd, 1])
    cSQL := " select distinct ID from " + ::tablename()
    cSQL += "  where " + upper(::faParents[nInd, 2]) + " > 0 and" 
    cSQL += "        " + upper(::faParents[nInd, 2]) + " not in (" 
    cSQL += "    select ID from " + ::faParents[nInd, 1] + " where D_E_L_E_T_ <> '*'"
    if !empty(::faParents[nInd, 3])
      cSQL += " and " + ::faParents[nInd, 3]
    endif
    cSQL += ")" + CRLF
    if !empty(::faParents[nInd, 4])
      cSQL += " and " + ::faParents[nInd, 4] + CRLF
    endif    
    cSQL += " order by ID"
    oQuery:open(,cSQL)

    lDel := .f.
    while !oQuery:eof()
      if ::seek(1, { oQuery:value("ID") } )
        if !lDel
          lDel := !lDel
          conout(STR0028 + oAux:descricao() + "(" + oAux:tablename() + ")")  //"   Pai: "
        endif
        ::delete()
        anDel++
      endif
      oQuery:_next()
    enddo
    oQuery:close()
  next
  
return anDel == 0

/*
--------------------------------------------------------------------------------------
Adiciona a tabela pai, para testes
--------------------------------------------------------------------------------------
*/                         
method addParent(acParent, acFieldKey, acWhereParent, acWhere) class TTable
  
  aAdd(::faParents, { acParent, acFieldKey, acWhereParent, acWhere } )
  
return

/*
--------------------------------------------------------------------------------------
Elimina os indices
Args: 
Rets: 
--------------------------------------------------------------------------------------
*/                         
method Reindex() class TTable
	local lOpen := ::IsOpen(), lIndex
	
	if lOpen
		::Close()
	endif

	lIndex := ::flIndexOn

	TCInternal(69, ::Tablename())
	TCRefresh(::Tablename())
	::IndexOn()
	::Open()

	if !lIndex	
		::IndexOff()
	endif
	if !lOpen
		::Close()
	endif
		
return

/*
--------------------------------------------------------------------------------------
Cria um indice, usando comandos SQL
Args: 
Rets: 
--------------------------------------------------------------------------------------
*/                         
method CreateIndex(anIndex) class TTable
	local lOpen := ::IsOpen(), lIndex, aAux := {}
	local oQuery
	
	if lOpen
		::Close()
	endif

	lIndex := ::flIndexOn
	::IndexOff()
	aEval(::Indexes()[anIndex][4], { |x| aAdd(aAux, "["+x+"]") })

	oQuery := TQuery():New(DWMakeName("TRA"))
  oQuery:Execute(EX_CREATE_INDEX, ::Tablename(), dwConcatWSep(",", aAux))
	oQuery:Close()

	if lIndex	
		::IndexOn()
	endif
	if lOpen
		::Open()
	endif
		
return

/*
--------------------------------------------------------------------------------------
Elimina a tabela fisicamente
Args: 
Rets: lRet -> logico, se o drop foi executado
--------------------------------------------------------------------------------------
*/                         
method DropTable() class TTable
	local lRet
                   
	if ::IsOpen()
		while ::IsOpen() .and. !DWKillApp()
			::Close()
		enddo
	endif

	::eraseDD(DD_INDEX)
	if upper(left(::Tablename(),2)) == "DS"
		if tcCanOpen("DV"+right(::Tablename(),5))
		  TCDelFile("DV"+right(::Tablename(),5))
		endif
	endif
	if tcCanOpen(::Tablename())
		lRet := TCDelFile(::Tablename())
		if  !lRet
			DWLog(STR0029, "DropTable", tcSqlError())  //"Erro SQL"
		endif
	endif

return lRet

/*
--------------------------------------------------------------------------------------
Efetua o "refresh" da base de dados
Args: 
Rets: 
--------------------------------------------------------------------------------------
*/                         
method Refresh(alRecord) class TTable
                       
	if alRecord
		(::fcAlias)->(dbGoto(recno()))
	else
		tcRefresh(::fcTablename)
	endif

return 

/*
--------------------------------------------------------------------------------------
Verifica se a estrutura fisica "bate" com a lógica e re-cria a tabela se necessário
Args: alVerOnly -> logico, somente verificar a estrutura
		abNotify -> codeblock, rotina de notificação
Rets: lDif -> logico, indica se há ou não diferença
--------------------------------------------------------------------------------------
*/
method ChkStruct(alVerOnly, abNotify) class TTable
	local aFields, lDif := .f., nInd, nPos, cOldFile
	local cTablename, nRec, lEof, aIntField, aFieldsDif := {}
	local nSecInic, nTotrec, nSecTot := 0, hInic, aListFld := {}
	local aOldStruc := {}, x, i
	local aNew, aOld, oQuery, nTopErr
	local aNewStruc := {}
	local lOpt := "MSSQL" $ TCGetDB() .or. TCGetDB() == DB_ORACLE .or. TCGetDB() == DB_DB2
			
	default alVerOnly := .f.
	::PutInUse()

	aFields := ::Struct()
	aIntField := aClone(::Fields())
	for nInd := 1 to len(aIntField)
		if valType(aIntField[nInd, 7]) == "B" .or. ;
		   valType(aIntField[nInd, 8]) == "B" .or. ;
			!empty(aIntField[nInd, 11])
			aIntField[nInd] := NIL
		else
			aAdd(aOldStruc, {aIntField[nInd, FLD_NAME], aIntField[nInd, FLD_TYPE], aIntField[nInd, FLD_LEN], aIntField[nInd, FLD_DEC] })
		endif
	next
	aIntField := packArray(aIntField)
	
	for nInd := 1 to len(aFields)
		nPos := ascan(aIntField, { |x| upper(alltrim(x[1])) == upper(alltrim(aFields[nInd, 1])) })
		if nPos == 0
			lDif := .t.
			exit
		endif
		if aIntField[nPos, 2] != aFields[nInd, 2] .or. ;
			(aIntField[nPos, 2] != "M" .and. ;
		   	(aIntField[nPos, 3] != aFields[nInd, 3] .or. ;
	   	    aIntField[nPos, 4] != aFields[nInd, 4]))
			lDif := .t.
			exit
		endif
	next

	if !lDif
		for nInd := 1 to len(aIntField)
			nPos := ascan(aFields, { |x| upper(alltrim(x[1])) == upper(alltrim(aIntField[nInd, 1])) })
			if nPos == 0
				lDif := .t.
				exit
			endif
			if aIntField[nInd, 2] != aFields[nPos, 2] .or. ;
				(aIntField[nPos, 2] != "M" .and. ;
	  			  (aIntField[nInd, 3] != aFields[nPos, 3] .or. ;
	   		   aIntField[nInd, 4] != aFields[nPos, 4]))
				lDif := .t.
				exit
			endif
		next
	endif

	::fcMsg := iif(lDif, STR0003, "")/*//"Há diferenças entre estrutura física e lógica"*/

	if !alVerOnly .and. lDif
		aIntField := aSort(aIntField,,,{|x,y| x[1] < y[1]})
		aFields := aSort(aFields,,,{|x,y| x[1] < y[1]})
		nInd := 1
		while nInd < max(len(aIntField), len(aFields))
			aNew := nil
			aOld := nil
			if nInd < len(aIntField) // nova
				aNew := aIntField[nInd]
			endif

			if nInd < len(aFields) // antiga
				aOld := aFields[nInd]
			endif

			if valType(aNew) == "A" .and. valType(aOld) == "A"
				if aNew[1] == aOld[1]
				elseif aNew[1] < aOld[1]
					aSize(aFields, len(aFields)+1)
					aIns(aFields, nInd)
				else
					aSize(aIntField, len(aIntField)+1)
					aIns(aIntField, nInd)
				endif
			else
				if !(valType(aNew) == "A")
					aSize(aIntField, len(aIntField)+1)
				endif
				if !(valType(aOld) == "A")
					aSize(aFields, len(aFields)+1)
				endif
			endif
			nInd++
		enddo

		aEval(aIntField, { |x,i| iif(valType(x)=="A",,aIntField[i]:={"(1)","",0,0})})
		aEval(aFields, { |x,i| iif(valType(x)=="A",,aFields[i]:={"(2)","",0,0})})
		aAdd(aFieldsDif, "" )
		aAdd(aFieldsDif, "/=============================================================\" )
		aAdd(aFieldsDif, "| " + padc(alltrim(STR0004 + upper(::Tablename())+" "+::descricao()),60) +"|" )  //"   Tabela: "
		aAdd(aFieldsDif, "|-----------------------------\ /-----------------------------|" )
		aAdd(aFieldsDif, "| " + padc(STR0019,29)+"|"+padc(STR0020,29)+" |")   //"Nova"  //"Atual"
		aAdd(aFieldsDif, "|------------------------------+------------------------------|" )
		aAdd(aFieldsDif, dwFormat("| [XXXXXXXXXXXXXX] [XXXX] [XXXXXXXX] | [XXXXXXXXXXXXXX] [XXXX] [XXXXXXXX] |", {STR0021, STR0022, STR0023, STR0021, STR0022, STR0023 }))
 		aAdd(aFieldsDif, "|------------------------------+------------------------------|" )
		for i := 1 to len(aIntField)                                    
			x := {aIntField[i,1], aIntField[i,2], aIntField[i,3], aIntField[i,4]}
			if x[1] == "(1)" .and. aFields[i, FLD_NAME] == "(2)
			elseif !(dwStr(x) == dwStr(aFields[i]))
				aAdd(aFieldsDif,  dwFormat("| [XXXXXXXXXXXXXXX]  [X]  [9999].[99]  | [XXXXXXXXXXXXXXX]  [X]  [9999].[99]  |", { x[FLD_NAME], x[FLD_TYPE], x[FLD_LEN], x[FLD_DEC], aFields[i, FLD_NAME], aFields[i, FLD_TYPE], aFields[i, FLD_LEN], aFields[i, FLD_DEC]}))
			endif
			if x[1] == "(1)" 
				aIntField[i] := nil
			endif
			if aFields[i, FLD_NAME] == "(2)" 
				aFields[i] := nil
			endif
		next
 		aAdd(aFieldsDif, "|------------------------------+------------------------------|" )
 		aAdd(aFieldsDif, "| "+STR0030+"        |" )  //"Somente campos com alguma modificão são apresentados"
 		aAdd(aFieldsDif, "| (1) "+STR0031+"                   (2) "+STR0032+"                     |" )  //"removido"  //"novo"
		aAdd(aFieldsDif, "\-----------------------------/ \-----------------------------/" )
		DWLogArray(::fcMsg, aFieldsDif)
		aIntField := packArray(aIntField)
		aFields := packArray(aFields)
		
		DWLog(">> " + STR0015 + " (TC4)") //Modificando a estrura da tabela
		::DropIndexes()

		if SGDB() == DB_DB2400
	
			cTablename := ::Tablename()
			cOldFile := "XX_" + ::Tablename()
			DWLog(STR0004 + cTablename)/*//"   Tabela: "*/
			DWLog(STR0005 + cOldFile)/*//"   Copiando para "*/
			if TCCanOpen(cOldFile)
				TCDelFile(cOldFile)
			endif                          
			if !lOpt
				::PutInUse()                                                                  
				nTotrec := reccount()
				DWLog(STR0006)/*//"   Preservando estrutura e dados atuais"*/
				dbSetOrder(0)
				dbGoTop()

				lEof := eof()
				if valType(abNotify) == "B"
					eval(abNotify, DWConcat(::Alias(),STR0007, nTotrec))/*//" - Total de registros: "*/
					hInic := time()
					nSecInic := seconds()
					nSecTot := nSecInic
					// if !lEof
					//	 copy to (cOldFile) via "TOPCONN" while Estima(@nSecInic, abNotify, recno(), nTotrec, 500, ::Alias(), STR0008)/*//"Preservando"*/
					// endif
					eval(abNotify, DWConcat(::Alias(),STR0009, elaptime(hInic, time())))/*//" - Copia efetuada em "*/
				else
					copy to (cOldFile) via "TOPCONN"
				endif
			else 
				DWLog(">> " + STR0006)/*//"   Preservando estrutura e dados atuais"*/
				::CreateTable(cOldFile,,.t.)
				aSelect := {}
				aeval(aFields, { |x| iif(!empty(x[1]), aAdd(aSelect, x[1]),nil)})
				cSelect := DWConcatWSep(",", aSelect) + "," + DWDelete()
				if DWSqlExec("insert into " + cOldFile + " select " + cSelect + " from " + cTableName) != 0
			   		return .f.
				endif
			endif
			::Close()
			::DropTable()
			DWLog(STR0010)/*//"   Criando nova estrutura"*/
			::CreateTable()                                       
			if !lOpt
				::Open()
				DWLog(STR0011 + cOldFile)/*//"   Restaurando os dados salvos em "*/
				if valType(abNotify) == "B"
					hInit := time()
					eval(abNotify, DWConcat(cTablename,STR0012))/*//" - Restaurando tabela"*/
					// if !lEof
					//   nSecInic := seconds()
					//   nSecTot := nSecInic
					// 	 append from (cOldFile) while Estima(@nSecInic, abNotify, recno(), nTotrec, 500, ::Alias(), STR0013)/*//"Restaurando"*/
					// endif
					eval(abNotify, DWConcat(cTablename,STR0014 + elaptime(hInic, time())))/*//" - Restauração efetuada em "*/
				else
					append from (cOldFile)
				endif
			else
				DWLog(">> " + STR0011 + cOldFile)/*//"   Restaurando os dados salvos em "*/
				aListFld := {{},{}}
				for nInd := 1 to len(aIntField)
					if !empty(aIntField[nInd,1])
						aAdd(aListFld[1], aIntField[nInd,1])
						if ascan(aFields, {|x| x[1] == aIntField[nInd,1] .and. x[2] == aIntField[nInd,2] }) != 0
							aAdd(aListFld[2], aIntField[nInd,1])
						elseif aIntField[nInd, 2] == "N"
							aAdd(aListFld[2], "0 " + aIntField[nInd, 1])
						else
							aAdd(aListFld[2], "'' " + aIntField[nInd, 1])
						endif				
					endif				
				next								

				if SGDB() <> DB_DB2400
					aAdd(aListFld[1], "R_E_C_N_O_")
				endif
				aAdd(aListFld[1], DWDelete())
				if SGDB() <> DB_DB2400
					aAdd(aListFld[2], "R_E_C_N_O_")
				endif
				aAdd(aListFld[2], DWDelete())
			
				oQuery := TQuery():New(DWMakeName("TRA"))
				oQuery:FieldList(dwConcatWSep(",", aListFld[2]))
				oQuery:FromList(cOldFile)
				oQuery:WithDeleted(.f.)
				oQuery:ExecSQL(oQuery:InsertInto(aListFld[1], cTablename,,,.f.))
				oQuery:Close()

				::Open()                      
			endif
		else               
			nTopErr := nil    
			aNewStruc := aclone(aOldStruc)
			aOldStruc := dbStruct()
			::Close()
			if !tcAlter(::Tablename(), aOldStruc, aNewStruc, @nTopErr)
				appRaise(ERR_009, SOL_002, STR0024 + dwStr(nTopErr, .t.) + "-" + tcSqlError()) //"Validação de estrutura. Mensagem TOP CONNECT:"
			endif
			::Open()
		endif
		
		::Close()
		::faStruct := {}
		::Open()
		DWLog(">> " + STR0016) //Modificação efetuada
	endif
	
return lDif

/*
--------------------------------------------------------------------------------------
Armazena mensagens (textos) especificas da tabela ao usuário/programador
--------------------------------------------------------------------------------------
*/
method Msg(alCRLF) class TTable
	default alCRLF := .f.
return iif(alCRLF, CRLF, "") + ::fcMsg

/*
--------------------------------------------------------------------------------------
Armazena na pilha a posição atual (indice e registro)
--------------------------------------------------------------------------------------
*/
method SavePos() class TTable
	local nPos, cOldAlias

	nPos := len(::faStack)

	if nPos == 0 .or. valType(::faStack[nPos]) == "A"
		aAdd(::faStack, NIL)
		nPos++
	endif               
	cOldAlias := select()
	::PutInUse()	
	::faStack[nPos] := { cOldAlias, recno(), IndexOrd() }
			
return

/*
--------------------------------------------------------------------------------------
Restaura da pilha a posição do arquivos (indice e registro)
--------------------------------------------------------------------------------------
*/
method RestPos() class TTable
	local nPos, cOldAlias

	nPos := len(::faStack)
	if nPos > 0
		::PutInUse()
		cOldAlias := ::faStack[nPos, 1]
		dbSetOrder(::faStack[nPos, 3])
		if ::Recno() != ::faStack[nPos, 2] 
			dbGoto(::faStack[nPos, 2]) 
		endif
		::faStack[nPos] := NIL
		::faStack := packArray(::faStack)
		dbSelectArea(cOldAlias)
	endif

return

/*
--------------------------------------------------------------------------------------
Anexa todo arquivo SDF na tabela (append from)
Arg: acFilename -> string, nome do arquivo SDF
Ret: 
--------------------------------------------------------------------------------------
*/                                 
method AppSDF(acFilename) class TTable

	::PutInUse()
	append from (acFilename) SDF

return

/*
--------------------------------------------------------------------------------------
Copia todo a tabela para um arquivo SDF
Arg: acFilename -> string, nome do arquivo SDF
Ret: 
--------------------------------------------------------------------------------------
*/                                 
method CopyToSDF(acFilename, acFieldSep) class TTable

	default acFieldSep := ","
	::PutInUse()
	copy to (acFilename) delimited with (acFieldSep)

return

/*
--------------------------------------------------------------------------------------
Copia o arquivo atual para um novo
Arg: acTargetFile -> string, nome do arquivo destino
	  abFilter -> code-block, utilizado para filtrar os registros 
	  alLocal -> logico, indica se é local	
Ret: aRet -> array, lista de campos a atualizar
--------------------------------------------------------------------------------------
*/                                 
method CopyTo(acTargetFile, abFilter, alLocal) class TTable
  if! alLocal
  
  	copy to (acTargetFile) via "TOPCONN"
		
  endif

return

/*
--------------------------------------------------------------------------------------
Propriedade descricao
--------------------------------------------------------------------------------------
*/                                 
method Descricao(acValue) class TTable

	property ::fcDescricao := acValue	
		
return ::fcDescricao

/*
--------------------------------------------------------------------------------------
Propriedade SX
--------------------------------------------------------------------------------------
*/                                 
method SX(alValue) class TTable

	property ::flSX := alValue	
		
return ::flSX

/*
--------------------------------------------------------------------------------------
Prepara um array para atualização da tabela a partir de cookies
Arg: aaCookies -> array, lista de cookies
     aaIgnFields -> array, lista de campos a ignorar
Ret: aRet -> array, lista de campos a atualizar
--------------------------------------------------------------------------------------
*/                                 
method FromPost(aaPostParm, aaIgnFields) class TTable

return ::FromCookies(aaPostParm, "HttpPost", aaIgnFields)

method FromCookies(aaCookies, acAlias, aaIgnFields) class TTable
	local aRet := {}
	local nInd, nPos, cFieldName

	default acAlias := "HttpCookies"               
	default aaIgnFields := {}
	
	if valtype(aaCookies) == "A" .and. len(aaCookies) > 0 .and. valType(aaCookies[1]) != "A"
		aEval(aaCookies, { |x| aAdd(aRet, { x, &(acAlias+"->"+x) } ) })
		aRet := ::FromCookies(aRet, acAlias)
	else
		for nInd := 1 to len(::Fields())
			cFieldname := alltrim(upper(::Fields()[nInd, 1]))
			if cFieldname == "ID"
				loop
			endif
			nPos := ascan(aaCookies, { |x| alltrim(upper(URLDecode(x[1]))) == cFieldname })
			if nPos == 0
				nPos := ascan(aaCookies, { |x| alltrim(upper(URLDecode(x[1]))) == "ED"+cFieldname })
			endif
			if nPos <> 0
				if valType(::Fields()[nInd, 7]) <> "B" .or. ;
					valType(::Fields()[nInd, 8]) == "B"
					aAdd(aRet, { cFieldname, DWConvTo(::Fields()[nInd, 2], aaCookies[nPos,2])})
				elseif ::Fields()[nInd, FLD_TYPE] == "L"
					aAdd(aRet, { cFieldname, .F. } )
				endif
			elseif ::Fields()[nInd, FLD_TYPE] == "L"   
				if valType(::Fields()[nInd, 7]) <> "B" .or. ;
					valType(::Fields()[nInd, 8]) == "B"
					aAdd(aRet, { cFieldname, .F. } )
				endif
			endif
		next
	endif	                   
	
	if len(aaIgnFields) > 0
		for nInd := 1 to len(aRet)
			if ascan(aaIgnFields, { |x| upper(aRet[nInd, 1]) == upper(x)}) > 0
				aRet[nInd] := nil
			endif
		next
		aRet := packArray(aRet)
	endif
	
return aRet

/*
--------------------------------------------------------------------------------------
Recupera a posição fisica do campo
Arg: acFieldName -> string, nome do campo
Ret: nRet -> integer, posição do campo
--------------------------------------------------------------------------------------
*/                                 
method FieldPos(acFieldName) class TTable
	
return (::fcAlias)->(FieldPos(acFieldName))

/*
--------------------------------------------------------------------------------------
Recupera o valor de um campo
Arg: anFieldPos -> integer, posição do campo
Ret: xRet -> expressao, valor do campo 
--------------------------------------------------------------------------------------
*/                                 
method FieldGet(anFieldPos) class TTable
	
return (::fcAlias)->(FieldGet(anFieldPos))

/*
--------------------------------------------------------------------------------------
Grava o valor de um campo
Arg: anFieldPos -> integer, posição do campo
	  xValue -> expressao, valor do campo 
--------------------------------------------------------------------------------------
*/                                 
method FieldPut(anFieldPos, axValue) class TTable
	
return (::fcAlias)->(FieldPut(anFieldPos, axValue))

/*
--------------------------------------------------------------------------------------
Propriedade consulta
--------------------------------------------------------------------------------------
*/                                 
method Consulta(aoValue) class TTable

	property ::foConsulta := aoValue
	
return ::foConsulta

/*
--------------------------------------------------------------------------------------
Propriedade Events
--------------------------------------------------------------------------------------
*/                                 
method Events(abValue) class TTable

	property ::fbEvents := abValue
	
return ::fbEvents

/*
--------------------------------------------------------------------------------------
Propriedade FireEvent
--------------------------------------------------------------------------------------
*/                                 
method FireEvent(anMoment, anEvent, alCond, aaValues) class TTable
	local lRet := .t.
	
	if valType(::Events()) == "B"
		default alCond := .f.
		::SavePos()
		eval(::Events(), Self, anMoment, anEvent, alCond, aaValues)
		::RestPos()
	endif
		
return lRet

/*
--------------------------------------------------------------------------------------
Converte valores numéricos para string, caso seja NIL, retorna ""
Arg: anValue -> numerico, valor a ser convertido em string
     anTam -> numerico, tamanho
     anDec -> numerico, numero de decimais
Ret: cRet -> string, valor convertido
--------------------------------------------------------------------------------------
*/                                 
//static 
function strNil(anValue, anTam, anDec)
	local cRet
	
	if valType(anValue) == "U"
		cRet := ""
	else
		cRet := str(anValue, anTam, anDec)
	endif
	
return cRet

/*
--------------------------------------------------------------------------------------
Converte valores data para string (yyyymmdd), caso seja NIL, retorna ""
Arg: adValue -> data, valor a ser convertido em string
Ret: cRet -> string, valor convertido
--------------------------------------------------------------------------------------
*/                                 
//static 
function dtosNil(adValue)
	local cRet

	if valType(adValue) == "U"
		cRet := ""
	elseif valType(adValue) == "C"
		if dwval(left(adValue, 4)) > 1900
			cRet := adValue
		else
			cRet := dtos(ctod(adValue))
		endif
	else 
		cRet := dtos(adValue)
	endif
	
return cRet

/*
--------------------------------------------------------------------------------------
Monta a chave para pesquisa 
Arg: adValue -> data, valor a ser convertido em string
Ret: cRet -> string, valor convertido
--------------------------------------------------------------------------------------
*/                                 
static function RetPesq(aPesq, aaValues)
	local aRet := {}
	local x, y
//   private x
//	aEval(aPesq, { |x| aScan(aaValues, {|y| iif(Upper(y[1])==Upper(x), aAdd(aRet, y[2]), nil) } ) } )
	for x:=1 to len(aPesq)
		for y:=1 to len(aaValues)
			if ValType(aaValues[y]) <> "U"
				if ( Upper(aPesq[x]) == Upper(aaValues[y][1]) )
					aAdd(aRet, aaValues[y][2])
				endif
			endif
		next
	next
	
return aRet

/*
--------------------------------------------------------------------------------------
Propriedade Validade
--------------------------------------------------------------------------------------
*/                                 
method Validate(abValue) class TTable

	property ::fbValidate := abValue
	
return ::fbValidate

/*
--------------------------------------------------------------------------------------
Propriedade Struct
--------------------------------------------------------------------------------------
*/                                 
method Struct() class TTable
	local aRet := ::faStruct

	if len(aRet) == 0
		if ::isOpen()
			aEval((::fcAlias)->(DBStruct()), { |x| aAdd(aRet, { x[1], x[2], x[3], x[4] })})
		else 
			aRet := {}
			aEval(::Fields(), { |x| aAdd(aRet, { x[FLD_NAME], x[FLD_TYPE], x[FLD_LEN], x[FLD_DEC] })})
		endif
	endif

return aRet

/*
--------------------------------------------------------------------------------------
Verifica se o registro é valido ou não
--------------------------------------------------------------------------------------
*/                                 
method isValid(aaValues) class TTable
	local lRet := .t.

	if valtype(::Validate()) == "B"
		::FireEvent(FE_BEFORE, FE_VALIDATE,, aaValues)
		lRet := __runCB(::Validate())
		::FireEvent(FE_AFTER, FE_VALIDATE,, aaValues)
	else
		::FireEvent(FE_DURING, FE_VALIDATE,, aaValues)
	endif
	
return lRet

/*
--------------------------------------------------------------------------------------
Monta a expressão da chave (string e codeblock)
Arg: aaKeyFields -> array string, nome dos campos que compoem a chave
Ret: cRet -> expressão da chave
--------------------------------------------------------------------------------------
*/                                 
method makeKeyExpr(aaFieldList) class TTable
	local nInd, aInfo, lOneField
	local aFields := {}
	local aFieldList := {}

	if ::flHaveDWField
		aAdd(aFieldList, "ID_DW")
	endif
	aEval(aaFieldList, { |x| aAdd(aFieldList, x) })
	
	lOneField := len(aFieldList) == 1
		
	for nInd := 1 to len(aFieldList)
		aFieldList[nInd] := upper(aFieldList[nInd])
		aInfo := ::Fields(aFieldList[nInd])
		if valType(aInfo) == "A"
			if lOneField
				aAdd(aFields, aFieldList[nInd])
			elseif aInfo[2] == "N"
				aAdd(aFields, "str(" + DWConcatWSep(",", aFieldList[nInd], aInfo[3], aInfo[4]) + ")" )
			elseif aInfo[2] == "D"
				aAdd(aFields, DWConcat("dtos(", aFieldList[nInd], ")") )
			elseif aInfo[2] == "C"
				aAdd(aFields, aFieldList[nInd] )
			endif
		endif
	next

return DWConcatWSep("+", aFields)

method makeKeyBlock(aaFieldList) class TTable
	local cRet := "", nInd, aInfo, aBlocks := {}, cParname
	local nSeq := 0, lOneField

	local aFieldList := {}

	if ::flHaveDWField
		aAdd(aFieldList, "ID_DW")
	endif
	aEval(aaFieldList, { |x| aAdd(aFieldList, x) })

	lOneField := len(aFieldList) == 1

	for nInd := 1 to len(aFieldList)
		aFieldList[nInd] := upper(aFieldList[nInd])
		aInfo := ::Fields(aFieldList[nInd])
		if valType(aInfo) == "A"
			nSeq++
			cParName := "p" + DWint2hex(nSeq,2)
			if lOneField
				aAdd(aBlocks, cParName)
			elseif aInfo[2] == "N"
				aAdd(aBlocks, "strNil(" + DWConcatWSep(",", cParName, aInfo[3], aInfo[4]) + ")" )
			elseif aInfo[2] == "D"
				aAdd(aBlocks, DWConcat("dtosNil(", cParName, ")") )
			elseif aInfo[2] == "C"
				aAdd(aBlocks, "padr(" + DWConcatWSep(",", cParName, aInfo[3]) + ")" )
			endif
		endif
	next

	cRet := "{|"
	aEval(aBlocks, { |x,i| cRet += "p" + DWint2hex(i,2) + "," })
	cRet := left(cRet, len(cRet)-1) + "|"
	cRet += DWConcatWSep("+", aBlocks)
	cRet += "}"

return &(cRet)
                          
/*
--------------------------------------------------------------------------------------
Busca por arquivos de indeces que satisfaça a chave
Arg: aaFieldList -> array string, nome dos campos que compoem a chave
	  alCreate -> indica se o indice dever ser criado se não existir
Ret: nRet -> número do indice localizado ou criado (0=não achou)
--------------------------------------------------------------------------------------
*/                                 
method SearchIndex(aaFieldList, alCreate) class TTable
	local nRet := 0, aIndexes := ::Indexes(), nInd, cFieldList
	local cAux, nLen

	default alCreate := .f.

	DplItems(aaFieldList, .t.)
	cFieldList := dwStr(aaFieldList)
	nLen := len(cFieldList)
	for nInd := 1 to len(aIndexes)
		cAux := dwStr(aIndexes[nInd, 4])
		if cAux == cFieldList .or. cFieldList == left(cAux, nLen)
			nRet := nInd
			exit
		endif
	next

	if nRet == 0 .and. alCreate       
		nRet := len(aIndexes)+1
		::AddIndex("I" + DWint2hex(nRet,2), ::makeKeyExpr(aaFieldList), ::makeKeyBlock(aaFieldList), aaFieldList)
		::SaveDD()
		if ::isOpen()
			::Close()
			::Open()
			::ApplyFilter()
		endif
	endif
				
return nRet

/*
--------------------------------------------------------------------------------------
Retorna a expressão do indice corrente ou do solicitado
Arg: anOrder -> numérico, numero do indice desejado ou nil para corrente
Ret: cRet -> string, expressão do indice
--------------------------------------------------------------------------------------
*/                                 
method indexkey(anOrder) class TTable

return (::fcAlias)->(indexkey(anOrder))

/*
--------------------------------------------------------------------------------------
Retorna o numero do indice corrente
Ret: nRet -> numerico, indice corrente
--------------------------------------------------------------------------------------
*/                                 
method indexOrd() class TTable

return (::fcAlias)->(indexOrd())

/*
--------------------------------------------------------------------------------------
Remove as definições do DD
Ret: 
--------------------------------------------------------------------------------------
*/                                 
method eraseDD(acTipoInfo) class TTable
	default acTipoInfo := ""	

	DWEraseDD(::Tablename(), acTipoInfo)	
return

/*
--------------------------------------------------------------------------------------
Le as definições do DD
Ret: 
--------------------------------------------------------------------------------------
*/                                 
method loadDD() class TTable
	local oDD := initTable(TAB_DD), aAux

	if ::Exists()
		if oDD:Seek(2, { ::TableName(), DD_INDEX } )
			while !oDD:Eof() .and. oDD:value("Tablename") == ::TableName() .and. oDD:value("TypeInfo") == DD_INDEX
				if !empty(oDD:value("Info"))
					// (1)Numero do Indice, (2){ lista de campos }
					aAux := dwToken(oDD:value("Info"), "|")
					aAux[2] := &(aAux[2])
					// Verifique se há dpl de campos e elimina o dpl
					DplItems(aAux[2], .t.)
					::AddIndex("I" + dwInt2Hex(aAux[1],2), ::makeKeyExpr(aAux[2]), ::makeKeyBlock(aAux[2]), aAux[2])		
				endif
				oDD:_Next()
			enddo
		endif
	endif

return

/*
--------------------------------------------------------------------------------------
Salvas as definições do DD
Ret: 
--------------------------------------------------------------------------------------
*/                                 
method saveDD() class TTable
	local oDD := initTable(TAB_DD), nInd
   local aIndexes := ::Indexes(), aAux 

	::eraseDD(DD_INDEX)
	for nInd := 1 to len(aIndexes)
		aAux := { dwStr(nInd), dwStr(aIndexes[nInd,4],.t.) }
		oDD:append({{ "tablename", ::Tablename() } , ;
						{ "typeInfo", DD_INDEX } , ;
						{ "info", dwConcatWSep("|", aAux ) } } )
	next

return

/*
--------------------------------------------------------------------------------------
Elimina o indice por Recno
Ret: 
--------------------------------------------------------------------------------------
*/                                 
method DropRecnoIndex() class TTable
	local oQuery
	
	oQuery := TQuery():New(DWMakeName("TRA"))
  oQuery:Execute(EX_DROP_PK, ::Tablename(), "_PK")

return

/*
--------------------------------------------------------------------------------------
Cria o indice por Recno
Ret: 
--------------------------------------------------------------------------------------
*/                                 
method CreateRecnoIndex() class TTable
	local oQuery
	
	oQuery := TQuery():New(DWMakeName("TRA"))
  oQuery:Execute(EX_CREATE_PK, ::Tablename())
		
return

/*
--------------------------------------------------------------------------------------
Executa a atualização de estatisticas na tabela
Ret: 
--------------------------------------------------------------------------------------
*/                                 
method updStat(acTable) class TTable
	local oQuery

  default acTable := ::Tablename()

	oQuery := TQuery():New(DWMakeName("TRA"))
  oQuery:Execute(EX_UPDATE_STAT, acTable)

return

/*
--------------------------------------------------------------------------------------
Elimina todos os indices
Ret: 
--------------------------------------------------------------------------------------
*/                                 
method DropIndexes() class TTable
	if !DWisAp7()
		tcInternal(69, ::Tablename())
		tcRefresh(::Tablename())
	endif
return

/*
--------------------------------------------------------------------------------------
Apura o espaço fisico sendo utilizado
Ret: 
--------------------------------------------------------------------------------------
*/                                 
method SpaceUsed(acTablename) class TTable
	local aRet := {}, oQuery, aAux := {}
	local nRows := 0, nSize := 0, cSPName

	default acTablename := ::Tablename()

	oQuery := TQuery():New(DWMakeName("TRA"))
	
	if SGDB() $ DB_MSSQL_ALL
		cSPName := "SP_USEDSPACE"
		if .t. //!DWExistSP(cSPName)
		  	oQuery:Execute(EX_DROP_PROCEDURE, cSPName+"_")
			aAdd(aAux, "create procedure "+cSPName/*+"_"+DWEmpresa()*/+"(@IN_tablename varChar(20),")
			aAdd(aAux, "       @OUT_result varChar(1) output,")
			aAdd(aAux, "       @OUT_rows float output,")
			aAdd(aAux, "       @OUT_size float output")
			aAdd(aAux, ") as begin")
			aAdd(aAux, "select @OUT_result = '1';")
			aAdd(aAux, "create table #DW_USEDSPACE")
			aAdd(aAux, "(")
			aAdd(aAux, "  name      sysname,")
			aAdd(aAux, "  rows      int null,")
			aAdd(aAux, "  reserved	varchar(10) null,")
			aAdd(aAux, "  data      varchar(10) null,")
			aAdd(aAux, "  indexp    varchar(10) null,")
			aAdd(aAux, "  unused    varchar(10) null")
			aAdd(aAux, ");")
			aAdd(aAux, "if exists (select * from dbo.sysobjects where id = object_id(N'["+acTablename+"]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)")
			aAdd(aAux, "begin")
			aAdd(aAux, "  insert #DW_USEDSPACE exec sp_spaceused '"+acTablename+"'")
			aAdd(aAux, "  select @OUT_rows = rows,")
			aAdd(aAux, "         @OUT_size = convert(float, left(data, charindex(' ', data))) + convert(float, left(indexp, charindex(' ', indexp)))")
			aAdd(aAux, "    from #DW_USEDSPACE;")
			aAdd(aAux, "end else")
			aAdd(aAux, "begin")
			aAdd(aAux, "  select @OUT_rows = 0, @OUT_size = 0")
			aAdd(aAux, "end")
			aAdd(aAux, "select @OUT_result = '1';")
			aAdd(aAux, "end;")
			aAdd(aAux, "--Não remover esta linha, senão a SP não eh criada")
			oQuery:ExecSQL(DWConcatWSep(LF, aAux))
		endif
		aRet := DWExecSP(cSPName, acTablename, " ", 0, 0)
		if aRet[1] != '1'
			appRaise(ERR_009, SOL_009, STR0025 + " [ SP_"+::Tablename()+"_"+DWEmpresa() + " ]")  //"Ocorreu um erro durante a execução"
		endif     
		nRows := aRet[2]
		nSize := aRet[3]
	elseif SGDB() == DB_ORACLE          
		aAux := {}
		aAdd(aAux, "select '1', SEGMENT_NAME, sum(BYTES) from user_segments A, user_indexes B")
		aAdd(aAux, "where A.SEGMENT_NAME = '"+acTablename+"'")
		aAdd(aAux, "and A.SEGMENT_NAME = B.TABLE_NAME")
		aAdd(aAux, "group by SEGMENT_NAME")
		if tcCanOpen(acTablename)
			aAdd(aAux, "union select '2', '"+acTablename+"', count(*) from "+acTablename)
		endif
		oQuery:Open(, dwConcatWSep(CR, aAux))
		if !oQuery:Eof()
			nSize := oQuery:value(3)
			oQuery:_next()
			if !oQuery:Eof()
				nRows := oQuery:value(3)
			endif
		endif
		oQuery:Close()
	endif
       //SPC_ROWS, SPC_SIZE
return { nRows, nSize }

/*
--------------------------------------------------------------------------------------
Renumera o campo R_E_C_N_O_
Ret: 
--------------------------------------------------------------------------------------
*/                                 
method RebuildRecno(anInic, anPasso, alForce) class TTable
	local lRet, aSP := {}
	local cSQL := "select R_E_C_N_O_ from " + ::Tablename() + " group by R_E_C_N_O_ having count(*) > 1"
	local oQuery := TQuery():New(DWMakeName("TRA")), oQuery2
	local cAux                      
	
	default anInic := 0   // O R_E_C_N_O_ deve ser igual a zero na tabela (veja definição do cursor)
	default anPasso := 1
	default alForce := .f.                                            

	oQuery:Open(, cSQL)
	if !oQuery:Eof() .or. alForce
		// cria a SP para renumerar os duplicados
        if SGDB() == DB_ORACLE
			aAdd(aSP,"create procedure SP_" + ::Tablename()+/*"_"+DWEmpresa() + */" (OUT_RET out char) is")
			aAdd(aSP,"nnCount  integer;")
			aAdd(aSP,"nRecno   integer;")
			aAdd(aSP,"nCommit  integer;")

			//  Cursor para ler os registros duplicados
			if anInic == 0
				aAdd(aSP,"  cursor CUR_Tst is select R_E_C_N_O_ from " + ::Tablename() + " where R_E_C_N_O_ in (")
				cAux := ""			
				while !oQuery:Eof()
					cAux += dwStr(oQuery:value(1))+","
					if len(cAux)>80
						aAdd(aSP, cAux)
						cAux := ""
					endif
					oQuery:_next()
				enddo
				if !empty(cAux)
					aAdd(aSP, cAux)
				endif
				aAdd(aSP, "-1) for update of R_E_C_N_O_;")
			elseif alForce
				aAdd(aSP,"  cursor CUR_Tst is select R_E_C_N_O_ from " + ::Tablename() + " for update of R_E_C_N_O_;")
			else
				aAdd(aSP,"  cursor CUR_Tst is select R_E_C_N_O_ from " + ::Tablename() + " where R_E_C_N_O_ = 0 for update of R_E_C_N_O_;")
			endif
			aAdd(aSP,"begin")
			aAdd(aSP,"  OUT_RET := '0';")
			aAdd(aSP,"  open  CUR_Tst;")
			if anInic == 0
				oQuery2 := TQuery():New(DWMakeName("TRA"))
				oQuery2:Clear()             
			  	oQuery2:FieldList("nvl(max(R_E_C_N_O_), 0) nCount")
				oQuery2:FromList(::Tablename())
				oQuery2:Open()
				anInic := oQuery2:value(1)
				oQuery2:close()
			else     
				anInic--
			endif
			aAdd(aSP,"  nnCount := " + dwStr(anInic) +";")
			aAdd(aSP,"  fetch CUR_Tst into nRecno;")
			//  Processa a renumeracao
			aAdd(aSP,"  while (CUR_Tst%FOUND) loop")
			aAdd(aSP,"    nnCount := nnCount + "+dwStr(anPasso)+";")
			aAdd(aSP,"    update " + ::Tablename() + " set R_E_C_N_O_ = nnCount where current of CUR_Tst;")
			aAdd(aSP,"    if nCommit > 2999 then ")
			aAdd(aSP,"       commit;")
			aAdd(aSP,"       nCommit := 0;")
			aAdd(aSP,"    else")
			aAdd(aSP,"       nCommit := nCommit + 1;")
			aAdd(aSP,"    end if;")
			aAdd(aSP,"    fetch CUR_Tst into nRecno;")
			aAdd(aSP,"  end loop;")
			aAdd(aSP,"  commit;")
			aAdd(aSP,"  close CUR_Tst;")
			aAdd(aSP,"  OUT_RET := '1';")
			aAdd(aSP,"end;")
			aAdd(aSP,"--linha de comentario")
		elseif SGDB() == DB_DB2
			aAdd(aSP,"create procedure SP_" + ::Tablename()+/*"_"+DWEmpresa() + */" ( out OUT_RET varchar(1) ) ")
			aAdd(aSP,"language sql")
			aAdd(aSP,"begin")
			aAdd(aSP,"declare nCount  integer default 0;")
			aAdd(aSP,"declare nRecno  integer;")
			aAdd(aSP,"declare n_fim_cur integer default 0;")

			//  Cursor para ler os registros duplicados
			if anInic == 0
				aAdd(aSP,"  declare CUR_Tst cursor with hold for select R_E_C_N_O_ from " + ::Tablename() + " where R_E_C_N_O_ in (")
				cAux := ""			
				while !oQuery:Eof()
					cAux += dwStr(oQuery:value(1))+","
					if len(cAux)>80
						aAdd(aSP, cAux)
						cAux := ""
					endif
					oQuery:_next()
				enddo
				if !empty(cAux)
					aAdd(aSP, cAux)
				endif
				aAdd(aSP, "-1) for update of R_E_C_N_O_;")
			else
				aAdd(aSP,"  declare CUR_Tst cursor with hold for select R_E_C_N_O_ from " + ::Tablename() + " where R_E_C_N_O_ = 0 for update of R_E_C_N_O_;")
			endif			
			aAdd(aSP,"declare continue handler for not found set n_fim_cur = 1;")

			//  Obtem o maior recno                                        
			if anInic == 0
				aAdd(aSP,"  select coalesce(max(R_E_C_N_O_), 0) into nCount from " + ::Tablename() + ";")
			else
				aAdd(aSP,"  set nCount = " + dwStr(anInic-1) + ";")
			endif
			if alForce
				aAdd(aSP,"  update "+::Tablename()+" set R_E_C_N_O_ = 0;")
			endif

			aAdd(aSP," set OUT_RET = '0';")
			aAdd(aSP,"  open  CUR_Tst;")
			aAdd(aSP,"  fetch from CUR_Tst into nRecno;")
			aAdd(aSP,"  parse1:")
			//  Processa a renumeracao
			aAdd(aSP,"  while (N_FIM_CUR <> 1) DO ")
			aAdd(aSP,"    set nCount = nCount + " + dwStr(anPasso) + ";")
			aAdd(aSP,"    update " + ::Tablename() + " set R_E_C_N_O_ = nCount where current of CUR_Tst;")
			aAdd(aSP,"    fetch from CUR_Tst into nRecno;")
			aAdd(aSP,"  end while parse1;")
			aAdd(aSP,"  close CUR_Tst;")
			aAdd(aSP,"  set OUT_RET = '1';")
			aAdd(aSP,"end")          
		elseif SGDB() == DB_INFORMIX
			aAdd(aSP,"create procedure SP_" + ::Tablename()+/*"_"+DWEmpresa() +*/" () ")
			aAdd(aSP,"returning char( 01 );")
			aAdd(aSP,"define OUT_RET char(1);")
			aAdd(aSP,"define nCount integer;")
			aAdd(aSP,"define nRecno integer;")
			aAdd(aSP,"begin")
			aAdd(aSP,"  let OUT_RET = '0';")
			//  Obtem o maior recno                                        
			if anInic == 0
				aAdd(aSP,"  select nvl(max(R_E_C_N_O_), 0) into nCount from " + ::Tablename() + ";")
			else
				aAdd(aSP,"  let nCount = " + dwStr(anInic-1)+";")
			endif
			if alForce
				aAdd(aSP,"  update "+::Tablename()+" set R_E_C_N_O_ = 0;")
			endif

			//  Cursor para ler os registros duplicados
			if anInic == 0
				aAdd(aSP,"  foreach CUR1 with hold for select R_E_C_N_O_ into nrecno from " + ::Tablename() + " where R_E_C_N_O_ in (")
				cAux := ""			
				while !oQuery:Eof()
					cAux += dwStr(oQuery:value(1))+","
					if len(cAux)>80
						aAdd(aSP, cAux)
						cAux := ""
					endif
					oQuery:_next()
				enddo
				if !empty(cAux)
					aAdd(aSP, cAux)
				endif
				aAdd(aSP, "-1) ")
			else
				aAdd(aSP,"  foreach CUR1 with hold for select R_E_C_N_O_ into nrecno from " + ::Tablename() + " where R_E_C_N_O_ = 0 ")
			endif			
			//  Processa a renumeracao
			aAdd(aSP,"    let nCount = nCount + " + dwStr(anPasso)+";")
			aAdd(aSP,"    update " + ::Tablename() + " set R_E_C_N_O_ = nCount where current of CUR1;")

			aAdd(aSP,"  end foreach")
			aAdd(aSP,"  let OUT_RET = '1';")
			aAdd(aSP," return OUT_RET;")
			aAdd(aSP,"end;")
			aAdd(aSP,"end procedure")
		else
			aAdd(aSP,"create procedure SP_" + ::Tablename()/*+"_"+DWEmpresa()*/+ " (@OUT_RET char(1) output) as")
			aAdd(aSP,"declare @nCount  integer")
			aAdd(aSP,"declare @nRecno  integer")
			aAdd(aSP,"begin")
			aAdd(aSP,"  select @OUT_RET = '0'")
			//  Obtem o maior recno                                        
			if anInic == 0
				aAdd(aSP,"  select @nCount = isnull(max(R_E_C_N_O_), 0) from " + ::Tablename())
			else
				aAdd(aSP,"  select @nCount = " + dwStr(anInic-1))
			endif
			if alForce
				aAdd(aSP,"  update "+::Tablename()+" set R_E_C_N_O_ = 0")
			endif

			//  Cursor para ler os registros duplicados
			if anInic == 0
				aAdd(aSP,"  declare CUR_Tst cursor for select R_E_C_N_O_ from " + ::Tablename() + " where R_E_C_N_O_ in (")
				cAux := ""			
				while !oQuery:Eof()
					cAux += dwStr(oQuery:value(1))+","
					if len(cAux)>80
						aAdd(aSP, cAux)
						cAux := ""
					endif
					oQuery:_next()
				enddo
				if !empty(cAux)
					aAdd(aSP, cAux)
				endif
				aAdd(aSP, "-1) for update of R_E_C_N_O_")
			else
				aAdd(aSP,"  declare CUR_Tst cursor for select R_E_C_N_O_ from " + ::Tablename() + " where R_E_C_N_O_ = 0 for update of R_E_C_N_O_")
			endif			
			aAdd(aSP,"  open  CUR_Tst")
			aAdd(aSP,"  fetch CUR_Tst into @nRecno")
			//  Processa a renumeracao
			aAdd(aSP,"  while (@@fetch_status = 0)")
			aAdd(aSP,"  begin")
			aAdd(aSP,"    select @nCount = @nCount + " + dwStr(anPasso))
			aAdd(aSP,"    update " + ::Tablename() + " set R_E_C_N_O_ = @nCount where current of CUR_Tst")
			aAdd(aSP,"    fetch CUR_Tst into @nRecno")
			aAdd(aSP,"  end")
			aAdd(aSP,"  close CUR_Tst")
			aAdd(aSP,"  deallocate CUR_Tst")
			aAdd(aSP,"  select @OUT_RET = '1'")
			aAdd(aSP,"end")          
		endif  
		dwstatOn("Exec SP")
		oQuery2 := TQuery():New(DWMakeName("TRA"))
		oQuery2:Execute(EX_DROP_PROCEDURE, "SP_"+::Tablename())
		lRet := oQuery2:ExecSQL(DWConcatWSep(LF, aSP)) == 0
		if lRet
			aRet := DWExecSP("SP_" + ::Tablename(), "")
			if aRet[1] != '1'
				appRaise(ERR_009, SOL_009, STR0025 + " [" + acSPname + "]")  //"Ocorreu um erro durante a execução"
			endif
		endif
		dwstatOff()
	endif  
	oQuery:Close()       
	::refresh()

return lRet
                                   
/*
--------------------------------------------------------------------------------------
Dispara evento de sincronização
Ret: 
--------------------------------------------------------------------------------------
*/                                 
method syncronize() class TTable
	
	::FireEvent(FE_BEFORE, FE_SYNC)
	::FireEvent(FE_DURING, FE_SYNC)
	::FireEvent(FE_AFTER , FE_SYNC)
	
return

static function ParaEvitarAvisoErroAoCompilar()

	if .f.    
		DTOSNIL(); STRNIL()
		ParaEvitarAvisoErroAoCompilar()
	endif

return

