// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : SigaDW
// Fonte  : RPCTable - Objeto TRPCTable, acesso as tabelas da base de dados via RPC
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 01.06.01 | 0548-Alan Candido |
// 03.01.06 | 0548-Alan Candido | Versão 3
// --------------------------------------------------------------------------------------

#include "dwincs.ch"
#include "tbiconn.ch"
#include "topconn.ch"
#include "rpctable.ch"

/*
--------------------------------------------------------------------------------------
Classe: TRPCTable
Uso   : Tabela de dados
--------------------------------------------------------------------------------------
*/
class TRPCTable from TTable

	data faBuffer
	data fnMaxBuffer
	data fnRecno
	data foRPC
	data fcSQL
	data fcEmpresa
	data fcFilial

	method New(aoRPC, acTablename, acAlias) 
	method Free()
	method CallRPC(acComando, aaArgs) 
               
	method IndexOff()
	
	method PutInUse()
	method Exists()
	method CreateTable(acTablename)
	method Open(alExclusive, alSX, acEmbSQL)
	method OpenIndex(acIndice, acChave)
	method Close()
	method Delete()
	method IsOpen()
	method GoTop()
	method _Next()
	method Previous()
	method GoBottom()
	method _Bof()
	method Eof()
	method Lock()
	method Unlock()
	method RecCount()
	method Seek(anIndexNumber, aaKeyValue, alSoftseek)
	method Found()
	method RecNo()
	method Filter()
	method Zap()
	method DropIndex()
	method DropTable()
	method Refresh(alRecord)
	method Msg()
	method SavePos()
	method RestPos()
	method AppSDF(acFilename)
	method CopyTo(acTargetFile, abFilter, alLocal) 
	method CopyToSDF(acFilename, acFieldSep)
	method Value(acField, alTrim)
	method FieldPos(acFieldName)   
	method FieldPut(anPos, axValue)
	method FieldGet(anPos)
	method setField(acFielname, acType, anLen, anNDec)
	method ResetBuffer()   
	method LoadBuffer(alNext)
	method OpenDB(acTopServer, acTipo, acTopBanco, acTopAlias)
	method SQL(acValue)
	method indexOrd()
	method indexKey(anOrder)
	method OpenSX(alExclusive) 
	method GeraID() 
endclass

/*
--------------------------------------------------------------------------------------
Construtor e destrutor da classe
Args: aoRPC -> objeto, conector RPC
		acTablename -> string, nome da tabela
		acAlias -> string, apelido da tabela
--------------------------------------------------------------------------------------
*/
method New(aoRPC, acTablename, acAlias, acEmpresa, acFilial) class TRPCTable
	_Super:New(acTablename, acAlias, .f.)
	
	::foRPC 		:= aoRPC
	::fcSQL 		:= ""
	::fnMaxBuffer 	:= 0
	::fnRecno 		:= 0
	::fcEmpresa 	:= acEmpresa
	::fcFilial 		:= acFilial
return

method Free() class TRPCTable
	_Super:Free()
return

/*
--------------------------------------------------------------------------------------
Efetua a chamada RPC
Args: acComando, string -> comando RPC a ser executado
	   aaArgs, array -> lista de argumentos do RPC
Rets: xRet -> expressao, valor retornado pelo RPC
--------------------------------------------------------------------------------------
*/                         
method callRPC(acComando, aaArgs) class TRPCTable
	local xRet, cMsg
	
	//###TODO WORKAROUND para tratar cPaisLoc := "BRA"
		
	default aaArgs	:= {}
      
	callproc in ::foRPC;
		function "RPCDWTable";
		parameters acComando, SELF:Alias(), aaArgs ;
		result xRet
	
	if valType(xRet) == "U" .or. (valType(xRet) == "L" .and. !xRet)
		callproc in ::foRPC;
			function "RPCDWTable";
			parameters "MSGERRO";
			result cMsg
			::fcMsg := cMsg
		if !empty(cMsg) //valType(xRet) == "U"
			if !(acComando == "usesql")
				DWRaise(ERR_001, SOL_001, ::fcMsg)
			else
				DWRaise(ERR_008, SOL_002, ::fcMsg)
			endif
		endif
	endif

return xRet

/*
--------------------------------------------------------------------------------------
Excluir registro atual
Args: 
Rets: lRet -> lógico, processo OK
--------------------------------------------------------------------------------------
*/                         
method Delete() class TRPCTable
	local lRet := ::Lock()
	
	if lRet
		lRet := ::callRPC("Delete")
	endif
	
return lRet

/*
--------------------------------------------------------------------------------------
Verifica se a tabela existe
Args: 
Rets: lRet -> lógico, indica a existencia ou não da tabela
--------------------------------------------------------------------------------------
*/                         
method Exists() class TRPCTable
			                             
	DWRaise(ERR_001, SOL_001)
	
return 

/*
--------------------------------------------------------------------------------------
Cria fisicamente a tabela
Args: acTablename -> string, nome da nova tabela
Rets: lRet -> lógico, indica se a criação foi bem suscedida
--------------------------------------------------------------------------------------
*/                         
method CreateTable(acTablename, alLocal) class TRPCTable
	local lRet := .f., aFields := {}
	default acTablename := ::Tablename()
	default alLocal := .f.
	
	aEval(::Fields(), { |x| iif(valType(x[7]) == "U", aAdd(aFields, { x[1], x[2], x[3], x[4]}), NIL)})

	lRet := ::callRPC("dbCreate", { acTablename, aFields } )
	
