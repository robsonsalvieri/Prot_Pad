// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : Tools/Ferramentas
// Fonte  : Limpeza do Datawarehouse
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 21.11.05 |2481-Paulo R Vieira| Novo Layout Fase 3
// 30.12.08 |0548-Alan Candido  | FNC 00000011160/2008 (8.11) e 00000011201/2008 (P10)
//          |                   | Implementação de aviso, quando não foi possível obter 
//          |                   | a lista de tabelas auxiliares
// --------------------------------------------------------------------------------------

#include "dwincs.ch"
#include "hCleanDw.ch"

#define QUERY_TABLE 	"1"
#define QUERY_GRAPH		"2"

/*
--------------------------------------------------------------------------------------
Classe de ferramentas/tools para limpeza do datawarehouse:
	- Compacta DW
	- Exclui dados de dimensão, cubos e querys (Pré-Definidas e de Usuário)
	- Exclui definição de dimensão, cubos e querys (Pré-Definidas e de Usuário)
--------------------------------------------------------------------------------------
*/
class TDWClean from TDWObject
	
	// dimensões a serem excluídos os dados
	data faDimContents
	
	// dimensões a serem excluídas as suas definições
	data faDimDefinitions
	
	// dimensões a serem excluídos os dados
	data faCubContents
	
	// dimensões a serem excluídas as suas definições
	data faCubDefinitions
	
	// consultas a serem excluídas as suas definições
	data faQuery
	
	// construtor
	method New() constructor
	
	// destrutor
	method Free()

	// compacta o DW corrente
	method packDW()
	
	// adiciona uma dimensão para exclusão de sua definição/tabela
	method addDimContents(anDimId)
	
	// exclui a definição das dimensões adicionados através do método addDimContents()
	method deleteDimContents(abFormatDWPack)
	
	// adiciona uma dimensão para exclusão de sua definição/tabela
	method addDimDefinitions(anDimId)
	
	// exclui a definição das dimensões adicionados através do método addDimDefinition()
	method dropDimDefinitions(abFormatDWPack)
	
	// adiciona um cubo para exclusão de seus dados
	method addCubContents(anCubId)
	
	// exclui os dados dos cubos adicionados através do método addCubContents()
	method deleteCubContents(abFormatMsg)
	
	// adiciona um cubo para exclusão de sua definição/tabela
	method addCubDefinitions(anCubId)
	
	// exclui a definição dos cubos adicionados através do método addCubDefinitions()
	method dropCubDefinitions(abFormatMsg)
	
	// exclui a definição de fatos para um cubo
	method dropFact(anCubeID)
	
	// exclui a definição de alerts de um fato
	method dropAlert(anFieldID)
	
	// adiciona uma consulta para exclusão de sua tabela ou gráfico
	method addQueryToClean(anQueryId)
	
	// exclui uma tabela de uma consulta
	method dropTableQuery(acQueryType, abFormatMsg)
	
	// exclui um gráfico de uma consulta
	method dropGraphQuery(acQueryType, abFormatMsg)
	
	// método genérico responsável por exclui uma tabela ou gráfico de uma consulta
	method dropQuery(acQueryType, acDropType, abFormatMsg)
	
	// verifica o impacto nos cubos do dw quando for realizar uma limpeza de uma dimensão
	method checkCubesImpacts(anDimId, abFormatMsg)
	
	// verifica o impacto nas consultas do dw quando for realizada uma limpeza de um cubo
	method checkQuerysImpacts(anCubeId, abFormatMsg)
	
endclass

/*
--------------------------------------------------------------------------------------
Construtor
--------------------------------------------------------------------------------------
*/
method New() class TDWClean
	_Super:New()
	
	::faDimContents		:= {}
	::faDimDefinitions	:= {}
	::faCubContents		:= {}
	::faCubDefinitions	:= {}
	::faQuery	:= {}
	
return

