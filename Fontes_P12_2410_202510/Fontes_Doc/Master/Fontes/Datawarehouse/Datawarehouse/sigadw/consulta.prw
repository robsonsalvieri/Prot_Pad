// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : SigaDW
// Fonte  : Consuta - Objeto TConsulta, contem definição da consulta
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 01.06.01 | 0548-Alan Candido |
// 12.01.06 | 0548-Alan Candido | Versão 3
// 03.10.07 | 0548-Alan Candido | BOPS 133608 - Aplicação de rank e filtro, onde o campo do filtro
//          |                   |   não faz parte da consulta
// 12.11.07 | 0548-Alan Candido | BOPS 135941 - Em determinadas circunstâncias, ocorre erro na sumarização
//          |                   |   (buildTable) em SGDB "DB2". Error : -803 - [IBM][CLI Driver][DB2/NT] SQL0803N  One or more ...
//          |                   |   - Implementado tratamento em DDFilter, para corrigir a exportação
//          |                   |   quando há DD e é aberto um nivel abaixo do nível inicial
//          |                   |   - Otimização na montagem da query para exportação de dados, 
//          |                   |   quando há DD e é aberto um nivel abaixo do nível inicial
// 23.11.07 | 0548-Alan Candido | BOPS 136453 - Implementado parametro para não usar cache na salva (doSave)
// 20.02.08 | 0548-Alan Candido | BOPS 140966 - Implementação do método getPage, para melhorar e 
//          |                   |   corrir a páginação de consulta XY
// 27.02.08 | 0548-Alan Candido | BOPS 141545 - Ajuste no processo de DD, para abri-lo abaixo da linha pai
// 06.03.08 | 0548-Alan Candido | BOPS 141436 - Correção na paginação e exportação de DD
// 18.03.08 | 0548-Alan Candido | BOPS 142638 - Adequação de código, para correção da exportação e DD *all*.
// 02.04.08 | 0548-Alan Candido | BOPS 143285 - Correção na paginação e abertura de DD
//          |                   | Nota: Atualizar o site   
// 10.04.08 | 0548-Alan Candido | BOPS 142154
//          |                   | Implementação do processamento da macro @dwref
// 17.04.08 |0548-Alan Cândido  | BOPS 1444476 - em bases de dados Oracle, DB2 ou Informix,
//          |                   | quando a consulta tem filtro com "prompt", ocorria um 
//          |                   | erro de acesso a array, durante o processo de sumarização
// 05.05.08 |0548-Alan Cândido  | BOPS 145242 - correção de DD "all" ao abrir todos os niveis e 
//          |                   | fechar algum nivel anterior
// 06.05.08 |0548-Alan Cândido  | BOPS 144768 - melhoria no processamento de prepareSql(), para
//          |                   | tratar descrições curtas
// 15.05.08 |0548-Alan Cândido  | BOPS 145724 - 
//          |                   | Ao utilizar participação com apenas um atributo no eixo X, 
//          |                   | ao ser executado o método getPage pela 1a vezocorria um erro ao entrar na consulta 
// 16.05.08 |0548-Alan Cândido  | BOPS 145995
//          |                   | Implementação do métodod clearDrillHist()
//          |                   | Exportação de consultas com DD, quando acionado "drill all"
// 26.05.08 |0548-Alan Cândido  | BOPS 146229
//          |                   | Ajuste no procedimento de "parser" de expressões SQL
//          |                   | Pequenas otimizações na montagem da query
//          |                   | Eliminação de código obsoleto
// 29.05.08 |0548-Alan Cândido  | BOPS 146059
//          |                   | Implementação dos métodos RankSubTotal() e RankTotal()
// 02.06.08 | 0548-Alan Candido | BOPS 146687
//          |                   | Correção nos procedimentos de aplicação de alertas
// 03.06.08 | 0548-Alan Candido | BOPS 146750
//          |                   | Correção no processamento de indicadores acumulados,
//          |                   | quando há filtros selecionados e aplicados
// 11.06.08 | 0548-Alan Candido | BOPS 147407
//          |                   | Ajuste na aplicação de filtros de seleção
// 26.06.08 | 0548-Alan Candido | BOPS 148647
//          |                   | Implementação de métodos e procedimentos, para efetuar o "cache" de 
//          |                   | informações de apoio a execução da consulta, de forma a melhorar
//          |                   | performance.
//          |                   | Ajuste na salva da consulta para quando for selecionado um indicador
//          |                   | para que faça parte de uma expressão de campo virtual, anteriormente
//          |                   | selecionado, seja salvo corretamente.
// 04.07.08 | 0548-Alan Candido | BOPS 149331
//          |                   | Ajustes no procedimento de "lock/unlock" nos procedimentos
//          |                   | de carga, salva e gerenciamento de cache.
// 14.07.08 | 0548-Alan Candido | BOPS 149353
//          |                   | Ajustes na apuração de "Total Outros" (rank)
//          |                   | Implementação de método para apuração "Total Global"
//          |                   | Eliminação de código obsoleto
// 05.08.08 |0548-Alan Cândido  | BOPS 151288
//          |                   | Ajuste na paginação de rank e no processamento da query, pois em algumas
//          |                   | situações, poderia ocorrer erro de SQL.
// 12.08.08 |0548-Alan Cândido  | BOPS 146580 (habilitado pelo define DWCACHE)
//          |                   | Implementação de novo sistema de leitura da consulta (uso de cache).
// 09.12.08 | 0548-Alan Candido | FNC 00000149278/811 (8.11) e 00000149278/912 (9.12)
//          |                   | Implementação da nova funcionalidade "ranking por nível de drill-down"
//          |                   | . Implementação de métodos e propriedades
//          |                   |   rankDef(), rankStyle(), updDDSql()
//          |                   | . Adequação de métodos
//          |                   |   haveRank(), sqlRank(), makeSQL()
//          |                   | . Eliminação de métodos obsoletos
//          |                   |    sqlTotal2(), ranking()
// 17.12.08 | 0548-Alan Candido | FNC 00000010314/2008 (8.11) e 00000010370/2008 (9.12)
//          |                   | Correção na seleção de registros para ranking, quando SGDB é DB2,
//          |                   | que passa a usar a função "truncate"
// -------------------------------------------------------------------------------------- 

#include "dwincs.ch"
#include "consulta.ch"
#include "consult1.ch"
#include "biiso.ch"
#include "dwIdProcs.ch"
#include "dwViewDataConst.ch"

#define SEP_DATA        chr(255)
#define SEL_DD "!"
#define NOT_EXIST_DD     -1

#define ID_BASE_SIZE     11
#define ID_SQL_BASE       1
#define ID_KEY_LIST       2
#define ID_FILTER         3
#define ID_KEY_Y          4
#define ID_FILTER_HIST    5
#define ID_UNION          6
#define ID_RANK_LIMIT     7
#define ID_SQL_RANK       8
#define ID_RANK_SIG       9
#define ID_HAVING        10
#define ID_CURVAABC      11

#ifdef DWCACHE
#else
	#define CACHE_IDENTIFIER ("QRY_" + ::Workfile())
#endif

/*
--------------------------------------------------------------------------------------
Classe: TConsulta
Uso   : Contem definição e acesso a consulta
--------------------------------------------------------------------------------------
*/
class TConsulta from TDWObject
	data foLockCtrl
	data faIntFrom
	data faAllFields
	data flEof
	data faKeyValues
	data faDDFilter 
	data flIgnDDFilter
	data flHaveMedInt
	data flHaveAcum    
	data flHaveHistAcum
	data faDrillParms
	data flZeraAcum
 	data fnDrillOrig
	data fcIPC
	data fnPanWidth
	data faAttWidth
	data faIndWidth
	data fdInicio
	data fcInicio
	data fnTotProcs
	data fnPageExp
	data fnTempoEst
	data fnCubeID
	data faCRWParams
	data faHideAtt
	data fnPageSize
	data faDrillHist
	data faCurvaABC
	data fcAutoFilter
	
	#ifdef DWCACHE
	 	data faTotGeral
	 	data faTotGlobal
	 	data faHeaderX
	#else
		data flUpdCache 
	#endif
 	
 	data flExporting
 	data flUserExp
 	data fnMinValue
 	data fnMaxValue 
 	data fnDoctoId
  	data faRankDef
  	
	method New(anConsultaID, anType, alCache) constructor
	method Free()
	method NewConsulta(anConsultaID, anType, alCache)
	method FreeConsulta()
	               
	method AddCube(axValue)
	method AddIndicador(anOper, anID, anOrdem, acColor, acLevel)
	method VerIndicador()
	method VerRefValues()
	method AddDimFields(acEixo, axID, anTemporal, acAlias, alSubTotal)
	method AddWhere(anID)
	method AddSegto(anID)                     
	method AddWhere2(acCampo, acOper, acValor)
	method AddAlert(anID)
	
	method DoLoad()
	method DoSave(acName, alConfirm, alCache)
	method loadFilters()
  	method Cube()	
	method HaveCube()
	method HaveFilter()
	method HaveAlert()
	method HaveRank(anLevel)
	method ID(anValue, anType, alLoad, alCache)
	method _Type(anType)
	method relationID(anValue)
	method Desc(acValue)	
	method Name(acValue)
	method Document()
	method IsPublic(acValue)
	method AccessType(acValue)
	method IDUser(acValue)
	method UserName(acValue)
	method Exists(acType, anIDUser, acName)
	method GraphClass(acValue)
	method GraphProps(acValue)
	method GraphYProps(acValue)
	method GraphY2Props(acValue)
	method HaveTable()	
	method HaveGraph()	
	method Indicadores(alAll)
	method IndList()
	method Dimensao()
	method DimFields()
	method DimFieldsX(alAll)
	method DimCountX(alAll)
	method DimFieldsY(alAll)
	method DimCountY(alAll)
	method DrillDown()
	method HaveDrillDown() 
	method IndFields(alAlias)
	method OtherFields(alAlias, aaRet, alStruc, alAdvpl)
	method IndVirtual(alAlias, alOnlyName)
	method rankDef(anNivel, anID, anValue, acType)
	method CurvaABC(axValues)
	method AutoFilter(acValue)
	method prepAutoFilter(aaFilter, acRnkPrefix, alQbe2Html)
	method RankField(alName, alOrder)
	method Fields(alAll)
	method FieldList(alUseAlias, alStruct)
	method FieldListY(alUseAlias)
	method FromList()
	method GroupBy(anLevel)
	method GroupByY(anLevel)
	method GroupByX(anLevel)
	method OrderBy()
	method FieldsCalc()
	method LinkList()
	method WhereList(alAll, alHist)
	method HavingList(alAll)
	method AdvPlList()
	method Where(alAll, alDrill)
	method Segto()
	method Alerts(alAll)
	method FieldByID(anID, alInd)
	method AddIntFrom(acValue)
	method BuildTable()
	method SQLSelect(lOnlyStruc) 
	method SQLLink() 
	method SQLObject(lOnlyStruc, anLevel, alLink) 
	method SQLTotal(anLevel, aaWhere, acSelect, anLevelX)
	method SQLAcum(acWhere, acKeyCount)
	method SQLAcumHist(acWhere, acKeyCount)
	method SQLTotPareto()
	method SQLRank(aaRankLink, acRecLimit, alTotal, aaWhere, anDDLevel)
	method BuildRank()
	method BuildPareto()
	method SQLRnkTotOut()
	method SQLTotGlobal()
	method getTable(alIndex, alView)
	method getSQL()
	method Filtered(alValue)
	method Total(alValue)
	method AlertOn(alValue)
	method HintOn(alValue)
	method RankOn(alValue)
	method RankOutros(alValue)
	method RankSubTotal(alValue)
	method RankTotal(alValue)
	method RankStyle(acValue)
	method IgnoreZero(alValue)
	method UseExcel(alValue)
	method WaitBuild(AVerifyOnly) 
	method Workfile(anType)
	method Viewname(anType)
	method TableMedInt() 
	method ResetWorkfile(alAll)
	method AddParam(acName, acValue)
	method Params()
	method PrepDrill(anType, alSave)
	method ApplyAlerts(aaRecord)
	method IsValid()
	method IsWrong()
	method Validate()
	method Invalidate()
	method FatorEscala(anValue)
	method PrepField(aaFieldList, aoField, acOper, anSeq, alStruct, alForProc)
	method IndSobrePosto(alValue)
	method FillAll(alValue) /*Preenche todas as células da consulta tabela com valores*/
	method EmptyCell(alValue)
	method readAxisX(aaData, anLevel, alHeader, alNoTotal, alUseCache)
	method DrillLevel()
	method DrillParms(anLevel, acKeys, alDDHist, alDDExclude)
	method updDDSql(anLevel, acKeys, acSQL)
	method Close()
	method HtmlHeader(alNoTotal, anType) 
	method HtmlFooter()
	method FilterForUse(alInd, alHist)
	method BuildIsNeed(aoOldCons)
	method PrepVirtual(aoDS)
	method PrepareSQL(acSQL, alAlias, acPrefixo, aaAllFields)
	method getAllFields()
	method ProcMacroAt(acMacro, alStruct)
	method ProcMacro(acMacro)
	method haveMacroAt(pcFieldName, acMacro, pnTemporal) 
	method StructBase(anLevel, aaWhere, alTotal, anLevelX, alHist, alDDHist)
	method getPage(acPage, aoDS, alProcDD)
	method GetDSForExport()
	method GetDS(acPage, alProcDD)
	method FirstPage(alProcDD)
	method PriorPage(alProcDD)
	method NextPage(aoDS, alProcDD)
	method LastPage(alProcDD)
	method DDFilter(aaFilter) 
	method procPage(aoQuery, aaDados, aaKeyList, aaKeys, acPage)
	method procAcum(aoQuery, aaDados, aaKeyList, aaKeys, acPage)
	method haveMedInt()
	method haveAcum()
	method haveAcumHist()
	method makeSQL(aaSQLBase, acPage, aaKeys, acOrder, acWhere, alCount, acSelect, alTotal, anLevelX, anLevel) 
	method recCount()
 	method haveaggfunc(acExp)
 	method ZeraAcum(alValue)
 	method DrillOrig(anValue)
 	method ipcNotify(acMsg, alInfo)
 	method ipcExpNotify()
 	method ipc(acIPC)
 	method PanWidth(anValue)
	method AttWidth(aaValues)
	method IndWidth(aaValues)
	method CubeID()
	method CRWName(acValue)
	method CRWDesc(acValue)
	method CRWURL(acValue)
	method CRWParams(aaValues)

	#ifdef DWCACHE
	#else
		method UpdFromCache(aaProps)
		method UpdCache()
		method UpdCacheRuntime(aaQueryInCache)
		method ClearCache(alSession)
		method inCache()

		method setCacheInfo(acInfoID, axValue)
		method getCacheInfo(acInfoID)
		method delCacheInfo(acInfoID)
		method inCacheInfo(acInfoID)
	#endif	
	
	method updFromPost()
	method updFromGet()
	method hideAtt(acAlias)
	method isAttVisible(acAlias)
	method ShowAllAtt()
	method pageSize(anSize)
	method KeyValues(aaSize)
	method SaveCacheArq()
	method caseCurvaABC(alTotal)
	method RecupCacheArq()
	method haveNext()
	method havePrevious()
 	method endExp(aoMakeExp)
 	method canUserExp()
 	method DrillHist()
 	method clearDrillHist()
	
  	method lock()
  	method unlock()

	Method checkLast(aoQuery, acSelect, acWhere, aaKeyList)  	
endclass
			
/*
--------------------------------------------------------------------------------------
Construtor e destrutor da classe
Args: 
--------------------------------------------------------------------------------------
*/
method New(anConsultaID, anType, alCache) class TConsulta
	::NewConsulta(anConsultaID, anType, alCache)
return
			
method Free() class TConsulta
	::FreeConsulta()
return
			
method NewConsulta(anConsultaID, anType, alCache) class TConsulta
	::NewObject(,ID_SIZE)
	::ID(anConsultaID, anType,,alCache)
	::fnPageSize := PAGE_SIZE
	::flIgnDDFilter := .f.

	#ifdef DWCACHE
	#else
		::flUpdCache := .t.
	#endif	
	
	::flExporting := .f.
return
			
method FreeConsulta() class TConsulta
	::FreeObject()
return
			
/*
--------------------------------------------------------------------------------------
Propriedade ID
--------------------------------------------------------------------------------------
*/
method ID(anValue, anType, alLoad, alCache) class TConsulta
	local nRet := ::Props(ID_ID, anValue)

	default alLoad := .t.
	
	::_Type(anType)

	if valType(anValue) == "N"
		if alLoad
			::doLoad(alCache)
		endif
	endif
return nRet

/*
--------------------------------------------------------------------------------------
Propriedade Type
--------------------------------------------------------------------------------------
*/
method _Type(anValue) class TConsulta
return ::Props(ID_TYPE, anValue)

/*
--------------------------------------------------------------------------------------
Propriedade relationID
--------------------------------------------------------------------------------------
*/
method relationID(anValue) class TConsulta
return ::Props(ID_RELATIONID, anValue)

/*
--------------------------------------------------------------------------------------
Propriedade Desc
--------------------------------------------------------------------------------------
*/
method Desc(acValue) class TConsulta
return ::Props(ID_DESC, acValue)
			
/*
--------------------------------------------------------------------------------------
Propriedade Name
--------------------------------------------------------------------------------------
*/
method Name(acValue) class TConsulta
return ::Props(ID_NAME, acValue)
  
/*
--------------------------------------------------------------------------------------
Propriedade Document
--------------------------------------------------------------------------------------
*/
method Document() class TConsulta
return ::fnDoctoId

/*
--------------------------------------------------------------------------------------
Propriedade IsPublic
--------------------------------------------------------------------------------------
*/
method IsPublic(acValue) class TConsulta
return ::Props(ID_ISPUBLIC, acValue)

/*
--------------------------------------------------------------------------------------
Propriedade AccessType
--------------------------------------------------------------------------------------
*/
method AccessType(acValue) class TConsulta
return ::Props(ID_ACCESSTYPE, acValue)

/*
--------------------------------------------------------------------------------------
Propriedade IDUser
--------------------------------------------------------------------------------------
*/
method IDUser(acValue) class TConsulta
return ::Props(ID_IDUSER, acValue)

/*
--------------------------------------------------------------------------------------
Propriedade UserName
--------------------------------------------------------------------------------------
*/
method UserName(acValue) class TConsulta
return ::Props(ID_USERNAME, acValue)

/*
--------------------------------------------------------------------------------------
Metodo Exists() - Booleano - retorna se a consulta com o nome acName ja existe
--------------------------------------------------------------------------------------
*/
method Exists(acType, anIDUser, acName) class TConsulta
	local oConsulta  := InitTable(TAB_CONSULTAS)
return oConsulta:seek( 8, { acType, anIDUser, acName }, .f. )

/*
--------------------------------------------------------------------------------------
Propriedade ZeraAcum
--------------------------------------------------------------------------------------
*/
method ZeraAcum(alValue) class TConsulta
	property ::flZeraAcum := alValue
return ::flZeraAcum

/*
--------------------------------------------------------------------------------------
Propriedade DrillOrig
--------------------------------------------------------------------------------------
*/
method DrillOrig(anValue) class TConsulta
	property ::fnDrillOrig := anValue
return ::fnDrillOrig

/*
--------------------------------------------------------------------------------------
Propriedade GraphClass
--------------------------------------------------------------------------------------
*/
method GraphClass(acValue) class TConsulta
return ::Props(ID_CLASS, acValue)

/*
--------------------------------------------------------------------------------------
Propriedade GraphProps
--------------------------------------------------------------------------------------
*/
method GraphProps(acValue) class TConsulta
return ::Props(ID_GRAPHPROPS, acValue)

/*
--------------------------------------------------------------------------------------
Propriedade GraphYProps
--------------------------------------------------------------------------------------
*/
method GraphYProps(acValue) class TConsulta
return ::Props(ID_GRAPHYPROPS, acValue)

/*
--------------------------------------------------------------------------------------
Propriedade GraphY2Props
--------------------------------------------------------------------------------------
*/
method GraphY2Props(acValue) class TConsulta
return ::Props(ID_GRAPHY2PROPS, acValue)

/*
--------------------------------------------------------------------------------------
Propriedade Cube
--------------------------------------------------------------------------------------
*/
method Cube() class TConsulta
return ::Props(ID_CUBES)[1]

/*
--------------------------------------------------------------------------------------
Propriedade HaveCube
--------------------------------------------------------------------------------------
*/
method HaveCube() class TConsulta
return len(::Props(ID_CUBES)) != 0

/*
--------------------------------------------------------------------------------------
Propriedade HaveFilter
--------------------------------------------------------------------------------------
*/
method HaveFilter() class TConsulta
return len(::Where(.t.)) > 0

/*
--------------------------------------------------------------------------------------
Propriedade HaveAlert
--------------------------------------------------------------------------------------
*/
method HaveAlert() class TConsulta
return len(::Alerts(.t.)) > 0

/*
--------------------------------------------------------------------------------------
Propriedade HaveRank
--------------------------------------------------------------------------------------
*/
method HaveRank(anLevel) class TConsulta
	Local nLevel 		:= 0
	Local aAux 			:= {}
	 
	/*Quando for ranking por nível e o nível não for informado.*/
	If (::rankStyle() == RNK_STY_LEVEL) .AND. (anLevel == Nil)
	    /*Itera por todos os atributos da consulta.*/
	    For nLevel := 1 to Len(::DimFields())
	    	/*Se qualquer nível estiver com ranking definido.*/
	    	If (::rankDef(nLevel)[1] <> 0)
	    		/*Retorna os atributos do ranking no array.*/   
	    	   	aAux := ::rankDef(nLevel)
	        EndIf
	    Next nLevel
 	Else 
 		/*Define o valor default de anLevel [1].*/   
 		Default anLevel 	:= 1 	
 	
 	    /*Retorna os atributos do ranking para o nível informado.*/
 	 	aAux := ::rankDef(anLevel)
 	EndIf   
return valType(aAux) == "A" .and. len(aAux) > 0 .and. aAux[1] <> 0

/*
--------------------------------------------------------------------------------------
Propriedade HaveTable
--------------------------------------------------------------------------------------
*/
method HaveTable() class TConsulta
	local lRetT := .f., lRetG := .f.

	DWVerCons(::ID(), @lRetT, @lRetG)
return lRetT

/*
--------------------------------------------------------------------------------------
Propriedade HaveGraph
--------------------------------------------------------------------------------------
*/
method HaveGraph() class TConsulta
	local lRetT := .f., lRetG := .f.

	DWVerCons(::ID(), @lRetT, @lRetG)
return lRetG

/*
--------------------------------------------------------------------------------------
Adiciona um cubo a consulta
Args: axValue, string|numerico, nome ou ID do cubo a ser anexado a consulta
--------------------------------------------------------------------------------------
*/
method AddCube(axValue) class TConsulta
	local lRet := .F.
	local oCubes := oSigaDW:Cubes():CubeList()
	local oConsulta  := InitTable(TAB_CONSULTAS)
	local oCalcVirt, oTabCalc, aValues

  	::fnCubeID := 0
	oCubes:goTop()
	while !oCubes:eof()
		if valType(axValue) == "N"
			lRet := oCubes:value('ID') == axValue
		else
			lRet := upper(oCubes:value('nome',.t.)) == upper(axValue)
		endif
	
		if lRet
			oCubes:SavePos()
			if len(::Props(ID_CUBES)) == 0
				aAdd(::Props(ID_CUBES), oSigaDW:OpenCube(oCubes:value('ID')))
			else
				::Props(ID_CUBES)[1] := oSigaDW:OpenCube(oCubes:value('ID'))
			endif   
			::fnCubeID := oCubes:value('ID')
			oCubes:RestPos()
	
			if ::ID() <> 0 .and. oConsulta:seek( 1, { ::ID() } ) .and. ::Cube():ID() <> oConsulta:value("id_cube")
				oConsulta:Update( { {"id_cube", ::Cube():ID()} } )
				// sincroniza atributos virtuais
				oTabCalc := initTable(TAB_CALC)
				oCalcVirt := InitTable(TAB_FACTVIRTUAL)
	
				oCalcVirt:Seek(2, { oCubes:value('ID') })
				while !oCalcVirt:eof() .and. oCalcVirt:value("id_cubes") == oCubes:value('ID')
					aValues := { { "ID_CONS", ::ID() },;
							{ "nome", oCalcVirt:value("nome") },;
                        	{ "descricao", oCalcVirt:value("descricao") },;
                        	{ "tipo", "N" },;
							{ "tam", oCalcVirt:value("tam") },;
							{ "ndec", oCalcVirt:value("ndec") },;
							{ "mascara", oCalcVirt:value("mascara") },;
							{ "id_expr", oCalcVirt:value("id_expr") },;
							{ "id_virtual", oCalcVirt:value("id")  } }
					oTabCalc:append(aValues)

					oCalcVirt:_Next()
				enddo
			endif	    
   			exit
		endif
		oCubes:_Next()
	enddo
return lRet
			
/*
--------------------------------------------------------------------------------------
Salva/le a consulta gravada em base de dados
--------------------------------------------------------------------------------------
*/
static function saveProp(poConsProp, paKey, pxValue)
	if !poConsProp:seek(2, paKey)
		poConsProp:Append( { { "id_cons", paKey[1]}, ;
				{ "nome", paKey[2] }, ;
				{ "seq", paKey[3]}, ;
				{ "valor", pxValue } } )
	else
		poConsProp:Update( { { "valor", pxValue } } )
	endif
return

static function delProp(poConsProp, paKey)
	if poConsProp:seek(2, paKey)
		poConsProp:delete()
	endif
return

method DoSave(acName, alConfirm, alCache) class TConsulta
	local oOldCons   := nil
	local oConsulta  := InitTable(TAB_CONSULTAS)
	local oConsType  := InitTable(TAB_CONSTYPE)
	local oConsInd   := InitTable(TAB_CONS_IND)
	local oConsDim   := InitTable(TAB_CONS_DIM)
	local oConsWhe   := InitTable(TAB_CONS_WHE)
	local oWhereCond := InitTable(TAB_WHERE_COND)
	local oConsAlert := InitTable(TAB_CONS_ALM)
	local oConsProp  := InitTable(TAB_CONS_PROP)
	local oConsCRW   := InitTable(TAB_CONSCRW)
	local oCRWParams := InitTable(TAB_CRWPARAMS)
	local oConsUsr   := InitTable(TAB_CONS_USR) 
	local aAux, aAux2, aAux3, lReset := .f., x, y
	local lCont, nCount
	local aIndVir, cAux
	local nInd, oInd
  	local nPos, cParam
	                
	oOldCons := TConsulta():New(::ID(), ::_Type(),.f.)

  	::lock()

	default acName := ::Name()	
	default alConfirm := .f.
	default alCache := .t.

	#ifdef DWCACHE
		dwDelCons(::id(), ::_type())
	#else
	  	if alCache
			::ClearCache(.t.)
		endif
	#endif	
	
	if !oConsulta:seek( 8, { ::AccessType(), ::IDUser(), acName }, .f. )
		// Nivel de acesso
		if(!oUserDW:UserIsAdm())
			if(::AccessType()=="P")
				::AccessType("U")
				::IDUser(oUserDW:UserID())
			endif
		endif
		lReset := .t.
		oConsulta:Append({ { "tipo", ::AccessType()} ,;
				{ "id_cons", 0},;
				{ "id_user", ::IDUser() },;
				{ "publica", ::IsPublic() },;
				{ "nome", acName }, ;
				{ "descricao", acName } } )
	else
		// Se vai sobrescrever outra consulta deve solicitar confirmação
		if(::ID()!=oConsulta:value("id") .and. !alConfirm)
			return .f.
		endif	
	endif
	::ID(oConsulta:value("id"), ::_Type(), .f.)
	
	lReset := lReset .or. ::BuildIsNeed(oOldCons)

	// Grava o cubo                 
	if ::Cube():ID() != oOldCons:Cube():ID()
		oConsulta:Update( { {"id_cube", ::Cube():ID()} } )
	endif
	
	// Relacao Consulta x Tipo
	if( oConsType:seek(2, {::ID(), DWStr(::_Type())}, .f.) )
		::relationID(oConsType:value("id"))
		oConsType:Update( { {"classe", ::GraphClass()}, {"props", alltrim(::GraphProps())}, {"props_y", alltrim(::GraphYProps())}, {"props_y2", alltrim(::GraphY2Props())} } )
	else      	
		oConsType:Append({ {"id_cons", ::ID()}, {"tipo", DWStr(::_Type())}, {"classe", ::GraphClass()}, {"props", alltrim(::GraphProps())}, {"props_y", alltrim(::GraphYProps())}, {"props_y2", alltrim(::GraphY2Props())} })
		::relationID(oConsType:value("id"))
	endif						
	
	//Indicadores
	oConsInd:seek(2, { ::relationID() } )
	while !oConsInd:eof() .and. oConsInd:value("id_cons") == ::relationID()
		oConsInd:Delete()
		oConsInd:_Next()
	enddo
	aEval(::IndList(), { |x| iif(x:ordem() < 0 , nil , ;
			oConsInd:Append( {{"id_cons", ::relationID()}, {"oper", x:AggFunc()}, {'id_ind', x:ID()}, {"color", x:GraphColor()}, {"sh_ind", x:showlevel()} } ))})
			
	//Dimensoes
	if !(dwStr(::DimFields()) == dwStr(oOldCons:DimFields()))
		oConsDim:seek(2, { ::relationID() } )
		while !oConsDim:eof() .and. oConsDim:value("id_cons") == ::relationID()
			oConsDim:Delete()
			oConsDim:_Next()
		enddo
		
		if ::HaveDrillDown()
			lCont := .t.
			nCount := 1
			while lCont
				if ::DimFields()[nCount]:DrillDown()
					lCont := .f.
				endif
				::DimFields()[nCount]:GraphColor(::GraphClass())
				nCount++			
			enddo
		endif
		aEval(::DimFields(), { |x| oConsDim:Append( {{"id_cons", ::relationID()}, {'id_dim', x:ID()}, {'temporal', x:Temporal()},;
				{'eixo', x:Eixo()}, {'drilldown', x:DrillDown()}, {'drillgraph', x:GraphColor()}, {'subtotal', x:isSubTotal()}} ) })
	endif
			
	// Where
	if !(dwStr(::Where()) == dwStr(oOldCons:Where()))
		oConsWhe:seek(2, { ::relationID() } )
		while !oConsWhe:eof() .and. oConsWhe:value("id_cons") == ::relationID()
			oConsWhe:Delete()
			oConsWhe:_Next()
		enddo

		aEval(::Where(), { |x| iif(x:Selected(), oConsWhe:Append({ {"id_cons", ::relationID() }, { "id_where", x:ID() }}), nil) })
	endif   

	//prompts
	if !(dwStr(::Params()) == dwStr(oOldCons:Params()))
		aAux := ::Where(.t.)
		for x := 1 to len(aAux)
			oWhereCond:seek(2, { aAux[x]:ID() })
			while !oWhereCond:eof() .and. oWhereCond:value("id_where") == aAux[x]:ID()
				aAux3 := {}
				aAux2 := PromptExtract(aAux[x]:Name(), oWhereCond:value("qbe"), oWhereCond:value("last_value"))
				for y := 1 to len(aAux2)
					aEval(::Params(), { |x| iif(x[1]==aAux2[y,1], aAdd(aAux3, x[2]), "") })
				next	
				
				if( len(aAux3)>0 )
					oWhereCond:Update({ {"last_value", DWConcatWSep(";", aAux3)} })
				endif	
				oWhereCond:_Next()
			enddo
	   next
	endif
					
	// Alertas             
	if !(dwStr(::Alerts()) == dwStr(oOldCons:Alerts()))
		oConsAlert:seek(2, { ::ID() } )
		while !oConsAlert:eof() .and. oConsAlert:value("id_cons") == ::ID()
			oConsAlert:Delete()
			oConsAlert:_Next()
		enddo
		aEval(::Alerts(), { |x| x:doSave(), ;
				iif(x:Selected(), oConsAlert:Append({ {"id_cons", ::ID() }, { "id_alert", x:ID() }}), nil) })
	endif
			
	// Lista de "rank" para indicadores
	if !(dwStr(::RankDef()) == dwStr(oOldCons:RankDef()))
		aAux := ::RankDef()
	  	for nInd := 1 to len(aAux)
			saveProp(oConsProp, { ::relationID(), "RNK2", nInd }, dwStr(aAux[nInd],.t.))
	  	next
	endif

	// parametros da CurvaABC
	if !(dwStr(::CurvaABC()) == dwStr(oOldCons:CurvaABC()))
		saveProp(oConsProp, { ::relationID(), "ABC", 0 }, dwStr(::CurvaABC(), .t.))
	endif
   
	// Fator de escala
	if ::FatorEscala() != oOldCons:FatorEscala()
		saveProp(oConsProp, { ::relationID(), "ESC", 0 }, DWStr(::FatorEscala()))
	endif
   
	// Ind. sobreposto
	if ::IndSobrePosto() != oOldCons:IndSobrePosto()
		saveProp(oConsProp, { ::relationID(), "SOBRE", 0 }, DWStr(::IndSobrePosto()))
	endif 
   
   	// FillAll
	if ::FillAll() != oOldCons:FillAll()
		saveProp(oConsProp, { ::relationID(), "FILLALL", 0 }, DWStr(::FillAll()))
   	endif
   
	// Formatação de célula vazia           
	if ::EmptyCell() != oOldCons:Emptycell()
		saveProp(oConsProp, { ::relationID(), "CEL", 0 }, DWStr(::EmptyCell()))
   	endif
   
	// AlertOn
	if ::AlertOn() != oOldCons:AlertOn()
		saveProp(oConsProp, { ::relationID(), "ALEON", 0 }, DWStr(::AlertOn()))
   	endif
   
	// HintOn
	if ::HintOn() != oOldCons:HintOn()
		saveProp(oConsProp, { ::relationID(), "HINTON", 0 }, DWStr(::HintOn()))
   	endif

	// IgnoreZero
	if ::IgnoreZero() != oOldCons:IgnoreZero()
		saveProp(oConsProp, { ::relationID(), "IGNZERO", 0 }, DWStr(::IgnoreZero()))
		lReset := .t.
   	endif      

	// UseExcel
	if ::UseExcel() != oOldCons:UseExcel()
		saveProp(oConsProp, { ::relationID(), "EXCEL", 0 }, DWStr(::UseExcel()))
   	endif      

	// Filtered
	if ::Filtered() != oOldCons:Filtered()
		saveProp(oConsProp, { ::relationID(), "FILON", 0 }, DWStr(::Filtered()))
   	endif

	// Total
	if ::Total() != oOldCons:Total()
		saveProp(oConsProp, { ::relationID(), "TOTAL", 0 }, DWStr(::Total()))
   	endif
   
	// RankOn
	if !::haveRank()
		::RankOn(.f.)
	endif
	
	saveProp(oConsProp, { ::relationID(), "RANON", 0 }, DWStr(::RankOn()))
                
	// RankOutros
	if ::RankOutros() != oOldCons:RankOutros()
		saveProp(oConsProp, { ::relationID(), "RANOU", 0 }, DWStr(::RankOutros()))
	endif

	// RankSubTotal
	if ::RankSubTotal() != oOldCons:RankSubTotal()
		saveProp(oConsProp, { ::relationID(), "RANST", 0 }, DWStr(::RankSubTotal()))
	endif

	// RankTotal
	if ::RankTotal() != oOldCons:RankTotal()
		saveProp(oConsProp, { ::relationID(), "RANTO", 0 }, DWStr(::RankTotal()))
	endif

	// RankStyle
	if ::RankStyle() != oOldCons:RankStyle()
		saveProp(oConsProp, { ::relationID(), "RANSTL", 0 }, DWStr(::RankStyle()))
	endif

	// ZeraAcum
	if ::ZeraAcum() != oOldCons:ZeraAcum()
		saveProp(oConsProp, { ::relationID(), "ZERAAC", 0 }, DWStr(::ZeraAcum()))
	endif

	// Largura das colunas
	if ::PanWidth() != oOldCons:PanWidth()                                     
		if empty(::PanWidth())
			delProp(oConsProp, { ::relationID(), "PANW", 0 })
		else
			saveProp(oConsProp, { ::relationID(), "PANW", 0 }, dwStr(::PanWidth()))
		endif
	endif

	if dwStr(::AttWidth()) != dwStr(oOldCons:AttWidth())    
		if len(::AttWidth()) == 0
			delProp(oConsProp, { ::relationID(), "ATTW", 0 })
		else
			saveProp(oConsProp, { ::relationID(), "ATTW", 0 }, DWStr(::AttWidth(), .t.))
		endif
	endif

	if dwStr(::IndWidth()) != dwStr(oOldCons:IndWidth())
		if len(::IndWidth()) == 0
			delProp(oConsProp, { ::relationID(), "INDW", 0 })
		else
			saveProp(oConsProp, { ::relationID(), "INDW", 0 }, DWStr(::IndWidth(), .t.))
		endif
	endif
	
	if oConsCRW:Seek(2, { ::relationID() } )
		oConsCRW:update( { {"nome", ::CRWName()}, {"descricao", ::CRWDesc()}, {"url", ::CRWURL()} })
	else
		oConsCRW:append( { {"id_cons", ::relationID()}, {"nome", ::CRWName()}, {"descricao", ::CRWDesc()}, {"url", ::CRWURL()} })
	endif
	
  	if len(::CRWParams()) > 0
   		oCRWParams:seek(2, { oConsCRW:value("id") })
		for x := 1 to len(::CRWParams())
			if (oCRWParams:value("id_crw") == oConsCRW:value("id")) .and. (oCRWParams:value("ordem") == dwstr(x))
			   oCRWParams:Update({ {"campo", ::CRWParams()[x]} })
			   oCRWParams:_Next()
			else
				oCRWParams:Append({ {"id_crw", oConsCRW:value("id")}, {"ordem", dwstr(x)}, {"campo", ::CRWParams()[x]} })
			endif
		next
		
		while !oCRWParams:eof() .and. oCRWParams:value("id_crw") == oConsCRW:value("id")
			oCRWParams:Delete()
			oCRWParams:_Next()
		enddo
  	else
   		if oCRWParams:seek(2, { oConsCRW:value("id") })
   			while !oCRWParams:eof() .and. oCRWParams:value("id_crw") == oConsCRW:value("id")
   				oCRWParams:Delete()
   				oCRWParams:_Next()
   			enddo
   		endif
  	endif

  	// valores dos prompts de referencia
	aIndVir := ::IndVirtual(,.f.)

	for nInd := 1 to len(aIndVir)
		oInd := aIndVir[nInd]
		cAux := upper(oInd:Expressao())
	  	nPos := at("@DWREF", cAux)
    	if nPos > 0
      		cAux := substr(cAux, nPos)
	    	nPos := at(")", cAux)
      		cAux := substr(cAux, 1, nPos-1)
      		cAux := substr(cAux, 8)
	    	aAux := dwToken(cAux,,.f.)
      		aEval(aAux, { |x,i| aAux[i] := delAspas(alltrim(x))})
      		aSize(aAux,3)
      		
      		cParam := "ptedDW_REF" + upper(aAux[2])
			if !(valType(&("httpPost->"+cParam)) == "U")
				// valor padrão
				if (valType(oUserDW) == "U") .or. oUserDW:UserIsAdm()
					if oConsUsr:Seek(2, { ::ID(), 0, cParam })
						oConsUsr:update( { {"id_cons", ::ID()}, { "id_user", 0},;
								{"prompt", cParam}, {"valor", dwStr(&("httpPost->"+cParam)) }})
					else
						oConsUsr:Append( { {"id_cons", ::ID()}, { "id_user", 0},;
								{"prompt", cParam}, {"valor", dwStr(&("httpPost->"+cParam)) }})
					endif
			  	elseif oConsUsr:Seek(2, { ::ID(), oUserDW:UserID(), cParam })
					oConsUsr:update( { {"id_cons", ::ID()}, { "id_user", oUserDW:UserID()},;
							{"prompt", cParam}, {"valor", dwStr(&("httpPost->"+cParam)) }})
				else				  
					oConsUsr:Append( { {"id_cons", ::ID()}, { "id_user", oUserDW:UserID()},;
							{"prompt", cParam}, {"valor", dwStr(&("httpPost->"+cParam)) }})
				endif
			endif
		endif
	next
  
	if lReset
		::ResetWorkfile()
		::Invalidate()			
	endif

  	::unlock()