return lRet

/*
--------------------------------------------------------------------------------------
Indica se a tabela esta aberta
Args: 
Rets: lRet -> lógico, indica se arquivo esta aberto
--------------------------------------------------------------------------------------
*/                         
method IsOpen() class TRPCTable
                                   
return ::callRPC("isOpen")

/*
--------------------------------------------------------------------------------------
Abra a tabela para uso
Args: alExclusive -> logico, indica se a abertura é exclusive
	   alsx -> logico, indica se a abertura é via SX
Rets: lRet -> lógico, indica se a abertura foi bem suscedida
--------------------------------------------------------------------------------------
*/                                                                  
static function getEmpComp() //  monta a lista de aliases compartilhados entre empresas
	local aRet := {}
	local oSX2 := initQuery(SEL_DSN_EMPCOMP)

	oSX2:open()	
	
	while !oSX2:eof() 
		aAdd(aRet, oSX2:value("alias"))
		oSX2:_next()
	enddo
	
	oSX2:close()
	
return aRet

	
method Open(alExclusive, alSX, acEmbSQL) class TRPCTable
	local lRet := .t.
	local aFields              
	local nInd
	
	default alExclusive := .f.
	default alSX := .f.
	default acEmbSQL := ""

	if !::IsOpen()	
		::fnRefCount := 0
   		if empty(::SQL())
	   		if alSX
				if !empty(acEmbSQL)                                                         
					if "DWDSTMPARQ" $ upper(acEmbSQL)
						::callRPC("useembsql", { ::fcAlias, acEmbSQL, getEmpComp(), /*DWDirInclude(),*/ dwDsTmpArq(), ::fcEmpresa, ::fcFilial } )
					else
						::callRPC("useembsql", { ::fcAlias, acEmbSQL, getEmpComp(), /*DWDirInclude(),*/ "", ::fcEmpresa, ::fcFilial } )
					endif
				else
					::callRPC("usesx", { ::Tablename(), ::fcAlias } )
				endif
			else
				::callRPC("use", { ::Tablename(), ::fcAlias, alExclusive, "DBFCDX" } )
			endif
	   	else
			::callRPC("usesql", { ::fcAlias, ::SQL() } )
		endif		
		if ::callRPC("neterr")
			lRet := .F.
		elseif len(::Fields()) == 0
			aFields := ::callRPC("DBStruct")

			aEval(aFields, { |x| ::AddField(nil, x[1], x[2], x[3], x[4]) })
            
			::ResetBuffer()
			::_Next()
		endif
	endif
	
return lRet

/*
--------------------------------------------------------------------------------------
Abra uma tabela via SX para uso
Args: alExclusive -> logico, indica se a abertura é exclusive
Rets: lRet -> lógico, indica se a abertura foi bem suscedida
--------------------------------------------------------------------------------------
*/                         
method OpenSX(alExclusive) class TRPCTable
	local lRet := .t.
	local aFields              
	local nInd
	
	default alExclusive := .f.

	if !::IsOpen()	
		::fnRefCount := 0
   	
		::callRPC("usesx", { ::Tablename(), ::fcAlias } )

		if ::callRPC("neterr")
			lRet := .F.
		elseif len(::Fields()) == 0
			aFields := ::callRPC("DBStruct")
			aEval(aFields, { |x| ::AddField(nil, x[1], x[2], x[3], x[4]) })
			::ResetBuffer()
			::_Next()
		endif
	endif
	
return lRet

/*
--------------------------------------------------------------------------------------
Fecha a tabela 
Args: 
Rets: lRet -> lógico, indica se o fechamento foi bem suscedido
--------------------------------------------------------------------------------------
*/                         
method Close() class TRPCTable

	if ::isOpen()
		if ::fnRefCount == 0
			::callRPC("dbCloseArea")
		else
			::fnRefCount--
		endif
	endif

return .t.

/*
--------------------------------------------------------------------------------------
Liga/Desliga o uso de indices
--------------------------------------------------------------------------------------
*/                         
method IndexOff() class TRPCTable
	     
	if ::isOpen()
		::callRPC("dbClearIndex")
	endif
	::flIndexOn := .f.

return

/*
--------------------------------------------------------------------------------------
Abre os arquivos de indices e se necessários cria-os
Args: 
Rets: lRet -> lógico, indica se o processo foi bem suscedido
--------------------------------------------------------------------------------------
*/                         
method OpenIndex(acIndice, acChave) class TRPCTable

	DWRaise(ERR_001, SOL_001)

return .t.

/*
--------------------------------------------------------------------------------------
Gera ID único
Args: 
Rets: nRet -> numérico, ID do registro
--------------------------------------------------------------------------------------
*/                         
method GeraID() class TRPCTable

return ::callRPC("geraID")

/*
--------------------------------------------------------------------------------------
Posiciona no ínicio da tabela
Args: 
Rets: 
--------------------------------------------------------------------------------------
*/                         
method GoTop() class TRPCTable

	::callRPC("DBGoTop")	
	::ResetBuffer()
	::_Next()
		
return .T.

/*
--------------------------------------------------------------------------------------
Posiciona no próxima registro da tabela
Args: 
Rets: 
--------------------------------------------------------------------------------------
*/                         
method _Next() class TRPCTable

	if ::fnRecno == -1 .or. ::fnRecno == len(::faBuffer)
		::LoadBuffer(.t.)
		::fnRecno := 1
	else        
		::fnRecno++
	endif