/*
--------------------------------------------------------------------------------------
Destrutor
--------------------------------------------------------------------------------------
*/
method Free() class TDWClean
	_Super:Free()
return

/*
--------------------------------------------------------------------------------------
Método responsável por compactar o DW corrente
Args: abFormatMsg, block code, contendo a formatção/exibição dos textos gerados
	nesse método. Opcional
--------------------------------------------------------------------------------------
*/
method packDW(abFormatMsg, alValidDB) class TDWClean
	Local oTable	:= TTable():New("pack")
	Local aAux 		:= DWTableList(), nInd
	Local aParms 	:= {}, nDel
	Local cbAux 	:= { |x| oSigaDW:Log(x), iif (valType(abFormatMsg) == "B", eval(abFormatMsg, x), NIL) }

  default alValidDB := .f.
  	
	//Compactando
	eval(cbAux, STR0001 + " [ " + DwStr(oSigaDW:DWCurr()[1]) + " - " + oSigaDW:DWCurr()[2] + " ]") //###"Compactando o DW"
	
	for nInd := 1 to len(aAux)
		eval(cbAux, ". " + STR0002 + " " + aAux[nInd]) //###"tabela"
		oTable:pack(aAux[nInd])
	next

  	// valida os dados do SigaDW, procurando por registros "orfãos" e se localizados, elimina-os
	if alValidDB
 	eval(cbAux, STR0003 + " [ " + DwStr(oSigaDW:DWCurr()[1]) + " - " + oSigaDW:DWCurr()[2] + " ]") //###"Validando o DW"
    
    for nInd := 1 to len(aAux)
		oTable := initTable(aAux[nInd])
      	nDel := 0
	    if oTable:validParents(@nDel) // se true é pq não havia orfãos
		    eval(cbAux, ". " + STR0002 + " " + oTable:Descricao() + "(" + aAux[nInd] + ")") //###"tabela"
		    conout("-- " + oTable:Descricao() + "(" + aAux[nInd] + ")")           
      	else  
		    eval(cbAux, ". " + STR0002 + " " + oTable:Descricao() + "(" + aAux[nInd] + ") - " + dwStr(@nDel) + " " + STR0004) //###"tabela"###"orfãos excluídos"
		    conout("-- " + oTable:Descricao() + "(" + aAux[nInd] + ")")
	    endif
	  next
	endif
	
	aAdd(aParms, 1)
	aAdd(aParms, DWTopServer())
	aAdd(aParms, "TCPIP")
	aAdd(aParms, DWTopDB())
	aAdd(aParms, DWTopAlias())
	aAdd(aParms, "")
	
	aAux := DWWaitJob(JOB_BASETOP, aParms)
	if !(valType(aAux) == "A")
	  aAux := {}
		eval(cbAux, "</p><b>" + STR0018 /*"AVISO:"*/ + " </b> " + STR0019 /*"Não foi possível obter a lista de tabelas auxiliares."*/) 
	endif
	
	if ascan(aAux, { |x| left(aAux[nInd, 2],3) $ "TRA|XX_" .or. right(aAux[nInd, 2],4) == "_BKP"}) > 0
		eval(cbAux, "</p><b>" + STR0005 + "</b>") //###"Eliminando tabelas auxiliares"
		for nInd := 1 to len(aAux)
			if left(aAux[nInd, 2],3) $ "TRA|XX_" .or. right(aAux[nInd, 2],4) == "_BKP"
				eval(cbAux, ". " + STR0002 + " " + aAux[nInd, 2]) //###"tabela"
				TCDelFile(aAux[nInd, 2])
			endif
		next
	endif
	
	eval(cbAux, "</p><b>" + STR0006 + "</b>") //###"Atualizando estatisticas"
	for nInd := 1 to len(aAux)
		if !(left(aAux[nInd, 2],3) $ "TRA|XX_" .or. right(aAux[nInd, 2], 4) == "_BKP")
		  if tcCanOpen(aAux[nInd, 2])
			  eval(cbAux, ". " + STR0002 + " " + aAux[nInd, 2]) //###"tabela"
			  oTable:updStat(aAux[nInd, 2])
		  endif
		endif
	next
	