return .t.

method loadFilters() class TConsulta
	local oWhere     := InitTable(TAB_WHERE)
	local oWhereCond := InitTable(TAB_WHERE_COND)
	local oConsUsr   := InitTable(TAB_CONS_USR) 
	local oFiltro, nInd
	
	oWhere:seek(2, { ::ID() })
	while !oWhere:eof() .and. oWhere:value("id_cons") == ::ID()
		if oWhere:value("tipo") == FILTER_SEGTO
			oFiltro := ::AddSegto(oWhere:value("id"))
		else
			oFiltro := ::AddWhere(oWhere:value("id"))
		endif
		
		if oWhere:value("tipo") == FILTER_SECURE
			oFiltro:ApplySecure(.t.)
			if oConsUsr:Seek(2, { ::ID(), 0, "."+dwStr(oWhere:value("id")), .F. })
				oFiltro:ApplySecure(oConsUsr:value("valor",.t.) == ".T.")
			endif
		
			if valType(oUserDW) <> "U"
				if oConsUsr:Seek(2, { ::ID(), oUserDW:GroupID(), "."+dwStr(oWhere:value("id")), .F. })
					oFiltro:ApplySecure(oConsUsr:value("valor",.t.) == ".T.")
				endif

				if oConsUsr:Seek(2, { ::ID(), oUserDW:UserID(), "."+dwStr(oWhere:value("id")), .F. })
					oFiltro:ApplySecure(oConsUsr:value("valor",.t.) == ".T.")
				endif
			endif
		else
			oFiltro:ApplySecure(.f.)
		endif
		
		oWhereCond:seek(2, { oWhere:value("id") })  // Carrega os prompts gravados
		while !oWhereCond:eof() .and. oWhereCond:value("id_where") == oWhere:value("id")
			aAux := PromptExtract(oWhere:value("nome"), oWhereCond:value("qbe"), oWhereCond:value("last_value"))
			for nInd := 1 to len(aAux)
				// valor padrão
				if oConsUsr:Seek(2, { ::ID(), 0, "pt"+aAux[nInd, 1] })
					aaux[nInd, 2] := oConsUsr:value("valor")
				endif
		
				// grupo
				if valType(oUserDW) == "O"
					if oConsUsr:Seek(2, { ::ID(), oUserDW:GroupID(), "pt"+aAux[nInd, 1] })
						aaux[nInd, 2] := oConsUsr:value("valor")
					endif
		
					// usuário
					if oConsUsr:Seek(2, { ::ID(), oUserDW:UserID(), "pt"+aAux[nInd, 1] })
						aaux[nInd, 2] := oConsUsr:value("valor")
					endif
				endif
			next
			aEval(aAux, { |x| ::AddParam(x[1], x[2]) })
			oWhereCond:_Next()
		enddo
		oWhere:_Next()
	enddo
return

method DoLoad(alCache) class TConsulta
	local oConsulta  := InitTable(TAB_CONSULTAS)
	local oConsType  := InitTable(TAB_CONSTYPE)
	local oConsInd   := InitTable(TAB_CONS_IND)
	local oConsDim   := InitTable(TAB_CONS_DIM)
	local oConsAlert := InitTable(TAB_CONS_ALM)
	local oConsProp  := InitTable(TAB_CONS_PROP)
	local oConsUsr   := InitTable(TAB_CONS_USR) 
	local oAlert     := InitTable(TAB_ALERT)
 	local oConsCRW   := InitTable(TAB_CONSCRW)
 	local oCRWParams := InitTable(TAB_CRWPARAMS)
	local nInd, aDimY
	local aAux, aWhere

  	::lock()

	#ifdef DWCACHE
	#else
		default alCache := .t.
	
		alCache := alCache .and. !empty(::_Type()) .and. DWisWebEx() .and. HTTPIsConnected()
	#endif
	
	::faIntFrom := {}
	::Name("")
	::Desc("")    
	::AttWidth({})
	::PanWidth(0)
	::IndWidth({})
	::Props(ID_CUBES, {})
	::Props(ID_INDLIST, {})
	::Props(ID_DIMENSAO, {})
	::Props(ID_DIMFIELDS, {})
	::Props(ID_RANKSTYLE, RNK_STY_CLEAR)
	::faRankDef := {}
	::CurvaABC({})
	::Props(ID_WHERE, {})
	::Props(ID_SEGTO, {})
	::Props(ID_ALERTS, {})
	::Props(ID_DRILLDOWN, {})
	::Props(ID_FILTERED, .f.)
	::Props(ID_TOTAL, .t.)
	::Props(ID_ALERTON, .f.)
	::Props(ID_HINTON, .f.)
	::Props(ID_IGNOREZERO, .f.)
	::Props(ID_USEEXCEL, .f.)
	::Props(ID_RANKON, .f.)
	::Props(ID_RANKOUTROS, .f.) 
	::Props(ID_RANKSUBTOTAL, .f.)
	::Props(ID_RANKTOTAL, .f.) 
	::Props(ID_RELATIONID, 0)
	::Props(ID_PARAMS, {})
	::Props(ID_FATORESCALA, 0)
	::Props(ID_SOBREPOSTO, .f.)
	::Props(ID_FILLALL, .f.)  
	::Props(ID_EMPTYCELL, .f.)
	::Props(ID_CLASS, "")
	::Props(ID_GRAPHPROPS, "")
	::Props(ID_GRAPHYPROPS, "")
	::Props(ID_GRAPHY2PROPS, "")
	::Props(ID_IDUSER, 0)
	::Props(ID_USERNAME, "")
	::Props(ID_ISVALID, .F.)
	::Props(ID_ISPUBLIC, .F.)
	::Props(ID_CRWNAME, "")
	::Props(ID_CRWDESC, "")
	::Props(ID_CRWURL, "")	
	::faCRWParams := {}
	::faDrillParms := { 0, "" }
	::flZeraAcum := .f.
	::fnDrillOrig := NOT_EXIST_DD
  	::fnCubeID := 0	
  	::faHideAtt := {}
	::faKeyValues := {}
	::faDrillHist := {}     
	::flUserExp := .f.
	
	if ::ID() <> 0 .and. oConsulta:seek( 1, { ::ID() } )
#ifdef DWCACHE	
#else
		if .f. //alCache .and. ::inCache()
			::updFromCache()
		else
#endif
			::Name(oConsulta:value("nome"))
			::Desc(oConsulta:value("descricao")) 			
			//Recebe o id do documento relacionado a consulta. 
			::fnDoctoId := oConsulta:value("id_docto") 				
     	    ::flUserExp := oConsulta:value("export") 
      		if oConsulta:value("id_cube") <> 0
				if !::AddCube(oConsulta:value("id_cube"))
					oConsulta:Update ( {{"id_cube", 0 }})
				endif
			endif
			::IsPublic(oConsulta:value("publica"))
			::AccessType(oConsulta:value("tipo"))
			::IDUser(oConsulta:value("id_user"))
			::UserName(oConsulta:value("user_name"))

			if ::_Type() == TYPE_TABLE
				::Props(ID_ISVALID, oConsulta:value("valida"))
			else
				::Props(ID_ISVALID, oConsulta:value("valgra"))
			endif
		
			if oConsulta:value("id_cube") <> 0
				if oConsType:seek(2, {::ID(), DWStr(::_Type())}, .f.)
					::relationID(oConsType:value("id"))
					::GraphClass(oConsType:value("classe"))
					::GraphProps(oConsType:value("props"))
					::GraphYProps(oConsType:value("props_y"))
					::GraphY2Props(oConsType:value("props_y2"))
					
					oConsInd:seek(4, { ::relationID() } )
					while !oConsInd:eof() .and. oConsInd:value("id_cons") == ::relationID()
						::AddIndicador(oConsInd:value("oper"), oConsInd:value("id_ind"), oConsInd:value("id"), alltrim(oConsInd:value("color")), alltrim(oConsInd:value("sh_ind")))
						oConsInd:_Next()
					enddo
          
          			::VerIndicador()
          			::VerRefValues()
          
					oConsDim:seek(4, { ::relationID() } )
					while !oConsDim:eof() .and. oConsDim:value("id_cons") == ::relationID()
						::AddDimFields(oConsDim:value("eixo"), ;
								"("+DWStr(oConsDim:value("temporal"))+"|"+;
								iif(::_Type() == TYPE_TABLE, iif(oConsDim:value("subtotal"), "1", "0"), "")+ ; 
								alltrim(oConsDim:value("drillgraph"))+")"+;
								iif(oConsDim:value("drilldown"), "*", "")+;
								DWStr(oConsDim:value("id_dim")) )
						oConsDim:_Next()
					enddo

					if oConsProp:seek(2, { ::relationID(), "RANSTL", 0 })
						::RankStyle(oConsProp:value("valor"))
					else	
						::RankStyle(RNK_STY_CLEAR)
					endif 

					if oConsProp:seek(2, { ::relationID(), "RNK2" })
					  	while !oConsProp:eof() .and. ::relationID() == oConsProp:value("id_cons") .and. oConsProp:value("nome") == "RNK2"
					  		aAux := &(oConsProp:value("valor"))
				  			::rankDef(oConsProp:value("seq"), aAux[1], aAux[2], aAux[3])
              			oConsProp:_next()
            			enddo
					else
						::RankStyle(RNK_STY_CLEAR)
					endif

					if oConsProp:seek(2, { ::relationID(), "ABC", 0 })
						::CurvaABC(&(oConsProp:value("valor")))
					endif
					
					if oConsProp:seek(2, { ::relationID(), "ESC", 0 })
						::FatorEscala(dwval(oConsProp:value("valor")))
					endif

					if oConsProp:seek(2, { ::relationID(), "SOBRE", 0 })
						::IndSobrePosto(oConsProp:value("valor") == ".T.")
					endif
                    
					if oConsProp:seek(2, { ::relationID(), "FILLALL", 0 })
						::FillAll(oConsProp:value("valor") == ".T.")
					endif

					if oConsProp:seek(2, { ::relationID(), "CEL", 0 })
						::EmptyCell(oConsProp:value("valor") == ".T.")
					endif

					if oConsProp:seek(2, { ::relationID(), "ALEON", 0 })
						::AlertOn(oConsProp:value("valor",.t.) == ".T.")
					endif

					if oConsProp:seek(2, { ::relationID(), "HINTON", 0 })
						::HintOn(oConsProp:value("valor",.t.) == ".T.")
					endif

					if oConsProp:seek(2, { ::relationID(), "IGNZERO", 0 })
						::IgnoreZero(oConsProp:value("valor",.t.) == ".T.")
					endif

					if oConsProp:seek(2, { ::relationID(), "EXCEL", 0 })
						::UseExcel(oConsProp:value("valor",.t.) == ".T.")
					endif

					if oConsProp:seek(2, { ::relationID(), "FILON", 0 })
						::Filtered(oConsProp:value("valor",.t.) == ".T.")
					endif

					if oConsProp:seek(2, { ::relationID(), "TOTAL", 0 })
						::Total(oConsProp:value("valor",.t.) == ".T.")
					endif

					if oConsProp:seek(2, { ::relationID(), "RANON", 0 })
						::RankOn(oConsProp:value("valor") == ".T.")
					endif

					if oConsProp:seek(2, { ::relationID(), "RANOU", 0 })
						::RankOutros(oConsProp:value("valor") == ".T.")
					endif

					if oConsProp:seek(2, { ::relationID(), "RANST", 0 })
						::RankSubTotal(oConsProp:value("valor") == ".T.")
					endif

					if oConsProp:seek(2, { ::relationID(), "RANTO", 0 })
						::RankTotal(oConsProp:value("valor") == ".T.")
					endif

     				if oConsProp:seek(2, { ::relationID(), "ZERAAC", 0 })
     					::ZeraAcum(oConsProp:value("valor",.t.) == ".T.")
          			endif

          			aDimY := ::DimFieldsY()
          			for nInd := len(aDimY) to 1 step -1
            			if aDimY[nInd]:Drilldown()
            				::DrillOrig(nInd)
            				exit
            			endif
          			next
					
					if oConsProp:seek(2, { ::relationID(), "PANW", 0 })
						::PanWidth(dwVal(oConsProp:value("valor")))
					endif

					if oConsProp:seek(2, { ::relationID(), "ATTW", 0 })
						::AttWidth(&(oConsProp:value("valor")))
					endif

					if oConsProp:seek(2, { ::relationID(), "INDW", 0 })
						::IndWidth(&(oConsProp:value("valor")))
					endif
				
					if oConsCRW:seek(2, { ::relationID() } )
						::CRWName(oConsCRW:value("nome"))
						::CRWDesc(oConsCRW:value("descricao"))
						::CRWURL(oConsCRW:value("url"))
						aAux := {}
						nInd := 0
					
						if oCRWParams:seek(2, { oConsCRW:value("id"), "1" })
							while !oCRWParams:eof() .and. oCRWParams:value("id_crw") == oConsCRW:value("id")
								nInd++
								aAdd(aAux, oCRWParams:value("campo"))
								oCRWParams:_Next()
							enddo
					
							if nInd > 0
								::CRWParams(aAux)
							endif
						endif
					endif
		
					::GraphY2Props(oConsType:value("props_y2", .t.))
				endif	
		    	
		    	::loadFilters()

				oAlert:seek(2, { ::ID() } )
				while !oAlert:eof() .and. oAlert:value("id_cons") == ::ID()
					::AddAlert(oAlert:value("id"))
					oAlert:_Next()
				enddo
			endif	

			#ifdef DWCACHE
			#else
				if alCache      
					if ::inCache()
						::updFromCache()
					else
						::updCache()
					endif
				endif
			#endif
		endif
	endif

	::unlock()
return

/*
--------------------------------------------------------------------------------------
Adiciona indicadores
--------------------------------------------------------------------------------------
*/
method AddIndicador(AOper, AID, anOrdem, acColor, acLevel) class TConsulta
	local lRet := .F., cAux, nPos
	local oInd, nOper, nInd, aInd
  	local aIndList
  	
	if valType(::Cube()) == "O"
	  	aIndList := ::IndList()
		nPos := ascan(aIndList, { |x| x:id() == AID .and. x:aggFunc() == AOper } )
		if  nPos == 0
			oInd := TFieldInfo():New(AID, Self, .f., ::Cube():ID())
			if oInd:IsValid()
				oInd:Ordem(anOrdem)
				oInd:AggFunc(AOper)
				oInd:GraphColor(acColor)
				oInd:ShowLevel(acLevel)
				aAdd(aIndList, oInd)
				lRet := .t.
			endif
		else
			oInd := aIndList[nPos]
      		if oInd:ordem() < 0
				oInd:ordem(anOrdem)
			endif      
		endif
	endif
return lRet
			
/*            
--------------------------------------------------------------------------------------
Verifica se há necessidades de indicadores de apoio
(indicadores utilizados em campos virutais e não selecionados)
--------------------------------------------------------------------------------------
*/
method VerIndicador() class TConsulta
	local aInd := ::Cube():GetIndicadores()
	local aIndVir := ::IndVirtual(,.f.), cAux, cRealname
	local nInd, nInd2, oInd

	for nInd := 1 to len(aIndVir)
		oInd := aIndVir[nInd]
		cAux := upper(oInd:Expressao())
		for nInd2 := 1 to len(aInd)
			cRealname := aInd[nInd2, 2]
			if "@ACUM(FATO->" + cRealname $ cAux
				::addIndicador(AGG_ACUM, aInd[nInd2, 1], -nInd2, "", "")
			endif
			
			if "@ACUMPERC(FATO->" + cRealname $ cAux
				::addIndicador(AGG_ACUMPERC, aInd[nInd2, 1], -nInd2, "", "")
			endif
			
			if "@ACUMHIST(FATO->" + cRealname $ cAux
				::addIndicador(AGG_ACUMHIST, aInd[nInd2, 1], -nInd2, "", "")
			endif
			
			if "@ACUMHISTPERC(FATO->" + cRealname $ cAux
				::addIndicador(AGG_ACUMHISTPERC, aInd[nInd2, 1], -nInd2, "", "")
			endif
			
			if "SUM(FATO->" + cRealname $ cAux
				::addIndicador(AGG_SUM, aInd[nInd2, 1], -nInd2, "", "")
			endif
			
			if "COUNT(FATO->" + cRealname $ cAux
				::addIndicador(AGG_COUNT, aInd[nInd2, 1], -nInd2, "", "")
			endif
			
			if "AVG(FATO->" + cRealname $ cAux
				::addIndicador(AGG_AVG, aInd[nInd2, 1], -nInd2, "", "")
			endif
			
			if "MIN(FATO->" + cRealname $ cAux
				::addIndicador(AGG_MIN, aInd[nInd2, 1], -nInd2, "", "")
			endif
			
			if "MAX(FATO->" + cRealname $ cAux
				::addIndicador(AGG_MAX, aInd[nInd2, 1], -nInd2, "", "")
			endif
		next	
	next
return 


/*            
--------------------------------------------------------------------------------------
Verifica se valores de referencias
--------------------------------------------------------------------------------------
*/
method VerRefValues() class TConsulta
	local oConsUsr   := InitTable(TAB_CONS_USR) 
	local aIndVir := ::IndVirtual(,.f.), cAux
	local nInd, oInd, aAux
  	local nPos, cParam

	for nInd := 1 to len(aIndVir)
		oInd := aIndVir[nInd]
		cAux := upper(oInd:Expressao())
	  	nPos := at("@DWREF", cAux)
    	if nPos > 0
      		cAux := substr(cAux, nPos)
	    	nPos := at(")", cAux)
      		cAux := substr(cAux, 1, nPos-1)
      		cAux := substr(cAux, 8)
	    	aAux := dwToken(cAux,,.f.)
      		aEval(aAux, { |x,i| aAux[i] := delAspas(alltrim(x))})
      		aSize(aAux, 4)
      		cParam := "ptedDW_REF" + upper(aAux[2])

			// valor padrão
			if oConsUsr:Seek(2, { ::ID(), 0, cParam })
				aAux[4] := oConsUsr:value("valor")
			endif
			
			// usuário
      		if valType(oUserDW) == "O"
				if oConsUsr:Seek(2, { ::ID(), oUserDW:UserID(), cParam })
					aAux[4] := oConsUsr:value("valor")
				endif
			endif
			
			if !empty(aAux[4])
				::AddParam(cParam, aAux[4])
			elseif aAux[1] == "N"
				::AddParam(cParam, "0")
			else
				::AddParam(cParam, "''")
			endif
		endif
	next
return
	
/*            
--------------------------------------------------------------------------------------
Adiciona DimFields
--------------------------------------------------------------------------------------
*/
method AddDimFields(acEixo, axID, acAlias, anTemporal,alSubTotal) class TConsulta
	local lRet := .T., lDrill := .F.
	local oField
	local nOrdem, nTemporal
	local cDrillGraph := "0", cStr

	default alSubTotal := .f.
	
	// axID deve ser string, composto por [(<temporal>[|<graphtype>)]][<*>]<id>
	// mas se for so o numero do id, tambem funcionara, porem sem definir temporal e graphtype
	cStr := alltrim(DWStr(axID))
	if( substr(cStr, 1, 1) == "(" )
		if( at("|", cStr) != 0 )
			nTemporal := val( substr(cStr, 2, at("|", cStr)-1) )
			cStr := substr(cStr, at("|", cStr)+1)
			cDrillGraph := substr(cStr, 1, at(")", cStr)-1)
		else
			nTemporal := val(substr(cStr, 2, at(")", cStr)-1))
		endif	
		cStr := substr(cStr, at(")", cStr)+1)
	else    
		cDrillGraph := ::GraphClass()
		nTemporal := anTemporal
	endif

	if( valtype(nTemporal)!="N" )
		nTemporal := 0	
	endif

	lDrill := left(cStr, 1) == "*"
	if lDrill
		cStr := substr(cStr, 2)
	endif

	axID := val(cStr)
	
	oField := TFieldInfo():New(axID, Self, .t., ::Cube():ID())
	if oField:isValid()
		nOrdem := iif(acEixo=="X", ::DimCountX(), ::DimCountY())
		oField:Eixo(acEixo)
		oField:Ordem(nOrdem+1)
		oField:DrillDown(lDrill)
		oField:Temporal(nTemporal)
		
		if ::_Type() == TYPE_TABLE
			oField:GraphColor("")
			oField:IsSubTotal(left(cDrillGraph,1)=="1" .or. alSubTotal)
		else
			oField:GraphColor(cDrillGraph)
			oField:IsSubTotal(.t.)
		endif
		
		if valType(acAlias) == "C"
			oField:Alias(acAlias) 
		endif
	
		aAdd(::DimFields(), oField)
	
		if ascan(::Dimensao(), { |x| x == oField:Dimensao() }) == 0
			aAdd(::Dimensao(), oField:Dimensao())
		endif
	endif	
return lRet

/*
--------------------------------------------------------------------------------------
Adiciona clausulas where (filtros)
--------------------------------------------------------------------------------------
*/
method AddWhere2(acCampo, acOper, acValor) class TConsulta
	local lRet := .t.
	local oFiltro := TFiltro():New(0, Self)
	
	oFiltro:Desc(acCampo)
	oFiltro:Name(acCampo)
	oFiltro:IsInd(.F.)
	oFiltro:Expressao(acCampo + " = " + DWStr(acValor, .t.))
	oFiltro:IsSQL(.T.)
	
	aAdd(::Where(), oFiltro)
	
	::AddIntFrom(acCampo)
return lRet
			
method AddWhere(anID) class TConsulta
	local oWhere := InitTable(TAB_WHERE)
	local oConsWhe := InitTable(TAB_CONS_WHE)
	local oFiltro
	            
	oWhere:SavePos()
	oConsWhe:SavePos()
	oFiltro := TFiltro():New(anID, Self)
	oFiltro:Selected(oConsWhe:seek(2, { ::relationID(), oFiltro:ID() }, .t. ))
	oWhere:RestPos()
	oConsWhe:RestPos()

	aAdd(::Where(.t.), oFiltro)
	if oFiltro:Selected() .and.  !oFiltro:IsInd() .and. oFiltro:IsSQL()
		aEval(oFiltro:Expressao(), { |x| iif(valtype(x)=="A" .and. x[1] <> 0, ::AddIntFrom(DWDimName(x[1])+"."+x[3]), nil)})
	endif
return oFiltro

method AddSegto(anID) class TConsulta
	local lRet := .t.
	local oWhere := InitTable(TAB_WHERE)
	local oConsWhe := InitTable(TAB_CONS_WHE)
	local oFiltro
	            
	oWhere:SavePos()
	oConsWhe:SavePos()
	oFiltro := TFiltro():New(anID, Self)
	oFiltro:Selected(.t.)

	oWhere:RestPos()
	oConsWhe:RestPos()

	aAdd(::Segto(.t.), oFiltro)
	if oFiltro:Selected() .and.  !oFiltro:IsInd() .and. oFiltro:IsSQL()
		aEval(oFiltro:Expressao(), { |x| iif(valtype(x)=="A" .and. x[1] <> 0, ::AddIntFrom(DWDimName(x[1])+"."+x[3]), nil)})
	endif
return oFiltro			

/*
--------------------------------------------------------------------------------------
Adiciona alertas
--------------------------------------------------------------------------------------
*/
method AddAlert(anID) class TConsulta
	local lRet := .t.
	local oTabAlert := InitTable(TAB_ALERT)
	local oConsAlm := InitTable(TAB_CONS_ALM)
	local oAlert

	if ascan(::Alerts(.t.), { |x| x:ID() == anID}) == 0
		oTabAlert:SavePos()
		oConsAlm:SavePos()
		oAlert := TAlert():New(anID, Self)
		oAlert:Selected(oConsAlm:seek(2, { ::ID(), oAlert:ID() }, .t. ))
		
		oTabAlert:RestPos()
		oConsAlm:RestPos()

		aAdd(::Alerts(.t.), oAlert)
	endif
return lRet
			
/*
--------------------------------------------------------------------------------------
Propriedade Indicadores
--------------------------------------------------------------------------------------
*/
method IndList() class TConsulta
return ::Props(ID_INDLIST)
		
/*
--------------------------------------------------------------------------------------
Propriedade Dimensao
--------------------------------------------------------------------------------------
*/
method Dimensao() class TConsulta
return ::Props(ID_DIMENSAO)

/*
--------------------------------------------------------------------------------------
Propriedade DimFields, DimCountX, DimCountY, DimFieldsX e DimFieldsY
--------------------------------------------------------------------------------------
*/
method DimFields() class TConsulta
return ::Props(ID_DIMFIELDS)
			
method DimFieldsX(alAll) class TConsulta
	local aRet := {}

	default alAll := .f.
	
	aEval(::DimFields(), { |x| iif(x:Eixo() == "X" .and. (alAll .or. ::isAttVisible(x:alias())), aAdd(aRet, x), nil) })
	DplItems(aRet, .t., 1, .T.)
return aRet

method DimCountX(alAll) class TConsulta
	Local aRet := {}

	default alAll := .f.

	aEval(::DimFields(), { |x| iif(x:Eixo() == "X" .and. (alAll .or. ::isAttVisible(x:alias())), aAdd(aRet, x:Alias()), nil) })
	DplItems(aRet, .t., 1, .T.)
return len(aRet)

method DimFieldsY(alAll) class TConsulta
	local aRet := {}
	local x,i
	                       
	default alAll := .f.

	aEval(::DimFields(), { |x| iif(x:Eixo() == "Y" .and. (alAll .or. ::isAttVisible(x:alias())), aAdd(aRet, x), nil) })
	DplItems(aRet, .t., 1, .T.)
return aRet

method DimCountY(alAll) class TConsulta
	Local aRet := {}
	default alAll := .f.

	aEval(::DimFields(), { |x| iif(x:Eixo() == "Y" .and. (alAll .or. ::isAttVisible(x:alias())), aAdd(aRet, x:Alias()), nil) })
	DplItems(aRet, .t., 1, .T.)
return len(aRet)
			
/*
--------------------------------------------------------------------------------------
Propriedade DrillDown
--------------------------------------------------------------------------------------
*/
method DrillDown() class TConsulta
	local aRet := {}

	aEval(::DimFieldsY(), { |x| iif(x:DrillDown(), aAdd(aRet, { "Y"+x:Desc(), x:ID(), x:Fullname() } ), nil) })
return aRet

/*
--------------------------------------------------------------------------------------
Metodo HaveDrillDown
--------------------------------------------------------------------------------------
*/
method HaveDrillDown() class TConsulta
return ::DrillOrig() <> NOT_EXIST_DD //ascan(::DimFieldsY(), { |x| x:DrillDown() == .t.} ) <> 0
			
/*
--------------------------------------------------------------------------------------
Propriedade Workfile
--------------------------------------------------------------------------------------
*/
method Workfile(anType) class TConsulta
	default anType := ::_Type()
return DWSumName(::ID(), iif(anType == TYPE_GRAPH, "G", "S"))

/*
--------------------------------------------------------------------------------------
Propriedade Viewname
--------------------------------------------------------------------------------------
*/
method Viewname(anType) class TConsulta
	default anType := ::_Type()
return DWSumName(::ID(), iif(anType == TYPE_GRAPH, "Z", "V"))

/*
--------------------------------------------------------------------------------------
Propriedade TableMedInt
--------------------------------------------------------------------------------------
*/
method TableMedInt() class TConsulta
return DWSumName(::ID(), iif(::_Type() == TYPE_GRAPH, "B", "A"))
/*
--------------------------------------------------------------------------------------
Propriedade RankDef
--------------------------------------------------------------------------------------
*/
method RankDef(anNivel, anID, anValue, acType) class TConsulta
	Local aRet 
	
	if valType(anNivel) == "U"
		if len(::faRankDef) == 0
			aAdd(::faRankDef, { 0, 0, "" })
		endif
		aRet := ::faRankDef
	elseif !(valType(anID) == "U")
		if ::rankStyle() <> RNK_STY_LEVEL .or. anNivel < 0
			anNivel := 1
		endif

		while len(::faRankDef) < anNivel
			aAdd(::faRankDef, { 0, 0, "" })
		enddo
		
		::faRankDef[anNivel] := { DwVal(anID), DwVal(anValue), acType }
		aRet := ::faRankDef[anNivel]
	else
		If ::rankStyle() <> RNK_STY_LEVEL .or. anNivel < 1
			anNivel := 1
		EndIf
		 
		/*TODO - Verificar porque em alguns casos o (anNivel) é maior que o len(::faRankDef).*/
		If (anNivel) > len(::faRankDef) 
			anNivel := len(::faRankDef)
		EndIf
		
		aRet := ::faRankDef[anNivel]
	endif 
return aRet

/*
--------------------------------------------------------------------------------------
Propriedade CurvaABC (parametros para calculo)
--------------------------------------------------------------------------------------
*/         
method CurvaABC(aaValues) class TConsulta
	local aRet

	if valType(aaValues) == "U"
		aRet := ::faCurvaABC
	elseif valType(aaValues) == "A"
		::faCurvaABC := aClone(aaValues)
  	else
		aRet := dwToken(aaValues, ";")
	  	aEval(aRet, { |x,i| aRet[i] := dwToken(x+"|", "|") })
	  	::faCurvaABC := aClone(aRet)
	endif
return aRet

method AutoFilter(acValue) class TConsulta
  	if valType(acValue) == "C"	
		property ::fcAutoFilter := acValue

		#ifdef DWCACHE		
			::faTotGeral := nil
 	  		::faTotGlobal := nil
 	  		::faHeaderX := nil
		#else
			::delCacheInfo("TotGeral")
			::delCacheInfo("TotGlobal")
		#endif
  	endif
return ::fcAutoFilter

/*
--------------------------------------------------------------------------------------
Prepara os parâmetros de AutoFilter, ou seja, Filtro de Seleção
Par: aaFilter, array, array ao qual serão adicionados cada expressão de auto filtro incluída pelo usuário
	 acRnkPrefix, string, prefixo necessário em caso de rank
	 alQbe2Html, lógico, sinaliza se deve ou não gerar a expressão em formato HTML. Default .F., gerando assim o formato SQL.
--------------------------------------------------------------------------------------
*/ 
method prepAutoFilter(aaFilter, acRnkPrefix, alQbe2Html) class TConsulta
	Local aAux, i, x
	
	default aaFilter 	:= {}
	default acRnkPrefix	:= ""
	default alQbe2Html	:= .F.
	
	If !empty(::AutoFilter())
		aAux := dwToken(::AutoFilter(), SEP_DATA, .f.)
		aeval(aAux, { |x,i| aAux[i] := dwToken(aAux[i], chr(254), .f.)})
		
		for i := 1 to len(aAux)
			x := aAux[i]
			if empty(x[1])
				aAux[i] := nil
			else
				if ::haveRank() .and. ::RankOn()
					x[1] := acRnkPrefix + x[1]
				endif
				
				If !alQbe2Html
					aAux[i] := qbe2Sql(x[1], x[2], { x[4] }, x[3])
				Else
					aAux[i] := qbe2Html(x[1], x[2], { x[4] }, x[3])
				EndIf
			endif
		next
		aeval(aAux, { |x| iif(valType(x) == "U", ,aAdd(aaFilter, x))})
	EndIf
return aaFilter

/*
--------------------------------------------------------------------------------------
Nome do campo de rnk
Par: alName, lógico, sinaliza se deve pegar o nome ao invés do Alias interno do campo. Default: .F.
	 alOrder, lógico, sinaliza se deve inserir Order no campo, para instruções SQL. Default: .T.
--------------------------------------------------------------------------------------
*/
method RankField(alName, alOrder, anLevel) class TConsulta
	local cRet := "", aRankInfo, nPos
	
	default alName 	:= .F.
	default alOrder := .T.
	default anLevel := 0
	
	if anLevel == 0
	  anLevel := 1
	endif
	
	aRankInfo := ::RankDef(anLevel)
	nPos := ascan(::Fields(), { |x| x:Dimensao() == 0 .and. x:ID() == aRankInfo[1] })
	
	If nPos > 0
		If !alName
			cRet := ::Fields()[nPos]:Alias()
		Else
			cRet := ::Fields()[nPos]:Name()
		EndIf

		if !empty(cRet) .and. alOrder .and. !(aRankInfo[3] == RNK_MENORES)
			cRet += " desc"
		endif
	EndIf
return cRet 	

/*
--------------------------------------------------------------------------------------
Propriedade Where
--------------------------------------------------------------------------------------
*/
method Where(alAll, alDrill) class TConsulta
	local aWhere := ::Props(ID_WHERE)
	local aRet, nInd
	
	default := alDrill
	
	if alAll
		aRet := aWhere
	else
		aRet := {}
		for nInd := 1 to len(aWhere)
			if aWhere[nInd]:Selected()
				aAdd(aRet, aWhere[nInd])			
			endif
		next
	endif
return aRet
                 
/*
--------------------------------------------------------------------------------------
Propriedade Segto
--------------------------------------------------------------------------------------
*/
method Segto() class TConsulta
return ::Props(ID_SEGTO)
		