return .t.

/*
--------------------------------------------------------------------------------------
Posiciona no registro anterior da tabela
Args: 
Rets: 
--------------------------------------------------------------------------------------
*/                         
method Previous() class TRPCTable

	if ::fnRecno == -1 .or. ::fnRecno == 0
		::LoadBuffer(.f.)
		::fnRecno := len(::faBuffer)
	else        
		::fnRecno--
	endif

return .t.

/*
--------------------------------------------------------------------------------------
Posiciona no final da tabela
Args: 
Rets: 
--------------------------------------------------------------------------------------
*/                         
method GoBottom() class TRPCTable

return ::callRPC("dbGoBottom")

/*
--------------------------------------------------------------------------------------
Indica se esta ou não no fim de arquivos
Args: 
Rets: lRet -> lógico, fim de arquivo (EOF)
--------------------------------------------------------------------------------------
*/                         
method Eof() class TRPCTable                                      

return (valtype(::faBuffer[::fnRecno])="U") .and. (aTail(aTail(::faBuffer)) == -1)

/*
--------------------------------------------------------------------------------------
Indica se esta ou não no inicio de arquivos
Args: 
Rets: lRet -> lógico, fim de arquivo (BOF)
--------------------------------------------------------------------------------------
*/                         
method _Bof() class TRPCTable
                          
return (::fnRecno == 0) .and. aTail(::faBuffer[1]) == 0

/*
--------------------------------------------------------------------------------------
Trava um registro
Args: alAppend -> lógico, indica que é lock com append
Rets: lRet -> lógico, travado 
--------------------------------------------------------------------------------------
*/                         
method Lock(alAppend) class TRPCTable

return ::callRPC("lock", {alAppend})

/*
--------------------------------------------------------------------------------------
Libera um registro travado
Args: 
Rets: lRet -> lógico, liberado
--------------------------------------------------------------------------------------
*/                         
method Unlock() class TRPCTable

return  ::callRPC("unlock")

/*
--------------------------------------------------------------------------------------
Coloca a tabela como sendo a correndo
Args: 
Rets: 
--------------------------------------------------------------------------------------
*/                         
method PutInUse() class TRPCTable

return ::callRPC("dbSelectArea")

/*
--------------------------------------------------------------------------------------
Retorna numero de registros
Args: 
Rets: nRet -> numerico, numero de registros da tabela
--------------------------------------------------------------------------------------
*/                         
method RecCount(acSQL) class TRPCTable
	
return ::callRPC("recCount", { acSQL })

/*
--------------------------------------------------------------------------------------
Retorna o numero do registro corrente
Args: 
Rets: nRet -> numerico, numero de registros da tabela
--------------------------------------------------------------------------------------
*/                         
method RecNo() class TRPCTable
		
return aTail(::faBuffer[::fnRecno])

/*
--------------------------------------------------------------------------------------
Localiza um registro a partir de um indice especifico
Args: anIndexNumber -> numerico, numero do indice a ser utilizado
		aaKeyValue -> array, valores de composição da chave
		alSoftseek -> lógico, indica usa softseek               
		Caso anIndexNumber seja 0, aaKeyValue deverá ser um numérico com 
		o numero do registro e não mais um array
Rets: xRet -> , valor do campo
--------------------------------------------------------------------------------------
*/                         
method Seek(anIndexNumber, aaKeyValue, alSoftseek) class TRPCTable

	::callRPC("dbSeek", {anIndexNumber, aaKeyValue, alSoftseek })
				
return ::Found()

/*
--------------------------------------------------------------------------------------
Indica se uma pesquisa prévia foi ou não bem suscedida
Args: 
Rets: lRet -> lógico, indica se pesquisa foi OK
--------------------------------------------------------------------------------------
*/                         
method Found() class TRPCTable

return ::callRPC("found")

/*
--------------------------------------------------------------------------------------
Propriedade Filter
Args: acValue -> string, clausula do filtro
Rets: cRet -> string, clausula do filtro
--------------------------------------------------------------------------------------
*/                         
method Filter(acValue)  class TRPCTable
   
return ::callRPC("FILTER", { acValue })

/*
--------------------------------------------------------------------------------------
Efetua um zap na tabela
Args: 
Rets: 
--------------------------------------------------------------------------------------
*/                         
method Zap() class TRPCTable

return ::callRPC("zap")

/*
--------------------------------------------------------------------------------------
Elimina os indices
Args: 
Rets: 
--------------------------------------------------------------------------------------
*/                         
method DropIndex() class TRPCTable

	DWRaise(ERR_001, SOL_001)
		
return

/*
--------------------------------------------------------------------------------------
Elimina a tabela fisicamente
Args: 
Rets: lRet -> logico, se o drop foi executado
--------------------------------------------------------------------------------------
*/                         
method DropTable() class TRPCTable

return ::callRPC("droptable")

/*
--------------------------------------------------------------------------------------
Efetua o "refresh" da base de dados
Args: 
Rets: 
--------------------------------------------------------------------------------------
*/                         
method Refresh(alRecord) class TRPCTable
       
	::callRPC("refresh", { alRecord } )
return 

/*
--------------------------------------------------------------------------------------
Armazena na pilha a posição atual (indice e registro)
--------------------------------------------------------------------------------------
*/
method SavePos() class TRPCTable

	DWRaise(ERR_001, SOL_001)			

return