return

/*
--------------------------------------------------------------------------------------
Método responsável por adicionar uma dimensão para exclusão de sua definição/tabela
Args: anDimId, numérico, contem o id da dimensão
--------------------------------------------------------------------------------------
*/
method addDimContents(anDimId) class TDWClean
	aAdd(::faDimContents, anDimId)
return

/*
--------------------------------------------------------------------------------------
Método responsável por excluir a definição das dimensões adicionados através do método
addDimContents()
Args: abFormatMsg, block code, contendo a formatção/exibição dos textos gerados
	nesse método. Opcional
--------------------------------------------------------------------------------------
*/
method deleteDimContents(abFormatMsg) class TDWClean
	Local cAux, oTable
	Local cbAux 		:= { |x| oSigaDW:Log(x), iif (valType(abFormatMsg) == "B", eval(abFormatMsg, x), NIL) }
	Local nInd
	Local oDimensao 	:= InitTable(TAB_DIMENSAO)
	
	oDimensao:Seek(2, { "" })
	while !oDimensao:EOF()
		for nInd := 1 to len(::faDimContents)
			if oDimensao:value("id") == ::faDimContents[nInd]  
				if tcCanOpen(DWDimName(oDimensao:value("id")))
					oTable := TTable():New(DWDimName(oDimensao:value("id")),oDimensao:value("nome",.t.) )
					eval(cbAux, STR0007 + " [ " + oDimensao:value("nome",.t.) + " ]") //###"Eliminando dados da dimensão"
					oTable:Zap()
				endif
			endif
		next
		
		oDimensao:_Next()
	enddo
	
return

/*
--------------------------------------------------------------------------------------
Método responsável por adicionar uma dimensão para exclusão de sua definição/tabela
Args: anDimId, numérico, contem o id da dimensão
--------------------------------------------------------------------------------------
*/
method addDimDefinitions(anDimId) class TDWClean
	aAdd(::faDimDefinitions, anDimId)
return

/*
--------------------------------------------------------------------------------------
Método responsável por excluir a definição das dimensões adicionados através do método
addDimDefinitions()
Args: abFormatMsg, block code, contendo a formatção/exibição dos textos gerados
	nesse método. Opcional
--------------------------------------------------------------------------------------
*/
method dropDimDefinitions(abFormatMsg) class TDWClean
	Local cAux, oTable
	Local nInd
	Local cbAux 		:= { |x| oSigaDW:Log(x), iif (valType(abFormatMsg) == "B", eval(abFormatMsg, x), NIL) }
	Local oDimensao 	:= InitTable(TAB_DIMENSAO)
	Local oDimFields	:= InitTable(TAB_DIM_FIELDS)
	
	oDimensao:Seek(2, { "" })
	while !oDimensao:EOF()
		for nInd := 1 to len(::faDimDefinitions)
			if oDimensao:value("id") == ::faDimDefinitions[nInd]
				oTable := TTable():New(DWDimName(oDimensao:value("id")), )
				eval(cbAux, STR0008 + " [ " + oDimensao:value("nome",.t.) + " ]") //###"Eliminando definição da dimensão"
				if oDimFields:Seek(2 , { oDimensao:value("id") })
					while !oDimFields:eof() .and. oDimFields:value("ID_DIM") == oDimensao:value("id")
						oDimFields:Delete()
						oDimFields:_Next()
				   enddo
			   endif             
				oTable:DropTable()
				oDimensao:Delete()
			endif
		next
		
		oDimensao:_Next()
	enddo
	
return

/*
--------------------------------------------------------------------------------------
Método responsável por adicionar um cubo para exclusão de seus dados
Args: anCubId, numérico, contem o id do cubo
--------------------------------------------------------------------------------------
*/
method addCubContents(anCubId) class TDWClean
	aAdd(::faCubContents, anCubId)