/*
--------------------------------------------------------------------------------------
Propriedade Alerts
--------------------------------------------------------------------------------------
*/
method Alerts(alAll) class TConsulta
	local aAlert := ::Props(ID_ALERTS)
	local aRet, nInd
	
	if alAll
		aRet := aAlert
	else
		aRet := {}
		for nInd := 1 to len(aAlert)
			if aAlert[nInd]:Selected()
				aAdd(aRet, aAlert[nInd])			
			endif
		next
	endif
return aRet
			
/*
--------------------------------------------------------------------------------------
Retorna a lista de campos para execução da query
--------------------------------------------------------------------------------------
*/
method PrepField(aaFieldList, aoField, acOper, acAlias, anSeq, alUseAlias, alStruct, alForProc) class TConsulta
	local cValue, cExp
		
	default alUseAlias := .f.
	default alStruct := .f.
	default alForProc := .f.
		
	if aoField:ID() > 0 // campo < 0 é calculado
		anSeq++
		if empty(aoField:Alias())
			aoField:Alias(acAlias + DWInt2Hex(aoField:ID(), 4))
		endif               

		if !alStruct
			if alUseAlias
				cValue := aoField:Alias()
			elseif !alForProc
				cValue := acOper + "(" + aoField:Fullname() + ") " + aoField:Alias()
			else
				if acAlias == "I"
					cValue := "FATO->" + aoField:Name()
				else 
					cValue := aoField:Dimensao() + aoField:Name()
				endif
			endif
		else 
			if aoField:Tipo() == "N" .or. aoField:Temporal() != 0
				cValue := "0"
			else
				cValue := "'" + replicate(" ", aoField:Tam()) + "'"
			endif                
			cValue := acOper + "(" + cValue + ") " + aoField:Alias() 
		endif		
		aAdd(aaFieldList, cValue)
	else
		anSeq++
		if empty(aoField:Alias())
			aoField:Alias("V" + DWInt2Hex(abs(aoField:ID()), 4))
		endif

		if alUseAlias
			aAdd(aaFieldList, aoField:Alias())
		elseif alStruct
			aAdd(aaFieldList, "" + "(0) " + aoField:Alias()) //acOper
		else
		   if !alForProc
				if aoField:isSQL()
					cExp := strTran(aoField:ExpSQL(), "->", "$>")
				else
					cExp := "0"
				endif                 

				if ::haveAggFunc(cExp)
					aAdd(aaFieldList, "(" + cExp  + ") " + aoField:Alias())
				else
					aAdd(aaFieldList, acOper + "(" + cExp  + ") " + aoField:Alias())
				endif
			else 
				if !aoField:isSQL()
					aAdd(aaFieldList, aoField:Expressao())
				endif
			endif
		endif
	endif
return
			
method FieldList(alUseAlias, alStruct) class TConsulta
	local aRet := {}, aAux
	local nInd, i := 0

	default alUseAlias := .f.         
	default alStruct := .f.         
	
	aAux := ::DimFields()
	for nInd := 1 to len(aAux)
		::PrepField(aRet, aAux[nInd], '', 'D', @i, alUseAlias, alStruct)
	next

	aAux := ::IndFields(alUseAlias, alStruct)
	for nInd := 1 to len(aAux)
		aAdd(aRet, aAux[nInd])
	next

	if alStruct
		::OtherFields(.t., aRet, alStruct, alStruct)
	endif
	
	DplItems(aRet, .T.)
return aRet

method FieldListY(alUseAlias) class TConsulta
	local aRet := {}
	local nInd := 0

	default alUseAlias := .f.

	aEval(::DimFields(), { |x| iif(x:Eixo()!="X", ::PrepField(aRet, x, '', 'D', @nInd, alUseAlias),nil)})
return aRet
			
/*
--------------------------------------------------------------------------------------
Retorna a lista de indicadores
--------------------------------------------------------------------------------------
*/
method IndFields(alAlias, alStruct, alExclVirtInd) class TConsulta
	local aRet := {}
	local nInd := 0
	local aInd := ::Indicadores()
	local i,x
			
	default alAlias := .f.
	default alStruct := .f.
	default alExclVirtInd := .f.
	
	for i := 1 to len(aInd)
		x := aInd[i]
		if !alExclVirtInd .or. (alExclVirtInd .and. empty(x:Expressao()))
			::PrepField(aRet, x, x:AggFuncText(), 'I', @nInd, alAlias, alStruct)
		endif
	next
return aRet

method IndVirtual(alAlias, alOnlyName) class TConsulta
	local aRet := {}, nInd := 0, x
	local aInd := ::Indicadores(.t.)
		
	default alAlias := .f.           
	default alOnlyName := .t.
	
	for nInd := 1 to len(aInd)    
		x := aInd[nInd]
		if !empty(x:Expressao())
			if alOnlyName
				::PrepField(aRet, x, x:AggFuncText(), 'V', @nInd, alAlias, nil, .t.)
			else
				aAdd(aRet, x)
			endif
		endif
	next
return aRet
			
/*
--------------------------------------------------------------------------------------
Retorna a lista de tabelas
--------------------------------------------------------------------------------------
*/
static function PrepFrom(aaFromList, aoField, alPeriodo)
	local cTablename := ""        
	                     
	if valType(aoField) == "O"                         
		if substr(aoField:fullName(), 4) == substr(TAB_CALEND +".PERIODO", 4)
			alPeriodo := .t.
		endif
		cTablename := aoField:Tablename()
	else
		cTablename := aoField
	endif	
	
	if !empty(cTablename)                          
		if ascan(aaFromList, { |x| x == cTablename}) == 0
			aAdd(aaFromList, cTablename)
		endif
	endif
return
			
method FromList() class TConsulta
	local aRet := {}, nInd, lPeriodo := .f.
                         
	aAux := ::DimFields()
	for nInd := 1 to len(aAux)
		PrepFrom(aRet, aAux[nInd], @lPeriodo)
	next

	aAux := ::IndList()
	for nInd := 1 to len(aAux)
		PrepFrom(aRet, aAux[nInd], @lPeriodo)
	next

	aAux := ::faIntFrom
	for nInd := 1 to len(aAux)
		PrepFrom(aRet, aAux[nInd], @lPeriodo)
	next

	if lPeriodo
		for nInd := 1 to len(aRet)	
			if left(aRet[nInd],2) == "DW" .and. substr(aRet[nInd],4) == substr(TAB_CALEND,4)
				aRet[nInd] := "DT"+substr(aRet[nInd],3,1)+"1000 " + TAB_CALEND
				lPeriodo := .f.
				exit
			endif     
		next

		if lPeriodo
			aAdd(aRet, "DT01000 " + TAB_CALEND)
		endif
	endif
return aRet
			
/*
--------------------------------------------------------------------------------------
Retorna a lista de campos para agrupamento
--------------------------------------------------------------------------------------
*/
method GroupBy(anLevel) class TConsulta
	local aRet := {}, aAux := {}, nInd
	
	aEval(::GroupByY(anLevel), { |x| aAdd(aRet, x) })
	aEval(::GroupByX(anLevel), { |x| aAdd(aRet, x) })

	::OtherFields(.f., aAux)
	for nInd := 1 to len(aAux)
		x := aAux[nInd]
		if !(left(x:Alias(),1) == "I")
			aAdd(aRet, x:TableName()+"."+x:Name())
		endif
	next
return aRet

method GroupByY(anLevel) class TConsulta
	local aRet := {}, aAux := ::DimFields()
	local nInd

	default anLevel := 0

	for nInd := 1 to len(aAux)
		if aAux[nInd]:Eixo() == "Y"
			aAdd(aRet, iif (anLevel!=0, aAux[nInd]:Alias(), aAux[nInd]:Fullname()))
		endif
	next

	if anLevel != 0
		aSize(aRet, anLevel)
	endif
	
	DplItems(aRet, .T.)
return aRet

method GroupByX(anLevel) class TConsulta
	local aRet := {}, aAux := ::DimFields()
	local nInd

	default anLevel := 0

	for nInd := 1 to len(aAux)
		if aAux[nInd]:Eixo() == "X"
			aAdd(aRet, iif (anLevel!=0, aAux[nInd]:Alias(), aAux[nInd]:Fullname()))
		endif
	next
	
	DplItems(aRet, .T.)
return aRet
			
/*
--------------------------------------------------------------------------------------
Retorna a lista de campos para ordenamento
--------------------------------------------------------------------------------------
*/
method OrderBy(anLevel) class TConsulta
	local aRet := {}, nPos, cAux, aAux
	                  
	if ::RankOn()
    	aAux := ::RankDef(anLevel)
		nPos := ascan(::Fields(), { |x| x:ID() == aAux[1] })
		if nPos <> 0              
			cAux := ::Fields()[nPos]:Alias()
			if !(aAux[3] == RNK_MENORES)
				cAux += " desc"
			endif
			aAdd(aRet, cAux)
		endif
	else
		aRet := ::GroupBy()
	endif
return aRet
			
/*
--------------------------------------------------------------------------------------
Retorna a lista de campos calculados
--------------------------------------------------------------------------------------
*/
method FieldsCalc() class TConsulta
	local aRet := {}
	local aAux := ::IndList(), nInd
		              
	for nInd := 1 to len(aAux)
		if !empty(aAux[nInd]:Expressao())
			aAdd(aRet, aAux[nInd])
		endif
	next
return aRet
			
/*
--------------------------------------------------------------------------------------
Retorna a lista de campos
--------------------------------------------------------------------------------------
*/
method Fields(alAll) class TConsulta
	local aRet := {}
	local nInd := 0
	
	default alAll := .t.
	
	if alAll
		aEval(::DimFields(), { |x| aAdd(aRet, x)})
	else
		aEval(::DimFields(), { |x| iif(empty(x:Expressao()), aAdd(aRet, x), nil)})
	endif
	aEval(::Indicadores(alAll), { |x| aAdd(aRet, x) } )
return aRet
			
/*
--------------------------------------------------------------------------------------
Retorna a lista de indicadores
--------------------------------------------------------------------------------------
*/
method Indicadores(alAll) class TConsulta
	local aRet := {}
  	local aInd := ::IndList()

	default alAll := .t.
	
	if alAll
		aEval(aInd, { |x| iif(x:Ordem() > -1, aAdd(aRet, x), nil)})
		aSort(aRet,,, { |x,y| x:Ordem() < y:Ordem() }) 
		aEval(aInd, { |x| iif(x:Ordem() < 0, aAdd(aRet, x), nil)})
	else
		aEval(aInd, { |x| iif(empty(x:Expressao()), aAdd(aRet, x), nil)})
		aEval(aInd, { |x| iif(!empty(x:Expressao()) .and. x:IsSQL(), aAdd(aRet, x), nil)})
		aSort(aRet,,, { |x,y| x:Ordem() < y:Ordem() }) 
	endif
return aRet

/*
--------------------------------------------------------------------------------------
Retorna a lista de "link" (clausula where para ligação entre tabelas)
--------------------------------------------------------------------------------------
*/                                                  
static function addLinkList(aaList, acItem)
	if ascan(aaList, { |x| x == acItem } ) == 0 //.or. left(x,2) <> "DC" }) == 0
		aAdd(aaList, acItem)
	endif
return

method LinkList() class TConsulta
	local aRet := {}, nDim
	local aDimFields := ::DimFields()
	local nInd, nInd2, lTemporal := .F.
	local aDim, aExpWhere, aDimID	, cAux, cAux2
	local aAllFields := {}

	for nInd := 1 to len(aDimFields)
		if ascan(aRet, { |x| left(x, 8) == aDimFields[nInd]:Tablename() }) == 0
			if aDimFields[nInd]:Temporal() > 0
				addLinkList(aRet, aDimFields[nInd]:Tablename() + "." + aDimFields[nInd]:RealField() + "=" + oSigaDW:Calend():Tablename() + ".DT")
				lTemporal := .t.
			endif
			addLinkList(aRet, aDimFields[nInd]:Tablename()+".ID=" + DWKeyDimname(aDimFields[nInd]:Dimensao()))
		endif
	next
	
	for nInd := 1 to len(::faIntFrom)
		if ascan(aRet, { |x| x <> oSigaDW:Calend():Tablename() .and. left(x, 8) == ::faIntFrom[nInd] }) == 0
			if left(::faIntFrom[nInd],2) <> "DC" .and. ::faIntFrom[nInd] <> oSigaDW:Calend():Tablename()
				nDim := DWHex2Int(right(::faIntFrom[nInd],4))
				if nDim != 0
					addLinkList(aRet, ::faIntFrom[nInd]+".ID=" +DWKeyDimname(nDim))
				endif
			endif
		endif
	next

	aExpWhere := ::WhereList()
	oCube := ::Cube()
	aDimID := aClone(oCube:DimProp('ID'))    
	for nInd := 1 to len(aExpWhere)             
		cAux := DWConcatWSep(" ", aExpWhere[nInd])
		for nInd2 :=1 to len(aDimID)
			cAux2 := oCube:DimObj(aDimID[nInd2]):Tablename()
			if cAux2 $ cAux                                              
				nDim := DWHex2Int(right(cAux2,4))
				::AddIntFrom(cAux2)
				addLinkList(aRet, cAux2+".ID=" +DWKeyDimname(nDim))
			endif
		next
	next

	aExpWhere := ::Segto()
	oCube := ::Cube()
	aDimID := aClone(oCube:DimProp('ID'))    
	for nInd := 1 to len(aExpWhere)             
		if valType(aExpWhere[nInd]) == "O"
			cAux := DWConcatWSep(" ", aExpWhere[nInd]:ExpSql())
		else
			cAux := DWConcatWSep(" ", aExpWhere[nInd])
		endif
		
		for nInd2 :=1 to len(aDimID)
			cAux2 := oCube:DimObj(aDimID[nInd2]):Tablename()
			if cAux2 $ cAux                                              
				nDim := DWHex2Int(right(cAux2,4))
				::AddIntFrom(cAux2)
				addLinkList(aRet, cAux2+".ID=" +DWKeyDimname(nDim))
			endif            
		next
		
		aAllFields := ::GetAllFields()
		for nInd2 := 1 to len(aAllFields)
		    if aAllFields[nInd2][1] $ cAux
		       cAux := strtran(cAux, aAllFields[nInd2][1], aAllFields[nInd2][7]+"."+aAllFields[nInd2][6])
		    endif
		next
		addLinkList(aRet, cAux)
	next

	if lTemporal
		::AddIntFrom(oSigaDW:Calend():Tablename())
	endif
return aRet
		
/*
--------------------------------------------------------------------------------------
Retorna a lista de "where"
--------------------------------------------------------------------------------------
*/
method WhereList(alAll, alHist, alStruc) class TConsulta
	local aRet := {}, nInd, oWhere, aWhere := ::Where(.t.), aAux
	local aDateFields := {}, lFiltered
	local lUserIsAdm := .t.
	
	default alAll := .f.      
	default alHist := .f.      
  	default alStruc := .f.
  
  	lFiltered := ::Filtered() .or. alStruc
	if valType(oUserDW) <> "U"
    	lUserIsAdm := oUserDW:UserIsAdm()
	endif
	     
	if alHist
		aEval(::getAllFields(), { |x,i| if(x[2] == "D", aAdd(aDateFields, x), nil) })
	endif

	for nInd := 1 to len(aWhere)
		oWhere := aWhere[nInd]
		if oWhere:IsSQL() .and. !oWhere:IsInd() .and. ;
			((oWhere:ApplySecure() .and. !lUserIsAdm) .or. ;
		    (lFiltered .and. (alAll .or. oWhere:Selected())))
			if alHist
				if oWhere:isTemporal(adateFields)
					aAux := nil
				else
					aAux := oWhere:ExpSQL(, , , alStruc)
				endif
			else
				aAux := oWhere:ExpSQL(, , , alStruc)
			endif
			
			if !empty(aAux)
				aAdd(aRet, aAux)
			endif
		endif
	next
return aRet
			
/*
--------------------------------------------------------------------------------------
Retorna a lista de "advPl" para seleção de registro
--------------------------------------------------------------------------------------
*/
method AdvPlList() class TConsulta
	local aRet := {}, aAux := ::Where(), nInd
	
	for nInd := 1 to len(aAux)                
		if !aAux[nInd]:IsSQL()
			aAdd(aRet, aAux[nInd]:ExpAdvpl())
		endif
	next
return aRet
			
/*
--------------------------------------------------------------------------------------
Retorna a lista de "having"
--------------------------------------------------------------------------------------
*/                                     	
method HavingList(alAll) class TConsulta
	local aRet := {}, nInd, oWhere               
	local aWhere, cAux, aInd := {}
	         
	if ::Filtered()
		default alAll := .f.
		
		aWhere := ::Where(.t.)	
		aEval(::IndFields(.f., , .t.), {|x| x := DWToken(x," ", .f.), aAdd(aInd,{ x[2], x[1] } ) })

		for nInd := 1 to len(aWhere)
			oWhere := aWhere[nInd]
			if oWhere:IsInd() .and. oWhere:IsSQL() .and. (alAll .or. oWhere:Selected())
				cAux := DWConcatWSep(" ", oWhere:ExpSQL(,.t., .t.))
				aEval(aInd, { |x| cAux := strTran(cAux, x[1], x[2]) })
				aAdd(aRet, cAux)
			endif
		next
	endif
return aRet
			
/*
--------------------------------------------------------------------------------------
Recupera as definições de um campo a partir de seu ID
--------------------------------------------------------------------------------------
*/
method FieldByID(anID, alInd) class TConsulta
	local oRet, nPos
	local aFields := ::Fields()

	default alInd := .f.
	                           
	if alInd
		nPos := aScan(aFields, {|x| !x:DimField() .and. x:ID() == anID})
	else
		nPos := aScan(aFields, {|x| x:DimField() .and. x:ID() == anID})
	endif
	
	if nPos <> 0
		oRet := aFields[nPos]
	endif
return oRet
			
/*
--------------------------------------------------------------------------------------
Adiciona nome de tabela na lista interna "from"
--------------------------------------------------------------------------------------
*/
method AddIntFrom(acValue) class TConsulta
	local nPos := at(".", acValue)
	
	if nPos != 0
		acValue := left(acValue, nPos - 1)
	endif         
	
	if acValue != "->"                                      
		acValue := upper(acValue)
		nPos := ascan(::faIntFrom, { |x| upper(x) == acValue})
		if nPos == 0
			aAdd(::faIntFrom, acValue)
		endif
	endif	
return
			