/*
--------------------------------------------------------------------------------------
Restaura da pilha a posição do arquivos (indice e registro)
--------------------------------------------------------------------------------------
*/
method RestPos() class TRPCTable

	DWRaise(ERR_001, SOL_001)			

return

/*
--------------------------------------------------------------------------------------
Anexa todo arquivo SDF na tabela (append from)
Arg: acFilename -> string, nome do arquivo SDF
Ret: 
--------------------------------------------------------------------------------------
*/                                 
method AppSDF(acFilename) class TRPCTable

	DWRaise(ERR_001, SOL_001)			

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
method CopyTo(acTargetFile, abFilter, alLocal) class TRPCTable

	DWRaise(ERR_001, SOL_001)			

return 

/*
--------------------------------------------------------------------------------------
Gera um arquivo SDF
Arg: acTargetFile -> string, nome do arquivo destino
	  acFieldSep -> string, separador de campo
Ret: 
--------------------------------------------------------------------------------------
*/                                 
method CopyToSDF(acTargetFile, acFieldSep) class TRPCTable
	
	default acFieldSep := ","

return ::callRPC("copytosdf", { acTargetFile, acFieldSep })

/*
--------------------------------------------------------------------------------------
Recupera a posição fisica do campo
Arg: acFieldName -> string, nome do campo
Ret: nRet -> integer, posição do campo
--------------------------------------------------------------------------------------
*/                                 
method FieldPos(acFieldName) class TRPCTable
	local nRet := ascan(::Fields(), { |x| x[1] == acFieldName })

return nRet

/*
--------------------------------------------------------------------------------------
Recupera o valor de um campo
Arg: anFieldPos -> integer, posição do campo
Ret: xRet -> expressao, valor do campo 
--------------------------------------------------------------------------------------
*/                                 
method FieldGet(anFieldPos) class TRPCTable
		
return iif(::eof(), nil, ::faBuffer[::fnRecno, anFieldPos])

/*
---------------------------------------------------------------------------------------
Grava o valor de um campo
Arg: anFieldPos -> integer, posição do campo
	  xValue -> expressao, valor do campo 
--------------------------------------------------------------------------------------
*/                                 
method FieldPut(anFieldPos, axValue) class TRPCTable

	DWRaise(ERR_001, SOL_001)

return .f.

/*
--------------------------------------------------------------------------------------
Reseta o buffer de registros
--------------------------------------------------------------------------------------
*/                                 
method ResetBuffer() class TRPCTable
	Local nRecSize 		:= 0 
	Local nMaxBuffer	:= 65535

	aEval(::Fields(), {|x| nRecSize += ( x[3] + x[4] ) } )
            
    If ! ( Int( 500000 / nRecSize ) > nMaxBuffer ) 
    	nMaxBuffer := Int( 500000 / nRecSize )	
    EndIf                
     
	::faBuffer 			:= NIL
	::fnRecno 			:= -1    
	::fnMaxBuffer 		:= nMaxBuffer 
return

/*
--------------------------------------------------------------------------------------
Carrega o buffer de registros
--------------------------------------------------------------------------------------
*/                                 
method LoadBuffer(alNext) class TRPCTable

	::faBuffer := ::callRPC("LoadBuffer", { alNext, ::fnMaxBuffer })
	if alNext
		::fnRecno := 1
	else
		::fnRecno := len(::faBuffer)
   endif
   
return

/*
--------------------------------------------------------------------------------------
Retorna o valor de um campo
Args: acnField -> string ou numerico, nome ou posição do campo
Rets: xRet -> , valor do campo
--------------------------------------------------------------------------------------
*/                         
method Value(acField, alTrim) class TRPCTable
 
return _Super:Value(acField, alTrim, .t.)

/*
--------------------------------------------------------------------------------------
Abre o banco de dados
Args: acTopServer, string -> nome do servidor top 
		acTopTipo, string -> tipo de comunicação
		acTopBanco, string -> tipo do banco
		acTopAlias, string -> alias de acesso
Rets: lRet-> boolean, processamento ok
--------------------------------------------------------------------------------------
*/                         
method OpenDB(acTopServer, acTopTipo, acTopBanco, acTopAlias) class TRPCTable

return ::callRPC("opendb", { acTopServer, acTopTipo, acTopBanco, acTopAlias } )

/*
--------------------------------------------------------------------------------------
Propriedade SQL
Args: acValue -> string, expressão select
Rets: cRet-> string, expressão select
--------------------------------------------------------------------------------------
*/                         
method SQL(acValue) class TRPCTable

	property ::fcSQL := acValue
	 
return ::fcSQL

/*
--------------------------------------------------------------------------------------
Retorna o numero do indice corrente
Ret: nRet -> numerico, indice corrente
--------------------------------------------------------------------------------------
*/                                 
method indexOrd() class TRPCTable

return iif(empty(::SQL()), ::callRPC("indexOrd"), 0)

/*
--------------------------------------------------------------------------------------
Retorna a expressão do indice corrente ou do solicitado
Arg: anOrder -> numérico, numero do indice desejado ou nil para corrente
Ret: cRet -> string, expressão do indice
--------------------------------------------------------------------------------------
*/                                 
method indexKey(anOrder) class TRPCTable

return iif(empty(::SQL()), ::callRPC("indexKey", { anOrder }), "")

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
method setField(acFieldname, acType, anLen, anDec) class TRPCTable

	::callRPC("setfield", { ::Alias(), acFieldname, acType, anLen, anDec } )