return

/*
--------------------------------------------------------------------------------------
Método responsável por excluir os dados dos cubos adicionados através do método
addCubContents()
Args: abFormatMsg, block code, contendo a formatção/exibição dos textos gerados
	nesse método. Opcional
--------------------------------------------------------------------------------------
*/
method deleteCubContents(abFormatMsg) class TDWClean
	Local oTable
	Local nInd
	Local oCubes
	Local cbAux := { |x| oSigaDW:Log(x), iif (valType(abFormatMsg) == "B", eval(abFormatMsg, x), NIL) }
	
	oCubes := oSigaDW:Cubes():CubeList()
	oCubes:Seek(2, { "" })
	while !oCubes:EOF()
		for nInd := 1 to len(::faCubContents)
			if oCubes:value("id") == ::faCubContents[nInd]
				if tcCanOpen(DWCubeName(oCubes:value("id")))
					oTable := TTable():New(DWCubeName(oCubes:value("id")), oCubes:value("nome",.t.) )
					eval(cbAux, STR0009 + " [ " + oCubes:value("nome",.t.) + " ]") //###"Eliminando dados do cubo"
					oTable:Zap()
				endif
			endif
		next
		
		oCubes:_Next()
	enddo

return

/*
--------------------------------------------------------------------------------------
Método responsável por adicionar um cubo para exclusão de sua definição/tabela
Args: anCubId, numérico, contem o id do cubo
--------------------------------------------------------------------------------------
*/
method addCubDefinitions(anCubId) class TDWClean
	aAdd(::faCubDefinitions, anCubId)
return

/*
--------------------------------------------------------------------------------------
Método responsável por excluir a definição dos cubos adicionados através do método
addCubDefinitions()
Args: abFormatMsg, block code, contendo a formatção/exibição dos textos gerados
	nesse método. Opcional
--------------------------------------------------------------------------------------
*/
method dropCubDefinitions(abFormatMsg) class TDWClean
	Local cAux, oTable
	Local cbAux := { |x| oSigaDW:Log(x), iif (valType(abFormatMsg) == "B", eval(abFormatMsg, x), NIL) }
	Local oCubes
	Local nInd

	oCubes := oSigaDW:Cubes():CubeList()
	oCubes:Seek(2, { "" })
	while !oCubes:EOF()
		for nInd := 1 to len(::faCubDefinitions)
			if oCubes:value("id") == ::faCubDefinitions[nInd]
				oTable := TTable():New(DWCubeName(oCubes:value("id")), oCubes:value("nome",.t.) )
				eval(cbAux, STR0010 + " [ " + oCubes:value("nome",.t.) + " ]") //###"Eliminando definição do cubo"
				::dropFact(oCubes:value("id"))
				oTable:DropTable()
				oCubes:Delete()
			endif
		next
		
		oCubes:_Next()
	enddo
	
return

/*
--------------------------------------------------------------------------------------
Método responsável por excluir a definição de fatos para um cubo
Args: anCubeID, númerico, contendo o Id do cubo
--------------------------------------------------------------------------------------
*/
method dropFact(anCubeID) class TDWClean
   local oFactFields := InitTable(TAB_FACTFIELDS)

	if oFactFields:Seek(2, { anCubeID })
		while !oFactFields:eof() .and. oFactFields:value("ID_CUBES") == anCubeID
			::dropAlert(oFactFields:value("id"))
			oFactFields:Delete()
			oFactFields:_Next()
		enddo
	endif

return

/*
--------------------------------------------------------------------------------------
Método responsável por excluir a definição de alerts de um fato
Args: anFieldID, númerico, contendo o Id do cubo
--------------------------------------------------------------------------------------
*/
method dropAlert(anFieldID) class TDWClean
   local oAlert := InitTable(TAB_ALERT)

	if oAlert:Seek(2, { anFieldID })
		while !oAlert:eof() .and. oAlert:value("ID_FACTFLD") == anFieldID
			oAlert:Delete()
			oAlert:_Next()
		enddo
	endif