/*
--------------------------------------------------------------------------------------
Constroi a tabela de consulta
--------------------------------------------------------------------------------------
*/
method BuildTable() class TConsulta
	local oDataset, aParams
	local oTable, oQuery, aFieldList := {}, lOk := .t.
	local aAux, aAux2, cSQL, nInd, nInd2, i, aAllFields
	local aFromAux := {}, aLinkAux := {}
	local oLockCtrl, lWaitMode := .f.
	local lFiltro, lAlerta
	local aDimKeys := {}, aGroups := {}
	local aInd, aOthers := {}, aCompl
	local aSQL, oStat := initTable(TAB_ESTAT)
	
  	if dwIsDebug()
		dwStatOn(STR0007 + " " + ::Name() + " - " + ::WorkFile()+ " (" + STR0008 + dwCubeName(::Cube():id()) + ")")  //"Construindo agregado"  //"Fato:"
  	else
		dwStatOn(STR0007 + ::Name())  //"Construindo agregado"
	endif
	  
	::fdInicio := date()
	::fcInicio := time()
	::fnTotProcs := 5
	::fnPageExp := 0
	::fnTempoEst := 0

  	if oStat:seek(2, { ST_BUILD_QUERYS, ::ID() } )
    	::fnTempoEst := oStat:value("Valor")
  	endif

	::IPCNotify(STR0009)  //"Iniciando construção"
	::IPCNotify(STR0010 + ::Name() + "-" + ::Desc(), .t.)  //"Consulta "
	
	// tratamento de lock (para evitar mais de um buildtable simultaneo)
	// caso entre em "modo espera", após a liberação, este processo
	// não será executado
	oLockCtrl := TDWFileIO():New(DwTempPath() + "\" + ::WorkFile(), ".lck")
	::foLockCtrl := oLockCtrl
	if !oLockCtrl:exists()
		oLockCtrl:Create(FO_EXCLUSIVE + FO_WRITE)
	else
		oLockCtrl:Open(FO_EXCLUSIVE + FO_WRITE)
	endif
	
	if !oLockCtrl:isOpen()
		lWaitMode := .t.
		::IPCNotify(STR0005, .t.)  //"Processo de construção já esta em andamento por outro JOB"
		conout(STR0005) //"Processo de construção já esta em andamento por outro JOB"
		conout(STR0006)  //"Iniciando modo de espera"
		dwStatOn(STR0011 + iif(DWIsDebug(), ::WorkFile(), ::Name())) //"Modo de espera "
	
		while !oLockCtrl:Open(FO_EXCLUSIVE + FO_WRITE)
			sleep(500)
		enddo
		oLockCtrl:Close()
		dwStatOff()
	endif
	
	if !lWaitMode
		::ipcNotify(STR0012)  //"Definindo estrutura"
		
		::Invalidate()
		oTable := ::getTable(.t.,,.f.)
		if oTable:Exists()
			oTable:DropTable()
		endif
		oTable:CreateTable()
		oTable:Open()            
		oTable:Close()
		
    	lFiltro := ::Filtered()
		if ::_Type() == TYPE_TABLE
    		lAlerta := ::AlertOn()
	 	endif
    	
    	::Filtered(.t.)
		if ::_Type() == TYPE_TABLE
  	  		::AlertOn(.t.)
		else
	    	::AlertOn(.f.)	
		endif

		aAux := ::DimFields()
		for nInd := 1 to len(aAux)
			aAdd(aDimKeys, aAux[nInd]:Alias())
		next
		
		// Monta a tabela de agregados
		oQuery := TQuery():New(DWMakeName("TRA"))
		oQuery:WithDeleted(.F.)
		aAux := {}
		aAux2	:= ::FieldList()
		for nInd := 1 to len(aAux2)
			aAdd(aAux, strtran(aAux2[nInd], "Fato$>", dwCubeName(::Cube():id())+"."))
		next
		
		aAllFields := ::getAllFields()
		for nInd := len(aAux) to 1 step - 1
			if  !::haveAggFunc(aAux[nInd])
				for nInd2 := 1 to len(aAllFields)
					if aAllFields[nInd2, 8] $ upper(aAux[nInd])
						aAdd(aAux, "sum("+aAllFields[nInd2, 8]+") " + aAllFields[nInd2, 5])
					elseif aAllFields[nInd2, 9] $ upper(aAux[nInd])
						aAdd(aAux, "sum("+aAllFields[nInd2, 8]+") " + aAllFields[nInd2, 5])
					endif
				next
			endif
		next
		
		aAux2	:= ::OtherFields(, , , , .t.)
		for nInd := 1 to len(aAux2)
			if aAux2[nInd]:Temporal() == 0 .or. aAux2[nInd]:Temporal() == -1
				if left(aAux2[nInd]:Alias(),1) == "I"
					if !empty(aAux2[nInd]:ExpSQL()) .and. ::haveAggFunc(aAux2[nInd]:ExpSQL())
						cAux := strTran(aAux2[nInd]:ExpSQL(),"FATO->", aAux2[nInd]:TableName() + "." ) + " " + aAux2[nInd]:Alias()
					else
						cAux := aAux2[nInd]:AggFuncText(.t.)+"("+aAux2[nInd]:TableName() + "." +aAux2[nInd]:name()+") "+aAux2[nInd]:Alias()
					endif
				else
					cAux := "("+ aAux2[nInd]:TableName() + "." + aAux2[nInd]:Name() + ") " + aAux2[nInd]:Alias()
				endif
			elseif aAux2[nInd]:Temporal() == DT_ANO
				cAux := "max(" + DWSQLFunc("SUBSTR", aAux2[nInd]:TableName() + "." + aAux2[nInd]:Name(), 1, 4) + ") " + aAux2[nInd]:Alias()
			elseif aAux2[nInd]:Temporal() == DT_ANOMES
				cAux := "max(" + DWSQLFunc("SUBSTR", aAux2[nInd]:TableName() + "." + aAux2[nInd]:Name(), 1, 6) + ") " + aAux2[nInd]:Alias()
			elseif aAux2[nInd]:Temporal() == DT_MES
				cAux := "max(" + DWSQLFunc("SUBSTR", aAux2[nInd]:TableName() + "." + aAux2[nInd]:Name(), 5, 2) + ") " + aAux2[nInd]:Alias()
			else
				cAux := "("+ aAux2[nInd]:TableName() + "." + aAux2[nInd]:Name() + ") " + aAux2[nInd]:Alias()
			endif
		
			aAdd(aAux, cAux)
			if !(left(aAux2[nInd]:Alias(),1) == "I")
				aAdd(aDimKeys, aAux2[nInd]:Alias())
				aAdd(aGroups, aAux2[nInd]:TableName() + "." + aAux2[nInd]:Name())
			endif
		next

		if SGDB() $ DB_MSSQL_ALL
			aAdd(aAux, "identity(int,1,1) R_E_C_N_O_") //ATENÇÃO: Ao modificar este comando, verificar em TQuery:InsertInto, pois há um strTran com base nele
			aAdd(aAux, "' ' "  + DWDelete() )
		elseif SGDB() = DB_ORACLE
			aAdd(aAux, "0 R_E_C_N_O_") //ATENÇÃO: Ao modificar este comando, verificar em TQuery:InsertInto, pois há um strTran com base nele
			aAdd(aAux, "' ' " + DWDelete() )
		else
			aAdd(aAux, "max("+dwCubeName(::Cube():id())+".R_E_C_N_O_) R_E_C_N_O_") //ATENÇÃO: Ao modificar este comando, verificar em TQuery:InsertInto, pois há um strTran com base nele
		endif
		aAdd(aAux, "'0' L_E_V_E_L_")
		
		aSegto := aClone(::Segto())
		aeval(aSegto, {|x,i| aSegto[i] := dwConcatWSep(" and ", aSegto[i]:expSQL())})
		for nInd := 1 to len(aSegto)
			for nInd2 := 1 to len(aAllFields)
				if aAllFields[nInd2, 8] $ upper(aSegto[nInd]) .or. aAllFields[nInd2, 1] $ upper(aSegto[nInd])
					aAdd(aFromAux, aAllFields[nInd2, 7])
					if left(aAllFields[nInd2, 7], 2) == "DD"
						aAdd(aLinkAux, aAllFields[nInd2, 7]+".ID=" + DWKeyDimname(dwHex2Int(right(aAllFields[nInd2, 7], 4))) )
					endif
				endif
			next
		next
		
		aAux := removeDpl(aAux, 2)
		if SGDB() == DB_POSTGRES
			for i := 1 to len(aAux)
				aAux[i] := left(aAux[i],at(")",aAux[i])) + " AS " +substr(aAux[i], at(")",aAux[i])+2, length(aAux[i])-at(")",aAux[i])+1)
			next
		endif
		oQuery:FieldList(DWConcatWSep(",", aAux))
		
		aEval(::LinkList(), { |x| aAdd(aLinkAux, x), iif(TAB_CALEND $ x, aAdd(aFromAux,TAB_CALEND), nil) })
		aEval(::FromList(), { |x| aAdd(aFromAux, x) })
		aFromAux := removeDpl(aFromAux)
		aLinkAux := removeDpl(aLinkAux)
		oQuery:WhereClause(DWConcatWSep(" and ", aLinkAux))
		oQuery:FromList(DWConcatWSep(",", aFromAux))
		aEval(::GroupBy(), { |x| aAdd(aGroups, x) } )
    	aGroups := removeDpl(aGroups)
		oQuery:GroupBy(DWConcatWSep(",", aGroups))
		
		for nInd := 1 to len(aAux)
			nPos := rat(" ", aAux[nInd])
			aAdd(aFieldList, substr(aAux[nInd], nPos+1))
		next
		
		aFieldList := removeDpl(aFieldList, 1)
		oQuery:WithDelete(.t.)
		
		if SGDB() $ DB_MSSQL_ALL
			oQuery:execute(EX_DROP_TABLE, ::Workfile()) // remove tabela
			cSQL := oQuery:SelectInto(aFieldList, "dbo."+::Workfile())
		elseif SGDB() = DB_ORACLE
			if DWOraProcess() == ORA_INSERT_INTO
				cSQL := oQuery:InsertInto(aFieldList, ::Workfile(), .f. )
			elseif DWOraProcess() == ORA_MERGE
				cSQL := oQuery:Merge(aFieldList, ::Workfile(), aDimKeys)
			else // ORA_CTAS
				cSQL := { }
				oQuery:execute(EX_DROP_TABLE, ::Workfile())
				aAdd(cSQL, "create table " + ::Workfile() + " unrecoverable ")
				aAdd(cSQL, "as " + ::PrepareSQL(oQuery:SQL()))
			endif
		else
			if SGDB() = DB_DB2
				oTable:DropRecnoIndex()
			endif
			cSQL := oQuery:InsertInto(aFieldList, ::Workfile(), .t. )
		endif
		
		::ipcNotify(STR0001)  //"Montagem de agregados"
		if SGDB() <> DB_ORACLE
			dwStatOn(STR0001)  //"Montagem de agregados"
		else
			dwStatOn(STR0001 + " (" + iif(DWOraProcess()==ORA_INSERT_INTO, 'default',iif(DWOraProcess()==ORA_MERGE, 'merge', 'ctas')) + ")") //"Montagem de agregados"
		endif

		cSQL := ::PrepareSQL(cSQL)

		aParams := ::params()
    	for nInd := 1 to len(aParams)                                    
      		cAux := dwStr(aParams[nInd, 2])
      		if empty(cAux)
        		cAux := "''"
      		else
        		cAux := aParams[nInd, 2]
      		endif
      	
      		if valType(cSQL) == "A"
      			aEval(cSQL, { |x,i| cSQL[i] := strTran(x, "["+aParams[nInd,1]+"]", cAux) })
      		else
	    		cSQL := strTran(cSQL, "["+aParams[nInd,1]+"]", cAux)
	   		endif
    	next

		if DWSQLExec(cSQL) == 0
			lOk := .t.
			dwStatOn(STR0002) //"Sequenciando resultado"
			::ipcNotify(STR0002)  //"Sequenciando resultado"
			if SGDB() <> DB_ORACLE .or. DWOraProcess() != 2 // CTAS
				if lOk
					dwStatOn(STR0002) //"Sequenciando resultado"
					oTable:RebuildRecno()
					dwStatOff()
				endif
			endif
			oTable:Reindex()
			dwStatOff()
			
			// remove os registros sumarizados, quando todos os indicadores forem igual a ZERO
			if ::IgnoreZero()
				::ipcNotify(STR0014)  //"Ignorando indicadores igual ZERO"
				aInd := ::Indicadores(.t.)
				for nInd := 1 to len(aInd)
					aInd[nInd] := aInd[nInd]:Alias() + " = 0"
				next
				cSQL := "delete from " + oTable:Tablename() + " where " + dwConcatWSep(" and ", aInd)
				lOk := DWSQLExec(::PrepareSQL(cSQL)) == 0
			endif
			oTable:Refresh()
		
			// transforma campos com conteúdo "vazio" para ".", somente eixo X
			if len(::FieldsCalc()) > 0 .and. ::DimCountX() > 0
				aAux := ::DimFieldsX()
				aSql := {}
				dwStatOn(STR0003)  //"Ajuste de campo 'vazios'"
				::ipcNotify(STR0015)  //"Ajustando valores"
				for nInd := 1 to len(aAux)
					if aAux[nInd]:Tipo() == "C"
						aAdd(aSql, "update " + oTable:Tablename() + " set " +;
						aAux[nInd]:alias() + " = '.' where " +;
						aAux[nInd]:alias() + " = ''")
					endif
				next
				lOk := DWSQLExec(aSql) == 0
				dwStatOff()
			endif
			
			// valida a consulta
			if lOk
				::Validate()
			endif
		else
			lOk := .f.
		endif // FIM DO IF DWSQLExec(cSQL) == 0
    	
    	::Filtered(lFiltro)
		if ::_Type() == TYPE_TABLE
  	  		::AlertOn(lAlerta)
		endif

    	if lOk
		  	::ipcNotify(STR0016)  //"Atualizando estatísticas no Banco de Dados"
      		oTable:updStat()
    	endif
	endif // FIM DO IF lWaitMode
	
	oLockCtrl:Close()
	dwStatOff()
	oDataset := InitTable(TAB_CONSULTAS)
	oDataset:savePos()
	if oDataset:Seek(1, { ::ID() })         
		oDataset:update( {{"erro", !lOk } })
	endif             
	oDataset:restPos()
                                           
  	::fnTempoEst := dwElapSecs(::fdInicio, ::fcInicio, date(), time())
  	if !oStat:seek(2, { ST_BUILD_QUERYS, ::ID() } )
    	oStat:append( { { "tipo", ST_BUILD_QUERYS }, { "id_obj", ::id() }, { "valor", 0 }, { "Compl", "999999999/0" } } )
  	endif                                                       

  	aCompl := dwToken(oStat:value("compl"), "/")
  	aCompl[1] := min(aCompl[1], ::fnTempoEst)
  	aCompl[2] := max(aCompl[2], ::fnTempoEst)
  	oStat:update( { { "valor", ::fnTempoEst }, { "compl", dwConcatWSep("/", aCompl) } } )
  
	if lOk
		::ipcNotify(STR0017)  //"Processo concluído"
		::ipcNotify("*END*", .t.)
	else              
		::ipcNotify("*ERROR*")
	endif
	dwStatOff()
return .t.

/*
--------------------------------------------------------------------------------------
Monta o comando SQL para executar a consulta
Args: lOnlyStruc -> logico, gerar SQL que não retorna dados
--------------------------------------------------------------------------------------
*/
method SQLSelect(lOnlyStruc) class TConsulta
return ::SQLObject(lOnlyStruc):SQL()

/*
--------------------------------------------------------------------------------------
Monta o comando SQL para a pré-seleção (link)
Args: 
--------------------------------------------------------------------------------------
*/
method SQLLink(alOnlyStruct) class TConsulta
	local aDim := ::Cube():DimProp('ID')
	local nInd, oDim, nID
	local aFields := {},  aFrom := {}, aWhere := {}
	local oQuery, aAux, cLastFrom
	local aIndVirt, nInd2                                     
	
	default alOnlyStruct := .f.

	cLastFrom := dwCubeName(::Cube():id())
	aAdd(aFields, cLastFrom+".ID ID")

	for nInd := 1 to len(aDim)
		oDim := ::Cube():DimObj(aDim[nInd])
		aAdd(aFields, DWKeyDimname(aDim[nInd]))
		aAdd(aFrom, oDim:Tablename())
		aAdd(aWhere, aTail(aFields)+"="+aTail(aFrom)+".ID")
	next                 	

	if !alOnlyStruct
		aAdd(aFields, cLastFrom+"." + DWDelete() + DWDelete() )
		aAdd(aFields, cLastFrom+".R_E_C_N_O_ R_E_C_N_O_")
	endif
	
	aAdd(aFrom, cLastFrom)
	
	aIndVirt := {}
	aEval(::IndList() , { |x| iif(!empty(x:Expressao()), aAdd(aFields, '0 ' + x:FullName()), nil)})

	oQuery := TQuery():New(DWMakeName("LNK"))
	oQuery:WithDeleted(.F.)
	oQuery:MakeDistinct(.T.)
	oQuery:FieldList(DWConcatWSep(",", aFields))
	oQuery:FromList(DWConcatWSep(", ", aFrom))
	if alOnlyStruct
		aAdd(aWhere, atail(::FromList())+".R_E_C_N_O_ = (select min(ID) from " + atail(::FromList())+ ")")
	endif 
	oQuery:WhereClause(DWConcatWSep(" and ", aWhere))
return oQuery

method SQLObject(lOnlyStruc, anLevel, alCount, alLink) class TConsulta
	local oQuery, aAux, aAux2, nInd
	
	default alCount := .f.
		
	oQuery := TQuery():New(DWMakeName("TRA"))
	oQuery:WithDeleted(.F.)
	aAux := {}
	if lOnlyStruc           
		aAux2 := ::FieldList(, .T.)
		aEval(aAux2, { |x| aAdd(aAux, x) })
	else	
		aAdd(aAux, DWConcatWSep(",", ::FieldList()))
		aAux2 := {}
		aEval(::OtherFields(), { |x| aAdd(aAux2, x:Fullname() + " " + x:Alias())})
		if len(aAux2) > 0
			aAdd(aAux, DWConcatWSep(",", aAux2))
		endif
	endif	
	
	oQuery:FieldList(DWConcatWSep(",", aAux))
	aAux := aClone(::LinkList(.t.))
	if lOnlyStruc
		aAdd(aAux, "0=1")
	else                      
		oQuery:OrderBy(DWConcatWSep(",", ::OrderBy()))
	endif
	oQuery:WhereClause(DWConcatWSep(" and ", aAux))
	oQuery:FromList(DWConcatWSep(",", ::FromList(.t.)))
	oQuery:GroupBy(DWConcatWSep(",", ::GroupBy()))

	aParams := aClone(::Params())
	for nInd := 1 to len(aParams)
		if "&" == left(aParams[nInd,2],1)
			aParams[nInd,2] := subStr(aParams[nInd,2], 2)
		endif
		oQuery:AddParam(aParams[nInd,1], &(aParams[nInd,2]))
	next
return oQuery

/*
--------------------------------------------------------------------------------------
Prepara objeto SQL para totalizações
--------------------------------------------------------------------------------------
*/
method SQLTotal(anLevel, aaWhere, acSelect, anLevelX, acOrder) class TConsulta
	local aBase , oQuery
	local aWhere := aaWhere

 	if !empty(::HavingList())                               
		aBase := ::StructBase((::DimCountY()), aWhere, .t., anLevelX)
	else
		aBase := ::StructBase(iif(anLevel==0, -1, anLevel), aWhere, .t., anLevelX)
 	endif
 	
	oQuery := ::makeSQL(aBase, FIRST_PAGE,,acOrder,,,acSelect, .t., anLevelX, anLevel)
return oQuery

method SQLTotPareto() class TConsulta
	local oQuery, cAlias, aAux
	local aDimY, aDimX, aFieldList, aInd
	local nInd
	
	oQuery := TQuery():New(DWMakeName("TRA"))
	::FieldList()

	aDimY := {}
	aDimX := {}
	aInd := {}
	aFieldList := {}
                       
	aAux := aClone(::DimFieldsY())
	for nInd := 1 to len(aAux)
		cAlias := aAux[nInd]:Alias()
		aAdd(aDimY, cAlias)
		aAdd(aFieldList, cAlias)
	next

	aAux := ::DimFieldsX()
	for nInd := 1 to len(aAux)
		cAlias := aAux[nInd]:Alias()
		aAdd(aDimX, cAlias)
		aAdd(aFieldList, cAlias)
	next
   	                       
	aAux := {}
	::OtherFields(.f., aAux)
	for nInd := 1 to len(aAux)
		cAlias := aAux[nInd]:Alias()
		aAdd(aDimX, cAlias)
		aAdd(aFieldList, cAlias)
	next

	aAux := ::Indicadores(.t.)
	for nInd := 1 to len(aAux)
		if !empty(aAux[nInd]:ExpSQL()) .and. ::haveAggFunc(aAux[nInd]:ExpSQL())
			aAdd(aInd, (aAux[nInd]:ExpSQL()) + " " + aAux[nInd]:Alias())
		else
			aAdd(aInd, aAux[nInd]:AggFuncText(.t.)+"("+aAux[nInd]:Alias()+") "+aAux[nInd]:Alias())
		endif

		aAdd(aFieldList, aAux[nInd]:Alias())
	next

	if(::_Type() == TYPE_GRAPH)
		PrepEixo3(nil, oQuery, ::Workfile(), aDimY, aInd, aFieldList, anLevel)
	else
		if len(aDimY) == 0
			PrepEixo2(nil, oQuery, ::Workfile(), aDimX, aDimY, aInd, aFieldList, ::Workfile(), len(::AdvPLList()) != 0)
   	else
			PrepEixo2(nil, oQuery, ::Workfile(), aDimY, aDimX, aInd, aFieldList, ::Workfile(), len(::AdvPLList()) != 0)
		endif
	endif
   
	for nInd := 1 to len(::Params())
		oQuery:AddParam(::Params()[nInd, 1], ::Params()[nInd, 2])
	next
return oQuery

/*
--------------------------------------------------------------------------------------
Prepara objeto SQL com acumulações
--------------------------------------------------------------------------------------
*/
method SQLAcum(acWhere, acKeyCount) class TConsulta
	local aBase , oQuery, cAlias, aAux, nInd
	local aDimY, aDimX, aFieldList, aInd, x
	local lHaveCalc := .f., cAux, aIndaux
	Local lRanking := ::HaveRank() .And. ::RankOn()
                       
	aBase := ::StructBase(-1, , .t.)
	oQuery := TQuery():New(DWMakeName("TRA"))
	::FieldList()

	aDimY := {}
	aDimX := {}
	aInd := {}
	aFieldList := {}
                       
	aAux := aClone(::DimFieldsY())
	for nInd := 1 to len(aAux)
		cAlias := aAux[nInd]:Alias()
		aAdd(aDimY, cAlias)
		if SGDB() == DB_DB2
			if aAux[nInd]:Tipo() == "N"
				cAux := 'cast(null as float) ' + cAlias
			else
				cAux := 'cast(null as char) ' + cAlias
			endif
		else
			cAux := 'null ' + cAlias
		endif
		aAdd(aFieldList, cAux)
	next

	aAux := ::DimFieldsX()
	for nInd := 1 to len(aAux)
		cAlias := aAux[nInd]:Alias()
		aAdd(aDimX, cAlias)
		if SGDB() == DB_DB2
			if aAux[nInd]:Tipo() == "N"
				cAux := 'cast(null as float) ' + cAlias
			else
				cAux := 'cast(null as char) ' + cAlias
			endif
		else
			cAux := 'null ' + cAlias
		endif
		aAdd(aFieldList, cAux)
	next

	// ignorar campos em ::OtherFields
	aAux := ::Indicadores(.t.)
	for nInd := 1 to len(aAux)          
		if aAux[nInd]:AggFunc() == AGG_MEDINT .or. aAux[nInd]:AggFunc() == AGG_ACUM .or. aAux[nInd]:AggFunc() == AGG_ACUMPERC
			if !empty(aAux[nInd]:ExpSQL())
				if ::haveAggFunc(aAux[nInd]:ExpSQL())
					aAdd(aInd, "("+aAux[nInd]:ExpSQL()+") "+aAux[nInd]:Alias())
				else
					aAdd(aInd, aAux[nInd]:AggFuncText(.t.)+"("+aAux[nInd]:ExpSQL()+") "+aAux[nInd]:Alias())
				endif
			else
				aAdd(aInd, aAux[nInd]:AggFuncText(.t.)+"("+aAux[nInd]:Alias()+") "+aAux[nInd]:Alias())
			endif

			if aAux[nInd]:AggFunc() == AGG_MEDINT 
				aAdd(aInd, "count(distinct "+acKeyCount+") CNT_" + aAux[nInd]:Alias())
			else
				aAdd(aInd, "1 CNT_" + aAux[nInd]:Alias())
			endif
			
			If lRanking .and. ::RankDef()[1][1] == aAux[nInd]:ID() 			                               
				aAdd(aInd, "sum(" + aAux[nInd]:Alias() + ") R_A_N_K_")
			EndIf
			
			lHaveCalc := .t.
		else
			aAdd(aInd, "0 " + aAux[nInd]:Alias())
		endif
	next
	
	oQuery:FromList(::Workfile() + " S") 
 	oQuery:FieldList(dwConcatWSep(",", aFieldList) + ", " + dwConcatWSep(",", aInd))

	aAux := { }
	
	If !lRanking .and. !empty(acWhere)
		aAdd(aAux, acWhere)
	endif
    
	if !empty(aBase[ID_FILTER])
		aAdd(aAux, aBase[ID_FILTER])
	endif

	if !empty(oQuery:WhereClause())
		aAdd(aAux, oQuery:WhereClause())
	endif     

	if !empty(::DDFilter())
		aAdd(aAux, dwConcatWSep(" and ", ::DDFilter()))
	endif      

	oQuery:WhereClause(dwConcatWSep(" and ", aAux))
	for nInd := 1 to len(::Params())
		oQuery:AddParam(::Params()[nInd, 1], ::Params()[nInd, 2])
	next

	if ::DrillLevel() <> 0
		aSize(aDimY, ::DrillLevel())
	endif
	oQuery:GroupBy(dwConcatWSep(",", aDimY))
	oQuery:WithDeleted(.t.)
	
	if lHaveCalc
		aAux := {}
		aAdd(aAux, "select")
		aAdd(aAux, dwConcatWSep(",", aFieldList) + ",")
		
		aInd := {}
		aIndAux := ::Indicadores(.t.)
		for nInd := 1 to len(aIndAux)
			x := aIndAux[nInd]
			if x:AggFunc() == AGG_MEDINT .or. x:AggFunc() == AGG_ACUM .or. x:AggFunc() == AGG_ACUMPERC
				aAdd(aInd, "sum(" + x:Alias() + ") " + x:Alias())
				if x:AggFunc() == AGG_MEDINT 
					aAdd(aInd, "sum(CNT_" + x:Alias() + ")" + "CNT_" + x:Alias())
				else
					aAdd(aInd, "1 CNT_" + x:Alias())
				endif
			else
				aAdd(aInd, "0 " + x:Alias())
			endif
		next
		aAdd(aAux, dwConcatWSep(",", aInd))
		
		cAux := oQuery:SQL() 

		if ::RankOn()
			cAux := strTran(cAux, "R.D", "S.D")
		endif
		aAdd(aAux, "from ( " + cAux + ") X")
		
		If lRanking
			If !empty(acWhere)
				// retira qualquer sinal, trocando por '0'
				acWhere := strTran(acWhere, "-", "0") + " AND "
			EndIf
			aAdd(aAux, "where " + acWhere + strTran(aBase[ID_RANK_LIMIT], "R.", "X."))
		EndIf   
		
		cAux := ::prepareSQL(dwConcatWSep(" ", aAux), .t.)
	else
		cAux := ::prepareSQL(oQuery:SQL(), .t.)
	endif

	oQuery:Open(, cAux)
return oQuery

/*
--------------------------------------------------------------------------------------
Prepara objeto SQL com acumulações históricas
--------------------------------------------------------------------------------------
*/
method SQLAcumHist(acWhere, acKeyCount) class TConsulta
	local aBase , oQuery, cAlias, aAux, nInd
	local aDimY, aDimX, aFieldList, aInd, x
	local lHaveCalc := .f., cAux 
                 
	aBase := ::StructBase(-1, , .t.,, .t.)
	oQuery := TQuery():New(DWMakeName("TRA"))
	::FieldList()

	aDimY := {}
	aDimX := {}
	aInd := {}
	aFieldList := {}
                       
	aAux := aClone(::DimFieldsY())
	for nInd := 1 to len(aAux)
		cAlias := aAux[nInd]:Alias()
		aAdd(aDimY, cAlias)
		if SGDB() == DB_DB2
			if aAux[nInd]:Tipo() == "N"
				cAux := 'cast(null as float) ' + cAlias
			else
				cAux := 'cast(null as char) ' + cAlias
			endif
		else
			cAux := 'null ' + cAlias
		endif
		aAdd(aFieldList, cAux)          
	next

	aAux := ::DimFieldsX()
	for nInd := 1 to len(aAux)
		cAlias := aAux[nInd]:Alias()
		aAdd(aDimX, cAlias)
		if SGDB() == DB_DB2
			if aAux[nInd]:Tipo() == "N"
				cAux := 'cast(null as float) ' + cAlias
			else
				cAux := 'cast(null as char) ' + cAlias
			endif
		else
			cAux := 'null ' + cAlias
		endif
		aAdd(aFieldList, cAux)          
	next

	// ignorar campos em ::OtherFields
	aAux := ::Indicadores(.t.)
	for nInd := 1 to len(aAux)          
		if aAux[nInd]:AggFunc() == AGG_ACUMHIST .or. aAux[nInd]:AggFunc() == AGG_ACUMHISTPERC
			if !empty(aAux[nInd]:ExpSQL())
				if ::haveAggFunc(aAux[nInd]:ExpSQL())
					aAdd(aInd, "("+aAux[nInd]:ExpSQL()+") "+aAux[nInd]:Alias())
				else
					aAdd(aInd, aAux[nInd]:AggFuncText(.t.)+"("+aAux[nInd]:ExpSQL()+") "+aAux[nInd]:Alias())
				endif
			else
				aAdd(aInd, aAux[nInd]:AggFuncText(.t.)+"("+aAux[nInd]:Alias()+") "+aAux[nInd]:Alias())
			endif
			lHaveCalc := .t.
		else
			aAdd(aInd, "0 " + aAux[nInd]:Alias())
		endif
	next

	oQuery:FromList(::Workfile() + " S") 
	oQuery:FieldList((dwConcatWSep(",", aFieldList) + ", " + dwConcatWSep(",", aInd)))
		
	aAux := { }

	if !empty(acWhere)
		aAdd(aAux, acWhere)
	endif

	if !empty(aBase[ID_FILTER])
		aAdd(aAux, aBase[ID_FILTER])
	endif

	if !empty(oQuery:WhereClause())
		aAdd(aAux, oQuery:WhereClause())
	endif     

	if !empty(::DDFilter())
		aAdd(aAux, dwConcatWSep(" and ", ::DDFilter()))
	endif      
	
	oQuery:WhereClause(dwConcatWSep(" and ", aAux))
	for nInd := 1 to len(::Params())
		oQuery:AddParam(::Params()[nInd, 1], ::Params()[nInd, 2])
	next

	if ::DrillLevel() <> 0
		aSize(aDimY, ::DrillLevel())
	endif
	oQuery:GroupBy(dwConcatWSep(",", aDimY))
	oQuery:WithDeleted(.t.)
	
	if lHaveCalc
		aAux := {}
		aAdd(aAux, "select")
		aAdd(aAux, dwConcatWSep(",", aFieldList) + ",")
		aInd := {}
		aIndAux := ::Indicadores(.t.)
		
		for nInd := 1 to len(aIndAux)
			x := aIndAux[nInd]
			if x:AggFunc() == AGG_ACUMHIST .or. x:AggFunc() == AGG_ACUMHISTPERC
				aAdd(aInd, "sum(" + x:Alias() + ") " + x:Alias())
		   	else
				aAdd(aInd, "0 " + x:Alias())
			endif
		next
		aAdd(aAux, dwConcatWSep(",", aInd))
		cAux := oQuery:SQL()
		aAdd(aAux, "from ( " + cAux + ") X")
		oQuery:Open(, ::prepareSQL(dwConcatWSep(" ", aAux)))
	else
		oQuery:Open(, ::prepareSQL(oQuery:SQL()))
	endif
return oQuery

/*
--------------------------------------------------------------------------------------
Prepara SQL para para execução de ranking
--------------------------------------------------------------------------------------
*/
method SQLRank(aaRankLink, acRecLimit, alTotal, aaWhere, anLevel) class TConsulta
	local nInd, cRankAgg, aSQL := {}
	local aFieldsY := {}, aInd := {}
	local aDimY, aInd1, aAllFields
	local cRet := "", aRankInfo
	local cFilterForUse, oQuery
	local cSQLLimit, cRankField, nMinVal, cRankCD
	local aAux, cAux, i, x, aHaving
	local aCurvaABC, aGroup := {}
	local nDifClasseA, nInd2, lRnkLevel := (::rankStyle() == RNK_STY_LEVEL)
	
	default anLevel := ::drillLevel()

	aRankInfo := ::RankDef(anLevel)
	
	if aRankInfo[3] == RNK_ZERA
		cSQL := ""
	else
		if !(::rankStyle() == RNK_STY_LEVEL)
      		anLevel := 0
		endif
          
		aAllFields := {}
		::FieldList()
		
		aDimY := ::DimFieldsY()
		aInd1 := ::Indicadores()
		
		for nInd := 1 to len(aDimY)
			if lRnkLevel .and. nInd > anLevel
				if aDimY[nInd]:Tipo() == "N"
					aAdd(aFieldsY, str(MAGIC_NUMBER, 20) + " " + aDimY[nInd]:Alias())
				elseif aDimY[nInd]:Tipo() == "D"
					aAdd(aFieldsY, "'"+MAGIC_DATE+"' "+aDimY[nInd]:Alias())
				else
					aAdd(aFieldsY, "'"+MAGIC_CHAR+"' "+aDimY[nInd]:Alias())
				endif
			else
				aAdd(aFieldsY, aDimY[nInd]:Alias())
        		aAdd(aGroup, aDimY[nInd]:Alias())
				aAdd(aaRankLink, "S." + aDimY[nInd]:Alias() + " = R." + aDimY[nInd]:Alias())
			endif
		next
		
		for nInd := 1 to len(aInd1)
			if aInd1[nInd]:ID() == aRankInfo[1]
				cRankABC := aInd1[nInd]:AggFuncText(.t.)+"("+::WorkFile()+"."+aInd1[nInd]:Alias()+")"
				cRankAgg := cRankABC + " R_A_N_K_"
				cRankField := aInd1[nInd]:Alias()
				cRankCD := aInd1[nInd]:NDec()
				aAdd(aInd, cRankAgg)
				exit
			endif
		next
		
		cAux := dwConcatWSep(",", aFieldsY) + "," + dwConcatWSep(",", aInd)
		if len(aFieldsY) == 0 .and. left(cAux, 1) == ","
			cAux := subStr(cAux, 2)
		endif
		aAdd(aSQL, "select " + cAux)
		aAdd(aSQL, "  from " + ::Workfile())
		
		if SGDB() == DB_POSTGRES
			if aRankInfo[2] > 0
				aAdd(aSQL, "  limit " + dwStr(abs(aRankInfo[2])))
			endif
		endif
		
		aFilters := {}
		cFilterForUse := ::FilterForUse()
		if !empty(cFilterForUse)
			for nInd := 1 to len(::Params())
				if at("'["+::Params()[nInd][1]+"]'", cFilterForUse) > 0
					cFilterForUse := strtran(cFilterForUse, "'["+::Params()[nInd][1]+"]'", ::Params()[nInd][2])
				endif
				
				if at("'%["+::Params()[nInd][1]+"]%'", cFilterForUse) > 0
					cFilterForUse := strtran(cFilterForUse, "%["+::Params()[nInd][1]+"]%", substr(::Params()[nInd][2],8,4)+substr(::Params()[nInd][2],5,2)+substr(::Params()[nInd][2],2,len(::Params()[nInd][2])-2))
				endif
				
				if at("["+::Params()[nInd][1]+"]", cFilterForUse) > 0
					cFilterForUse := strtran(cFilterForUse, "["+::Params()[nInd][1]+"]", substr(::Params()[nInd][2],8,4)+substr(::Params()[nInd][2],5,2)+substr(::Params()[nInd][2],2,2))
				endif
			next
		endif
		
		if !empty(cFilterForUse)
			aAdd(aFilters, cFilterForUse)
		endif
		
		if valType(::DDFilter()) <> "U" .and. len(::DDFilter()) > 0 .and. ::rankStyle() == RNK_STY_LEVEL
			aeval(::DDFilter(), { |x| aAdd(aFilters, substr(x, 3, Len(x))) } )
		endif
		
		// Prerara o auto-filtro
		::prepAutoFilter(aFilters)
		
		if !empty(aFilters)
			aAdd(aSQL, " where " + DWConcatWSep(" and ", aFilters))
		endif
		
		if len(aGroup) > 0
			aAdd(aSQL, " group by " + dwConcatWSep(",", aGroup))
		endif

		aHaving := {}
		cFilterForUse := ::FilterForUse(.t.)
		if !empty(cFilterForUse)
			for nInd := 1 to len(::Params())
				cFilterForUse := strtran(cFilterForUse, "'["+::Params()[nInd][1]+"]'", DwStr(::Params()[nInd][2]))
				cFilterForUse := strtran(cFilterForUse, "["+::Params()[nInd][1]+"]", DwStr(::Params()[nInd][2]))
			next
			aAdd(aHaving, cFilterForUse)
		elseif alTotal .and. valType(aaWhere) == "A" .and. len(aaWhere) > 0 .and. DWCurvaABC() $ dwStr(aaWhere[1])
			cAux := ::caseCurvaABC(.t.)
			cAux := strtran(aaWhere[1], DWCurvaABC(), cAux)
			aAdd(aHaving, cAux)
		endif
		
		if len(aHaving) <> 0
			aAdd(aSQL, "       having " + dwConcatWSep(" and ", aHaving))
		endif
		
		cRet := dwConcatWSep(" ", aSQL)
		
		oQuery := TQuery():New(DWMakeName("TRA"))
		oQuery:WithDeleted(.T.)
		if aRankInfo[3] == RNK_PARETO
			cRet := ::prepareSQL(cRet, .t.)
			if SGDB() == DB_INFORMIX
				cSQLLimit := "select sum(R_A_N_K_) R_A_N_K_ "
				cSQLLimit += "from table ( multiset ("
				cSQLLimit += cRet
				cSQLLimit += ") ) X "
			else
				cSQLLimit := "select sum(R_A_N_K_) R_A_N_K_ "
				cSQLLimit += "from ("
				cSQLLimit += cRet
				cSQLLimit += ") X "
			endif
			oQuery:Open(, cSQLLimit)
			
			nTotPareto := oQuery:value("R_A_N_K_")
			nValPareto := nTotPareto * aRankInfo[2] / 100
			oQuery:Close()
			oQuery:Open(, cRet + " order by R_A_N_K_" + iif(aRankInfo[3] <> RNK_MENORES, " desc", ""))
			
			while !oQuery:eof() .and. nTotPareto > nValPareto
				nMinVal := oQuery:value("R_A_N_K_")
				nTotPareto := nTotPareto - nMinVal
				oQuery:_next()
			enddo
			
			oQuery:Close()
			acRecLimit := "R.R_A_N_K_ >= " + dwStr(nMinVal)
		elseif ::rankStyle() == RNK_STY_CURVA_ABC .and. len(::CurvaABC()) > 0
			cRet := ::prepareSQL(cRet, .t.)
			if SGDB() == DB_INFORMIX
				cSQLLimit := "select sum(R_A_N_K_) R_A_N_K_ "
				cSQLLimit += "from table ( multiset ("
				cSQLLimit += cRet
				cSQLLimit += ") ) X "
			else
				cSQLLimit := "select sum(R_A_N_K_) R_A_N_K_ "
				cSQLLimit += "from ("
				cSQLLimit += cRet
				cSQLLimit += ") X "
			endif
			oQuery:Open(, cSQLLimit)
			
			nTotPareto := oQuery:value("R_A_N_K_")
			aCurvaABC := ::CurvaABC()
			if !alTotal .or. empty(aCurvaABC[1, ABC_LIMITE])
				for nInd := 1 to len(aCurvaABC)
					aCurvaABC[nInd, ABC_LIMITE] := nTotPareto * aCurvaABC[nInd, ABC_PERC] / 100
				next
				oQuery:Close()

				if len(aHaving) > 0
					oQuery:Open(, cRet)
				elseif nTotPareto <> 0
					for nInd := 1 to len(aCurvaABC) - 1
						nValPareto := 0
						if nInd == 1
							oQuery:Open(, cRet + " order by R_A_N_K_ desc")
						else
							oQuery:Open(, cRet + " having " + cRankABC + "  < " + dwStr(aCurvaABC[nInd - 1, ABC_LIMITE]) +" order by R_A_N_K_ desc")
						endif
						
						while !DWKillApp() .and. !oQuery:eof() .and. nValPareto < aCurvaABC[nInd, ABC_LIMITE]
							nMinVal := oQuery:value("R_A_N_K_")
							nValPareto := nValPareto + nMinVal
							oQuery:_next()
						enddo
						aCurvaABC[nInd, ABC_LIMITE] := nMinVal
						oQuery:Close()
					next
					aCurvaABC[len(aCurvaABC), ABC_LIMITE] := nil
				else
					for nInd := 1 to len(aCurvaABC)
						aCurvaABC[nInd, ABC_LIMITE] := 0
					next
				endif
			endif
			acRecLimit := ""
		else
			if SGDB() $ DB_MSSQL_ALL
				cSQLLimit := "select min(R_A_N_K_) minRank, max(R_A_N_K_) maxRank "
				cSQLLimit += "from ("
				cSQLLimit += substr(cRet, 1, 6) + " top " + dwStr(abs(aRankInfo[2])) + " " + substr(cRet, 7)
				cSQLLimit += " order by R_A_N_K_" + iif(aRankInfo[3] <> RNK_MENORES, " desc", "")
				cSQLLimit += ") X "
			elseif SGDB() = DB_INFORMIX
				cSQLLimit := "select min(x.R_A_N_K_) minRank, max(x.R_A_N_K_) maxRank "
				cSQLLimit += "from table ( multiset ("
				cSQLLimit += substr(cRet, 1, 6) + " first " + dwStr(abs(aRankInfo[2])) + " " + substr(cRet, 7)
				cSQLLimit += " order by R_A_N_K_" + iif(aRankInfo[3] <> RNK_MENORES, " desc", "")
				cSQLLimit += ") ) x"
			elseif SGDB() == DB_ORACLE
				cSQLLimit := "select min(R_A_N_K_) minRank, max(R_A_N_K_) maxRank "
				cSQLLimit += "from ("
				cSQLLimit += " select * from ("
				cSQLLimit += cRet
				cSQLLimit += " order by R_A_N_K_" + iif(aRankInfo[3] <> RNK_MENORES, " desc", "")
				cSQLLimit += ") Y where rownum <= " + dwStr(abs(aRankInfo[2]))
				cSQLLimit += ") X "
			elseif SGDB() == DB_DB2
				cSQLLimit := "select min(R_A_N_K_) minRank, max(R_A_N_K_) maxRank "
				cSQLLimit += "from ("
				cSQLLimit += cRet
				cSQLLimit += " order by R_A_N_K_" + iif(aRankInfo[3] <> RNK_MENORES, " desc", "")
				if ::rankStyle() <> RNK_STY_CURVA_ABC
					cSQLLimit += " fetch first " + dwStr(abs(aRankInfo[2])) + " rows only"
				endif
				cSQLLimit += ") X "
			else //DB_POSTGRES
				cSQLLimit := "select min(R_A_N_K_) minRank, max(R_A_N_K_) maxRank "
				cSQLLimit += "from ("
				cSQLLimit += cRet
				cSQLLimit += ") X "
			endif      

			cSQLLimit := ::prepareSQL(cSQLLimit, .t.)
			oQuery:Open(, cSQLLimit)
			
	   		::fnMinValue := oQuery:value("minRank")
	   		::fnMaxValue := oQuery:value("maxRank")
				
			cMinValue := dwStr(oQuery:value("minRank"))
			cMaxValue := dwStr(oQuery:value("maxRank"))
			oQuery:Close()
			
			if SGDB() $ DB_MSSQL_ALL
				cRankCD := dwStr(dwVal(cRankCD) + 1)
				acRecLimit := "round(R.R_A_N_K_,[@X]) between round([@X], [@X]) and round([@X], [@X])"
			  	acRecLimit := dwFormat(acRecLimit, { cRankCD, cMinValue, cRankCD, cMaxValue, cRankCD })
			elseif SGDB() == DB_DB2
				acRecLimit := "truncate(R.R_A_N_K_,[@X]) between truncate([@X], [@X]) and truncate([@X], [@X])"
			  	acRecLimit := dwFormat(acRecLimit, { cRankCD, cMinValue, cRankCD, cMaxValue, cRankCD })
			else
				acRecLimit := "R.R_A_N_K_ between [@X] and [@X]"
			  	acRecLimit := dwFormat(acRecLimit, { cMinValue, cMaxValue })
			endif
		endif

		if oQuery:isOpen()
			oQuery:Close()
		endif
	endif
return cRet //iif(::rankStyle() == RNK_STY_LEVEL, cRet, cSqlLimit)//#### processamento de ult nivel com dd errado

/*
-------------------------------------------------------------------------------------
Prepara SQL para apurar totalização outros (rank)
--------------------------------------------------------------------------------------
*/
method SQLRnkTotOut(acSQL) class TConsulta
	local oQuery := TQuery():New("X_RNKOUTROS")
	
  	oQuery:open(,strTran(acSQL, "between", "not between"))
return oQuery

/*
-------------------------------------------------------------------------------------
Prepara SQL para apurar totalização global
--------------------------------------------------------------------------------------
*/
method SQLTotGlobal() class TConsulta
	local aBase , oQuery
	Local lRank, lFiltered
	local cAutoFilter := ::autoFilter()
  
  	::autoFilter("")
	lRank 		:= ::RankOn()
	lFiltered := ::Filtered()
	::RankOn(.F.)
	::Filtered(.F.)
	aBase := ::StructBase(0, , .t.)
	oQuery 		:= ::makeSQL(aBase, FIRST_PAGE,,,,,,.T.)
	::RankOn(lRank)
	::Filtered(lFiltered)
  	::autoFilter(cAutoFilter)
return oQuery

/*
--------------------------------------------------------------------------------------
Propriedade Filtered
--------------------------------------------------------------------------------------
*/
method Filtered(alValue) class TConsulta
return ::Props(ID_FILTERED, alValue)

/*
--------------------------------------------------------------------------------------
Propriedade Total
--------------------------------------------------------------------------------------
*/
method Total(alValue) class TConsulta
return ::Props(ID_TOTAL, alValue)

/*
--------------------------------------------------------------------------------------
Propriedade AlertOn
--------------------------------------------------------------------------------------
*/
method AlertOn(alValue) class TConsulta
return ::Props(ID_ALERTON, alValue)

/*
--------------------------------------------------------------------------------------
Propriedade HintOn
--------------------------------------------------------------------------------------
*/
method HintOn(alValue) class TConsulta
return ::Props(ID_HINTON, alValue)

/*
--------------------------------------------------------------------------------------
Propriedade IgnoreZero
--------------------------------------------------------------------------------------
*/
method IgnoreZero(alValue) class TConsulta
return ::Props(ID_IGNOREZERO, alValue)

/*
--------------------------------------------------------------------------------------
Propriedade UseExcel
--------------------------------------------------------------------------------------
*/
method UseExcel(alValue) class TConsulta
return ::Props(ID_USEEXCEL, alValue)

/*
--------------------------------------------------------------------------------------
Propriedade RankOn
--------------------------------------------------------------------------------------
*/
method RankOn(alValue) class TConsulta
return ::Props(ID_RANKON, alValue)

/*
--------------------------------------------------------------------------------------
Propriedade RankOutros
--------------------------------------------------------------------------------------
*/
method RankOutros(alValue) class TConsulta
return ::Props(ID_RANKOUTROS, alValue)

/*
--------------------------------------------------------------------------------------
Propriedade RankSubTotal
--------------------------------------------------------------------------------------
*/
method RankSubTotal(alValue) class TConsulta
return ::Props(ID_RANKSUBTOTAL, alValue)

/*
--------------------------------------------------------------------------------------
Propriedade RankTotal
--------------------------------------------------------------------------------------
*/
method RankTotal(alValue) class TConsulta
return ::Props(ID_RANKTOTAL, alValue)

/*
--------------------------------------------------------------------------------------
Propriedade RankStyle
--------------------------------------------------------------------------------------
*/
method RankStyle(acValue) class TConsulta
return ::Props(ID_RANKSTYLE, acValue)

/*
--------------------------------------------------------------------------------------
Propriedade DrillLevel
--------------------------------------------------------------------------------------
*/
method DrillLevel() class TConsulta
	local nRet := 0, nInd, aAux
	local aDimY := ::DimFieldsY(.t.)
		
	if ::HaveDrillDown()       
		aAux := ::DrillParms()
		if !empty(aAux) .and. ::_Type() == TYPE_TABLE
			nRet := aAux[1]
			if nRet == 0
				nRet := ::DrillOrig()
			endif

     		if ::flExporting
     			aAux := ::DrillHist()
				if "*all*" $ DwStr(aAux, .t.)
					nRet := 0
   			  		for nInd := 1 to len(aAux)
	      	  			if "*all*" $ aAux[nInd, 2]
	      		  			nRet := len(dwToken(aAux[nInd, 2], "!", .f.))
		      			endif
		      		next
		    	endif
	    	endif
		else
			for nInd := len(aDimY) to 1 step -1
				if aDimY[nInd]:Drilldown()
					nRet := nInd
					exit
				endif
			next
		endif
	endif
return nRet

/*
--------------------------------------------------------------------------------------
Propriedade DrillParms
--------------------------------------------------------------------------------------
*/
method updDDSql(anLevel, acKeys, acSQL) class TConsulta
	local nPos, nAux
  
  	if (nPos := aScan( ::faDrillHist, {|x| x[1] == anLevel .and. x[2] == acKeys} )) > 0
    	nAux := rat('ORDER BY', upper(acSQL))
    	if nAux == 0
    		nAux := len(acSQL) + 1
    	endif
    	::faDrillHist[nPos, 3] := subStr(acSQL, 1, nAux - 1)
  	endif
return

method DrillParms(anLevel, acKeys, alDDHist, alDDExclude) class TConsulta
	Local nPos
	
	default alDDHist	:= .t.
	default alDDExclude := .f.
	
	if valType(anLevel) == "N"
		::faDrillParms := { anLevel, acKeys }
		         
    	if "!all!" $ acKeys
      		::clearDrillHist()
    	endif
    
		if alDDHist
			If (nPos := aScan( ::faDrillHist, {|x| x[1] == anLevel .and. x[2] == acKeys} )) == 0
				aAdd(::faDrillHist, { anLevel , acKeys, "" } )
			Elseif alDDExclude
				::faDrillHist[nPos] := NIL
				::faDrillHist 		  := packArray(::faDrillHist)
				
				If (::faDrillParms[2] == acKeys)
					if len(::faDrillHist) > 0
						::faDrillParms := ::faDrillHist[len(::faDrillHist)]
					else
						::faDrillParms := { 0, "", "" }
					endif
				Endif
			EndIf
		EndIf
	endif
return ::faDrillParms

/*
--------------------------------------------------------------------------------------
Aguarda construção da consulta
--------------------------------------------------------------------------------------
*/
method WaitBuild(AVerifyOnly) class TConsulta
	local aInfo
	local nPos := -1
	local lRet := .F.
	local cSig := DWint2hex(::ID(),5)+DWint2hex(::_Type(),1)

	default AVerifyOnly := .f.
		
	while nPos <> 0 .and. !DWKillApp()
		aInfo := oProcess:ThreadsInfo()
		nPos := ascan(aInfo, {|x| x[11] == cSig })
		if nPos <> 0    
			if AVerifyOnly
				lRet := .T.
			endif  
			sleep(15000)
		endif
	enddo
return lRet

/*
--------------------------------------------------------------------------------------
"Reseta" o arquivo de trabalho
--------------------------------------------------------------------------------------
*/
method ResetWorkfile(alAll) class TConsulta
	local oTable 

	default alAll := .f.
		
	if alAll
		oTable := TTable():New(::Workfile(TYPE_TABLE))
		if oTable:Exists()
			oTable:DropTable()
		endif

		oTable := TTable():New(::Workfile(TYPE_GRAPH))
		if oTable:Exists()
			oTable:DropTable()
		endif
	else
		oTable := TTable():New(::Workfile())
		if oTable:Exists()
			oTable:DropTable()
		endif
  	endif
return

/*
--------------------------------------------------------------------------------------
Adiciona parametros para montagem de SQL dinamico
--------------------------------------------------------------------------------------
*/
method AddParam(acName, acValue) class TConsulta
	local aParams := ::Params()
	
	if ascan(aParams, { |x| upper(x[1]) == upper(acName)}) == 0
		aAdd(aParams, { alltrim(acName), acValue })
	endif
return
	
/*
--------------------------------------------------------------------------------------
Propriedade Params
--------------------------------------------------------------------------------------
*/
method Params() class TConsulta
return ::Props(ID_PARAMS)

/*
--------------------------------------------------------------------------------------
Prepara o proximo/anterior nivel de drilldown
--------------------------------------------------------------------------------------
*/
method PrepDrill(anType, alSave) class TConsulta
	local nInd
	local aDimY := ::DimFieldsY(.t.)
	local nRet := len(aDimY)
	
	if anType == DRILLDOWN
		for nInd := len(aDimY) - 1 to 1 step - 1
			if aDimY[nInd]:Drilldown()
				aDimY[nInd]:Drilldown(.f.)
				aDimY[nInd+1]:Drilldown(.t.)
				nRet := nInd+1
				exit
			endif
		next  
	elseif anType == DRILLUP
		for nInd := 2 to len(aDimY)
			if aDimY[nInd]:Drilldown()
				aDimY[nInd]:Drilldown(.f.)
				aDimY[nInd-1]:Drilldown(.t.)
				nRet := nInd-1
				exit
			endif
		next         
	elseif anType == DRILLRESET
		aEval(aDimY, { |x| x:Drilldown(.f.) } )
		nRet := ::DrillOrig()
		for nInd := 1 to nRet
			aDimY[nInd]:Drilldown(.t.)
		next
	else
		aEval(aDimY, { |x| x:Drilldown(.f.) } )
	endif
	
	if alSave
		::SaveDef()
	endif
return nRet

/*
--------------------------------------------------------------------------------------
Aplica os alertas
--------------------------------------------------------------------------------------
*/
method ApplyAlerts(aaRecord, aoInd) class TConsulta
	local xRet := '', xAux, nInd, aAlerts := ::Alerts()
	local aID := {}
	                                	
	for nInd := 1 to len(aAlerts) 
		xAux := aAlerts[nInd]:apply2(aaRecord, aoInd)
		if valType(xAux) == "C" .and. (left(xAux,2) == "T@" .or. left(xAux,2) == "F@")
			xRet := substr(xAux,2)
			if left(xAux,1) == "T" 
				aAdd(aID, 'T'+dwInt2Hex(aAlerts[nInd]:ID(), 4))
			else
				aAdd(aID, 'F'+dwInt2Hex(aAlerts[nInd]:ID(), 4))
			endif
		endif
	next
	
	if len(aID) > 0
		if len(aID) > 1
			xRet := "@BN000000;@FNffffff;"
		endif
		xRet := xRet + ";#" + DWConcatWSep("-", aID)
	endif				                                  
return xRet

/*
--------------------------------------------------------------------------------------
Indica se a consulta é uma consulta válida ou não
--------------------------------------------------------------------------------------
*/       
method IsValid() class TConsulta
return ::Props(ID_ISVALID) .and. !::BuildIsNeed() .and. TCCanOpen(::Workfile())	

/*
--------------------------------------------------------------------------------------
Indica se a consulta esta com erro de construção ou não
--------------------------------------------------------------------------------------
*/       
method IsWrong() class TConsulta
  	local oDataset := InitTable(TAB_CONSULTAS)
	local lRet := .f.
	                
	oDataset:savePos()
	if oDataset:Seek(1, { ::ID() })         
		lRet := oDataset:value("erro")
	endif             
	oDataset:restPos()
return lRet

/*
--------------------------------------------------------------------------------------
Valida ou invalida a consulta
--------------------------------------------------------------------------------------
*/
function invalCons(pnID, plTable, plGraph, poDataset)
	local oDataset := iif(valType(poDataset)=="O", poDataset, InitTable(TAB_CONSULTAS))
	local oConsType 

	default plTable := .f.
	default plGraph := .f.
	
	oDataset:SavePos()
	if oDataset:Seek(1, { pnID })
		oDataset:Update({ {"id_base", 0}, { "valida", plTable }, { "valgra", plGraph }, { "erro", .f. } })
		oConsType := InitTable(TAB_CONSTYPE)
    	
    	if !plTable .and. tcCanOpen(DWSumName(pnID, "S"))
    		TCDelFile(DWSumName(pnID, "S"))
    	endif  
    
    	if !plGraph .and. tcCanOpen(DWSumName(pnID, "G"))
    		TCDelFile(DWSumName(pnID, "G"))
    	endif  
		
		if plTable .and. oConsType:Seek(2, { pnID, "1" }, .f.)
			oConsType:update({{"id_base", 0}})
		endif
		
		if plGraph .and. oConsType:Seek(2, { pnID, "2" }, .f.)
			oConsType:update({{"id_base", 0}})
		endif
	endif		
	
	oDataset:RestPos()
return

static function doValidate(poConsulta, plValue)
   local oDataset := InitTable(TAB_CONSULTAS)

	if oDataset:Seek(1, { poConsulta:ID() })
		if poConsulta:_Type() == TYPE_TABLE
			invalCons(poConsulta:ID(), plValue, oDataset:value("valgra"), oDataset)   
		else
			invalCons(poConsulta:ID(), oDataset:value("valida"), plValue, oDataset)   
		endif
		poConsulta:Props(ID_ISVALID, plValue)
	endif
return

method Validate(alAll) class TConsulta
	default alAll := .f.

	if alAll
		invalCons(::ID(), .f., .f.)
	else
		doValidate(self, .t.)
  	endif
return

method Invalidate(alAll) class TConsulta
	default alAll := .f.

	if alAll
		invalCons(::ID(), .f., .f.)   
		if ::HaveTable()
			DWEraseDD(::Workfile(TYPE_TABLE))
			DWEraseDD(::Viewname(TYPE_TABLE))
		endif
		
		if ::HaveGraph()
			DWEraseDD(::Workfile(TYPE_GRAPH))
			DWEraseDD(::Viewname(TYPE_GRAPH))
		endif
		::resetWorkfile(.t.)
	else
		doValidate(self, .f.)
		DWEraseDD(::Workfile())
		DWEraseDD(::Viewname())
	endif
return

/*
--------------------------------------------------------------------------------------
Fator de escala
--------------------------------------------------------------------------------------
*/       
method FatorEscala(anValue) class TConsulta
return ::Props(ID_FATORESCALA, anValue)

/*
--------------------------------------------------------------------------------------
Indice sobreposto
--------------------------------------------------------------------------------------
*/       
method IndSobrePosto(alValue) class TConsulta
return ::Props(ID_SOBREPOSTO, alValue)
  
/*
--------------------------------------------------------------------------------------
Preenche todas as células da tabela, inclusive as que apresentam valores repetidos. 
--------------------------------------------------------------------------------------
*/       
method FillAll(alValue) class TConsulta
return ::Props(ID_FILLALL, alValue)

/*
--------------------------------------------------------------------------------------
Apresenta célula vazia
--------------------------------------------------------------------------------------
*/       
method EmptyCell(alValue) class TConsulta
return ::Props(ID_EMPTYCELL, alValue)

/*
--------------------------------------------------------------------------------------
Prepara objeto Table para acesso a tabela de agregados
--------------------------------------------------------------------------------------
*/
static function PrepEixo2(aaSQL, aoQuery, acWorkfile, aaDim, aaDimAux, paInd, paFieldList, acSource, alAdvplFilter)
	local nLevel, aAux, aAux2 
	local aFieldList := {}, nInd
	
	default alAdvplFilter := .f.

	if len(aaDim) != 0
		aEval(paFieldList, { |x| aAdd(aFieldList, x)})

		for nLevel := len(aaDim) - 1 to 0 step -1
			aAux := {}
			aAdd(aAux, "'"+DWStr(nLevel)+"' L_E_V_E_L_")
			for nInd := 1 to len(aaDim)
				if nInd <= nLevel
					aAdd(aAux, aaDim[nInd])
				elseif !alAdvplFilter
					aAdd(aAux, "max("+aaDim[nInd]+") " + aaDim[nInd])
				else
					aAdd(aAux, aaDim[nInd])
				endif
			next
		
			aEval(aaDimAux, { |x| aAdd(aAux, x)})
			aEval(paInd, { |x| aAdd(aAux, x)})

			aAdd(aAux, "' ' " + DWDelete())
			aAdd(aAux, "max("+acWorkfile+".R_E_C_N_O_) R_E_C_N_O_")
			aoQuery:Clear()

			aAux2 := {}
			for nInd := 1 to len(aFieldList)
				nPos := ascan(aAux, { |x| valType(x) == "C" .and. aFieldList[nInd] $ x })
				if nPos <> 0
					aAdd(aAux2, aAux[nPos])
					aAux[nPos] := nil
				endif					
			next                                          
			asize(aAux2, len(aAux))
			aEval(aAux, { |x,i| iif(valType(x)=="U", nil, eval({ |z,y| aIns(aAux2, y), aAux2[y] := z }, x, i)) })
			aAux := aClone(aAux2)
			aoQuery:FieldList(DWConcatWSep(",", aAux))
			aoQuery:FromList(acSource)

			aAux2 := {}
			for nInd := 1 to len(aAux)    
				if left(aAux[nInd],1) = "'" .or. isDigit(aAux[nInd]) .or.;
					lower(left(aAux[nInd],3)) $ "sum|max|cou|avg|min"
				else
					aAdd(aAux2, DWToken(aAux[nInd], ",")[1])
				endif
			next
			aoQuery:GroupBy(DWConcatWSep(",", aAux2))
			
			if valType(aaSQL) == "A"
				aAdd(aaSQL, aoQuery:InsertInto(aFieldList, acWorkfile))
			endif

			if left(acWorkfile, 2) == "DG"
				exit
			endif
		next
	endif
return

/*
--------------------------------------------------------------------------------------
Prepara objeto Table para acesso a tabela de agregados
--------------------------------------------------------------------------------------
*/
static function PrepEixo3(aaSQL, aoQuery, acWorkfile, aaDim, paInd, paFieldList, pnLevel)
	local nLevel, aAux, aAux2 
	local aFieldList := {}, nInd
                        
	if len(aaDim) != 0
		aEval(paFieldList, { |x| aAdd(aFieldList, x)})

		aAux := {}
		for nInd := 1 to len(aaDim)
			if pnLevel == 0 .or.	nInd = pnLevel
				aAdd(aAux, aaDim[nInd])
			endif
		next
		
		aEval(paInd, { |x| aAdd(aAux, x)})

		aAdd(aAux, "' ' " + DWDelete())
		aAdd(aAux, "max("+acWorkfile+".R_E_C_N_O_) R_E_C_N_O_")
		
		aoQuery:Clear()

		aAux2 := {}
		for nInd := 1 to len(aFieldList)
			nPos := ascan(aAux, { |x| valType(x) == "C" .and. aFieldList[nInd] $ x })
			if nPos <> 0
				aAdd(aAux2, aAux[nPos])
				aAux[nPos] := nil
			endif					
		next                                          
		asize(aAux2, len(aAux))
		aEval(aAux, { |x,i| iif(valType(x)=="U", nil, eval({ |z,y| aIns(aAux2, y), aAux2[y] := z }, x, i)) })
		aAux := aClone(aAux2)
		aoQuery:FieldList(DWConcatWSep(",", aAux))
		aoQuery:FromList(acWorkfile)
			
		aAux2 := {}
		for nInd := 1 to len(aAux)    
			if left(aAux[nInd],1) = "'" .or. isDigit(aAux[nInd]) .or.;
				lower(left(aAux[nInd],3)) $ "sum|max|cou|avg|min"
			else
				aAdd(aAux2, DWToken(aAux[nInd], ",")[1])
			endif
		next
		aoQuery:GroupBy(DWConcatWSep(",", aAux2))
		aoQuery:OrderBy(DWConcatWSep(",", aAux2))
		if valType(aaSQL) == "A"
			aAdd(aaSQL, aoQuery:InsertInto(aFieldList, acWorkfile))
		endif
	endif
return

method getTable(alIndex, alView, alOpenTable) class TConsulta
	local oTable, aAux, aIndFields := {}, aDim := {}, aIndX := {}, aDimY := {}
	local oQuery, cSQL, aFieldList, nInd, nInd2, nInd3
	local cFilename , nPos, aAux2, aTmp
	local aRes := {}, aInd, aAux3, aAllFields := ::getAllFields()
	
	default alIndex := .f.     
	default alView := .f.
	default alOpenTable := .t.
	
	cFilename := iif(alView .and. ::HaveRank(), ::Viewname(), ::Workfile())
	::FieldList()
	
	// Cria a tabela de sumarização
	aAux := ::DimFields()
	for nInd := 1 to len(aAux)
		if aAux[nInd]:Temporal() == DT_DT    // data cheia ou não é temporal
			aAdd(aRes, aAux[nInd]:DimName() + "->" + aAux[nInd]:Name())
			aAdd(aDim, { aAux[nInd]:Alias(), aAux[nInd]:Tipo(), aAux[nInd]:Tam(), aAux[nInd]:Ndec()})
		elseif aAux[nInd]:Temporal() == DT_PERIODO
			aAdd(aDim, { aAux[nInd]:Alias(), "C", 15, 0})
		elseif aAux[nInd]:Temporal() == DT_ANO
			aAdd(aDim, { aAux[nInd]:Alias(), "N", 4, 0})
		elseif aAux[nInd]:Temporal() == DT_DOY
			aAdd(aDim, { aAux[nInd]:Alias(), "N", 3, 0})
		elseif aAux[nInd]:Temporal() == DT_MES .or. aAux[nInd]:Temporal() == DT_DIA
			aAdd(aDim, { aAux[nInd]:Alias(), "N", 2, 0})
		else
			aAdd(aDim, { aAux[nInd]:Alias(), "N", 1, 0})
		endif

		if aAux[nInd]:Eixo() == "X"
			aAdd(aIndX, aAux[nInd]:Alias())
		else
			aAdd(aDimY, aAux[nInd]:Alias())
		endif
	next

	aAux := ::Indicadores(.t.)
	aInd := {}
	for nInd := 1 to len(aAux)
		aAdd(aRes, aAux[nInd]:DimName() + "->" + aAux[nInd]:Name()) 
		if aAux[nInd]:AggFunc() <> AGG_NONE .or. !empty(aAux[nInd]:Expressao())
			aAdd(aInd, { aAux[nInd]:Alias(), aAux[nInd]:Tipo(), aAux[nInd]:Tam(), aAux[nInd]:NDec() })
			if !empty(aAux[nInd]:Expressao())
				aAdd(aRes, aAux[nInd]:Expressao())
			endif
		endif
	next

	if ::_Type() != TYPE_GRAPH
		aAux := ::Alerts(.t., .t.)
		for nInd := 1 to len(aAux)
			aAdd(aRes, aAux[nInd]:expressao())
		next
	endif
	
	aAux := ::WhereList(.t.,,.t.)     
	for nInd := 1 to len(aAux)
		aAdd(aRes, dwStr(aAux[nInd]))
	next

	aAux := ::HavingList(.t.)     
	for nInd := 1 to len(aAux)
		aAdd(aRes, dwStr(aAux[nInd]))
	next

	cAux := upper(dwConcatWSep(" ", aRes))

	oTable := TTable():New(cFilename)
	oTable:Descricao(::Desc())
	for nInd := 1 to len(aAllFields)
		if aAllFields[nInd,1 ] $ cAux .or. aAllFields[nInd, 9] $ cAux .or. aAllFields[nInd, 12] $ cAux
			if ascan(oTable:Fields(), { |x| x[1] == aAllFields[nInd, 5] }) == 0
				oTable:AddField(nil, aAllFields[nInd, 5], aAllFields[nInd, 2], aAllFields[nInd, 3], aAllFields[nInd, 4])
			endif
		endif
	next

	for nInd := 1 to len (aDim)
		if ascan(oTable:Fields(), { |x| x[1] == aDim[nInd, 1] }) == 0
			oTable:AddField(nil, aDim[nInd, 1], aDim[nInd, 2], aDim[nInd, 3], aDim[nInd, 4])
		endif
	next

	for nInd := 1 to len (aInd)
		if ascan(oTable:Fields(), { |x| x[1] == aInd[nInd, 1] }) == 0
			oTable:AddField(nil, aInd[nInd, 1], aInd[nInd, 2], aInd[nInd, 3], aInd[nInd, 4])
		endif
	next

	aAux := aClone(::WhereList(.t.,,.t.))
	for nInd := 1 to len(aAux)
		aAux[nInd] := dwStr(aAux[nInd])
		for nInd2 := 1 to len(aAllFields)
			if aAllFields[nInd2, 1] $ aAux[nInd]
				aTmp := ::procMacro(aAux[nInd], .t.)
				for nInd3 := 1 to len(aTmp)
					if valType(aTmp[nInd3]) == "A" .and. ascan(oTable:Fields(), { |x| x[1] == aTmp[nInd3, 1] }) == 0
						oTable:AddField(nil, aTmp[nInd3, 1], aTmp[nInd3, 2], aTmp[nInd3, 3], aTmp[nInd3, 4])
					endif				
				next
			endif
		next                
	next			

	oTable:AddField( nil, "L_E_V_E_L_", "C", 2)

	oTable:LoadDD()
	if len(aDimY) != 0
		oTable:SearchIndex(aDimY, .t.)// Eixo Y
	endif

	if len(aIndX) > 0 
		oTable:SearchIndex(aIndX, .t.)// Eixo X
	endif

	if alOpenTable .and. oTable:Exists()
		::PrepVirtual(oTable)
		oTable:Open()   
		if alIndex 
			oTable:reindex()
		endif
	endif
return oTable

/*
--------------------------------------------------------------------------------------
Alimenta uma lista com os valores (headers) do eixo X
--------------------------------------------------------------------------------------
*/
method readAxisX(aaData, anLevel, alHeader, alNoTotal, alUseCache) class TConsulta
	local oQuery, aAux := {}, aAux2, aField :={}
	local aDimX, cAux, aInd, cFlagTot, nInd
	local aDimAnt, aDimAtu, aBase, aWhere := {}
	local aRankLink 
 	local lFiltro, lAlerta
 	local lIgnDDFilter := ::flIgnDDFilter
	
	::flIgnDDFilter := .t.
	
	aDimX := ::DimFieldsX(.t.)
	if !(len(aDimX) ==0)
		default alNoTotal := .f.
		default alUseCache := .t.

    	lFiltro := ::Filtered()
    	lAlerta := ::AlertOn()

#ifdef DWCACHE	
		if alUseCache .and. valType(::faHeaderX) == "A"
			aaData := aClone(::faHeaderX)
#else
		if alUseCache .and. ::inCacheInfo("headerX")
			aaData := aClone(::getCacheInfo("headerX"))
#endif
		else
			aBase := ::StructBase()
			aInd := ::Indicadores()
			
			// retira indicadores adicionados por serem utilizados em campos virtuais
			aEval(aInd, {|xElem,i| iif(xElem:Ordem() > -1, aAdd(aAux, xElem), NIL)})
			aInd := aAux
			aAux := {}
			
			default anLevel := len(aDimX)
			default alHeader := .f.
		
			aDimAnt := array(anLevel-1)
			aDimAtu := array(anLevel-1)

			aEval(aDimX, { |x| aAdd(aAux, " S."+x:Alias()), aAdd(aField, " S."+x:Alias())}, 1, anLevel)
			
		 	oQuery := TQuery():New(DWMakeName("TRA"))
			oQuery:MakeDistinct(.t.)
			oQuery:WithDeleted(.t.)
			oQuery:FieldList(DWConcatWSep(",", aField))
			if empty(aBase[ID_SQL_RANK])
				oQuery:FromList(::Workfile() + " S")
			else		
				oQuery:FromList(::Workfile() + " S," + aBase[ID_SQL_RANK])
				if !empty(aBase[ID_RANK_LIMIT])
					aAdd(aWhere, aBase[ID_RANK_LIMIT])
				endif
			endif
		
			oQuery:OrderBy(DWConcatWSep(",", aAux))

			if !empty(aBase[ID_FILTER])
				aAdd(aWhere, aBase[ID_FILTER])
			endif

			oQuery:WhereClause(dwConcatWSep(" and ", aWhere))
			aEval(::Params(), { |x| oQuery:addParam(x[1], x[2])})
			cSQL := oQuery:SQL()           
      		cSQL := ::PrepareSQL(cSQL, .t.,iif(::RankOn(), "S.", ""))
      		oQuery:Open(, cSQL) 
			oQuery:adjustField(aDimX)

			cFlagTot := CHR(255)+iif(anLevel==len(aDimX), "", chr(254))
                                
			aFill(aDimAnt, "")
			for nInd := 1 to len(aDimAnt)
				aEval(aDimX, { |x| aDimAnt[nInd] += dwStrZero((x:adjustValue(oQuery:value(x:alias()))), x:Tam(), x:NDec()) + cFlagTot}, 1, anLevel-nInd)
			next

			while !oQuery:Eof() 
				aFill(aDimAtu, "")
				cAux := ""               
				aEval(aDimX, { |x| cAux += dwStrZero((x:adjustValue(oQuery:value(x:alias()))), x:Tam(), x:NDec()) + chr(255)}, 1, anLevel)

				if !alNoTotal  
					for nInd := 1 to len(aDimAtu)
						aEval(aDimX, { |x| aDimAtu[nInd] += dwStrZero((x:adjustValue(oQuery:value(x:alias()))), x:Tam(), x:NDec()) + cFlagTot}, 1, anLevel-nInd)
		 			next

					for nInd := 1 to len(aDimAtu)
						if aDimAtu[nInd] <> aDimAnt[nInd]
							aEval(aInd, { |x| aAdd(aaData, aDimAnt[nInd]+chr(254)) })
							aDimAnt[nInd] := aDimAtu[nInd]
						endif
					next
				endif
				aEval(aInd, { |x| aAdd(aaData, cAux) })
				oQuery:_Next()
			end		
		
			oQuery:Close()
			if !alNoTotal  
				for nInd := 1 to len(aDimAnt)
					aEval(aInd, { |x| aAdd(aaData, aDimAnt[nInd]+chr(254)) })
				next
				cAux := ""
				aEval(aDimX, { |x| cAux += "TOTAL"+CHR(255)})

				if ::IndSobrePosto()
					aAdd(aaData, cAux)
				else                                  
					aEval(aInd, { |x,i| aAdd(aaData, cAux) })
				endif
			endif      

			#ifdef DWCACHE
				::faHeaderX := aClone(aaData)
			#else
				if ::inCache()
					::setCacheInfo("headerX", aClone(aaData))
				endif
			#endif
		endif
    	
    	::Filtered(lFiltro)
    	::AlertOn(lAlerta)
	endif
			
	::flIgnDDFilter := lIgnDDFilter
return len(aaData)

/*
--------------------------------------------------------------------------------------
Fecha a consulta
--------------------------------------------------------------------------------------
*/
method Close() class TConsulta
	local cFilename := ::WorkFile()

	if ::HaveCube()
		oSigaDW:CloseCube(::Cube())
		if select(cFilename) <> 0
			&(cFilename)->(dbCloseArea())
		endif
		
		cFilename := ::Viewname()
		if select(cFilename) <> 0
			&(cFilename)->(dbCloseArea())
		endif
	endif
return

/*
--------------------------------------------------------------------------------------
Retorna a lista de campos utilizados em filtros, rankings e alertas
--------------------------------------------------------------------------------------
*/
method OtherFields(alAlias, aaRet, alStruc, alAdvpl, alInsert) class TConsulta
	local aAux := {}, aAux2 := {}, nInd, cText
	local nCubeID := ::Cube():ID(), oField, nTemporal
	local cXYFields := "", x, cAux, cExp, nSeq
	local aFields := {}

  	//####TODO: Verificar a possibilidade de armanzenar em um atributo, na 1a execução
  	
	default alStruc := .f.
	default aaRet := {}
	default alAdvpl := .f.

	aAux := ::DimFields()
	for nInd := 1 to len(aAux)
		if 	aAux[nInd]:Temporal() == 0
			cXYFields += alltrim(aAux[nInd]:DimName())+"->"+alltrim(aAux[nInd]:Name())
		endif
	next

	aAux := {}                                              
	aAux2 := ::Indicadores(.t.)
	nSeq := 0   
	cExp := ""
	for nInd := 1 to len(aAux2)
		x := aAux2[nInd]
		if empty(x:expressao())
			if x:canTotalize()
   			else
				::PrepField(aAux, x, x:AggFuncText(), 'I', @nSeq, .f., .f., .t.)
			endif
		else
			::PrepField(aAux, x, x:AggFuncText(), 'V', @nSeq, .f., .f., .t.)
			cExp := cExp + " " + x:expressao()
		endif
	next                           

	for nInd := 1 to len(aAux)
		cXYFields += allTrim(aAux[nInd]) + " "
		cXYFields += allTrim(aAux[nInd]) + CRLF
	next
        
	aAux2 := ::WhereList(.t.,, alInsert)
	for nInd := 1 to len(aAux2)
		aAdd(aAux, dwStr(aAux2[nInd]))
	next

	aAux2 := ::HavingList(.t.)
	for nInd := 1 to len(aAux2)
		aAdd(aAux, dwStr(aAux2[nInd]))
	next

  	if ::_Type() == TYPE_TABLE
	  	aAux2 := ::Alerts(.t., .t.)
	  	for nInd := 1 to len(aAux2)
		  	aAdd(aAux, upper(aAux2[nInd]:expressao()))
	  	next
	endif

	aAdd(aAux, cExp)
	cText := upper(dwConcatWSep(" ", aAux))

	if !empty(cText)
		aFields := ::getAllFields(alStruc)
		for nInd := 1 to len(aFields)
			cAux := aFields[nInd,1]
			if !(cAux+" " $ cXYFields)
				if (cAux $ cText)
					if alStruc
						aAdd(aaRet, "("+ cAux + ") " + aFields[nInd, 5])
					else
						if left(aFields[nInd, 5],1) == "D"
							oField := TFieldInfo():New(aFields[nInd, 1], Self, .t., hex2Int(right(aFields[nInd,5], 3)))
						else
							oField := TFieldInfo():New(aFields[nInd, 1], Self, .t., nCubeID)	
						endif           
						
						nTemporal := 0
						if ::haveMacroAt(aFields[nInd, 1], cText, @nTemporal)
							oField:Temporal(nTemporal)
						else
							oField:Temporal(0)
						endif
						oField:Eixo("")
						oField:GraphColor("")
						oField:Alias(aFields[nInd, 5])
						::AddIntFrom(aFields[nInd,7]+"."+aFields[nInd,6])
						
						nPos := at("->", aFields[nInd,1])
						if nPos <> 0
							oField:DimName(substr(aFields[nInd,1],1, nPos-1))
							oField:Tablename(aFields[nInd, 7])
							oField:Name(substr(aFields[nInd,1],nPos+2))
						else
							oField:DimName("%%%%%%%%%%%%")
							oField:Tablename("%%%%%%%%%%%%")
							oField:Name(aFields[nInd,1])
						endif
						aAdd(aaRet, oField)
						cXYFields += " " + aFields[nInd,1]
					endif
				endif
			endif
		next
	endif                    
return aaRet

/*
--------------------------------------------------------------------------------------
Monta um header/footer de <table> sem formatações, para uso na exportação
--------------------------------------------------------------------------------------
*/
method HtmlHeader(alNoTotal, anType) class TConsulta
	local oPivot := THPivot():New()
	local aRet := {}

	oPivot:ForExcel(anType == FT_EXCEL_XML .or. anType == FT_CSV)
	oPivot:InitTabExp(aRet, ::DimCountY(), self, alNoTotal)
return aRet

method HtmlFooter() class TConsulta
	local oPivot := THPivot():New()
	local aRet := {}
	
	oPivot:EndTable(aRet, .f.) 
return aRet

/*
--------------------------------------------------------------------------------------
Monta o filtro para ser utilizado
--------------------------------------------------------------------------------------
*/     
method FilterForUse(alInd, alHist) class TConsulta
	default alInd := .f.
return (dwConcatWSep(" and ", if(alInd,::HavingList(),::WhereList(,alHist))))

/*
--------------------------------------------------------------------------------------
Copia uma consulta, gravando com outro ID
--------------------------------------------------------------------------------------
*/
#define FILE_RELATIVE_PATH		"/metadata/"

function DWCopyCons(anIDOrig, anIDTarget)
	local oConsulta := InitTable(TAB_CONSULTAS)	
  	local oXmlFile := TDWXmlMetaDado():New(.F., anIDOrig)
  	local oXmlImport
  	local aBuffer := {} // lixo
  	Local cXmlName

	if !(oConsulta:Seek(1, { anIDOrig } ))
		return .f.
	endif
	
	// constroi esta consulta
	buildOneQuery(aBuffer, oXmlFile, oConsulta)
	
	// salva
	cXmlName := DWMetaPath() + "/" + DWMakeName("md") + ".DWM"
	cXmlName := strTran(cXmlName, "\", "/")
	doSaveXML(oXmlFile, cXmlName, .F.)
	
	// faz a importação
	oXmlImport := TDWImportMeta():New(cXmlName, .T., anIDTarget)
	oXmlImport:ImportQuerys()
return

/*
--------------------------------------------------------------------------------------
Verifica a necessida de se reconstruir a consulta
--------------------------------------------------------------------------------------
*/     
method BuildIsNeed(aoOldCons) class TConsulta
	local oOldCons, lReset := .f., aFields, aFieldsOld
	local lFiltered := ::Filtered()
	local lAlertOn := ::AlertOn()
	local lOldFiltered
	local lOldAlertOn

	if !(len(::Props(ID_CUBES)) == 0)
		::Filtered(.t.)
		
		if ::_Type() == TYPE_TABLE
			::AlertOn(.t.)
		else
			::AlertOn(.f.)		
		endif
		
		default aoOldCons := TConsulta():New(::ID(), ::_Type())
	
		lOldFiltered := aoOldCons:Filtered()
		lOldAlertOn := aoOldCons:AlertOn()
		
		oOldCons := aoOldCons
		oOldCons:Filtered(::Filtered())
		oOldCons:AlertOn(::AlertOn())
		aFieldsOld := aSort(oOldCons:FieldList(.t.,.t.),,, { |x,y| x < y})	
		aFields := aSort(::FieldList(.t.,.t.),,, { |x,y| x < y})
		if ::Cube():ID() != oOldCons:Cube():ID()
			lReset := .t.
		elseif !(dwStr(aFields) == dwStr(aFieldsOld))
			lReset := .t.
		elseif !(dwStr(::Alerts(.t.)) == dwStr(oOldCons:Alerts(.t.)))
			lReset := .t.
		elseif !(dwStr(::RankDef()) == dwStr(oOldCons:RankDef()))  
			lReset := .t.
		endif
		::Filtered(lFiltered)
		::AlertOn(lAlertOn)
		oOldCons:Filtered(lOldFiltered)
		oOldCons:AlertOn(lOldAlertOn)
	else
		lReset := .t.
	endif
return lReset

/*
--------------------------------------------------------------------------------------
Prepara os campos virtuais
--------------------------------------------------------------------------------------
*/     
method PrepVirtual(aoDS) class TConsulta
	local aAux2 := ::IndVirtual(.t., .f.)
	local nInd
	
	for nInd := 1 to len(aAux2)
		if !aAux2[nInd]:IsSQL()
			aoDS:setGetBlock(aAux2[nInd]:Alias(), &((getCBSource(aAux2[nInd]:CBExpr()))))
		endif
	next
return
/*
--------------------------------------------------------------------------------------
Converte os nomes de campos com formato advpl para formato SQL
--------------------------------------------------------------------------------------
*/     
method PrepareSQL(acSQL, alAlias, acPrefixo, aaAllFields) class TConsulta
	local cRet := acSQL, nInd, x, nLenAux
	local aAux := if(valType(aaAllFields) == "A", aaAllFields, ::getAllFields())

	default acPrefixo := ""
	default alAlias := .f.

	if valType(acSQL) == "A"
		for nInd := 1 to len(acSQL)
			if !(acSQL[nInd] == "go")
				acSQL[nInd] := ::PrepareSQL(acSQL[nInd], alAlias, acPrefixo, aAux) 
			endif
		next
		return acSQL
	endif

  	// passo 1 - trata nomes fisicos
  	nLenAux := len(aAux)
	for nInd := 1 to nLenAux 
		x := aAux[nInd]
		if alAlias
			cRet := strTranIgnCase(cRet, x[1], acPrefixo + x[5])             // (objeto)->(nome do atributo)
			cRet := strTranIgnCase(cRet, x[7]+"."+x[6], acPrefixo + x[5])    // (objeto fisico).(nome do atributo)
			cRet := strTranIgnCase(cRet, x[8], acPrefixo + x[5])             // (objeto)$>(nome do atributo)
			cRet := strTranIgnCase(cRet, x[7]+"."+x[9], acPrefixo + x[5])    // (objeto fisico).(objeto)->(descricao do atributo)
		else
			cRet := strTranIgnCase(cRet, x[1], x[7]+"."+x[6])    // (objeto)->(nome do atributo)
			cRet := strTranIgnCase(cRet, x[8], x[7]+"."+x[6])    // (objeto)$>(nome do atributo)
		endif
	next    
	// passo 1 - fim

  	// passo 2 - trata descricoes
  	if "->" $ cRet
		for nInd := 1 to len(aAux)
			x := aAux[nInd]
			if alAlias
				cRet := strTranIgnCase(cRet, x[9], acPrefixo + x[5]) // (objeto)->(descricao do atributo)
			else
				cRet := strTranIgnCase(cRet, x[9], x[7]+"."+x[5])    // (objeto)->(descricao do atributo)
			endif
		next    
	endif
	
	// passo 2 - fim
	cRet := ::ProcMacro(cRet)

	if SGDB() == DB_ORACLE
		cRet := strtran(cRet, "''", "' '")
		cRet := strtran(cRet, "'+chr(39)+'", "''")
	endif     

  	cRet :=	strtran(cRet, "sum(sum(", "sum((")
return cRet

/*
--------------------------------------------------------------------------------------
Monta a lista de todos os campos possiveis para uso na consulta
--------------------------------------------------------------------------------------
*/     
method getAllFields() class TConsulta
	local aAux, nInd, i, x, cAux, aAux2
	local aAllFields
	                
	aAllFields := ::faAllFields
	
	if valType(aAllFields) != "A" .or. len(aAllFields) == 0
		::faAllFields := {}
		aAllFields := ::faAllFields
		aAux := ::Cube():Dimension()		
		for nInd := 1 to len(aAux)
			for i := 1 to len(aAux[nInd]:Fields())
				x := aAux[nInd]:Fields()[i]                                                                                      
				if x[FLD_NAME] != "ID"
					if x[12] > 0       
						aAux2 := {}
						aAdd(aAux2, upper(aAux[nInd]:Alias() + "->" + x[FLD_NAME]))
						aAdd(aAux2, x[FLD_TYPE])
						aAdd(aAux2, x[FLD_LEN])
						aAdd(aAux2, x[FLD_DEC])
						aAdd(aAux2, "D"+dwInt2Hex(x[12], 4))
						aAdd(aAux2, x[FLD_NAME])
						aAdd(aAux2, upper(aAux[nInd]:Tablename()))
						aAdd(aAux2, upper(aAux[nInd]:Alias() + "$>" + x[FLD_NAME]))
						//####TODO - longname
						aAdd(aAux2, upper(aAux[nInd]:Alias() + "->" + x[FLD_TITLE]))
						aAdd(aAux2, chr(255)) //upper(aAux[nInd]:Alias() + "." + x[FLD_LONGNAME]))
						aAdd(aAux2, chr(255)) //upper(aAux[nInd]:Tablename() + "." + x[FLD_LONGNAME]))
						aAdd(aAux2, chr(255)) //"[" + aAux[nInd]:Tablename() + "->" + x[FLD_LONGNAME] + "]")
						aAdd(aAllFields, aAux2)
					endif
				endif
			next
		next
		cAux := dwCubeName(::Cube():id())
		aAux := ::Cube():GetIndicadores()
		for nInd := 1 to len(aAux)
			x := aAux[nInd]
			aAux2 := {}
			aAdd(aAux2, "FATO->" + x[2])
			aAdd(aAux2, "N")
			aAdd(aAux2, x[3])
			aAdd(aAux2, x[4])
			aAdd(aAux2, "I0_"+dwInt2Hex(x[1], 4))
			aAdd(aAux2, x[2])
			aAdd(aAux2, upper(cAux))
			aAdd(aAux2, "FATO$>" + x[2])
 			//####TODO - longname
			aAdd(aAux2, "FATO->" + x[5])
			aAdd(aAux2, chr(255)) //upper(aAux[nInd]:Alias() + "." + x[FLD_LONGNAME]))
			aAdd(aAux2, chr(255)) //upper(aAux[nInd]:Tablename() + "." + x[FLD_LONGNAME]))
			aAdd(aAux2, chr(255)) //"[" + aAux[nInd]:Tablename() + "->" + x[FLD_LONGNAME] + "]")
			aAdd(aAllFields, aAux2)
		next
	endif
	aSort(aAllFields,,,{|x,y| padr(x[1],20) > padr(y[1],20)})
return aAllFields

method getSQL() class TConsulta
	local oQuery, aAux, aAux2, nInd
	
	default alFilter := .t.     
	default alStruct := .t.
		
	oQuery := TQuery():New(DWMakeName("TRA"))
	oQuery:WithDeleted(.T.)
	aAux := {}
	aAux2 := ::FieldList(, alStruct)
	aEval(aAux2, { |x| aAdd(aAux, x) })
	oQuery:FieldList(DWConcatWSep(",", aAux))
	
	if alFilter
		aAux := aClone(::LinkList(.t.))
		aEval(::DDFilter(), { |x| aAdd(aAux, x)})
		oQuery:WhereClause(DWConcatWSep(" and ", aAux)) 
	endif 
	oQuery:FromList(DWConcatWSep(",", ::FromList(.t.)))
	oQuery:GroupBy(DWConcatWSep(",", ::GroupBy()))

	aParams := aClone(::Params())
	for nInd := 1 to len(aParams)
		if "&" == left(aParams[nInd,2],1)
			aParams[nInd,2] := subStr(aParams[nInd,2], 2)
		endif
		oQuery:AddParam(aParams[nInd,1], &(aParams[nInd,2]))
	next
return oQuery:SQL()

method DDFilter(aaFilter) class TConsulta
	local nDrillLevel, aDimY, aDDKeys
	local dAux, aAux
	local cPrefixo 	:= ""
	local nInd			:= 0
	local aFilter		:= {}
	local lFilter
	local aRet := nil
                     
	aDimY 		:= ::DimFieldsY()
	nDrillLevel := ::DrillParms()[1]
	aDDKeys 	:= iif(!empty(::DrillParms()[2]), dwToken(::DrillParms()[2], SEL_DD, .f.), {""})

	if ::flIgnDDFilter
		aRet := {}
	elseif valType(aaFilter) == "A"
		::faDDFilter := aClone(aaFilter)
	else
		lFilter := empty(::faDDFilter)
		if !lFilter
			lFilter := len( alltrim(::faDDFilter) ) == 0
		endif
		
		If lFilter
			for nInd := 1 to min(nDrillLevel, len(aDDKeys))
				if !(aDDKeys[nInd] == "*all*") 
					aAux := aDimY[nInd]
					if nInd < nDrillLevel
						aAux:isSubTotal(.f.)
					endif
					
					if ::RankOn()
						cPrefixo := "S."
					endif
				
					if !(aAux:Tipo() == "D")
						aAdd(aFilter, cPrefixo+aAux:Alias() + '='+ dwStr(dwConvTo(aAux:Tipo(), aAux:RealValue(aDDKeys[nInd])),.t.))
					else
						dAux := ctod(aDDKeys[nInd])
						if empty(dAux)
							aAdd(aFilter, cPrefixo+aAux:Alias() + "='        '")
						else
							aAdd(aFilter, cPrefixo+aAux:Alias() + "='" + dwStr(dtos(dAux))+"'")
						endif
					endif
				endif
			next
			
			if valType(aFilter) == "A"
				::faDDFilter := aClone(aFilter)
			endif
		endif
	endif
return 	iif(valType(aRet) == "U", ::faDDFilter, aRet)

method StructBase(anLevel, aaWhere, alTotal, anLevelX, alHist) class TConsulta
	local oQuery := TQuery():New(DWMakeName("TRA")), aAux
	local aDimY := {}, aDimX := {}, aFieldList := {}, aInd := {}
	local aKeyList := {}, aKeyY := {}, xAux
	local nInd, aFilters := {}, cAux
	local aUnion := {}, i, x, aAllFields
	local aRankInfo, aRankLink, cRankLimit
	local aRet := array(ID_BASE_SIZE)
	local nPos := 0, nAux, lIndVirt := .f.
	local aDDFilter     

	Local nCount 		:= 1
	Local aFields 		:= {}
	Local aExpressions 	:= {}  

	default anLevel	:= ::DrillLevel()
	default alTotal	:= .f.
	default anLevelX	:= -1

	::FieldList()

	aAux := ::DimFieldsY()

	for nInd := 1 to len(aAux)
		if anLevel == 0 .or. nInd <= anLevel
			aAdd(aDimY, "S."+aAux[nInd]:Alias())
			aAdd(aKeyList, { "S." + aAux[nInd]:Alias(), aAux[nInd]:Tipo(), aAux[nInd]:Tam() })
			aAdd(aKeyY, { aAux[nInd]:Alias(), aAux[nInd]:Tipo(), aAux[nInd]:Tam() })
		else
			if aAux[nInd]:Tipo() == "N"
				aAdd(aDimY, str(MAGIC_NUMBER, 20) + " " + aAux[nInd]:Alias())
			elseif aAux[nInd]:Tipo() == "D"
				aAdd(aDimY, "'"+MAGIC_DATE+"' "+aAux[nInd]:Alias())
			else
				aAdd(aDimY, "'"+MAGIC_CHAR+"' "+aAux[nInd]:Alias())
			endif
		endif
	next
	
	aAux := ::DimFieldsX()
	
	// Itera pelas dimensões.
	for nInd := 1 to len(aAux)
		if anLevelX <> -1
			if nInd > anLevelX
				if aAux[nInd]:Tipo() == "N"
					aAdd(aDimX, "0 " + aAux[nInd]:Alias())
				else
					aAdd(aDimX, "'"+chr(255)+"' " + aAux[nInd]:Alias())
				endif
				aAdd(aUnion, atail(aDimX))
			else
				aAdd(aDimX, aAux[nInd]:Alias())
				if aAux[nInd]:Tipo() == "N"
					aAdd(aUnion, "0 " + aAux[nInd]:Alias())
				else
					aAdd(aUnion, "'"+chr(255)+"' " + aAux[nInd]:Alias())
				endif
			endif
		else
			aAdd(aDimX, "S."+aAux[nInd]:Alias())
		endif
		aAdd(aKeyList, { "S."+aAux[nInd]:Alias(), aAux[nInd]:Tipo(), aAux[nInd]:Tam() })
	next
	
	aAux := ::Indicadores(.t.)
	
	// Itera pelos indicadores.
	For nAux := 1 to 2
		For nInd := 1 to len(aAux)
			If (!lIndVirt .and. aAux[nInd]:Ordem() > 0) .or. (lIndVirt .and. aAux[nInd]:Ordem() < 1)
				If !empty(aAux[nInd]:ExpSQL()) .and. ::haveAggFunc(aAux[nInd]:ExpSQL())
					aAdd(aInd, aAux[nInd]:ExpSQL() + " " + aAux[nInd]:Alias())
				Else
					aAdd(aInd, aAux[nInd]:AggFuncText(.t.)+"(S."+aAux[nInd]:Alias()+") "+aAux[nInd]:Alias())
				EndIf

				If anLevelX <> -1
					aAdd(aUnion, atail(aInd))
				EndIf
			EndIf
		Next
		lIndVirt := !lIndVirt
	Next

	if anLevelX <> -1
		aAdd(aFieldList, "'0' L_E_V_E_L_")
	endif
	aEval(aDimY, {|x| aAdd(aFieldList, x)})
	aEval(aDimX, {|x| aAdd(aFieldList, x)})
	aEval(aInd, {|x| aAdd(aFieldList, x)})
	
	aAux := ::OtherFields(.t.)
	for nInd := 1 to len(aAux)
		x := aAux[nInd]
		if (left(x:Alias(),1) == "I" .or. left(x:Alias(),1) == "V")
			if !empty(x:Expressao()) .and. left(lower(x:Expressao()),3) $ "sum|max|cou|avg|min"
				if !(("S." + x:Alias()) $ DwStr(aFieldList))
					aAdd(aFieldList, "S." + x:Alias())
				endif
			else
				if !(("sum(S." + x:Alias()+") " + x:Alias()) $ DwStr(aFieldList))
					aAdd(aFieldList, "sum(S." + x:Alias()+") " + x:Alias())
				endif
			endif
			
			if anLevelX <> -1
				aAdd(aUnion, atail(aFieldList))
			endif
		endif
	next

	if ::RankOn() .and. ::HaveRank(anLevel)
		aRankLink := {}
		cSQLRank := ::prepareSQL(::SQLRank(aRankLink, @cRankLimit, alTotal, aaWhere, anLevel), .t.)
		
		aRankInfo := ::rankDef(anLevel)
		if aRankInfo[3] == RNK_MENORES
			aAdd(aFieldList, "max(R.R_A_N_K_) R_A_N_K_")
			aRet[ID_RANK_SIG] := ""
		else
			aAdd(aFieldList, "-max(R.R_A_N_K_) R_A_N_K_")
			aRet[ID_RANK_SIG] := "-"
			if ::rankStyle() == RNK_STY_CURVA_ABC
				aRet[ID_CURVAABC] := ::caseCurvaABC()
				if !empty(aRet[ID_CURVAABC])
					aAdd(aFieldList, aRet[ID_CURVAABC])
				endif
			else
				aRet[ID_CURVAABC] := ""
			endif
		endif
		
		aRet[ID_RANK_LIMIT] := cRankLimit
		if SGDB() == DB_INFORMIX
			aRet[ID_SQL_RANK] := "table ( multiset ( " + cSQLRank + ") ) R"
		else
			aRet[ID_SQL_RANK] := "( " + cSQLRank + ") R"
		endif
		oQuery:FromList(::WorkFile() + " S, " + aRet[ID_SQL_RANK])
	else
		oQuery:FromList(::WorkFile() + " S")
	endif
	oQuery:WithDelete(.t.)
	
	DplItems(aFieldList, .T., , .T.)
	DplArray(aKeyList, .t., , 1, .T.)
	DplArray(aKeyY, .t., , 1, .T.)
	DplItems(aUnion, .t.)

	oQuery:FieldList(dwConcatWSep(",", aFieldList))

	aRet[ID_SQL_BASE] := (oQuery:SQL())
	aRet[ID_KEY_LIST] := aKeyList
	
	// Prepara filtro de ligação com o rank
	if !empty(aRankLink)
		aEval(aRankLink, { |x| aAdd(aFilters, x)})
	endif
	
	// Prerara o auto-filtro
	::prepAutoFilter(aFilters, "S.")
	
	if anLevel > 0
		aDDFilter := ::DDFilter()
		if valType(aDDFilter) == "A" .and. len(aDDFilter) > 0
			aEval(aDDFilter, { |x| aAdd(aFilters, x)})
		endif
	endif
	
	cAux := ::FilterForUse(, alHist)
	if !empty(cAux)
		aAdd(aFilters, cAux)
	endif
	
	if valType(aaWhere) == "A"
		aAllFields := {}
		aDate := {}
		aEval(::getAllFields(), { |x| iif(x[2] == "D", aAdd(aDate, x[5]),), aAdd(aAllFields, x[5]) })
		
		if len(aDate) > 0
			for nInd := DT_ANO to DT_ANOMES
				aEval(aDate, { |x| aAdd(aAllFields, left(x,1) + DWint2hex(nInd, 1) + "_" + right(x,4)) })
			next
		endif
		
		if anLevel == -1
			for nInd := 1 to len(aaWhere)
				if valType(aaWhere[nInd]) == "C" .and. ascan(aAllFields, { |x| "S."+x+"=" $ aaWhere[nInd] } ) > 0
					aAdd(aFilters, aaWhere[nInd])
				endif
			next
		else
			for nInd := 1 to len(aaWhere)
				if valType(aaWhere[nInd]) == "C" .and. ascan(aAllFields, { |x| "S."+x $ aaWhere[nInd] } ) > 0
					aAdd(aFilters, aaWhere[nInd])
				elseif aKeyList[nInd, 2] == "C" .or. left(aKeyList[nInd, 1], 3) == "D2_" //Tratamento de periodo
					aAdd(aFilters, aKeyList[nInd, 1] + "='"+aaWhere[nInd]+"'")
				elseif aKeyList[nInd, 2] == "L"
					aAdd(aFilters, aKeyList[nInd, 1] + "='"+iif(aaWhere[nInd], "T","F")+"'")
				elseif aKeyList[nInd, 2] == "D"
					xAux := aaWhere[nInd]
					if valType(xAux) == "C"
						xAux := ctod(xAux)
					endif
					aAdd(aFilters, aKeyList[nInd, 1] + "='"+dtos(xAux)+"'")
				else
					aAdd(aFilters, aKeyList[nInd, 1] + "="+dwStr(aaWhere[nInd]))
				endif
			next
		endif
	endif
	
	if DWisWebEx() .and. HTTPIsConnected()
		/*Aplicação de filtro através do suplemento de integração DW-Excel.*/
		if valType(httpSession->ExcelFilter) == "A" .and. len(httpSession->ExcelFilter) > 0			
			/*Recupera o nome dos campos e a expressão de filtro aplicado através da integração Excel.*/
			aFields 		:= dwToken(httpSession->ExcelFilter[1], ",")
			aExpressions 	:= dwToken(httpSession->ExcelFilter[2], ",", .F.)			
			
			/*Itera por cada campo no qual foi aplicado filtro.*/
			For nCount := 1 to Len(aFields)
				/*Recupera os campos da consulta.*/
				aAux := oConsulta:Fields(.t.)    
				/*Verifica se o campo no qual o filtro foi aplicado faz parte da consulta.*/
				nPos := ascan(aAux, { |x| upper(x:Alias()) == upper(AllTrim(aFields[nCount])) } )
				
				if nPos > 0
					/*Cria a expressão SQL que servirá como filtro.*/
					cExcelFilter := qbe2SQL("S." + aAux[nPos]:Alias(), aAux[nPos]:Tipo(), { AllTrim(aExpressions[nCount]) } ,"","",{},.t.)

					if !empty(cExcelFilter)
						/*Guarda o filtor criado, como item de um array, para ser recuperdo posteriormente. */
						aAdd(aFilters, cExcelFilter)
					endif
				endif      
			Next nCount 			
		endif
	endif

	if !empty(aFilters)
		aRet[ID_FILTER] := (dwConcatWSep(" and ", aFilters))
	else
		aRet[ID_FILTER] = ""
	endif
	
	aRet[ID_KEY_Y] := aKeyY
	aRet[ID_HAVING] := ::FilterForUse(.t., alHist)
	
	if !empty(aUnion)
		oQuery:FieldList("'1' L_E_V_E_L_, " + dwConcatWSep(",", aUnion))
		oQuery:WithDelete(.t.)
		oQuery:FromList(::WorkFile() + " S")
		aRet[ID_UNION] := (oQuery:SQL())
	else
		aRet[ID_UNION] := ""
	endif
return aRet

method GetDSForExport() class TConsulta
	local aBase, oDS, aAllFields, aFields, nInd, nPos
	local aSQL := {}, aDrillHist := aclone( ::faDrillHist )
	local cOrder := "", nElem := 0, nDrillLevel := 0, nLastLevel	:= 0
	local oStat := initTable(TAB_ESTAT), nMaxDrill := 0
  	local nDrillHist, cAux
  	
	::fdInicio := date()
	::fcInicio := time()
	
	if oStat:seek(2, { ST_EXPORT_QUERYS, ::ID() } )
		::fnTempoEst := oStat:value("Valor")
	endif
	
	if ::HaveDrillDown() .and. len(aDrillHist) > 1 .and. ::_Type() <> TYPE_GRAPH
		//monta a ordem do SQL
		cOrder := " order by "
		for nElem := 1 to (n_LenDimY + nLenDimX)
			cOrder += dwStr(nElem) + ","
		next
		cOrder := Substr(cOrder,1,len(cOrder)-1)
		
		//Ordena o historico do drill down por nivel
		aSort(aDrillHist,,,{|x,y| x[1] < y[1] })
		aEval(aDrillHist, { |x| nMaxDrill := max(nMaxDrill, x[1]) })
   		nDrillHist := len(aDrillHist)
		for nElem := nDrillHist to 1 step -1
      		if !empty(aDrillHist[nElem, 3])
			  	aAdd(aSQL, aDrillHist[nElem, 3])
		  	endif
		next  

		if !(::rankStyle() == RNK_STY_CURVA_ABC)
  			::flIgnDDFilter := .t.
      		aBase := ::StructBase(::drillOrig(),,,,,.t.)
			oDS := ::makeSQL(aBase, FIRST_PAGE, ::faKeyValues, " ")
			aAdd(aSQL, oDS:SQLInUse())
			oDS:Close()
  			::flIgnDDFilter := .f.
		endif
			
    	oDS := oQuery := TQuery():New("X_TRA")
    	cAux := dwconcatWSep(' union ', aSQL)
    	cAux := cAux + cOrder

		oDS:Open(,cAux)

		aAllFields := ::getAllFields()
		aFields := oDS:Fields()
		for nInd := 1 to len(aFields)
			nPos := ascan(aAllFields, { |x| x[5] == aFields[nInd, FLD_NAME] })
			if nPos <> 0 .and. aAllFields[nPos, 2] <> "C"
				tcSetField(oDS:Alias(), aFields[nInd, FLD_NAME], aAllFields[nPos, 2], aAllFields[nPos, 3], aAllFields[nPos, 4])
			endif
		next
		oDS:faStruct := {}
		::fnTotProcs := int(oDS:recCount() / ::PageSize())
		::ipcNotify(STR0020, .t.)  //"Exportação de dados"
	else
		aBase := ::StructBase()
		::faKeyValues := array(2, len(aBase[ID_KEY_Y]))
		oDS := ::makeSQL(aBase, FIRST_PAGE, ::faKeyValues)
	endif
	::flExporting := .t.
	::ipcExpNotify()
return oDS
 
method getDS(acPage, alProcDD) class TConsulta
	local aBase, oQuery 
	local aPreserveKeys, aDDParms
	local nDrillLevel

	default alProcDD := .f.

	if alProcDD .and. valtype(::faKeyValues) == "A"
		aPreserveKeys := aclone(::faKeyValues)
 	endif

	if !alProcDD 
		if ::HaveDrillDown() 
  			::flIgnDDFilter := .t.
     		aDDParms := ::DrillParms()
     		if !("*all*" $ aDDParms[2] .or. "*all*" $ DwStr(::DrillHist(), .t.))
     			::DrillParms(0, "")         
  			endif     
	  		::PrepDrill(DRILLRESET)
  		endif
  		nDrillLevel := nil
	else
  		nDrillLevel := ::drillLevel() + 1
	endif
 	aBase := ::StructBase(nDrillLevel, nil, nil, nil, nil)	
	
	if acPage == FIRST_PAGE
		::flHaveMedInt := NIL
		::flHaveAcum := NIL
		::flHaveHistAcum := NIL
		if ::_Type() == TYPE_TABLE
			::faKeyValues := array(2, len(aBase[ID_KEY_Y]))
		elseif ::_Type() == TYPE_GRAPH
			if !(::RankOn() .and. ::HaveRank())
				::faKeyValues := array(2, len(aBase[ID_KEY_Y]))
			else
				::faKeyValues := array(2, 1)
			endif
		endif
	endif
			
	oQuery := ::makeSQL(aBase, acPage, ::faKeyValues, , , , , , , nDrillLevel)

	if ::_Type() == TYPE_GRAPH
		alProcDD := .F.
	endif

	if alProcDD .and. valtype(aPreserveKeys) == "A"
		::faKeyValues := aclone(aPreserveKeys)
	endif
return oQuery
 

method getPage(acPage, aoDS, alProcDD) class TConsulta
	local aBase, aDados := {}, oQuery 
	local aPreserveKeys, aDDParms
	local nElem, nDrillLevel, aDrillHist
	local cDSAlias := Alias()

	default alProcDD := .f.
  
	if (alProcDD) .and. valtype(::faKeyValues) == "A"
		aPreserveKeys := aclone(::faKeyValues)
 	endif
	
	if !alProcDD 
	    if ::HaveDrillDown() 
	  		::flIgnDDFilter := .t.
	     	aDDParms := ::DrillParms()
	     	if !("*all*" $ aDDParms[2])
	       		::DrillParms(0, "")
	  		endif     
		  	::PrepDrill(DRILLRESET)
	  	endif
	endif
 	
 	aBase := ::StructBase(nil, nil, nil, nil, nil)	
 	if valType(aoDS) == "U"
		if acPage == FIRST_PAGE
			::flHaveMedInt := NIL
			::flHaveAcum := NIL
			::flHaveHistAcum := NIL
//		if ::_Type() == TYPE_TABLE
			::faKeyValues := array(2, len(aBase[ID_KEY_Y])+1)
//			elseif ::_Type() == TYPE_GRAPH
//				if !(::RankOn() .and. ::HaveRank(::drillLevel()))
//					::faKeyValues := array(2, len(aBase[ID_KEY_Y]))
//				else
//					::faKeyValues := array(2, 1)
//				endif
//			endif
 		endif
		
		oQuery := ::makeSQL(aBase, acPage, ::faKeyValues)
		::procPage(oQuery, aDados, aBase[ID_KEY_Y], ::faKeyValues, acPage)
		::flEof := oQuery:Eof()
		oQuery:Close()

		if ::_Type() == TYPE_GRAPH
			alProcDD := .F.
		endif
	else
   		if empty(cDSAlias)
   			cDSAlias := aoDS:alias()
		endif
		
		dbSelectArea(cDSAlias)
		if alProcDD
			aDrillHist := aclone(::faDrillHist)
		else
			aDrillHist := {}
		endif		
		
		if ::HaveDrillDown() .and. len(aDrillHist) > 1 .and. ::_Type() <> TYPE_GRAPH
			//Ordena o historico do drill down por nivel
			aSort(aDrillHist,,,{|x,y| x[1] < y[1] })
			for nElem := 1 to len(aDrillHist)
				nDrillLevel := aDrillHist[nElem, 1]
				::PrepDrill(DRILLRESET)
				if nDrillLevel > 0
					while ::PrepDrill(DRILLDOWN, .f.) < (nDrillLevel + 1)
					enddo	 
				endif
				::DrillParms(nDrillLevel, aDrillHist[nElem, 2], .f.)
			next
		endif
		::procPage(aoDS, aDados, aBase[ID_KEY_Y], ::faKeyValues, acPage)
	endif
	
	if (alProcDD) .and. valtype(::faKeyValues) == "A"
		::faKeyValues := aclone(aPreserveKeys)
	endif

	#ifdef DWCACHE
	#else
		if DWisWebEx() .and. ::flUpdCache .and. HTTPIsConnected()
			::updCache()
		endif
	#endif	
	
	if empty(httpGet->DD) .and. ::haveMedInt() .or. ::haveAcum() .or. ::haveAcumHist()
		if ::RankOn() .and. ::HaveRank()
			::procAcum(aoDS, aDados, { {"R_A_N_K_", "N", 18, 10 } }, { { aTail(::faKeyValues[1]) } }, acPage)
		else
			::procAcum(aoDS, aDados, aBase[ID_KEY_Y], ::faKeyValues[1], acPage)
		endif
	endif
	
	if acPage == NEXT_PAGE .and. len(aDados) == 0
		aPreserveKeys := aclone(::faKeyValues)
		aDados := ::getPage(LAST_PAGE, aoDS, alProcDD) 		
		::faKeyValues := aclone(aPreserveKeys)
	endif
return aDados

method FirstPage(alProcDD) class TConsulta
return ::getPage(FIRST_PAGE, ,alProcDD)

method PriorPage(alProcDD) class TConsulta
return ::getPage(PREVS_PAGE, , alProcDD)

method NextPage(aoDS, alProcDD) class TConsulta
return ::getPage(NEXT_PAGE, aoDS, alProcDD)

method LastPage(alProcDD) class TConsulta
return ::getPage(LAST_PAGE, ,alProcDD)

method ProcMacro(acMacro, alStruc) class TConsulta
return DWMacroAt2(acMacro, alStruc, ::getAllFields())

method ProcMacroAt(acMacro, alStruct, pnTemporal) class TConsulta
return DWMacroAt(acMacro, alStruct, pnTemporal) 

method haveMacroAt(pcFieldName, acMacro, pnTemporal) class TConsulta
	local cAux, aAux, nInd, aLines
	
	pnTemporal := 0

	if "@" $ acMacro
		cAux := strTran(acMacro, CRLF, " ")
		aAux := ::getAllFields()
		for nInd := 1 to len(aAux)     
			cAux := strTran(cAux, aAux[nInd, 1], aAux[nInd, 5])
			if pcFieldName == aAux[nInd, 1]
				pcFieldName := aAux[nInd, 5]
			endif
		next                    

		aLines := dwToken(cAux, "@",,.f.)

		for nInd := 1 to len(aLines)
			if left(aLines[nInd], 1) == "@" .and. pcFieldName $ aLines[nInd]
				cAux := ::ProcMacroAt(left(aLines[nInd], at(")", aLines[nInd])),,@pnTemporal)
				exit
			endif  
		next             
		
		pnTemporal := aScan(DT_FIELDS, {|cField| upper(cField) $ upper(acMacro)})-1
	endif
return pnTemporal <> 0

static function removeDpl(aaFields, anCol)
	local aRet, nPos, aAux, nInd
	
	if anCol == 1
		aRet := aclone(aaFields)
		DplItems(aRet, .t.)
	else
		aAux := {}        
		aRet := {}
		for nInd := 1 to len(aaFields)
			nPos := rat(" ", aaFields[nInd])
			aAdd(aAux, substr(aaFields[nInd], nPos + 1))
		next
		DplItems(aAux, .f., .t.)
		
		for nInd := 1 to len(aAux)
			if valtype(aAux[nInd]) != "U"
				aAdd(aRet, aaFields[nInd])
			endif
		next
	endif
return aRet

method haveAggFunc(acExp) class TConsulta
return DWHaveAggFunc(acExp)

function DWHaveAggFunc(acExp)
	local aAggFunc := { "SUM", "MAX", "COUNT", "AVG", "MIN", "@ACUM", "@ACUMHIST", "@ACUMPERC", "@ACUMHISTPERC" }
	local nInd, lRet := .f., nAggFunc

	if SGDB() == DB_ORACLE
		aAdd(aAggFunc, "PERCENTILE_CONT")
		aAdd(aAggFunc, "PERCENTILE_DISC")
		aAdd(aAggFunc, "RANK")
	elseif SGDB() $ DB_MSSQL_ALL
		aAdd(aAggFunc, "STDEV")
		aAdd(aAggFunc, "STDEVP")
		aAdd(aAggFunc, "VAR")
		aAdd(aAggFunc, "VARP")
	endif

	aEval(DWAggFunc(), { |x| aadd(aAggFunc, upper(x)) })
	
	nAggFunc := len(aAggFunc)
	aEval(aAggFunc, { |x| aadd(aAggFunc, x +" (") }, 1, nAggFunc)
	aEval(aAggFunc, { |x| aadd(aAggFunc, x +"  (") }, 1, nAggFunc)
	aEval(aAggFunc, { |x,i| aAggFunc[i] := x +"(" }, 1, nAggFunc)
	
	acExp := upper(acExp)
	
	for nInd := 1 to len(aAggFunc)
		if aAggFunc[nInd] $ acExp
			lRet := .t.
			exit
		endif						
	next                   
return lRet

/*
--------------------------------------------------------------------------------------
Verifica se existe uma consulta e se há definição de tabela e de gráfico para a mesma
Parametros
anID -> numerico, ID da consulta
alHaveTable -> logico, por referencia, indica se há ou não definição de tabela
alHaveGraph -> logico, por referencia, indica se há ou não definição de gráfico
Retorno
logico -> se .t., existe gráfico ou tabela, se .f. não existe nada
--------------------------------------------------------------------------------------
*/                                                
function DWVerCons(anID, alHaveTable, alHaveGraph)
	local oConsType := InitTable(TAB_CONSTYPE)
	local oConsInd  := InitTable(TAB_CONS_IND)
	local oConsDim  := InitTable(TAB_CONS_DIM)

	alHaveTable := verCons(anID, TYPE_TABLE, oConsType, oConsInd, oConsDim)
	alHaveGraph := verCons(anID, TYPE_GRAPH, oConsType, oConsInd, oConsDim)
return alHaveTable .or. alHaveGraph

static function verCons(anID, anType, aoConsType, aoConsInd, aoConsDim)
	local lRet := .f.
	
	if aoConsType:seek(2, { anID, DWStr(anType) }, .f.)
		lRet := aoConsInd:seek(2, { aoConsType:value("ID") } )
		lRet := lRet .and. aoConsInd:value("id_cons") == aoConsType:value("ID")
		lRet := lRet .and. aoConsDim:seek(2, { aoConsType:value("ID") } )		
		lRet := lRet .and. aoConsDim:value("id_cons") == aoConsType:value("ID")
	endif
return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} makeSQL
Constroi o SQL para paginação.

@param   acPage String que indica o controle de página:
          	- PREVS_PAGE: Página Anterior
          	- NEXT_PAGE : Próxima página
          	- FIRST_PAGE: Primeira página
          	- LAST_PAGE : ùltima página
@version P11
@author  BI Team
@return  logico array, SQL a ser processado.
/*/
//-------------------------------------------------------------------                                                
method makeSQL(aaSQLBase, acPage, aaKeys, acOrder, acWhere, alCount, acSelect, alTotal, anLevelX, anLevel) class TConsulta
	local aSQL := {}, s, cSQL, cAux, nInd, oQuery, cWhere := ""
	local cSQLBase := aaSQLBase[ID_SQL_BASE]
	local cWhereBase := aaSQLBase[ID_FILTER]
	local aKeyList := aaSQLBase[ID_KEY_LIST]
	local cWhereHist := aaSQLBase[ID_FILTER_HIST]
	local cHaving := aaSQLBase[ID_HAVING]
	local cSQLUnion := ""//aaSQLBase[ID_UNION]
	local cRankLimit := aaSQLBase[ID_RANK_LIMIT]
	local lFormatFields := .t., nPos
	local aAllFields, aFields	
	local aKeyAux, oQuery2, cCompara
  	local lUseRank
  	Local aGroup := {}
  	Local aBkp	 := {}
  	Local i	:= 0

	default alCount := .f.
	default acSelect := ""
	default alTotal := .f.
	default anLevelX := -1
  	default anLevel := ::drillLevel()

  	lUseRank := ::RankOn() .and. ::HaveRank(anLevel)

  	if lUseRank
  		if !(::rankStyle() == RNK_STY_LEVEL)
  			if anLevel <> 0 .and. anLevel <> ::DimCountY()
  				lUseRank := .f.
  			endif
 		endif
	endif
  
	oQuery := TQuery():New(iif(alCount, "X_TRACOUNT", iif(alTotal, "X_TRATOT", "X_TRA")))
	
	if valType(acOrder) == "U"
		acOrder := ""
		aEval(aKeyList, { |x| acOrder := acOrder + x[1] + ","})
		acOrder := left(acOrder, len(acOrder)-1)

	  	if lUseRank
			If acPage == PREVS_PAGE
				acOrder := ""
				aEval(aKeyList, { |x| acOrder := acOrder + x[1] + " DESC,"})
				acOrder := left(acOrder, len(acOrder)-6)
			EndIf
			acOrder := "R_A_N_K_" + iif(acPage == PREVS_PAGE, " desc", "") + iif(empty(acOrder), "", ","+acOrder) + iif(acPage == PREVS_PAGE, " desc", "")
		endif
	endif

	aAdd(aSQL, cSQLBase)

	while .t.
		if acPage == FIRST_PAGE		

		elseif acPage == PREVS_PAGE  
			if lUseRank    
				oQuery2 := ::makeSQL(aaSQLBase, FIRST_PAGE, nil, acOrder, aaSQLBase[ID_RANK_SIG] + "R_A_N_K_ < " + dwStr(aaKeys[1, len(aaKeys[1])-1]) )
				::procPage(oQuery2, nil,  aKeyList, aaKeys, acPage)	 
				
				acWhere := aaSQLBase[ID_RANK_SIG]+"R.R_A_N_K_ < " 
				
				if ::_Type() == TYPE_GRAPH .and. ::HaveRank()
					 acWhere += dwStr(aaKeys[2, len(aaKeys[1])])
				elseif ::_Type() == TYPE_TABLE .and. ::HaveRank()			
					acWhere += dwStr(aaKeys[1 , 2])
				EndIf				  			
			else
				cAux := ""
				aEval(aKeyList, { |x| cAux := cAux + x[1] + " desc,"})
				cAux := left(cAux, len(cAux)-1)

				/*TODO
    			REPENSAR NO TRATAMENTO DESTE BLOCO*/

	  			oQuery2 := ::makeSQL(aaSQLBase, FIRST_PAGE, nil, cAux, prepKeyList(aaSQLBase[ID_KEY_Y]) + " <= "+ prepKeyValue(aaSQLBase[ID_KEY_Y], aaKeys[1]))
				::procPage(oQuery2, nil, aKeyList, aaKeys, acPage)
			    // Evita paginação (PREVS_PAGE) quando posicionado na primeira página.
				cCompara := iif ( Vazio(aaKeys[1][1]),  " <= " , " >= " )
				// Cria a condição de paginação de acordo com o resultado de cCompara.
		  		acWhere := prepKeyList(aaSQLBase[ID_KEY_Y]) + cCompara + prepKeyValue(aaSQLBase[ID_KEY_Y], aaKeys[2])
		  				  		
		  		If !Empty(aaKeys) .And. ValType(aaKeys) == 'A'		  				
	  				If dwCompArray(aClone(aaKeys[1]), aClone(aaKeys[2]))
		  				HttpGet->acao := FIRST_PAGE
	  				EndIf
		  		EndIf
			endif
		elseif acPage == NEXT_PAGE
			if lUseRank .and. ::RankOn() 
				acWhere := aaSQLBase[ID_RANK_SIG]+"R.R_A_N_K_ > " + dwStr(aaKeys[2, 1])	
			Else	
				cAux := ""
				aEval(aKeyList, { |x| cAux := cAux + x[1] + " desc,"})
				cAux := left(cAux, len(cAux)-1)
                     
    			/*TODO
    			REPENSAR NO TRATAMENTO DESTE BLOCO*/

				// Somente validação para não dar erro.
				If !Empty(aaKeys)
					// Verifica se é a última página da consulta.
					If ::checkLast(cSQLBase, " where " + prepKeyList(aaSQLBase[ID_KEY_Y]) + " >= " +prepKeyValue(aaSQLBase[ID_KEY_Y], aaKeys[2]), aKeyList)
						acWhere := prepKeyList(aaSQLBase[ID_KEY_Y]) + " >= " +prepKeyValue(aaSQLBase[ID_KEY_Y], aaKeys[2])
					Else
						BREAK
					EndIf  
				EndIf
			endif               
		elseif acPage == LAST_PAGE 
			if lUseRank .and. ::RankOn() 
				cAux := "R_A_N_K_ desc"
				oQuery2 := ::makeSQL(aaSQLBase, FIRST_PAGE, nil, cAux)
				::procPage(oQuery2, nil,  aKeyList, aaKeys, acPage)
				acWhere := aaSQLBase[ID_RANK_SIG]+"R.R_A_N_K_ > "+ dwStr(aaKeys[2, 1])
			else
				cAux := ""
				aEval(aKeyList, { |x| cAux := cAux + x[1] + " desc,"})
				cAux := left(cAux, len(cAux)-1)
				oQuery2 := ::makeSQL(aaSQLBase, FIRST_PAGE, nil, cAux)
				::procPage(oQuery2, nil,  aKeyList, aaKeys, acPage)      

    			/*TODO
    			REPENSAR NO TRATAMENTO DESTE BLOCO*/				
				// Somente validação para não dar erro.
				If !Empty(aaKeys[1])				
					acWhere := prepKeyList(aaSQLBase[ID_KEY_Y])+ " >= "+prepKeyValue(aaSQLBase[ID_KEY_Y], aaKeys[2])
				EndIf
			endif  
		endif
   		exit
	enddo                                   
	aAux := {}
	
	if !empty(cRankLimit)
		aAdd(aAux, cRankLimit)
	endif		
	
	if !empty(cWhereBase)
		aAdd(aAux, cWhereBase)
	endif                   
	
	if !empty(cWhereHist)
		aAdd(aAux, cWhereHist)
	endif                   
	
	// Adiciona o filtro para atributos.
	if !empty(acWhere) .and. left(acWhere,1) <> "@"
		aAdd(aAux, acWhere)
	endif

	if len(aAux) <> 0
		cWhere := dwConcatWSep(" and ", aAux)
		cWhere := ::ProcMacro(cWhere)

		aAdd(aSQL, "where " + cWhere)
	endif
	cAux := ""
	
	if !alCount
		if ((anLevelX < 1) .or. SGDB() == DB_DB2 .or. SGDB() == DB_ORACLE)
			aEval(aKeyList, { |x| cAux := cAux + x[1] + ","})
		else
			aEval(aKeyList, { |x| cAux := cAux + x[1] + ","}, 1, anLevelX)
		endif
	
		cAux := left(cAux, len(cAux)-1)
		if !empty(cAux)
			aAdd(aSQL, "group by " + cAux)
		endif
	endif

	// Adiciona o filtro para Indicadores.
	if !empty(cHaving)
		aAdd(aSQL, "having " + cHaving)
	endif

	if !empty(cSQLUnion)
		aAdd(aSQL, "union")
		aAdd(aSQL, cSQLUnion)
		if !empty(cWhere)
			aAdd(aSQL, "where " + cWhere)
		endif 
	endif		

	if alTotal .and. !empty(cHaving)
	else
		if !empty(acOrder) .and. !alCount .and. empty(acSelect)
			aAdd(aSQL, "order by " + acOrder)
		endif
	endif
	cSQL := dwConcatWSep(" ", aSQL)
	cSQL := ::prepareSQL(cSQL,.T.,"S.")  
   
	if alCount
		if  select("X_TRACOUNT") != 0
	   		oQuery:Close()
		endif
	elseif alTotal
		if  select("X_TRATOT") != 0
	   		oQuery:Close()
		endif
	elseif select("X_TRA") != 0
		oQuery:Close()
	endif
		
	if !empty(::Params()) .and. len(::Params()) <> 0
		for nInd := 1 to len(::Params())
			oQuery:AddParam(::Params()[nInd, 1], ::Params()[nInd, 2])
		next
	endif         
	
	if alCount     
		nPos := at("FROM", Upper(cSQL))
		  	
		if SGDB() == DB_INFORMIX   
			oQuery:Open(, "SELECT COUNT (CNT) AS TOTAL FROM (SELECT DISTINCT " + prepKeyList(aKeyList) + " CNT FROM " + substr(cSQL, nPos+5) + ")"  )	   	
		else  
			oQuery:Open(, "SELECT COUNT(DISTINCT " + prepKeyList(aKeyList) + ") CNT FROM " + substr(cSQL, nPos+5))
		endif
		lFormatFields := .f.
	elseif !empty(acSelect)
		if SGDB() == DB_INFORMIX
			oQuery:Open(, cSQL + " ORDER BY " + acOrder + " DESC ")
		else
			oQuery:Open(, "SELECT " + acSelect + " FROM ( " + cSQL + ") x")
		endif
	elseif alTotal .and. !empty(cHaving) 
		aAux := {}
		aEval(::IndFields(.t.), {|x| aadd(aAux, "SUM(" + x + ") " + x) } )
		
		// Adiciona os campos para efetuar a sumarização.
		aEval(::DimFieldsX(), {|x| aadd(aAux, x:Alias() ) } )
		aEval(::DimFieldsX(), {|x| aadd(aGroup, x:Alias() ) } )
		
		cSQL := "SELECT " + dwConcatWSep(",", aAux) + " FROM ( " + cSQL + ") x "

		// Verifica se existe algum campo para efetuar o agrupamento 
		If !Empty(aGroup)
			cSQL += "group by " + dwConcatWSep(",", aGroup)
		EndIf
		oQuery:Open(, cSQL)
		::PrepVirtual(oQuery)
	else             
		oQuery:Open(, cSQL)
		::PrepVirtual(oQuery)
	endif

	if lFormatFields
		aAllFields := ::getAllFields()
		aFields := oQuery:Fields()
		for nInd := 1 to len(aFields)
			nPos := ascan(aAllFields, { |x| x[5] == aFields[nInd, FLD_NAME] })
			if nPos <> 0 .and. aAllFields[nPos, 2] <> "C"
				tcSetField(oQuery:Alias(), aFields[nInd, FLD_NAME], aAllFields[nPos, 2], aAllFields[nPos, 3], aAllFields[nPos, 4])
			endif
		next
		oQuery:faStruct := {}
	endif
return oQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} checkLast
Método que verifica se o registro passado é o último da tabela.