return

/*
=====     =====     =====     =====     =====     =====     =====     =====     =====
     =====     =====     =====     =====     =====     =====     =====     =====
=====     =====     =====     =====     =====     =====     =====     =====     =====
     =====     =====     =====     =====     =====     =====     =====     =====
=====     =====     =====     =====     =====     =====     =====     =====     =====
     =====     =====     =====     =====     =====     =====     =====     =====
=====     =====     =====     =====     =====     =====     =====     =====     =====
     =====     =====     =====     =====     =====     =====     =====     =====
/*

/*
--------------------------------------------------------------------------------------
Responde as chamadas RPCDWTable
Args: acComando -> string, comando RPC
aaParms -> array, contem os parametros complementares conforme o acComando
Ret: xRet -> expressão, valor a ser retornado pelo RPC
--------------------------------------------------------------------------------------
*/
static _RPCDWMsgErro

function RPCDWTable(acComando, acAlias, aaParms)
	local xRet
	local bLastError := ErrorBlock({|e| __DWRPCError(e, @_RPCDWMsgErro) })
	
	begin sequence
		acComando := upper(acComando)
		if acComando == "MSGERRO"
			xRet := _RPCDWMsgErro
		else   
			_RPCDWMsgErro := ""
			if acComando == "ISOPEN"
				xRet := RPCIsOpen(acAlias)
			elseif acComando == "USE"
				xRet := RPCUse(aaParms[1], aaParms[2], aaParms[3], aaParms[4])
			elseif acComando == "OPENDB"
				xRet := RPCOpenDB(aaParms[1], aaParms[2], aaParms[3], aaParms[4])
			elseif acComando == "SETFIELD"
				xRet := RPCSetField(aaParms[1], aaParms[2], aaParms[3], aaParms[4], aaParms[5])
			elseif acComando == "USESQL"
				xRet := RPCUseSQL(aaParms[1], aaParms[2])
			elseif acComando == "USESX"
				xRet := RPCUseSX(aaParms[1], aaParms[2])
			elseif acComando == "USEEMBSQL"
				xRet := RPCUseEmbSQL(aaParms[1], aaParms[2], aaParms[3], aaParms[4], aaParms[5], aaParms[6]/*, aaParms[7]*/)
			elseif acComando == "INDEXORD"
				xRet := RPCIndexOrd(acAlias)
			elseif acComando == "INDEXKEY"
				xRet := RPCIndexKey(acAlias, aaParms[1])
			elseif acComando == "NETERR"
				xRet := RPCNetErr()
			elseif acComando == "DBSTRUCT"
				xRet := RPCDBStruct(acAlias)
			elseif acComando == "DBCLOSEAREA"
				xRet := RPCDBCloseArea(acAlias)
			elseif acComando == "FILTER"
				xRet := RPCFilter(acAlias, aaParms[1])
			elseif acComando == "DBGOTOP"
				xRet := RPCDBGoTop(acAlias)
			elseif acComando == "DBGOBOTTOM"
				xRet := RPCDBGoBottom(acAlias)
			elseif acComando == "RECCOUNT"            
				if valType(aaParms) == "A"
					aSize(aaParms, 1)
					xRet := RPCRecCount(acAlias, aaParms[1])
				else
					xRet := RPCRecCount(acAlias)
				endif
			elseif acComando == "LOADBUFFER"
				xRet := RPCLoadBuffer(acAlias, aaParms[1], aaParms[2])
			elseif acComando == "COPYTOSDF"
				xRet := RPCCopyToSdf(acAlias, aaParms[1], aaParms[2])
			elseif acComando == "DBSELECTAREA"
				xRet := RPCDBSelectArea(acAlias)
			else
				_RPCDWMsgErro := acComando + STR0002  //" não reconhecido"
			endif
		endif
//	recover using oE    
//		_RPCDWMsgErro := "Internal error 1932. "
//		if valType(oE) == "O"
//			_RPCDWMsgErro += oE:Description
//		endif                         
//		xRet := NIL
	end sequence

	if !empty(_RPCDWMsgErro)
		conout(STR0003 + acComando, _RPCDWMsgErro)  //"Erro RPC "
	endif

	ErrorBlock(bLastError)

return xRet

/*
--------------------------------------------------------------------------------------
Verifica se a tabela esta aberta
Args: acAlias -> string, alias a ser verificado
Ret: lRet -> boolean, indica se esta aberto ou não
--------------------------------------------------------------------------------------
*/
static function RPCIsOpen(acAlias)

return select(acAlias) <> 0

/*
--------------------------------------------------------------------------------------
Retorna o indice corrente
Args: acAlias -> string, alias a ser verificado
Ret: nRet -> numerico, numero de indice corrente
--------------------------------------------------------------------------------------
*/
static function RPCIndexOrd(acAlias)

return (acAlias)->(indexOrd())
                           
/*
--------------------------------------------------------------------------------------
Retorna a expressão do indice corrente ou do solicitado
Arg: anOrder -> numérico, numero do indice desejado ou nil para corrente
Ret: cRet -> string, expressão do indice
--------------------------------------------------------------------------------------
*/                                 
static function RPCIndexKey(acAlias, anOrder)

return (acAlias)->(indexkey(anOrder))