return

/*
--------------------------------------------------------------------------------------
Método responsável por adicionar uma consulta para exclusão de sua tabela ou gráfico
Args: anQueryId, numérico, contém o id da consulta
--------------------------------------------------------------------------------------
*/
method addQueryToClean(anQueryId) class TDWClean
	aAdd(::faQuery, anQueryId)
return

/*
--------------------------------------------------------------------------------------
Método responsável por excluir todas as tabelas de uma consulta
Args: acQueryType, string, contém o tipo da consulta
		abFormatMsg, block code, contendo a formatção/exibição dos textos gerados
			nesse método.Opcional
--------------------------------------------------------------------------------------
*/
method dropTableQuery(acQueryType, abFormatMsg) class TDWClean
	::dropQuery(acQueryType, QUERY_TABLE, abFormatMsg)
return

/*
--------------------------------------------------------------------------------------
Método responsável por excluir todos os gráficos de uma consulta
Args: acQueryType, string, contém o tipo da consulta
		abFormatMsg, block code, contendo a formatção/exibição dos textos gerados
			nesse método.Opcional
--------------------------------------------------------------------------------------
*/
method dropGraphQuery(acQueryType, abFormatMsg) class TDWClean
	::dropQuery(acQueryType, QUERY_GRAPH, abFormatMsg)
return

/*
--------------------------------------------------------------------------------------
Método responsável por excluir uma tabela ou gráfico de uma consulta
Args: acQueryType, string, contém o tipo da consulta
		acDropType, string, contém o tipo de drop a ser executado
		abFormatMsg, block code, contendo a formatção/exibição dos textos gerados
			nesse método.Opcional
--------------------------------------------------------------------------------------
*/
method dropQuery(acQueryType, acDropType, abFormatMsg) class TDWClean
	Local oConsulta := InitTable(TAB_CONSULTAS)
	Local oConsType := InitTable(TAB_CONSTYPE)
	Local oConsDim 	:= InitTable(TAB_CONS_DIM)
	Local oConsInd	:= InitTable(TAB_CONS_IND)
	Local oConsWhe  := InitTable(TAB_CONS_WHE)
	Local oWhereCond:= InitTable(TAB_WHERE_COND)
	Local oConsAlert:= InitTable(TAB_CONS_ALM)
	Local oConsProp := InitTable(TAB_CONS_PROP)
	Local cbAux 	:= { |x| oSigaDW:Log(x), iif (valType(abFormatMsg) == "B", eval(abFormatMsg, x), NIL) }
	Local nInd
	Local cWorkfile
	Local nID
	
	for nInd := 1 to len(::faQuery)
		// exclui um tipo (tabela ou gráfico) de uma consulta
		if oConsType:Seek(2, { ::faQuery[nInd], acDropType })
			
			// realiza a pesquisa da consulta para recuperar o nome da consulta
			oConsulta:Seek(1, { ::faQuery[nInd] })
			if oConsulta:Eof() .OR. !(oConsulta:value("id") == ::faQuery[nInd])
				exit
			endif
			
			eval(cbAux, STR0011 + " " + iif(acDropType = QUERY_TABLE, STR0012, STR0013) + " [ " + oConsulta:value("nome") + " ]") //###"Eliminando"###"TABELA"###"GRAFICO"
			oConsType:Delete()
			
			nID := oConsType:value("id")
			if oConsInd:Seek(2, { nID } )
				while !oConsInd:eof() .and. oConsInd:value("id_cons") == nID
					oConsInd:delete()			
					oConsInd:_Next()
				enddo
			endif
	
			if oConsDim:Seek(2, { nID } )
				while !oConsDim:eof() .and. oConsDim:value("id_cons") == nID
					oConsDim:delete()			
					oConsDim:_Next()
				enddo
			endif

			if oConsWhe:Seek(2, { nID } )
				while !oConsWhe:eof() .and. oConsWhe:value("id_cons") == nID
					if oWhereCond:Seek(2, { oConsWhe:value("id") })
						while !oWhereCond:eof() .and. oWhereCond:value("id_where") == nID
							oWhereCond:delete()			
							oWhereCond:_Next()
						enddo
					endif
					oConsWhe:delete()			
					oConsWhe:_Next()
				enddo
			endif
	
			if oConsAlert:Seek(2, { nID } )
				while !oConsAlert:eof() .and. oConsAlert:value("id_cons") == nID
					oConsAlert:delete()			
					oConsAlert:_Next()
				enddo
			endif
	
			if oConsProp:Seek(2, { nID } )
				while !oConsProp:eof() .and. oConsProp:value("id_cons") == nID
					oConsProp:delete()			
					oConsProp:_Next()
				enddo
			endif
			
			cWorkfile := DWSumName(::faQuery[nInd], iif(acDropType = QUERY_TABLE, "S", "G"))
			if tcCanOpen(cWorkfile)
			   if TCDelFile(cWorkfile)
					eval(cbAux, STR0014 + " [ " + cWorkfile + "]") //###"Eliminado o arquivo"
				else
				 	//"Não foi possivel eliminar o arquivo [ @X ]. Verifique log do <i>TopConnect</i>"
					eval(cbAux, DWFormat(STR0015 + " [XXXXXXXXXXXXXXX]. " + STR0016, { cWorkfile }) ) //###"Não foi possivel eliminar o arquivo"###"Verifique log do <i>TopConnect</i>"
			   endif
			endif
			
			if !oConsType:Seek(2, { ::faQuery[nInd], QUERY_TABLE }) .AND. ;
			   !oConsType:Seek(2, { ::faQuery[nInd], QUERY_GRAPH })
				eval(cbAux, STR0017 + " [ " + oConsulta:value("nome") + " ]") //###"Eliminando DEFINIÇÃO consulta"
				oConsulta:Delete()
			endif
			
		endif
	next
	
	// reset a variável utilizada na limpeza da consulta
	::faQuery := {}
 	