@param   acSelect String com o select a ser processado
@param   acWhere String com o where do select
@param   aKeyList Array com os campos da tabela
@author  BI Team
@version P11
@since   12/07/2013
@return  lRet Valor lógico que se verdadeiro indica que há mais registros
/*/
//-------------------------------------------------------------------
Method checkLast(acSelect, acWhere, aaKeyList) Class TConsulta
	Local lRet:= .F.
	Local cSql := ""
	Local aCampos := {}
	Local nCnt
	Local oQuery
	Local nPos := 0

	acSelect := ::prepareSQL(acSelect,.T.,"S.")

	oQuery := TQuery():New("X_CHKLAST")

	cSql += acSelect
	cSql += iif(!Empty(acWhere), acWhere, "")

	For nCnt := 1 To Len(aaKeyList)
		aAdd(aCampos, aaKeyList[nCnt, ID_SQL_BASE])
	Next nCnt

	cSql += " group by " + dwConcatWSep(",", aCampos)

	oQuery:Open(, cSQL)

	If !oQuery:eof()
		oQuery:Close()

		cSql := acSelect
		nPos := At('=', acWhere)
		cSql += Stuff(acWhere, nPos, 1, "")
		cSql += " group by " + dwConcatWSep(",", aCampos)

		oQuery:Open(, cSQL)

		If !oQuery:eof()
			lRet := .T. // Se ainda há registros para frente.
		Else
			lRet := .F. // Caso não haja mais registros para frente.	
		EndIf
	Else
		lRet := .F. // Caso não haja mais registros para frente.	
	EndIf
	oQuery:Close()
Return lRet

/*
--------------------------------------------------------------------------------------
Obtem o número de registros da consulta
logico -> numerico, numero de registros da consulta
--------------------------------------------------------------------------------------
*/                                                
method recCount() class TConsulta
	local oQuery, nRet, cAlias := alias()

	oQuery := ::makeSQL(::StructBase(), FIRST_PAGE, nil, nil, nil, .t.)
	nRet := oQuery:value(1)
	oQuery:Close()                     

	if !empty(cAlias)
		dbSelectArea(cAlias)
	endif