/*
--------------------------------------------------------------------------------------
Abre a tabela
Args: acTopServer, string -> servidor Top
		acTopTipo, string -> tipo de comunicação
		acTopBanco, string -> tipo do banco
		acTopAlias, string -> alias do banco
Ret: lRet -> boolean, indica se abertura esta OK
--------------------------------------------------------------------------------------
*/
static function RPCOpenDB(acTopServer, acTopTipo, acTopBanco, acTopAlias)
	local lRet := .t.
	local cServer := extractServer(acTopServer)
	local nPort := extractPort(acTopServer)
	TCCONTYPE(acTopTipo)
	if acTopTipo == "APPC"                 
		if empty(nPort)
			nConecta := TCLINK(acTopBanco, cServer)
		else
			nConecta := TCLINK(acTopBanco, cServer, nPort)
		endif
	else
		if "AS" $ acTopBanco .and. "400" $ acTopBanco
			if empty(nPort)                                           
				nConecta := TCLINK(acTopAlias, acTopServer)
			else
				nConecta := TCLINK(acTopAlias, acTopServer, nPort)
			endif
		else
			if empty(nPort)
				nConecta := TCLINK(acTopBanco+"/"+acTopAlias, cServer)
			else
				nConecta := TCLINK(acTopBanco+"/"+acTopAlias, cServer, nPort)
			endIf
		endIf
	endIf

	if nConecta < 0
		_RPCDWMsgErro := STR0004 + str(nConecta) + STR0005 + acTopServer + ":" + acTopBanco + "/" + acTopAlias  //"Falha de conexão com o TopConnect. Código de erro: " //"Parâmetros: "
		TCQUIT()
		lRet := .f.
	elseif TCSrvType() == "AS/400"
		TCSETBUFF("*ON")    // habilita buffer para versao AS/400
	endIf

return lRet
                         
static function RPCSetField(acAlias, acFieldname, acType, anLen, anDec)
#ifdef TOP
	tcSetField(acAlias, acFieldname, acType, anLen, anDec)
#endif
return .t.                   