return 

/*
--------------------------------------------------------------------------------------
Método para verificar o impacto nos cubos do dw quando for realizar uma limpeza de uma dimensão 
Args: anDimId, númerico, contém o id da dimensão
		abFormatMsg, block code, contendo a formatção/exibição dos textos gerados
			nesse método.Opcional
--------------------------------------------------------------------------------------
*/
method checkCubesImpacts(anDimId, abFormatMsg) class TDWClean
   Local oDimCubes := InitTable(TAB_DIM_CUBES)
   Local oCubes	   := InitTable(TAB_CUBESLIST)
   
	oDimCubes:seek(3 , { anDimId })

	while !oDimCubes:eof() .and. oDimCubes:value("id_dim") == anDimId
		if oCubes:Seek(1, { oDimCubes:value("id_cube") })	
			if valType(abFormatMsg) == "B"
				eval(abFormatMsg, oCubes:value("nome", .t.))
			endif
		endif
		oDimCubes:_Next()
	enddo

return

/*
--------------------------------------------------------------------------------------
Método para verificar o impacto nas consultas do dw quando for realizada uma limpeza de um cubo
Args: anCubeId, númerico, contém o id do cubo
		abFormatMsg, block code, contendo a formatção/exibição dos textos gerados
			nesse método.Opcional
--------------------------------------------------------------------------------------
*/
method checkQuerysImpacts(anCubeId, abFormatMsg) class TDWClean
	Local oConsulta := InitTable(TAB_CONSULTAS)
	
	oConsulta:seek(9, { anCubeId })

	while !oConsulta:eof() .and. oConsulta:value("id_cube") == anCubeId
		eval(abFormatMsg, oConsulta:value("nome", .t.))
		oConsulta:_Next()
	enddo
	
return