return nRet

/*
--------------------------------------------------------------------------------------
Processa a leitura da página
--------------------------------------------------------------------------------------
*/                                                
method procPage(aoQuery, aaDados, aaKeyList, aaKeys, acPage) class TConsulta
	Local nRecno := ::PageSize() , cStyle, aAux, aAux2
	Local cOldKeys, i, x, nLenDim, nLenDimX := 0
	Local aKeyAux, lCount, aInd
	Local aKeyList := aclone(aaKeyList)
	Local lUseRank := ::RankOn() .and. ::HaveRank(iif(::drillLevel()<>0,iif(::drillLevel() <> ::DimCountY(),::drillLevel()+1, ::drillLevel()), .f.))
	Local nAux := 0, nQtdeInd
	Local aPreserveKeys, nOldRank
	Local aDadosAux := {}
	Local lShowRegister := .T.
	Local lApplyAlert := ::_Type() == TYPE_TABLE .and. ::alertOn()
	Local lCtrl := .F.
    Local aComp := {}
    Local nLenComp := 0
    Local aAux3 := {}
    Local cAux1 := ""
	         
	/*Incluído para impedir array out of bounds no drill down.*/ 
	If (Len(aaKeys) == 0) 
		aaKeys  := {{},{}}
	EndIf
	
	dbSelectArea(aoQuery:alias())
	
	lUseRank := lUseRank .and. fieldPos("R_A_N_K_") > 0
	aEval(aKeyList, { |x,i| aKeyList[i,1] := strTran(x[1],"S.","")})
	
	// Retira a linha de total das linhas válidas 
	if valType(acPage) == "C"
		if acPage == LAST_PAGE
			nRecno := int(nRecno * 0.6)  + 1
		endif
	endif
	
	if lUseRank 
		aaKeys[1, 1] := "R_A_N_K_"
		aaKeys[1, len(aaKeys[1])] := &("R_A_N_K_")
		aKeyList := { { "R_A_N_K_" } }
	else
		for i := 1 to min(len(aKeyList), len(aaKeys[1]))
			aaKeys[1, i] := &(aKeyList[i, 1])
		next
	endif
	
	aInd := ::Indicadores()
	nQtdeInd := len(aInd)
	nLenDim := ::DimCountX() + ::DimCountY()
	
	if !aoQuery:eof()   
		aKeyAux := {} 
		
		for i := 1 to min(len(aKeyList), len(aaKeys[2]))
			aAdd(aKeyAux, &(aKeyList[i, 1]))
		next
		
		cKeyAux := dwStr(aKeyAux, .t.)
		cOldKeys := cKeyAux

		while !aoQuery:eof() .And. ( nRecno > 1 .Or. lCtrl )
			// Controle para apresentar o registro da última linha de forma correta.
			If lCtrl
				aComp := aoQuery:Record(10) // Array auxiliar para comparação.
				
				//Monta a chave para o atual registro
				aAux3 := {}
				for i := 1 to  min(len(aKeyList), len(aaKeys[2]))
					aAdd(aAux3, &(aKeyList[i, 1]))
				next     
				cAux1 := DwStr(aAux3, .t.)				
				
				If cOldKeys == cAux1
					aAux := aoQuery:Record(10)
				Else                
					IF acPage != LAST_PAGE
						//Monta a chave para o atual registro
						for i := 1 to  min(len(aKeyList), len(aaKeys[2]))
							aaKeys[2, i] := &(aKeyList[i, 1])
						next
					EndIf
					lCtrl := .F.
					Loop
				EndIf
			Else
				aAux := aoQuery:Record(10)
			EndIf

			for i := 1 to nQtdeInd   
				if lApplyAlert
					cStyle := ::ApplyAlerts(aoQuery:Record(1), aInd[i])
				else
					cStyle := ""
				endif  
				
				aAux[i+nLenDim+nLenDimX] := { aAux[i+nLenDim+nLenDimX], iif(empty(cStyle),aAux[i+nLenDim+nLenDimX],cStyle), aInd[i]:alias(), aInd[i]:AggFunc() }
			next
			
			// monta a chave para o atual registro
			aKeyAux := {} 
			
			for i := 1 to  min(len(aKeyList), len(aaKeys[2]))
				aAdd(aKeyAux, &(aKeyList[i, 1]))
			next     
			
			cKeyAux := DwStr(aKeyAux, .t.)
			
			// verificação de último registro com valores iguais
			// (sendo que deverão ser exibidos pois caso seja feita a paginação só começará no novo valor)
			// último registro E as chaves do último registro e do próximo registro é diferente
			//If !(cOldKeys == cKeyAux)
			//	lShowRegister := .T.
			//Else
			//	lShowRegister := .T.
			//EndIf
			
			if lShowRegister
				//Adiciona o registro ao array de retorno dos dados
				aAdd(aDadosAux, aAux)
				
				//Monta a chave para o atual registro
				for i := 1 to  min(len(aKeyList), len(aaKeys[2]))
					aaKeys[2, i] := &(aKeyList[i, 1])
				next
				
				//				if lUseRank
				//			  aaKeys[2, 1] := "R_A_N_K_"
				// 					if aaKeys[2, len(aaKeys[2])] == &("R_A_N_K_")
				// 						nRecno++
				// 					endif
				//					aaKeys[2, len(aaKeys[2])] := &("R_A_N_K_")
				//				endif
				
				//A variável nRecno será decrementada para cada ocorrência de item no Eixo Y.
				If !(cOldKeys == cKeyAux)			
					nRecno--
					
					// No último registro há mais loops para verificar se ainda há valores p/ ele. 
					If nRecno == 1
						lCtrl := .T.
					EndIf
				EndIf 
				cOldKeys := cKeyAux
			endif
			aoQuery:_Next()
		enddo
		
		if valType(aaDados) == "A" 
			if acPage == PREVS_PAGE .AND. ::HaveRank() .AND. ::RankOn()
				for nAux := len(aDadosAux) to 1 step -1
					aAdd(aaDados, aDadosAux[nAux])
				next
				
				// caso seja tabela inverte as chaves
				if ::_Type() == TYPE_TABLE 
					aAux := aaKeys[1]
					aaKeys[1] := aaKeys[2]
					aaKeys[2] := aAux
				endif
			else   
				for nAux := 1 to len(aDadosAux)
					aAdd(aaDados, aDadosAux[nAux])
				next
			endif
		endif
	endif
	
	if ::flExporting
		::fnPageExp++
		::ipcExpNotify()
	endif