/*
--------------------------------------------------------------------------------------
Abre a tabela
Args: acTablename, string -> nome da tabela (completo)
		acAlias, string -> alias da tabela
		alExclusive, boolean -> indica se abertura é exclusiva ou não
		acRDD, string -> nome da RDD
Ret: lRet -> boolean, indica se abertura esta OK
--------------------------------------------------------------------------------------
*/
static function RPCUse(acTablename, acAlias, alExclusive, acRDD)
	local lRet
	
	acTablename := strTran(acTablename, "/", "\")	
	if !alExclusive
		use (acTablename) alias (acAlias) shared new via (acRDD)
	else
		use (acTablename) alias (acAlias) exclusive new via (acRDD)
	endif
   
	lRet := RPCIsOpen(acAlias)
	
	if !lRet
		_RPCDWMsgErro := STR0006 + acTableName  //"Arquivo não encontrado. Arquivo: "
	endif
	
return lRet

/*
--------------------------------------------------------------------------------------
Abre um SQL Embedded
--------------------------------------------------------------------------------------
*/
function DWUseEmbSQL(acAlias, acEmbed, aaEmpComp, /*acDirInclude,*/ acDWDSTmpArq, acEmpSM0, acFilSM0)

return RPCUseEmbSQL(acAlias, acEmbed, aaEmpComp, /*acDirInclude,*/ acDWDSTmpArq, acEmpSM0, acFilSM0)

function DWBuildEmbSQL(acAlias, acEmbed, aaEmpComp, /*acDirInclude,*/ acDWArqTmp, acEmpSM0, acFilSM0)
	local cRet := ""
	local cPpo := ""
	local aDeps := {}
	local aQuery := {}
	local cQuery := ""

	local cExecSint := "__execSql("
	local cUsFunc := "user function xdwxcmp() "
	local cBeginSql := "BeginSql alias "
	local cEndSql := "EndSql "
	local cRetFunc := "return nil "
	local cSrcName := "dwcomp"
	local oRpo := RPO():New(.t.)

	default acEmpSM0 := cEmpAnt
	default acFilSM0 := cFilAnt
	
	oRpo:MainHeader := "PRTOPDEF.CH"
	if DWisAp10()   
		/*Verificar o define*/
		oRpo:Defines := { "Protheus", "AP811", "TOP" } 
	else
		oRpo:Defines := { "Protheus", "AP811", "TOP" }
	endif
	 
	/*Recupera a chave DIRINCLUDE da sessão GENERAL do servidor alvo do RPC.*/		
	oRpo:Includes := dwToken(DWDirInclude(), ";")
	
	oRpo:Open("\xdwxtmp.rpo")
	
	if ( ! oRpo:StartBuild(.T.) )
		ConOut(STR0007 + " 'Embedded SQL'")  /*"Não foi possível iniciar compilação"*/
	endif
	
	if !empty(acDWArqTmp)
		acEmbed := strTranIgnCase(acEmbed, "%xExp:DWDSTmpArq()%", acDWArqTmp)
		acEmbed := strTranIgnCase(acEmbed, "%exp:DWDSTmpArq()%", acDWArqTmp)
	endif                                                                  
	acEmbed := strTranIgnCase(acEmbed, "%xEmpresa:SM0%", "'" + acEmpSM0 + "'")
	acEmbed := strTranIgnCase(acEmbed, "%xFilial:SM0%", "'" + acFilSM0 + "'")
	acEmbed := trataXEmpresa(acEmbed, aaEmpComp, acEmpSM0, acFilSM0)
	
	aAdd(aQuery, " " + cUsFunc)
	aAdd(aQuery, " " + cBeginSql + " '" + acAlias + "' ")
	aAdd(aQuery, " " + acEmbed)
	aAdd(aQuery, " " + cEndSql)
	aAdd(aQuery, " " + cRetFunc)
	cQuery := DWConcatWSep(CRLF, aQuery)
	     
    /*OBS.: O método PreComp não funciona corretamente em LINUX. FNC 000000154762009 aberta em 18/06/2009*/
	if ( ! oRpo:PreComp(cSrcName, cQuery, @cPpo, @aDeps) )
		Conout(STR0008)  /*"Não pode compilar"*/
	else
		cRet := cPpo
		cRet := substr(cRet, at(cExecSint, cRet), at(trim(cRetFunc), cRet)-at(cExecSint, cRet)) 
		cRet := strTran(cRet, chr(10), " ")	
		cRet := strTran(cRet, chr(13), " ")	
	EndIf 
	
	oRpo:EndBuild()
	oRpo:Close()
	
return cRet

static function RPCUseEmbSQL(acAlias, acEmbed, aaEmpComp, /*acDirInclude,*/ acDWArqTmp, acEmpSM0, acFilSM0)
	local lRet := .f.
	local cRet := ""

	RPCSetType(3)
	prepare environment empresa acEmpSM0 filial acFilSM0
	
	cRet := DWBuildEmbSQL(acAlias, acEmbed, aaEmpComp, /*acDirInclude,*/ acDWArqTmp, acEmpSM0, acFilSM0)
	cRet := strTran(cRet, chr(10), " ")	
	cRet := strTran(cRet, chr(13), " ")	
  &(cRet)
	
	lRet := RPCIsOpen(acAlias)

return lRet

/*
--------------------------------------------------------------------------------------
Trata a expressão %xEmpresa:alias% existentes em uma comando SQL Embedded
Args: acSQL, string -> comando SQL (select)
      aaEmpComp, array -> lista de empresas/aliases compartilhadas
Ret: lRet -> boolean, indica se abertura esta OK
--------------------------------------------------------------------------------------
*/
static function trataXEmpresa(acSQL, aaEmpComp, acEmpSM0, acFilSM0)
	local cRet := acSQL
	local cErro := ""
	local nPosI := 0, nPosF := 0, cAux
	local cFullPath := ""
	                                            
	default acEmpSM0 := cEmpAnt
	default acFilSM0 := cFilAnt

	cRet := strTran(cRet, "%xFilial:" + DIM_EMPFIL + "%", "'" + acFilSM0 + "'")
	cRet := strTran(cRet, "--", "//")
	while (nPosI := at("%xEmpresa", cRet)) > 0
		cAux := substr(cRet, nPosI+1)
		nPosF := at("%", cAux)
		if nPosF == 0
			cErro := STR0009 + " %xEmpresa% " + STR0010  //"Especificação " //"não esta correto"
			exit
		endif
		cAux := left(cAux, nPosF-1)
		aAux := dwToken(cAux, ":")
		if len(aAux) <> 2
			cErro := STR0009 + " %xEmpresa:Alias% " + STR0010 //"Especificação " //"não esta correto"
			exit
		endif  
		if aAux[2] == DIM_EMPFIL
			aAux[2] := acEmpSM0
		elseif chkFile(aAux[2])
			if xFilial(aAux[2]) == '  ' // filial compartilhada, portanto a empresa pode ser compartilhada
				if ascan(aaEmpComp, { |x| x == aAux[2] }) == 0 // só filiais
					aAux[2] := acEmpSM0
				else // 
					aAux[2] := "@@"
				endif
				
			else
				aAux[2] := acEmpSM0
			endif
		else
			cErro := STR0011 + aAux[2] //"Erro ao tentar abrir "
			exit
		endif
		cRet := left(cRet, nPosI-1) + "'" + aAux[2] + "' " + substr(cRet, nPosI+nPosF+1)
	enddo

	if !empty(cErro)
		cRet := acSQL
    dwLog(STR0012 + " 'embedded SQL' ", cErro, STR0013 + " %xEmpresa%:XXX " + STR0014, cRet)  //"Erro durante pré-processamento " //"Use" //"onde XXX é o alias da tabela"
	endif
	
return cRet

/*
--------------------------------------------------------------------------------------
Abre a tabela via SQL
Args: acAlias, string -> alias da tabela
		acSQL, string -> comando SQL (select)
Ret: lRet -> boolean, indica se abertura esta OK
--------------------------------------------------------------------------------------
*/
static function RPCUseSQL(acAlias, acSQL)
	local lRet

	tcquery (dwStripChr(acSQL)) alias (acAlias) new

	lRet := RPCIsOpen(acAlias)
	if !lRet
		_RPCDWMsgErro := STR0015 + tcSqlError()  //"Erro SQL"
	endif

return lRet

/*
--------------------------------------------------------------------------------------
Abre a tabela via SX
Args: acSXAlias, string -> alias SX da tabela
		acAlias, string -> alias SX da tabela
Ret: lRet -> boolean, indica se abertura esta OK
--------------------------------------------------------------------------------------
*/
static function RPCUseSX(acSXAlias, acAlias)
	local lRet := ChkFile(acSXAlias, .f., acAlias)	

	if !lRet
		_RPCMsgErro := STR0001 + " [ " + acSXAlias + " ]"  //"Não foi possível abrir"
	endif
	
return lRet

/*
--------------------------------------------------------------------------------------
Obtem codigo de erro
Args: 
Ret: nRet -> numerico, codigo de erro
--------------------------------------------------------------------------------------
*/
static function RPCNetErr()

return netErr()

/*
--------------------------------------------------------------------------------------
Obtem a estrutura da tabela
Args: acAlias, string -> tabela a processar
Ret: aRet -> array, estrutura da tabela
--------------------------------------------------------------------------------------
*/
static function RPCDBStruct(acAlias)

return (acAlias)->(DBStruct())

/*
--------------------------------------------------------------------------------------
Fecha a tabela
Args: acAlias, string -> tabela a processar
Ret: lRet -> boolean, ok
--------------------------------------------------------------------------------------
*/
static function RPCDBCloseArea(acAlias)

	(acAlias)->(DBCloseArea())
	
return .t.

/*
--------------------------------------------------------------------------------------
Aplica o filtro
Args: acAlias, string -> tabela a processar
		acFiltro, string -> filtro
Ret: cRet -> string, filtro aplicado
--------------------------------------------------------------------------------------
*/
static function RPCFilter(acAlias, acFiltro)
	local cRet := acFiltro
		
	if valType(acFiltro) == "C"
		(acAlias)->(DBSetFilter(&("{|| "+acFiltro+"}"), acFiltro))
	else
		cRet := (acAlias)->(DBFilter())
	endif 	

return cRet

/*
--------------------------------------------------------------------------------------
Vai para o inicio da tabela
Args: acAlias, string -> tabela a processar
Ret: lRet -> boolean, posicionado
--------------------------------------------------------------------------------------
*/
static function RPCDBGoTop(acAlias)

	(acAlias)->(DBGoTop())

return .t.

/*
--------------------------------------------------------------------------------------
Vai para o final da tabela
Args: acAlias, string -> tabela a processar
Ret: lRet -> boolean, posicionado
--------------------------------------------------------------------------------------
*/
static function RPCDBGoBottom(acAlias)

	(acAlias)->(DBGoBottom())

return .t.

/*
--------------------------------------------------------------------------------------
Total de registros
Args: acAlias, string -> tabela a processar
Ret: nRet -> numerico, total de registros
--------------------------------------------------------------------------------------
*/
static function RPCRecCount(acAlias, acQuery)
	local nRet := -1, qAux
	
	if valType(acQuery) == "C"
		qAux := TQuery():New(DWMakeName("TRA"))
		nRet := qAux:recCount(, acQuery)
	else
		nRet := (acAlias)->(recCount())
	endif

return nRet

/*
--------------------------------------------------------------------------------------
Efetua a carga de buffer
Args: acAlias, string -> tabela a processar
		alNext, boolean -> indica a direção
		anTam, numerico -> tamanho do buffer
Ret: aRet -> array, com os registros 
--------------------------------------------------------------------------------------
*/
static function RPCLoadBuffer(acAlias, alNext, anTam)
	local aRet 		:= {}            
	local aValues  	:= {}
	local nRec 		:= 1
	local nAux 		:= 0 

	aRet := Array(anTam)		

	if alNext
		while !((acAlias)->(eof())) .and. nRec <= anTam
			aRet[nRec] := array((acAlias)->(FCount()))
			aValues := aRet[nRec] 
			aeval(aValues, { |x,i| aValues[i] := (acAlias)->(FieldGet(i))})
			aAdd(aValues, (acAlias)->(recno()))
			(acAlias)->(dbSkip())
			nRec++
		enddo
	else
		while !((acAlias)->(bof())) .and. nRec <= anTam
			(acAlias)->(dbSkip(-1))
		enddo
		nAux := (acAlias)->(recno())
		aRet := RPCLoadBuffer(acAlias, .t., anTam - nRec)
		nRec := len(aRet)
		if (acAlias)->(bof())
		   aSize(aRet, len(aRet)+1)
			aIns(aRet, 1)
			aRet[1] := { nil, nil, 0 }
		endif
   endif                      

	if nRec < anTam
	   aSize(aRet, nRec)
	endif
	if (acAlias)->(eof())
		aAdd(aRet, { nil, nil, -1 } )
	endif 	   
   
return aRet

/*
--------------------------------------------------------------------------------------
Copia a tabela para um arquivo texto
Args: acAlias, string -> tabela a processar
Ret: lRet -> boolean, copia Ok
--------------------------------------------------------------------------------------
*/
static function RPCCopyToSDF(acAlias, acTargetFile, acFieldSep)
	
//	copy to (acFilename) delimited with (acFieldSep)
	acAlias->(__dbDelim( .T., (acFilename), (acFieldSep), { },,,,, .F. ))

return .t.                  

/*
--------------------------------------------------------------------------------------
Seleciona o alias corrente (esta rotina não faz DEVE executar nada, foi criada apenas
para manter a compatibilidade)
Args: acAlias, string -> tabela a processar
Ret: lRet -> boolean, ok
--------------------------------------------------------------------------------------
*/
static function RPCDBSelectArea(acAlias)

return .t.

static function extractPort(acServer)
	local nPos := at(":", acServer)
	local nRet := 0
	
	if nPos != 0
		nRet := dwval(substr(acServer, nPos+1))
	endif  

return nRet

static function extractServer(acServer)
	local nPos := at(":", acServer)
	local cRet := acServer
	
	if nPos != 0
		cRet := left(cRet, nPos-1)
	endif  

return cRet