return
 
/*
--------------------------------------------------------------------------------------
Prepara a lista de campos chaves para paginação
--------------------------------------------------------------------------------------
*/                                                
function prepKeyList(aaKeyList)
	local aRet := {}, cRet
	local nInd, cAux, nTam
	local nKeyLen := len(aaKeyList)

  	if nKeyLen == 1 .and. aaKeyList[1, 1] == "R_A_N_K_"
		cRet := "round("+aaKeyList[1, 1]+ ", 3)"
		
		if SGDB() == DB_DB2
			cRet := dwFormat("truncate([@X],[@X])", { aaKeyList[1, 1], aaKeyList[1, 3] })
		else
			cRet := dwFormat("round([@X],[@X])", { aaKeyList[1, 1], aaKeyList[1, 3]+1 })
		endif 
  	else	
		nTam := 0
		for nInd := 1 to nKeyLen
			if aaKeyList[nInd, 2] == "N"   
				if SGDB() == DB_ORACLE    
					cAux := "to_char(" + aaKeyList[nInd, 1] + ", '0"+replicate("9", aaKeyList[nInd, 3]-1)+"')"
				elseif SGDB() == DB_INFORMIX
					cAux := "to_char(" + aaKeyList[nInd, 1] + ")"
				elseif SGDB() == DB_DB2
      				cAux := "right(rtrim(varchar(repeat ('0', "+dwStr(aaKeyList[nInd, 3])+"),"+dwStr(aaKeyList[nInd, 3])+")||cast(cast(" + aaKeyList[nInd, 1] + " as char) as varchar("+dwStr(aaKeyList[nInd, 3])+"))),"+dwStr(aaKeyList[nInd, 3])+")"
				else
					cAux := "right(rtrim(replicate('0', "+dwStr(aaKeyList[nInd, 3])+")+cast(" + aaKeyList[nInd, 1] + " as char("+dwStr(aaKeyList[nInd, 3])+"))),"+dwStr(aaKeyList[nInd, 3])+")"
				endif	 
			elseif aaKeyList[nInd, 2] == "C" .and. SGDB() $ DB_MSSQL_ALL
				cAux := "left(" + aaKeyList[nInd, 1] + "+space("+dwStr(aaKeyList[nInd, 3])+"),"+dwStr(aaKeyList[nInd, 3])+")"
			else
				cAux := aaKeyList[nInd, 1]
			endif
			nTam := nTam + aaKeyList[nInd, 3]
			aAdd(aRet, cAux)
		next

		if nKeyLen > 1 .and. (SGDB() == DB_ORACLE .or. SGDB() == DB_DB2 .or. SGDB() == DB_INFORMIX)
			cRet := dwConcatWSep("||", aRet)  
			
			if SGDB() == DB_DB2
			   cRet := " cast( " + cRet + " as varchar(" + dwStr(nTam) + ")) "    
			endif
		else
			cRet := dwConcatWSep("+", aRet)
		endif
	endif
return cRet
/*
--------------------------------------------------------------------------------------
Prepara a lista de valores dos campos chaves para paginação
--------------------------------------------------------------------------------------
*/                                                
function prepKeyValue(aaKeyList, aaKeyValue)
	local cRet := ""
	local nInd
	local nKeyLen := len(aaKeyList)
	
  	if nKeyLen == 1 .and. aaKeyList[1, 1] == "R_A_N_K_"
		cRet := "round(" + dwStr(aaKeyValue[1, 1]) + ",3)"
  	else
		for nInd := 1 to nKeyLen
			if aaKeyList[nInd, 2] == "N"
				if SGDB() == DB_ORACLE
					cRet += " "
				endif
	
				if valType(aaKeyValue) == "A" .and. len(aaKeyValue) >= nInd
					if valType(aaKeyValue[nInd]) == "A"
						cRet += strZero(dwVal(aaKeyValue[nInd][len(aaKeyValue[nInd])]), dwVal(aaKeyList[nInd, 3]))
					else
						cRet += strZero(dwVal(aaKeyValue[nInd]), dwVal(aaKeyList[nInd, 3]))
					endif
				endif
			elseif aaKeyList[nInd, 2] == "D" .and. valType(aaKeyValue[nInd]) == "D"
	   			cRet += dtos(aaKeyValue[nInd])
	 		elseif aaKeyList[nInd, 2] == "C" 
	 			cRet += Trim(DwStr(aaKeyValue[nInd])) + REPLICATE(" ", aaKeyList[nInd, 3] - iif(!empty(Trim(aaKeyValue[nInd])), len(Trim(aaKeyValue[nInd])), 0))
			else
  		   		cRet += dwStr(aaKeyValue[nInd])
			endif
		next
         
       //Realiza a limpeza de caracteres especiais indesejados. 
       //DB2 deve possuir tratamento específico em função da sintaxe dos comandos.  
		if nKeyLen == 1 .and. !(aaKeyList[1,2] == "N")
			if SGDB() == DB_DB2
				cRet := "'" + strTran(cRet, "'", "||char(39)||") + "'"
          	else
				cRet := "'" + strTran(cRet, "'", "'+char(39)+'") + "'"
   		  	endif
		else                         
			cRet := dwStr(cRet,.t.)
		endif
        
		if SGDB() == DB_DB2                  
		  	cRet := strTran(cRet, "+chr(10)+", "||char(10)||")   
		  	cRet := strTran(cRet, "+chr(13)+", "||char(13)||") 		  
		endif
	endif
return cRet

/*
--------------------------------------------------------------------------------------
Verifica se há indicadores com media interna
--------------------------------------------------------------------------------------
*/                                                
method haveMedInt() class TConsulta
	if valType(::flHaveMedInt) == "U"
		::flHaveMedInt := ascan(::Indicadores(), { |x| x:AggFunc() == AGG_MEDINT}) <> 0
	endif
return ::flHaveMedInt

/*
--------------------------------------------------------------------------------------
Verifica se há indicadores com acumulado
--------------------------------------------------------------------------------------
*/                                                
method haveAcum() class TConsulta
	if valType(::flHaveAcum) == "U"
		::flHaveAcum := ascan(::Indicadores(), { |x| x:AggFunc() == AGG_ACUM .or. x:AggFunc() == AGG_ACUMPERC }) <> 0
	endif
return ::flHaveAcum

/*
--------------------------------------------------------------------------------------
Verifica se há indicadores com acumulado histórico
--------------------------------------------------------------------------------------
*/                                                
method haveAcumHist() class TConsulta
	if valType(::flHaveHistAcum) == "U"
		::flHaveHistAcum := ascan(::Indicadores(), { |x| x:AggFunc() == AGG_ACUMHIST .or. x:AggFunc() == AGG_ACUMHISTPERC }) <> 0
	endif
return ::flHaveHistAcum

/*
--------------------------------------------------------------------------------------
Efetua o processamento de indicadores acumalados (media interna, acumulado e acumulado histórico)
--------------------------------------------------------------------------------------
*/                                 
static function apuraAcum(aoQuery, aaInd, aaAcum, aaCount, lAcumHist, lRankOn)
	local nInd 
	
	default lAcumHist := .f.

	for nInd := 1 to len(aaInd)
		if aaInd[nInd]:AggFunc() == AGG_MEDINT .or. aaInd[nInd]:AggFunc() == AGG_ACUM .or. aaInd[nInd]:AggFunc() == AGG_ACUMPERC
				aaAcum[nInd] += oQuery:value(aaInd[nInd]:Alias())
		elseif aaInd[nInd]:AggFunc() == AGG_ACUMHIST .or. aaInd[nInd]:AggFunc() == AGG_ACUMHISTPERC
			aaAcum[nInd] += iif(lRankOn, 0, oQuery:value(aaInd[nInd]:Alias()))
		endif
		
		if aaInd[nInd]:AggFunc() == AGG_MEDINT
			aaCount[nInd] += oQuery:value("CNT_"+aaInd[nInd]:Alias())
		else
			aaCount[nInd] := 1
			if aaInd[nInd]:AggFunc() == AGG_ACUMHIST .or. aaInd[nInd]:AggFunc() == AGG_ACUMHISTPERC
				lAcumHist := .t.
			endif
		endif
	next
return lAcumHist

static function apuraAcumHist(aoQuery, aaInd, aaAcum, aaCount)
	local nInd 

	while !aoQuery:eof()
		for nInd := 1 to len(aaInd)
			if aaInd[nInd]:AggFunc() == AGG_ACUMHIST .or. aaInd[nInd]:AggFunc() == AGG_ACUMHISTPERC
				aaAcum[nInd] := oQuery:value(aaInd[nInd]:Alias())
			endif
		next
		aoQuery:_next()
	enddo
return nil
               
// trata macro @ACUM, @ACUMHIST, @ACUMPERC, @ACUMHISTPERC
static function execMacro(aoCons, aaRow, acExpressao, acAlvo)
	local aInd := aoCons:Indicadores()
	local aIndVir := aoCons:IndVirtual(,.f.), oIndVirt
  	local cAux := upper(acExpressao)                      
	local cFieldname := ""
	local nInd, nInd2, nInd3

  	for nInd := 1 to len(aIndVir)
		oIndVirt := aIndVir[nInd]
		for nInd2 := 1 to len(aInd)
			oInd := aInd[nInd2]
			if oInd:alias() == oIndVirt:alias()
				loop
			endif
			nPos := 0
	
			for nInd3 := 1 to len(aaRow)
				if valtype(aaRow[nInd3]) == "A" .and. aaRow[nInd3, 3] == oInd:Alias()
					nPos := nInd3
					exit
				endif
			next

  			if nPos <> 0         
  				cFieldname := oInd:DimName()+"->"+oInd:realField()
				if oInd:AggFunc() == AGG_ACUM .and. "@ACUM("+ cFieldname + ")" $ cAux
					acExpressao := strTranIgnCase(acExpressao, "@ACUM("+cFieldname+")", dwStr(aaRow[nPos, 1]))
				endif
				
				if oInd:AggFunc() == AGG_ACUMHIST .and. "@ACUMHIST("+ cFieldname + ")" $ cAux
					acExpressao := strTranIgnCase(acExpressao, "@ACUMHIST("+cFieldname+")", dwStr(aaRow[nPos, 1]))
				endif
				
				if oInd:AggFunc() == AGG_ACUMPERC .and. "@ACUMPERC("+ cFieldname + ")" $ cAux
					acExpressao := strTranIgnCase(acExpressao, "@ACUMPERC("+cFieldname+")", dwStr(aaRow[nPos, 1]))
				endif
				
				if oInd:AggFunc() == AGG_ACUMHISTPERC .and. "@ACUMHISTPERC("+ cFieldname + ")" $ cAux
					acExpressao := strTranIgnCase(acExpressao, "@ACUMHISTPERC("+cFieldname+")", dwStr(aaRow[nPos, 1]))
				endif
				
				if oInd:AggFunc() == AGG_SUM .and. "SUM("+ cFieldname + ")" $ cAux
					acExpressao := strTranIgnCase(acExpressao, "SUM("+cFieldname+")", dwStr(aaRow[nPos, 1]))
				endif
				
				if oInd:AggFunc() == AGG_MIN .and. "MIN("+ cFieldname + ")" $ cAux
					acExpressao := strTranIgnCase(acExpressao, "MIN("+cFieldname+")", dwStr(aaRow[nPos, 1]))
				endif
				
				if oInd:AggFunc() == AGG_MAX .and. "MAX("+ cFieldname + ")" $ cAux
					acExpressao := strTranIgnCase(acExpressao, "MAX("+cFieldname+")", dwStr(aaRow[nPos, 1]))
				endif
				
				if oInd:AggFunc() == AGG_AVG .and. "AVG("+ cFieldname + ")" $ cAux
					acExpressao := strTranIgnCase(acExpressao, "AVG("+cFieldname+")", dwStr(aaRow[nPos, 1]))
				endif
				
				if oInd:AggFunc() == AGG_COUNT .and. "COUNT("+ cFieldname + ")" $ cAux
					acExpressao := strTranIgnCase(acExpressao, "COUNT("+cFieldname+")", dwStr(aaRow[nPos, 1]))
				endif			
				cAux := upper(acExpressao)
  			endif
  		next
  	next
return &(parseSQL(acExpressao))

method procAcum(aoQuery, aaDados, aaKeyList, aaKeys, acPage) class TConsulta
	local aInd := ::Indicadores(,.t.)
	local aAcum := array(len(aInd))
	local aCount := array(len(aInd))
	local nCountY := iif(::HaveDrillDown(), ::DrillLevel(), ::DimCountY())
	local nRow, nInd, nPos := len(::DimFields()) 
	local cKeyList, lAcumHist := .f.
 	local aOldKey := {}, aAuxKey, lHaveMacroAt
	local lZeraAcum
      
	aFill(aAcum, 0)
	aFill(aCount, 0)
	
	if acPage != FIRST_PAGE .or. ::HaveAcumHist()
		cKeyList := prepKeyList(aaKeyList)       
		
		if (::HaveAcum() .or. ::haveMedInt()) .And. !(::HaveAcumHist())
			If !(::RankOn() .and. ::haveRank())
				oQuery := ::SQLAcum(cKeyList+" < "+prepKeyValue(aaKeyList, aaKeys), cKeyList)
			Else    
				If ::RankDef()[1][3] == RNK_MENORES
					oQuery := ::SQLAcum(cKeyList+" < " + prepKeyValue(aaKeyList, aaKeys), cKeyList)
				Else
					oQuery := ::SQLAcum(cKeyList+" > "+prepKeyValue(aaKeyList, aaKeys), cKeyList)
				EndIf
			EndIf
			lAcumHist := apuraAcum(oQuery, aInd, aAcum, aCount, , ::RankOn())
			oQuery:Close()
		endif
		 
		/*Não calcula acumulado histórico em consultas com Hanking ativo.*/
		if ::HaveAcumHist() .And. !::RankOn()
			oQuery := ::SQLAcumHist(cKeyList + " < "+prepKeyValue(aaKeyList, aaKeys), cKeyList)
			apuraAcumHist(oQuery, aInd, aAcum, aCount, .t.)
			oQuery:Close()
		endif
	endif	
 	lZeraAcum := (DWZeraAcum() .or. ::ZeraAcum()) 
  	
 	if lZeraAcum
		aAuxKey := array(nCountY)
		aOldKey := array(nCountY)
	endif

	lHaveMacroAt := .f.			

	for nRow := 1 to len(aaDados) //ignorar a primeira linha do result-set
		if lZeraAcum .and. len(aOldKey) > 0 	
			for nInd := 1 to nCountY
				aAuxKey[nInd] := aaDados[nRow, nInd]
			next

			if !(dwStr(aAuxKey) == dwStr(aOldKey))
				aFill(aAcum, 0)
				aOldKey := aclone(aAuxKey)
			endif
		endif

		for nInd := 1 to len(aInd)
			if "@acum" $ lower(aInd[nInd]:expressao())
					lHaveMacroAt := .t.
			elseif !aInd[nInd]:canTotalize()
				aAcum[nInd] += aaDados[nRow, nPos + nInd, 1]
				if aInd[nInd]:AggFunc() == AGG_MEDINT
					aCount[nInd]++
					aaDados[nRow, nPos + nInd, 1] := aAcum[nInd] / aCount[nInd]
				elseif (aInd[nInd]:AggFunc() == AGG_ACUMHIST .or. aInd[nInd]:AggFunc() == AGG_ACUMHISTPERC) .and. ::RankOn()
					aaDados[nRow, nPos + nInd, 1] := 0
				else
					aaDados[nRow, nPos + nInd, 1] := aAcum[nInd]
				endif
				aaDados[nRow, nPos + nInd, 2] := aaDados[nRow, nPos + nInd, 1]
			endif
		next
		
		if lHaveMacroAt
			for nInd := 1 to len(aInd)                 
				if !empty(aInd[nInd]:expressao()) .and. "@acum" $ lower(aInd[nInd]:expressao())
					aaDados[nRow, nPos + nInd, 1] := execMacro(self, aaDados[nRow], aInd[nInd]:expressao(), aInd[nInd]:alias())
					aaDados[nRow, nPos + nInd, 2] := aaDados[nRow, nPos + nInd, 1]
				endif
			next
		endif
	next
return

/*
--------------------------------------------------------------------------------------
Envia notificações via IPC
Args: 
--------------------------------------------------------------------------------------
*/
method ipcNotify(acMsg, alInfo) class TConsulta
	if !empty(::ipc())	
		default alInfo := .f.

		if acMsg == "*END*"
			sendIpcMsg(::ipc(), IPC_TERMINO)
		elseif acMsg == "*ERROR*"
			sendIpcMsg(::ipc(), IPC_ERRO, { "true", STR0021 })  //"Ocorreu um erro durante o processo. Favor verificar as definições."
		elseif alInfo
			sendIpcMsg(::ipc(), IPC_BUFFER, .t.)
			sendIpcMsg(::ipc(), IPC_PROCESSO, QRY_PRO_INICIO, ::fnTotProcs)
			sendIpcMsg(::ipc(), IPC_INFO, { acMsg })
			sendIpcMsg(::ipc(), IPC_BUFFER, .f.)
		else                           
			sendIpcMsg(::ipc(), IPC_BUFFER, .t.)
			sendIpcMsg(::ipc(), IPC_ETAPA, acMsg, QRY_ETA_INICIO)       
			if ::fnTempoEst == 0
			  	sendIpcMsg(::ipc(), IPC_TEMPO, dtoc(::fdInicio) + " " + ::fcInicio,,)
			else
			  	sendIpcMsg(::ipc(), IPC_TEMPO, dtoc(::fdInicio) + " " + ::fcInicio, DWSecs2Str(::fnTempoEst), DWSecs2Str(dwTime2Secs(time()) + ::fnTempoEst))
			endif
			sendIpcMsg(::ipc(), IPC_BUFFER, .f.)
		endif
	endif
return 

method ipcExpNotify() class TConsulta
	if !empty(::ipc())	
//    sendIpcMsg(::ipc(), IPC_BUFFER, .t.)
		sendIpcMsg(::ipc(), IPC_AVISO_SP, ::fnPageExp, ::fnTotProcs, ::fnPageExp / ::fnTotProcs)
//		if ::fnTempoEst == 0
//		  sendIpcMsg(::ipc(), IPC_TEMPO, dtoc(::fdInicio) + " " + ::fcInicio,,)
//    else
//		  sendIpcMsg(::ipc(), IPC_TEMPO, dtoc(::fdInicio) + " " + ::fcInicio, DWSecs2Str(::fnTempoEst), DWSecs2Str(dwTime2Secs(time()) + ::fnTempoEst))
//		endif
//		sendIpcMsg(::ipc(), IPC_BUFFER, .f.)
	endif
return 

/*
--------------------------------------------------------------------------------------
Configura as larguras das colunas
Args: 
--------------------------------------------------------------------------------------
*/
method PanWidth(anValue) class TConsulta
	property ::fnPanWidth := anValue
return ::fnPanWidth

method AttWidth(aaValues) class TConsulta
	if valType(aaValues) == "A"
		::faAttWidth := aClone(aaValues)
	endif	
return ::faAttWidth

method IndWidth(aaValues) class TConsulta
	if valType(aaValues) == "A"
		::faIndWidth := aClone(aaValues)
	endif	
return ::faIndWidth

/*
--------------------------------------------------------------------------------------
Propriedade IPC
Args: 
--------------------------------------------------------------------------------------
*/
method IPC(acValue) class TConsulta
	property ::fcIPC := acValue
return ::fcIPC

/*
--------------------------------------------------------------------------------------
Propriedade CubeID
Args: 
--------------------------------------------------------------------------------------
*/
method CubeID() class TConsulta
return ::fnCubeID

method CRWName(acValue) class TConsulta
return ::Props(ID_CRWNAME, acValue)

method CRWDesc(acValue) class TConsulta
return ::Props(ID_CRWDESC, acValue)

method CRWURL(acValue) class TConsulta
return ::Props(ID_CRWURL, acValue)

method CRWParams(aaValues) class TConsulta
	if valType(aaValues) == "A"
		::faCRWParams := aClone(aaValues)
	endif	
return ::faCRWParams

#ifdef DWCACHE
#else
	/*
	--------------------------------------------------------------------------------------
	Acesso e manipulação do cache de consultas
	--------------------------------------------------------------------------------------
	*/
	method inCache() class TConsulta
		local lRet := .f.
	  
		if DWisWebEx() .and. HTTPIsConnected()
			lRet := dwExistProp(CACHE_QUERY, CACHE_IDENTIFIER)
		endif
	return lRet
	
	method clearCache(alSession) class TConsulta
		local aAux, cAux, nInd
	
		default alSession := .f.
	
		if ::inCache()
			DWDelProp(CACHE_QUERY, CACHE_IDENTIFIER)
			if alSession
				::delCacheInfo("TotGeral")
				::delCacheInfo("TotGlobal")
	
				// Params                 
				aAux := ::Params()
				if valType(aAux) == "A"
					for nInd := 1 to len(aAux)
						cAux := "HttpSession->pt" + aAux[nInd, 1]
		  				(&cAux) := nil
					next     
				endif
	
				::AutoFilter("")
				DwSetProp(ID_ARRVALUES + DwStr(::ID()) + DwStr(::_Type()), NIL, ID_VIEW_NAMPRG)
			endif
		endif
	return 

	method UpdCache() class TConsulta
		local aAxisX := {}, aAxisY := {}, aAxisM := {}, aCAlert := {}, aCWhere := {}
		local aQueryInCache, nInd
		
		if !::HaveCube()
			::clearCache()
			return
		endif
		
		// dimensoes             
		aEval(::DimFieldsX(.t.), { |x| aAdd(aAxisX, "("+DWStr(x:Temporal())+"|"+iif(::_Type() == TYPE_TABLE, iif(x:IsSubTotal(), "1", "0"), "")+alltrim(x:GraphColor())+")"+iif(x:DrillDown(), "*", "")+DWStr(x:ID())) })
		aEval(::DimFieldsY(.t.), { |x| aAdd(aAxisY, "("+DWStr(x:Temporal())+"|"+iif(::_Type() == TYPE_TABLE, iif(x:IsSubTotal(), "1", "0"), "")+alltrim(x:GraphColor())+")"+iif(x:DrillDown(), "*", "")+DWStr(x:ID())) })
	
		// indicadores
		aEval(::Indicadores(), { |x| iif(x:Ordem() < 0, nil, aAdd(aAxisM, x:CharIndicador()+DWStr(x:ID())))})
		
		// Lista de where ativos
		aEval(::Where(.t.), { |x| iif(x:selected(), aAdd(aCWhere, x:ID()),nil) })
	
		// Lista de alertas ativados
		aEval(::Alerts(.t.), { |x| iif(x:selected(), aAdd(aCAlert, x:ID()),nil) })
		
		// Ajusta cache para a consulta corrente
		aQueryInCache = array(MEMO_CONS_QTDE_ELEMS)
		//cubo                         
		aQueryInCache[MEMO_CONS_CUBE_ID] := ::fnCubeID
		aQueryInCache[MEMO_CONS_PROPS]   := { aClone(::faIntFrom), ::Name(), ::Desc(), aClone(::AttWidth()), ;
				::PanWidth(), aClone(::IndWidth()), {}, {}, {}, {}, aClone(::Props(ID_RANKING)), {}, {}, {}, ;
				{}, ::Props(ID_FILTERED), ::Props(ID_TOTAL), ::Props(ID_ALERTON), ::Props(ID_HINTON), ;
				::Props(ID_IGNOREZERO), ::Props(ID_USEEXCEL), ::Props(ID_RANKON), ::Props(ID_RANKOUTROS), ;
				::Props(ID_RELATIONID), ::Props(ID_PARAMS), ::Props(ID_FATORESCALA), ::Props(ID_SOBREPOSTO),;
				::Props(ID_EMPTYCELL), ::Props(ID_CLASS), ::Props(ID_GRAPHPROPS), ::Props(ID_GRAPHYPROPS), ;
				::Props(ID_GRAPHY2PROPS), ::Props(ID_IDUSER), ::Props(ID_USERNAME), ::Props(ID_ISVALID), ;
				::Props(ID_ISPUBLIC), ::Props(ID_CRWNAME), ::Props(ID_CRWDESC), ::Props(ID_CRWURL), ;
				aClone(::faCRWParams), /*aClone(::faDrillParms)*/ nil, ::flZeraAcum, /*::fnDrillOrig*/, ::fnCubeID, nil/*aclone(::faHideAtt)*/, ::Props(ID_FILLALL)}
		aQueryInCache[MEMO_CONS_AXIS_X] 	  	:= aClone(aAxisX)
		aQueryInCache[MEMO_CONS_AXIS_Y] 	  	:= aClone(aAxisY)
		aQueryInCache[MEMO_CONS_AXIS_M] 	  	:= aClone(aAxisM)
		aQueryInCache[MEMO_CONS_ALERT] 		  	:= aClone(aCAlert)
		aQueryInCache[MEMO_CONS_WHERE] 		  	:= aClone(aCWhere)
		aQueryInCache[MEMO_CONS_RANK]       	:= aClone(::RankDef())
		aQueryInCache[MEMO_CONS_CURVAABC]   	:= aClone(::CurvaABC())
		aQueryInCache[MEMO_CONS_AUTO_FILTER]	:= ::AutoFilter()
		aQueryInCache[MEMO_CONS_DRILL] 			  := ::DrillParms()
		aQueryInCache[MEMO_CONS_HIDEATT]      := aclone(::faHideAtt)
		aQueryInCache[MEMO_CONS_PAGE_KEYS]    := aclone(::faKeyValues)
		aQueryInCache[MEMO_CONS_DRILL_HIST]   := aclone(::faDrillHist)
		aQueryInCache[MEMO_CONS_RANKSUBTOTAL] := ::Props(ID_RANKSUBTOTAL)
		aQueryInCache[MEMO_CONS_RANKTOTAL]    := ::Props(ID_RANKTOTAL)
		aQueryInCache[MEMO_CONS_RANKSTYLE]    := ::Props(ID_RANKSTYLE)
	
		// Params                 
		aAux := ::Params()
		for nInd := 1 to len(aAux)
			cAux := "HttpSession->pt" + aAux[nInd, 1]
	  		(&cAux) := aAux[nInd, 2]
		next
	
		// Grava no cache
	  	dwSetProp(CACHE_QUERY, aClone(aQueryInCache), CACHE_IDENTIFIER)
	return

	method UpdFromCache(aaProps) class TConsulta
		local aAxisX, aAxisY, aAxisM
		local nInd, nScope, cGraphColor, cStr, cLevel
		local aQueryInCache
	
	  	::lock()
	
		if valtype(aaProps) == "A"
			aQueryInCache := aaProps
		else
			aQueryInCache := aClone(dwGetProp(CACHE_QUERY, CACHE_IDENTIFIER))
			::UpdCacheRuntime(aQueryInCache)
		endif
	
		::AttWidth(aQueryInCache[MEMO_CONS_PROPS, 4])
		::PanWidth(aQueryInCache[MEMO_CONS_PROPS, 5])
		::IndWidth(aQueryInCache[MEMO_CONS_PROPS, 6])
		::Props(ID_DRILLDOWN, aQueryInCache[MEMO_CONS_PROPS, 15])
		::Props(ID_USEEXCEL, aQueryInCache[MEMO_CONS_PROPS, 21])
		::Props(ID_RELATIONID, aQueryInCache[MEMO_CONS_PROPS, 24])
		::Props(ID_CLASS, aQueryInCache[MEMO_CONS_PROPS, 29])
		::Props(ID_GRAPHPROPS, aQueryInCache[MEMO_CONS_PROPS, 30])
		::Props(ID_GRAPHYPROPS, aQueryInCache[MEMO_CONS_PROPS, 31])
		::Props(ID_GRAPHY2PROPS, aQueryInCache[MEMO_CONS_PROPS, 32])
		::faHideAtt := aclone(aQueryInCache[MEMO_CONS_HIDEATT])
		::faKeyValues	:= aclone(aQueryInCache[MEMO_CONS_PAGE_KEYS])
		::faDrillHist	:= aclone(aQueryInCache[MEMO_CONS_DRILL_HIST])
	
		// prepara os dados da HttpSession para serem salvos
		aAxisX := aClone(aQueryInCache[MEMO_CONS_AXIS_X])
		aAxisY := aClone(aQueryInCache[MEMO_CONS_AXIS_Y])
		aAxisM := aClone(aQueryInCache[MEMO_CONS_AXIS_M])
		
		// reset - dimensoes, indicadores, ranking
		aSize(::Dimensao(), 0)
		aSize(::DimFields(), 0)
		aSize(::IndList(), 0)
		aSize(::RankDef(), 0)
		//aSize(::CurvaABC(), 0)
		
		// dimensoes
		for nInd := 1 to len(aAxisX)
			::AddDimFields("X", aAxisX[nInd])
		next
		
		for nInd := 1 to len(aAxisY)
			::AddDimFields("Y", aAxisY[nInd])
		next
		
		// indicadores
		for nInd := 1 to len(aAxisM)
			nScope := 0
			cGraphColor := ""
			cLevel := ""
			cStr := aAxisM[nInd]
			if( substr(cStr, 1, 1) == "(" )
				if( at("|", cStr) != 0 )
					nScope := val( substr(cStr, 2, at("|", cStr)-1) )
					cStr := substr(cStr, at("|", cStr)+1)
					if( at("|", cStr) != 0)
						cGraphColor := substr(cStr, 1, at("|", cStr)-1)
						cStr := substr(cStr, at("|", cStr)+1)
						cLevel := substr(cStr, 1, at(")", cStr)-1)
					else
						cGraphColor := substr(cStr, 1, at(")", cStr)-1)
					endif
				else
					nScope := val(substr(cStr, 2, at(")", cStr)-1))
				endif
				cStr := substr(cStr, at(")", cStr)+1)
			endif
			::AddIndicador(nScope, val(cStr), nInd, cGraphColor, cLevel)
		next
		::VerIndicador()
		
		// Parametros do Drill-down
		if isNull(aQueryInCache[MEMO_CONS_DRILL])
			::DrillParms(0, "")
		else
			::DrillParms(aQueryInCache[MEMO_CONS_DRILL][1], aQueryInCache[MEMO_CONS_DRILL][2])
		endif
	
		// rank
		for nInd := 1 to len(aQueryInCache[MEMO_CONS_RANK])
			::RankDef(nInd, aQueryInCache[MEMO_CONS_RANK, nInd, 1], aQueryInCache[MEMO_CONS_RANK, nInd, 2], aQueryInCache[MEMO_CONS_RANK, nInd, 3])
	  	next	
		
		// parametros da curva ABC
		::CurvaABC(aQueryInCache[MEMO_CONS_CURVAABC])
		
		// AUTO FILTER - SELEÇÃO
		::AutoFilter(aQueryInCache[MEMO_CONS_AUTO_FILTER])
	
	  	::unlock()
	return
	
	/*
	Método responsável por atualizar do cache, opções de runtime (Filtros, Alertas, etc)
	*/
	method UpdCacheRuntime(aaQueryInCache) class TConsulta
		local nInd, aCRank, aAux, aCAlert := {}, aCWhere := {}
		
		if !::inCache() .and. valType(aaQueryInCache) == "U"
			return
		endif
	
	  	::lock()
		
		default aaQueryInCache := aClone(dwGetProp(CACHE_QUERY, CACHE_IDENTIFIER))
		
		aCAlert := aClone(aaQueryInCache[MEMO_CONS_ALERT])
		aCWhere := aClone(aaQueryInCache[MEMO_CONS_WHERE])
		
		::Props(ID_FILTERED, aaQueryInCache[MEMO_CONS_PROPS, 16])
		::Props(ID_TOTAL, aaQueryInCache[MEMO_CONS_PROPS, 17])
		::Props(ID_ALERTON, aaQueryInCache[MEMO_CONS_PROPS, 18])
		::Props(ID_HINTON, aaQueryInCache[MEMO_CONS_PROPS, 19])
		::Props(ID_IGNOREZERO, aaQueryInCache[MEMO_CONS_PROPS, 20])
		::Props(ID_RANKON, aaQueryInCache[MEMO_CONS_PROPS, 22])
		::Props(ID_RANKOUTROS, aaQueryInCache[MEMO_CONS_PROPS, 23])
		::Props(ID_RANKSUBTOTAL, aaQueryInCache[MEMO_CONS_RANKSUBTOTAL])
		::Props(ID_RANKTOTAL, aaQueryInCache[MEMO_CONS_RANKTOTAL])
		::Props(ID_RANKSTYLE, aaQueryInCache[MEMO_CONS_RANKSTYLE])
	
		::Props(ID_PARAMS, aaQueryInCache[MEMO_CONS_PROPS, 25])
		::Props(ID_FATORESCALA, aaQueryInCache[MEMO_CONS_PROPS, 26])
		::Props(ID_SOBREPOSTO, aaQueryInCache[MEMO_CONS_PROPS, 27])
		::Props(ID_EMPTYCELL, aaQueryInCache[MEMO_CONS_PROPS, 28])	
		::Props(ID_FILLALL, aaQueryInCache[MEMO_CONS_PROPS, 46]) //####TODO: Verificar se a posição etsa correto?????
		
		// Params
		aAux := ::Params()
		for nInd := 1 to len(aAux)
			cAux := "HttpSession->pt" + aAux[nInd, 1]
	    	if DWisWebEx() .and. httpIsConnected()
		  		aAux[nInd, 2] := dwStr(&cAux)
	  			if !empty(ctod(aAux[nInd, 2]))
		   	  		aAux[nInd, 2]	:= ctod(aAux[nInd, 2])
	   			endif   	
		 	else 
	
		 	endif
		next
		
		// alertas
		aAux := ::Alerts(.t.)
		for nInd := 1 to len(aAux)
			aAux[nInd]:Selected(ascan(aCAlert, { |x| x==aAux[nInd]:id()})>0)
		next
	
		aAux := ::Where(.t.)
		for nInd := 1 to len(aAux)
			aAux[nInd]:Selected(ascan(aCWhere, { |x| x==aAux[nInd]:id()})>0)
		next
		
		// rank
		for nInd := 1 to len(aaQueryInCache[MEMO_CONS_RANK])
			::RankDef(nInd, aaQueryInCache[MEMO_CONS_RANK, nInd, 1], aaQueryInCache[MEMO_CONS_RANK, nInd, 2], aaQueryInCache[MEMO_CONS_RANK, nInd, 3])
	  	next	
		
		// parametros da curva ABC
		::CurvaABC(aaQueryInCache[MEMO_CONS_CURVAABC])
		
		// AUTO FILTER - SELEÇÃO
		::AutoFilter(aaQueryInCache[MEMO_CONS_AUTO_FILTER])
	
	  	::unlock()
	return
	
	/*
	--------------------------------------------------------------------------------------
	Verifica se há informações no cache da consulta
	--------------------------------------------------------------------------------------
	*/
	method inCacheInfo(acInfoID) class TConsulta
		local lRet := .f.
		
		if dwIsWebEx() .and. HTTPIsConnected()
			lRet := dwExistProp(acInfoID, CACHE_IDENTIFIER)
		endif
	return lRet
	
	/*
	--------------------------------------------------------------------------------------
	Grava informações no cache da consulta
	--------------------------------------------------------------------------------------
	*/
	method setCacheInfo(acInfoID, axValue) class TConsulta
		if dwIsWebEx() .and. HTTPIsConnected()
	    	dwSetProp(acInfoID, axValue, CACHE_IDENTIFIER)
		endif
	return
	
	/*
	--------------------------------------------------------------------------------------
	Recupera informações no cache da consulta
	--------------------------------------------------------------------------------------
	*/
	method getCacheInfo(acInfoID) class TConsulta
		local xRet := nil
		
		if ::inCacheInfo(acInfoID)
			xRet := dwGetProp(acInfoID, CACHE_IDENTIFIER)
		endif
	return xRet
	
	/*
	--------------------------------------------------------------------------------------
	Remove informações do cache da consulta
	--------------------------------------------------------------------------------------
	*/
	method delCacheInfo(acInfoID) class TConsulta
		if ::inCacheInfo(acInfoID)
			dwDelProp(acInfoID, CACHE_IDENTIFIER)
		endif
	return	
#endif

method updFromGet() class TConsulta
	local aAxisX, aAxisY, aDimFields
	local nInd, nPos
                 
	if HttpGet->AxisX == "none"
		HttpGet->AxisX := ""
	endif
	
	if HttpGet->AxisY == "none"
		HttpGet->AxisY := ""
	endif

	aAxisX := DWToken(HttpGet->AxisX, ";", .f.)
	aAxisY := DWToken(HttpGet->AxisY, ";", .f.)

	// reset - dimensoes, indicadores, ranking
	if len(aAxisX) > 0 .or. len(aAxisY) > 0
		aDimFields := ::DimFields()
		for nInd := 1 to len(aAxisX)
			nPos := ascan(aDimFields, { |x| x:alias() == aAxisX[nInd] })
			if nPos > 0
				aDimFields[nPos]:eixo('X')
				aDimFields[nPos]:ordem(nInd)
			endif
		next
	
		for nInd := 1 to len(aAxisY)
			nPos := ascan(aDimFields, { |x| x:alias() == aAxisY[nInd] })
			if nPos > 0
				aDimFields[nPos]:eixo('Y')
				aDimFields[nPos]:ordem(nInd)
			endif
		next
		aSort(aDimFields,,, { |x,y| x:eixo() > y:eixo() .or. (x:eixo() == y:eixo() .and. x:ordem() < y:ordem())})
		::UpdCache()
	endif
return

method updFromPost() class TConsulta
	local aAxisX, aAxisY, aAxisM, aCAlert, aCWhere
	local nInd, nScope, cGraphColor, cStr, aCRank, aAux, cLevel
	local aAutoFilter := {}, aSessFldValue, nPos
	local aClassif := {}
	
	// proprieades somente alteradas na definição de uma consulta
	if HttpGet->Action == AC_QUERY_DEF
		if HttpPost->AxisX == "none"
			HttpPost->AxisX := ""
		endif
	
		if HttpPost->AxisY == "none"
			HttpPost->AxisY := ""
		endif
		
		// prepara os dados de HttpPost para serem salvos
		aAxisX := DWToken(isNull(HttpPost->AxisX, ""), ";", .f.)
		aAxisY := DWToken(isNull(HttpPost->AxisY, ""), ";", .f.)
		aAxisM := DWToken(isNull(HttpPost->AxisM, ""), ";", .f.)
		
		// verifica a existência de drill down
		if at("*", isNull(HttpPost->AxisY, "")) > 0
			// verifica qual nível possui o drilldown e define-o como origem
			for nInd := 1 to len(aAxisY)
				if at("*", aAxisY[nInd]) > 0
					::DrillOrig(nInd)
					nInd := len(aAxisY)
				endif
			next
		else
			// define como não tendo drilldown (em caso de redefinições da consulta e que tenha tirado o drilldonw)
			::DrillOrig(NOT_EXIST_DD)
		endif
		
		// reset - dimensoes, indicadores, ranking
		if len(aAxisX) > 0 .or. len(aAxisY) > 0 .or. len(aAxisM) > 0
			aSize(::Dimensao(), 0)
			aSize(::DimFields(), 0)
			aSize(::IndList(), 0)
			aSize(::RankDef(), 0)
			aSize(::CurvaABC(), 0)
		
			// dimensoes  
			for nInd := 1 to len(aAxisX)
				::AddDimFields("X", aAxisX[nInd])
			next
	
			for nInd := 1 to len(aAxisY)
				::AddDimFields("Y", aAxisY[nInd])
			next
		
			// indicadores
			for nInd := 1 to len(aAxisM)
				nScope := 0
				cGraphColor := ""
				cLevel := ""
				cStr := aAxisM[nInd]
				if( substr(cStr, 1, 1) == "(" )
					if( at("|", cStr) != 0 )
						nScope := val( substr(cStr, 2, at("|", cStr)-1) )
						cStr := substr(cStr, at("|", cStr)+1)
						if( at("|", cStr) != 0)
							cGraphColor := substr(cStr, 1, at("|", cStr)-1)
							cStr := substr(cStr, at("|", cStr)+1)
							cLevel := substr(cStr, 1, at(")", cStr)-1)
						else
							cGraphColor := substr(cStr, 1, at(")", cStr)-1)
						endif
					else
						nScope := val(substr(cStr, 2, at(")", cStr)-1))
					endif
					cStr := substr(cStr, at(")", cStr)+1)
				endif
				::AddIndicador(nScope, val(cStr), nInd, cGraphColor, cLevel)
			next
		endif
	endif
	
  	// prepara a lista de campos
	::FieldList()
		
	aAutoFilter := {}
	aEval(::DimFieldsX(), { |x| aAdd(aAutoFilter, { x:Alias(), x:Tipo(), x:Desc()})})
	aEval(::DimFieldsY(), { |x| aAdd(aAutoFilter, { x:Alias(), x:Tipo(), x:Desc()})})
	aEval(::Indicadores(), { |x| aAdd(aAutoFilter, { x:Alias(), x:Tipo(), x:Desc()})})
	
	aSessFldValue := DwGetProp(ID_ARRVALUES + DwStr(::ID()) + DwStr(::_Type()), ID_VIEW_NAMPRG)
	if empty(aSessFldValue)
		aSessFldValue := {}
	endif
	
	for nInd := 1 to len(aAutoFilter)
		//Todo filtro vem em apenas uma posição do array delimitado por pipe "|"
		nPos := ascan(aSessFldValue, { |x| aAutoFilter[nInd, 1] == x[1] })
		if nPos <> 0
			cAux := aSessFldValue[nPos, 2]
		else
			cAux := "HttpPost->sel"+aAutoFilter[nInd, 1]
			cAux := &(cAux)
   		endif
    
 		if valType(cAux) == "C" .and. "{VAZIO}" $ cAux
			cAux := strTran(cAux,"{VAZIO}","''")                   
			aAutoFilter[nInd] := aAutoFilter[nInd, 1] + chr(254) + aAutoFilter[nInd, 2]  + chr(254) + aAutoFilter[nInd, 3]  + chr(254) + cAux 
		elseif valType(cAux) == "C" .and. !empty(cAux)
			aAutoFilter[nInd] := aAutoFilter[nInd, 1] + chr(254) + aAutoFilter[nInd, 2]  + chr(254) + aAutoFilter[nInd, 3]  + chr(254) + cAux 
		else
			aAutoFilter[nInd] := nil
		endif
	next   
	           
	aAutoFilter := packArray(aAutoFilter)
	
	if len(aAutoFilter) > 0
		::AutoFilter(dwConcatWSep(SEP_DATA, aAutoFilter))
	else
		::AutoFilter("")
	endif
			
	// propriedades  
	::IndSobrePosto(HttpPost->cdIndSobre==CHKBOX_ON)
	::FillAll(HttpPost->cbFillAll==CHKBOX_ON)
	::EmptyCell(HttpPost->cbEmptyCell==CHKBOX_ON)
	::Filtered(HttpPost->cbFiltered==CHKBOX_ON)
	::Total(HttpPost->cbTotal==CHKBOX_ON)
	::AlertOn(HttpPost->edAlertOn==CHKBOX_ON)
	::HintOn(HttpPost->edHintOn==CHKBOX_ON)
	::IgnoreZero(HttpPost->cbIgnoreZero==CHKBOX_ON)
	::UseExcel(HttpPost->cbUseExcel==CHKBOX_ON)
	::RankOn(HttpPost->edRankOn==CHKBOX_ON)
	::RankOutros(HttpPost->edRankOutrosOn==CHKBOX_ON)
	::RankSubTotal(HttpPost->edRankSubTotalOn==CHKBOX_ON)
	::RankTotal(HttpPost->edRankTotalOn==CHKBOX_ON)
	::RankStyle(HttpPost->edRankStyle)
 	::FatorEscala(dwVal(HttpPost->edFatorEscala))
	::faRankDef := {}
	::CurvaABC({})
	
	if !(httpPost->edRankStyle == RNK_STY_LEVEL)
		::RankDef(1, dwVal(httpPost->edIndList0001), dwVal(httpPost->edRank0001), httpPost->edType0001)
	  	if httpPost->edRankStyle == RNK_STY_CURVA_ABC
	    	aClassif := {}
    		aAux := array(ABC_SIZE)
	  		for nInd := 1 to 5
	    		cAux := dwInt2Hex(nInd,4)
        		aAux[ABC_CLASSIF] := chr(64 + nInd)
        		aAux[ABC_PERC]    := dwVal(&("httpPost->edPerc" + cAux))
        		aAux[ABC_DESC]    := &("httpPost->edDescricao" + cAux)
        		aAux[ABC_COR]     := &("httpPost->edCor" + cAux)
        		aAux[ABC_LIMITE]  := nil
        		aAdd(aClassif, aClone(aAux))
        		if aAux[ABC_PERC] == 0
        			exit
        		endif
			next
			::CurvaABC(aClassif)
		endif
	else
		for nInd := 2 to ::dimCountY() + 1             
	    	cAux := dwInt2Hex(nInd,4)
		  	::RankDef(nInd-1, dwVal(&("httpPost->edIndList" + cAux)), dwVal(&("httpPost->edRank"  + cAux)), &("httpPost->edType" + cAux))
		next
	endif

	// alertas
	aCAlert := DWToken(isNull(HttpPost->Alr, ""), ";")
	aAux := ::Alerts(.t.)
	for nInd := 1 to len(aAux)                              
		aAux[nInd]:Selected(ascan(aCAlert, { |x| x==aAux[nInd]:id()})>0)
	next

	// Params
	aAux := ::Params()
	for nInd := 1 to len(aAux)
		if left(aAux[nInd, 1],2) == "pt"
	   		cAux := "HttpPost->" + aAux[nInd, 1]
		else	
	   		cAux := "HttpPost->pt" + aAux[nInd, 1]
		endif
		
		aAux[nInd, 2] := dwStr(&cAux)
	   	if !empty(ctod(aAux[nInd, 2]))
	   	  aAux[nInd, 2]	:= ctod(aAux[nInd, 2])
	   	endif   	
	next
   
	// Parametros do Drill-down
	if isNull(HttpPost->DrillParms)
		::DrillParms(0, "")
	else		
		::DrillParms(HttpPost->DrillParms[1], HttpPost->DrillParms[2])
	endif

	// filtros
	aCWhere := DWToken(isNull(HttpPost->Whe, ""), ";")
	aAux := ::Where(.t.)
	for nInd := 1 to len(aAux)
		aAux[nInd]:Selected(ascan(aCWhere, { |x| x==aAux[nInd]:id()})>0)
	next
				
	// Classe do grafico
	::GraphClass(HttpPost->GraphClass)
	::GraphProps(HttpPost->GraphProps)
	::GraphYProps(HttpPost->GraphYProps)
	::GraphY2Props(HttpPost->GraphY2Props)
	
	//relatorio crystal
	::CRWName(HttpPost->edCRWNome)
	::CRWDesc(HttpPost->edCRWDesc)
	::CRWURL(HttpPost->edCRWURL)
	aVar := {}
	if ::HaveDrillDown()
		for nInd := 1 to ::DimCountY()
			cVar := "HttpPost->cbNiv"+ dwstr(nInd)
			if &cVar <> NIL
				aAdd(aVar, &cVar)
			endif
		next
		::CRWParams(aVar)
	endif

	#ifdef DWCACHE
	#else
		::UpdCache()
	#endif
return

/*
--------------------------------------------------------------------------------------
Esconde/testa um atributo
--------------------------------------------------------------------------------------
*/
method hideAtt(acAlias) class TConsulta
	if ::isAttVisible(acAlias)
		aAdd(::faHideAtt, acAlias)
	
		#ifdef DWCACHE
		#else
			::updCache()
		#endif
	endif
return

method isAttVisible(acAlias) class TConsulta
return ascan(::faHideAtt, { |x| x == acAlias }) == 0

/*
--------------------------------------------------------------------------------------
Tamanho da pagina de retorno dos dados
--------------------------------------------------------------------------------------
*/
method pageSize(anSize) class TConsulta
	property ::fnPageSize := anSize
return ::fnPageSize

/*
--------------------------------------------------------------------------------------
Esconde/testa um atributo
--------------------------------------------------------------------------------------
*/
method ShowAllAtt() class TConsulta	
	::faHideAtt := {}
return

/*
--------------------------------------------------------------------------------------
Esconde/testa um atributo
--------------------------------------------------------------------------------------
*/
method KeyValues(aaSize) class TConsulta
	property ::faKeyValues := aaSize
return ::faKeyValues

/*
--------------------------------------------------------------------------------------
Salva o cache em arquivo
--------------------------------------------------------------------------------------
*/
method SaveCacheArq() class TConsulta
	local cFileName		:= DwTempPath() + "\DWEXP" + dwInt2Hex(::ID(), 8) + dwEncodeParm("", oSigaDW:DWCurr()[2]) + ".DWA"
	local oFile 	 		:= TDWFileIO():New(cFileName)
	
	#ifdef DWCACHE
	#else
		local nElem		 		:= 0
	 	local aQueryInCache	:= {}
	#endif
	
	if oFile:Exists()
		oFile:erase()
	endif

	oFile:create(FO_EXCLUSIVE + FO_WRITE)
	if !oFile:IsOpen()
		DWRaise(ERR_002, SOL_005, STR0026 + " [ " + cFileName + " ]")  //"Erro interno no arquivo"
	endif       
	
	#ifdef DWCACHE
		oFile:writeln(::toString())
	#else
		aQueryInCache := aClone(dwGetProp(CACHE_QUERY, CACHE_IDENTIFIER))
	  
	  	if "*all*" $ aQueryInCache[6, 2]
			aQueryInCache[6, 2] := replicate("*all*!", aQueryInCache[6, 1])
			aQueryInCache[6, 2] := left(aQueryInCache[6, 2], len(aQueryInCache[6, 2])-1)
		endif
	
		For nElem := 1 to Len(aQueryInCache)
			oFile:writeln(DwStr(aQueryInCache[nElem], .T.))
		Next nElem
	#endif
	
	oFile:Close()        
return     
           
/*
--------------------------------------------------------------------------------------
Monta o "case" para apuracao da Curva ABC
--------------------------------------------------------------------------------------
*/                  
static function prepCaseABC(aaParams)
  	local aRet := {}, nInd
  
  	if len(aaParams) > 0
    	for nInd := 1 to len(aaParams) - 1
 	    	if !empty(aaParams[nInd, ABC_LIMITE])
        		aAdd(aRet, aaParams[nInd])
   	  		endif
 	  	next   
    	aAdd(aRet, atail(aaParams))
  	endif
return aRet

method caseCurvaABC(alTotal) class TConsulta
	local cRet := "", aAux := prepCaseABC(::CurvaABC())
  	local cRnkField := "max(R_A_N_K_)"
      	
	default alTotal := .f.

	if alTotal                                            
		cRnkField := ::RankField(,,1)
		cRnkField := "sum("+strTran(cRnkField, " desc", "")+")"
	endif

	aEval(aAux , { |x| cRet := cRet + " when "+cRnkField+" >= " + dwStr(x[ABC_LIMITE]) + " then '" + x[ABC_CLASSIF] +"'"}, 1, len(aAux)-1)

  	if !empty(cRet)
    	cRet := "case " + cRet + " else '" +aTail(aAux)[ABC_CLASSIF]+"' end " + iif(alTotal, "", DWCurvaABC())
	endif
return cRet

/*
--------------------------------------------------------------------------------------
Recupera o cache do arquivo
--------------------------------------------------------------------------------------
*/
method RecupCacheArq() class TConsulta
	local cFileName := DwTempPath() + "\DWEXP" + dwInt2Hex(::ID(), 8) + dwEncodeParm("", oSigaDW:DWCurr()[2]) + ".DWA"
	local oFile 	 := TDWFileIO():New(cFileName)
	local cDados	 := ""   
	local aCache	 := {}

	oFile:open()
	if !oFile:IsOpen()
		DWRaise(ERR_002, SOL_005, STR0026 + " [ " + cFileName + " ]")  //"Erro interno no arquivo"
	endif
	
	while (oFile:Readln(@cDados) > 0)
		aAdd(aCache, &(cDados))
	end
	oFile:Close()   
	
	#ifdef DWCACHE
	#else
		::UpdFromCache(aCache)   
	  	::UpdCacheRuntime(aCache)
	#endif 
return 

/*
--------------------------------------------------------------------------------------
Verifica se há mais dados para processamento
--------------------------------------------------------------------------------------
*/
method haveNext() class TConsulta
  	local nPageSize, aPreserveKeys

  	if !::flEOF
		#ifdef DWCACHE
		#else
		   	::flUpdCache := .f.
		#endif
    	
    	nPageSize := ::PageSize()
    	::PageSize(1)  
	  	aPreserveKeys := aclone(::faKeyValues)
    	::NextPage() 

	  	::faKeyValues := aclone(aPreserveKeys)
    	::PageSize(nPageSize)

		#ifdef DWCACHE
		#else
    		::flUpdCache := .t.
		#endif
  	endif
return !::flEOF

method havePrevious() class TConsulta
return .t.

/*
--------------------------------------------------------------------------------------
Finaliza a exportação de dados
--------------------------------------------------------------------------------------
*/
method endExp(aoMakeExp) class TConsulta
	local aCompl
  	local oStat := initTable(TAB_ESTAT)
  
  	::fnTempoEst := dwElapSecs(::fdInicio, ::fcInicio, date(), time())
  	if !oStat:seek(2, { ST_EXPORT_QUERYS, ::ID() } )
    	oStat:append( { { "tipo", ST_EXPORT_QUERYS }, { "id_obj", ::id() }, { "valor", 0 }, { "Compl", "999999999/0" } } )
  	endif                                                       

  	aCompl := dwToken(oStat:value("compl"), "/")
  	aCompl[1] := min(aCompl[1], ::fnTempoEst)
  	aCompl[2] := max(aCompl[2], ::fnTempoEst)
  	oStat:update( { { "valor", ::fnTempoEst }, { "compl", dwConcatWSep("/", aCompl) } } )
  
	aoMakeExp:writeFinish(::HtmlFooter())
	aoMakeExp:infoArray( { STR0027 + " [ " + ::Name() + " ]", ;  //"SigaDW - Exportação agendada de "
			STR0028 + "</p>" + CRLF + ;   //"Sr. Usuário"
			STR0029 + "[ " + ::Name() + "-" + ::Desc() + " ], " + CRLF +;   //"Segue anexo o resultado da consulta "
			STR0030 + dtoc(date()) + STR0031 + time() + ", " + STR0032 + ;  //"processada em "  //" as "  //"no formato "
			aoMakeExp:descType() + "</p>" + CRLF +;
			"--<br><pre> __<br>/_/| SigaDW<br>|_|/ " + STR0033 + "</pre>"})  //"Processo de exportação agendada"

return     

/*
--------------------------------------------------------------------------------------
Indica se o usuário pode exportar consulta, se não for o dono (consulta de usuários)
--------------------------------------------------------------------------------------
*/
method CanUserExp() class TConsulta
return ::AccessType() == "U" .and. (oUserDW:UserID() == ::IDUser() .or. ::flUserExp)

/*
--------------------------------------------------------------------------------------
Drill-down histórico
--------------------------------------------------------------------------------------
*/
method DrillHist() class TConsulta
return ::faDrillHist

/*
--------------------------------------------------------------------------------------
Limpa Drill-down histórico
--------------------------------------------------------------------------------------
*/
method clearDrillHist() class TConsulta
  ::faDrillHist := {}
return 

/*
--------------------------------------------------------------------------------------
Verifica se esta em "lock", se sim aguarda liberação, senão trava
--------------------------------------------------------------------------------------
*/             
static __FUNC_LCK := ""

method lock() class TConsulta
  	local cAux

  	if valType(::foLockCtrl) == "U"
		::foLockCtrl := TDWFileIO():New(DwTempPath() + "\" + ::WorkFile(), ".lck")
	elseif ::foLockCtrl:isOpen()
		return
	endif
	
	if !::foLockCtrl:exists()
		::foLockCtrl:Create(FO_EXCLUSIVE + FO_WRITE)
	else
		::foLockCtrl:Open(FO_EXCLUSIVE + FO_WRITE)
	endif
	
	if !::foLockCtrl:isOpen()
		while !::foLockCtrl:Open(FO_EXCLUSIVE + FO_WRITE) .and. !dwKillApp()
			sleep(1000)                           
		enddo
	endif
                 
  	__FUNC_LCK := procName(1)
	
	if dwKillApp()
    	cAux := dwCallStack(,,.f.)
		conout("======================================================", cAux)
		conout(cAux)
		conout("------------------------------------------------------")
		conout(STR0035) //"Processo cancelado em função de notificação de KILLAPP"
		
		if "DOLOAD" $ cAux .or. "DOSAVE" $ cAux
			conout(STR0036 + dwStr(::name()) + "-" + dwStr(::desc())) //"Favor verificar as definições da consulta "
		endif			
		
		conout("======================================================")
		quit // ATENÇÃO: Este comando derruba o processo IMEDIATAMENTE
	endif
return

/*
--------------------------------------------------------------------------------------
Libera o lock
--------------------------------------------------------------------------------------
*/
method unlock() class TConsulta
  	if __FUNC_LCK == procName(1)
		__FUNC_LCK := ""
		::foLockCtrl:close()
	endif
return

/*
--------------------------------------------------------------------------------------
Funções de apoio internas
--------------------------------------------------------------------------------------
*/
static function parseSQL(acExpressao)
	local cAux := acExpressao
	local cRet := "", nPos := 0
	local cCond, cTrue, cFalse, lErro := .t.
	
	if upper(left(cAux, 4)) == "CASE"
		cRet := ""
		while nextToken("case", cAux, @nPos) .and. !DWKillApp()
			cAux := substr(cAux, nPos+4)
			if nextToken("when", cAux, @nPos)
				cAux := substr(cAux, nPos+4)
				if nextToken("then", cAux, @nPos)
					cCond := substr(cAux, 1, nPos-1)
					cAux := substr(cAux, nPos+4)
				endif
		
				if nextToken("else", cAux, @nPos)
					cTrue := substr(cAux, 1, nPos-1)
					cAux := substr(cAux, nPos+4)
				endif
		
				if nextToken("end", cAux, @nPos)
					if empty(cTrue)
						cTrue := substr(cAux, 1, nPos-1)
						cFalse := "0"
					else					
						cFalse := substr(cAux, 1, nPos-1)
					endif
				endif
				
				if empty(cCond) .or. empty(cTrue)
					exit
				endif     
				lErro := .f.
				cRet := "iif(" + cCond + "," + cTrue + "," + cFalse + ")"
			endif
			exit
		enddo
	endif
	
	if lErro 
		cRet := acExpressao
	endif
return cRet

static function nextToken(acToken, acSource, anPos)
	local nPosI, nPosF
	local nLenToken 
	
	acToken   := upper(acToken)
	nPosF 		:= len(acSource)
	nLenToken := len(acToken)
	anPos     := 0

	for nPosI := 1 to nPosF
		if upper(substr(acSource, nPosI, nLenToken)) == acToken
			anPos := nPosI
			exit
		endif
	next
return anPos <> 0

/*
// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : SigaDW
// Fonte  : DWStartBuildTable - executa a sumarização em JOB
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 02.02.06 | 0548-Alan Candido | Versão 3
// --------------------------------------------------------------------------------------
*/              
function DWStartBuildTable(pnID, pnType, acLogFile, alFalseStart)
	default alFalseStart := .f.	
	
	acLogFile := "DWBLD" + dwInt2Hex(pnID, 8) + iif(pnType==1, "T","G") + dwInt2Hex(oSigaDW:DWCurr()[1], 8) + ".LOG"

	if !alFalseStart
		dwStartJob(JOB_EXECCONS, {pnID, pnType, acLogFile},,.t.)
	endif
return .t.

function lIncNivel(anAtuLevel, anInd, anDrillOrig)
   local lRet := .f.
   
   if ( anDrillOrig == anAtuLevel .and. anInd <= anAtuLevel ) .or. ( anDrillOrig <> anAtuLevel .and. anInd == anAtuLevel )
      lRet := .t.
   endif
return lRet

/*
-----------------------------------------------------------------------
Inicializa o objeto consulta, quandando-o em cache (se disponivel)
Args: anID, integer   ID da consulta a ser inicializada
      acType, string  Identifica o tipo (tabela/grafico) a ser inicializada. 
                      Pode-se usar as constantes TYPE_TABLE_S e TYPE_GRAPH_S
      abConstructor   code-block a ser executado caso a consulta não exista
                      ou httpSession não esteja disponivel (opcional).
                      Caso não seja informado, será assumido o sequinte construtor
                      { || TConsulta():New(anD, acType)
Ret.: object, o objeto recuperado do cache ou inicializado pelo code-block de construção
-----------------------------------------------------------------------
*/                          
function dwNewCons(anID, acType, abConstructor)
	local oRet, cID

  	acType := dwStr(acType)
  	cID := dwInt2Hex(anID, 4)
  
  	if DWisWebEx() .and. HTTPIsConnected()
  		conout("******* " + STR0037 + cID + " QUERY" + acType) //"Lendo do cache "
  		if dwExistProp(cID, "QUERY" + acType)
  			oRet := dwGetProp(cID, "QUERY" + acType)
  		endif
  	endif
  
  	if valType(oRet) == "U"                     
    	default abConstructor := { || TConsulta():new(anID, dwVal(acType)) }
  		oRet := eval(abConstructor)
  		if dwIsWebEx() .and. HTTPIsConnected()
	  		conout("******* " + STR0038 + cID + " QUERY" + acType) //"Gravando no cache " 
  			dwSetProp(cID, oRet, "QUERY" + acType)
	  	endif
	endif  
return oRet

/*
-----------------------------------------------------------------------
Deleta o objeto consulta do cache
Args: anID, integer   ID da consulta a ser inicializada
      acType, string  Identifica o tipo (tabela/grafico) a ser inicializada. 
                      Pode-se usar as constantes TYPE_TABLE_S e TYPE_GRAPH_S
Ret.: 
-----------------------------------------------------------------------
*/                          
function dwDelCons(anID, acType)
	local cID

  	acType := dwStr(acType)
  	cID := dwInt2Hex(anID, 4)
  
  	if DWisWebEx() .and. HTTPIsConnected()
  		conout("******* " + STR0039 + cID + " QUERY" + acType) //"Removendo do cache " 
  		if dwExistProp(cID, "QUERY" + acType)
			DWDelProp(cID, "QUERY" + acType)
  			conout("        " + STR0040 + cID + " QUERY" + acType) //"Removido do cache "
  		endif
  	endif
return


/*
static function queryDebugMessage(acMessage, acDescription, acFunction)

	default acDescription := ""
	default acFunction := ""
	conout("")
	conout("***** DEBUG MESSAGE INIT ******************************************************")
	conout("====> (consulta.prw " + acFunction + " - " + DTOC(Date()) + " " + Time() + " - " + acDescription + ")", acMessage)
	conout("***** DEBUG MESSAGE END *******************************************************")
	conout("")

return
*/

