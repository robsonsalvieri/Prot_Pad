// #####################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : SigaDW
// Fonte  : Database - Gerencia o acesso ao banco de dados do SigaDW
// ---------+------------------+--------------------------------------------------------
// Data     | Auto             | Descricao
// ---------+------------------+--------------------------------------------------------
// 01.06.01 |0548-Alan Candido |
// 24.09.07 |0548-Alan Candido | BOPS 132350 - Implementação do campo "export" em TAB_CONSULTAS
// 14.11.07 |0548-Alan Candido | BOPS 135941 - Adicionado comentário de segurança na função verDBOwner()
// 18.01.08 |0548-Alan Candido | BOPS 139342 - Implementação e adequação de código, 
//          |                  | em função de re-estruturação para compartilhamento de 
//          |                  | código.    
// 23.01.08 |0548-Alan Candido | BOPS 136637 - Compatibilização da query SEL_FACT_INFO para
//          |                  | para o Informix.
// 12.06.08 |0548-Alan Candido | BOPS 147424
//          |                  | Ajuste nas clausulas 'where' para ligação entre tabelas
//          |                  | Tabelas: TAB_USER_PRIV -> TAB_CONSULTAS, TAB_DW, TAB_CUBESLIST
//          |                  |          TAB_DSN -> TAB_DIMENSAO, TAB_CUBESLIST
//          |                  |          TAB_EXPORT -> TAB_DIMENSAO, TAB_CONSTYPE
// 05.08.08 |0548-Alan Candido | BOPS 151312
//          |                  | Ajuste no join da SEL_DSNCONF2 para DB2, Informix e PostGres.
// 05.08.08 |0548-Alan Candido | BOPS 149441
//          |                  | Implementação do campo TAB_SXM->info.
// 08.08.08 |0548-Alan Candido | BOPS 151591
//          |                  | Modificada a query SEL_DSNCONF, para compatibilização com 
//          |                  | MS-SQL 9 (2005)
// 24.09.08 |0548-Alan Candido | BOPS 154692
//          |                  | Correção na SEL_DSNCONF, quando SGDB é oracle
// 25.11.08 |0548-Alan Candido | FNC 00000007374/2008 (10) e 00000007385/2008 (8.11)
//          |                  | Implementação da query SEL_BUILD
// 15.12.08 |0548-Alan Candido | FNC 09025/2008 (8.11) e 09034/2008 (10)
//          |                  | . Adequação de geração de máscara em campos numéricos e datas, 
//          |                  | para respeitar o formato conforme idioma 
//          |                  | (chave RegionalLanguage na sessão do ambiente).
//          |                  | . Implementação do campo TAB_EXPORT->percIsInd.
// 30.12.08 |0548-Alan Candido | FNC 00000011160/2008 (8.11) e 00000011201/2008 (P10)
//          |                  | . Adequação em query de seleção na tabela TAB_EXPORT
//          |                  | . Inicialização da tabela TAB_BUILD antes de executar SEL_BUILD
// -------------------------------------------------------------------------------------
    
#include "dwincs.ch"
#include "Database.ch"
#include "dbinfo.ch"

#define PREFIX "@!!@"   

// --------------------------------------------------------------------------------------
// Não acesse estas variaveis diretamente/utilize sempre as funções de acesso
// --------------------------------------------------------------------------------------
static __DWTopCon := -1
/*
--------------------------------------------------------------------------------------
Listas de tabelas e viwes
--------------------------------------------------------------------------------------
*/

#define AVIEWLIST { ;
		VIE_CALEND ;
	}               
	
#define ATABLELIST { ;
				TAB_BUILD, ;
				TAB_DW, ;
				TAB_CUBESLIST, ;
				TAB_CONFIG, ;
				TAB_CONEXAO, ;
				TAB_CALEND, ;
				TAB_EVENTS, ;
				TAB_PERIODO, ;     
				TAB_USER, ;
				TAB_LOG, ;
				TAB_FACTFIELDS, ;
				TAB_FACTVIRTUAL, ; 
				TAB_FACT_WHERE, ;
				TAB_CONSULTAS,;
				TAB_CONSTYPE,;
				TAB_CONS_PROP, ;
				TAB_CONSCRW, ;
				TAB_CRWPARAMS, ;
				TAB_CONS_IND, ;
				TAB_CONS_DIM, ;
				TAB_CONS_WHE, ;
				TAB_CONS_USR, ;
				TAB_CONS_ALM, ;
				TAB_WHERE, ;
				TAB_WHERE_COND, ;
				TAB_CALC,;
				TAB_EXPR, ;
				TAB_ALERT,;
				TAB_DIM_FIELDS, ;
				TAB_DIM_CUBES, ;
				TAB_DIMENSAO, ;
				TAB_DSN, ;
				TAB_DSNCONF, ;
				TAB_EXPORT, ;
				TAB_USER_DW, ;
				TAB_USER_CONS, ;
				TAB_USER_CUB, ;
				TAB_USER_PRIV, ;
				TAB_USER_RES, ;
				TAB_USER_LOG, ;
				TAB_USER_DSKTOP, ;
				TAB_DD, ;
				TAB_MSG, ;
				TAB_MSG_USER, ;
				TAB_SXM, ;
				TAB_SX2, ;
				TAB_SX9, ;
				TAB_ESTAT_SPC, ;
				TAB_PROCESS, ;
				TAB_IPC, ;
				TAB_ACTIONS, ;
				TAB_ESTAT }

#define ATAB_SHARED { ;
				TAB_CONFIG, ;
				TAB_USER, ;
				TAB_USER_DSKTOP, ;
				TAB_ESTAT, ;
				TAB_USER_PRIV }

function DWTableList()

return ATABLELIST

function DWViewList()

return AVIEWLIST

/*
--------------------------------------------------------------------------------------
Verifica a existencia de uam view
--------------------------------------------------------------------------------------
*/       
function DWCanOpenView(acViewname)
	local oQuery := TQuery():New(DWMakename("TRA"))
	local cSQL, lRet := .f.
	
	if SGDB() == DB_ORACLE
		cSQL := "SELECT COUNT(NAME) FROM SYS.OBJ$ WHERE NAME = '"
		cSQL += acViewname
		cSQL += "' AND OWNER# = userenv('SCHEMAID') AND TYPE# = 4"
	elseif SGDB() == DB_INFORMIX
		cSQL := "SELECT COUNT(tabname) FROM SYSTABLES WHERE TABNAME = '"
		cSQL += lower(acViewname)
		cSQL += "' AND TABTYPE = 'V'"
	elseif SGDB() == DB_POSTGRES
		cSQL := "SELECT COUNT(VIEWNAME) FROM pg_views where VIEWNAME = '"
		cSQL += lower(acViewname)
		cSQL += "'"
	elseif SGDB() == DB_DB2
		cSQL := "SELECT COUNT(NAME) FROM SYSIBM.SYSTABLES WHERE NAME = '"
		cSQL += acViewname
		cSQL += "' AND TYPE = 'V'"
	else
		cSQL := "select count(name) from sysobjects where name = '"
		cSQL += acViewname
		cSQL += "' and xtype = 'V'"
	endif
	if SGDB() == DB_DB2400
//	if "AS" $ DWTopAlias() .and. "400" $ DWTopAlias()
		lRet := .t.
	else
		oQuery:Open(, cSQL)    
		if oQuery:value(1) > 0
			lRet := .t.
		endif
		oQuery:Close()
	endif
		
return lRet

/*
--------------------------------------------------------------------------------------
Abre uma conexão ao banco de dados
--------------------------------------------------------------------------------------
*/       
function isDWOpenDB()

return __DWTopCon >= 0

function DWOpenDB(alVerifyOwner)
	local cConType

  default alVerifyOwner := .f.
                                             
	if valType(__DWTopCon) != "U" .and. __DWTopCon < 0
		cConType  := Upper(GetPvProfString(GetEnvServer(),"TopContype","TCPIP", DWIniFile() ))

		if cConType == "ERROR"
			cConType  := Upper(GetPvProfString("TopConnect","Contype","TCPIP", cIniFile ))
		endif

		TCCONTYPE(cConType)

		if cConType == "APPC"                                   
			if empty(DWTopPort())
				if "AS" $ DWTopAlias() .and. "400" $ DWTopAlias()
					__DWTopCon := TCLINK(DWTopServer(), DWTopDB())
				else
					__DWTopCon := TCLINK(PREFIX+DWTopDB(), DWTopServer())				
				endif
			else                         
				if SGDB() == DB_DB2400
					__DWTopCon := TCLINK(DWTopServer(), DWTopDB(), DWTopPort())
				else
					__DWTopCon := TCLINK(PREFIX+DWTopDB(), DWTopServer(), DWTopPort())				
				endif
			endif
		else
			if "AS" $ DWTopAlias() .and. "400" $ DWTopAlias()
				if empty(DWTopPort())
					__DWTopCon := TCLINK(DWTopServer(), DWTopDB())
				else
					__DWTopCon := TCLINK(DWTopDB(), DWTopServer(), DWTopPort())
				endif
			else
				if empty(DWTopPort())
					__DWTopCon := TCLINK(PREFIX+DWTopDB()+"/"+DWTopAlias(), DWTopServer())
				else
					__DWTopCon := TCLINK(PREFIX+DWTopDB()+"/"+DWTopAlias(), DWTopServer(), DWTopPort())
				endif
			endif
		endIf

		if __DWTopCon < 0
			DWLog(STR0015, DWTopDBFull(), STR0271 + str(__DWTopCon)) //"Falha na conexão TopConnect"  //"Código de erro:"
			TCQUIT()
			return .f.
		endIf

		if TCSrvType() == "AS/400"
			TCSETBUFF("*ON")    // habilita buffer para versao AS/400
		endIf
	endif  
	
	if alVerifyOwner
	  verDBOwner()
  endif
  
return __DWTopCon >= 0

static function verDBOwner()
  // ATENÇÃO: Não utilizar a função DWDBOwner() para obter o "owner" do banco de dados
  local oAux, oQuery, lAbort := .f.
  local cConfig, cOwner
  local aConfig, aOwner

  if (SGDB() ==DB_ORACLE .or. SGDB() == DB_DB2) .and. tcCanOpen("TOP_FIELD") .and. tcCanOpen(TAB_CONFIG)
    dwLog(STR0272)  //"Verificando o 'owner' do banco de dados"
    
    oAux := TTable():New("DWVEROWNER")
    oQuery := TTable():New("DWVEROWNER")

    oAux:addField(,"CPO1", "C", 10, 0)
    oAux:addField(,"CPO2", "N", 10, 1)
    oAux:addField(,"CPO3", "D")
       
    if oAux:exists()
      oAux:dropTable()
    endif
    oAux:createTable()
    oAux:open()
    oAux:close()
  
    oQuery := TQuery():New(DWMakeName("TRA"))
    oQuery:FromList("TOP_FIELD")
		if SGDB() == DB_DB2400
 		  oQuery:FieldList("FNAMF2 as FIELD_TABLE")
			oQuery:WhereClause("FNAMF2 LIKE '%"+(oAux:tableName())+"%' or FNAMF2 LIKE '%"+(TAB_CONFIG)+"%'")
    else      
 		  oQuery:FieldList("FIELD_TABLE")
			oQuery:WhereClause("FIELD_TABLE LIKE '%"+oAux:tableName()+"%' or FIELD_TABLE LIKE '%"+TAB_CONFIG+"%'")
 	  endif
		oQuery:WithDeleted(.t.)
		oQuery:MakeDistinct(.t.)
    oQuery:OrderBy("FIELD_TABLE")
    oQuery:Open()
                 
    if TAB_CONFIG $ oQuery:value("FIELD_TABLE")
      cConfig := oQuery:value("FIELD_TABLE")
    else
      cOwner := oQuery:value("FIELD_TABLE")
    endif
    oQuery:_next()
    if TAB_CONFIG $ oQuery:value("FIELD_TABLE")
      cConfig := oQuery:value("FIELD_TABLE")
    else
      cOwner := oQuery:value("FIELD_TABLE")
    endif
    dwLog(STR0273, cConfig, cOwner)  //"Tabelas utilizadas na verificação"
    
    aConfig := dwToken(cConfig, ".")
    aOwner := dwToken(cOwner, ".")

    oAux:dropTable()
    oQuery:close()
    
    if len(aConfig) == 2 .and. len(aOwner) == 2
      if aConfig[1] <> aOwner[1]
        if !dwUpdDBOwner()
          dwLog(STR0274, ;  //"O 'owner' não confere. Para que o procedimento de atualização do 'owner' seja executado, favor ajustar a chave 'UpdDBOwner' para '1', no job que responde pelo SigaDW."
                STR0275 + aConfig[1], ;  //"'Owner' antigo: "
                STR0276 + aOwner[1])  //"'Owner' atual: "
          lAbort := .t.
        else
          dwLog(STR0277, STR0278 + aConfig[1], STR0279 + aOwner[1])  //"O 'owner' não confere.", "Ajustando-o na tabela TOP_FIELD"  //"De: "  //"Para: "
          if DWSQLExec("update TOP_FIELD set FIELD_TABLE = '"+aOwner[1]+"'||substr(FIELD_TABLE, "+dwStr(len(aConfig[1])+1)+") where FIELD_TABLE LIKE '"+aConfig[1]+"%'") == 0
            dwLog(STR0280)  //"Ajuste efetuado"
          else
            lAbort := .t.
          endif
        endif
      elseif dwUpdDBOwner()
        dwLog(STR0281)  //"O 'owner' esta correto"
      endif
    else
      dwLog(STR0282)  //"Não foi possivel obter o 'owner' a partir das tabelas de verificação"
      lAbort := .t.
    endif    
    
  endif

  if lAbort
    dwLog(STR0283)  //"Esta inicialização do SigaDW cancelada."
    appRaise(ERR_002, SOL_002, STR0284)  //"Verifique o 'log' de console para maiores informações"
  else
    dwUpdDBOwner(.f.)
  endif

return

function InitDW_DB(alWarning, alReindex)
	local nInd, cViewname
	local aAux, cTablename
		                                  
	default alWarning  := .f.
	default alReindex := .f.
	
	__DWInitDB := .t.

	if !(getGlbValue("DWFirstStart") == "T")
		DWLog(STR0213)  //"Verificando as tabelas"
	    if alReindex
			DWLog(STR0285)  //"... refazendo os indices"
		endif
        if alWarning
			conout(STR0286)  //".... criando as tabelas"
		endif
		      
		if alReindex .or. alWarning
			aAux := DWTableList()
			for nInd := 1 to len(aAux)
				cTablename := aAux[nInd]
				oTable := InitTable(cTablename, .t.,,alReindex)
				oTable:Close()
				DWFreeObj(oTable)
			next               

			aAux := DWViewList()
			for nInd := 1 to len(aAux)
				if !DWCanOpenView(aAux[nInd])
					DWLog(STR0016 + aAux[nInd])  //"Inicializando "
					cViewname := aAux[nInd] + "()"
					&cViewname
				endif
			next               
		endif
	endif
           
	DWLog(STR0005)  //"Banco de dados pronto"

	__DWInitDB := .f.
	
return .t.

function StopDW_DB()

	if type("oSigaDW") == "O"
		oSigaDW:ReleaseTable()
	endif

	closeDB(.t.)
	
return .t.

function JobInitTable(aParms)
	local oTable 	          
	
	oTable := InitTable(aParms[1], .f., aParms[2])
	oTable:Close()
	
	DWFreeObj(oTable)

return .t.






























/*
--------------------------------------------------------------------------------------
Tipo de banco de dados
Arg: 
Ret: lRet -> lógico, indica se a inicialização foi bem suscedida
--------------------------------------------------------------------------------------
*/       
function SGDB()
	local cRet := upper(alltrim(TcGetDB()))

	if left(cRet,1) == '@'
		cRet := substr(cRet, 5)
	endif

return cRet

/*
--------------------------------------------------------------------------------------
Fecha a conexão ao banco de dados
Arg: 
Ret: lRet -> lógico, indica se a inicialização foi bem suscedida
--------------------------------------------------------------------------------------
*/       
function CloseDB(alKeep)
	local nWorkArea

	default alKeep := .f.
		
	for nWorkArea := 1 to 250
		dbSelectArea(nWorkArea)
		if !(alias() == "") .and. !(left(alias(),2) $ "SX|SM|SI|CT")
			dbCloseArea()
		endif
	next
		
	if !alKeep .and. __DWTopCon > -1
		TCUNLINK(__DWTopCon)
		__DWTopCon := -1
	endif

return .t.

/*
--------------------------------------------------------------------------------------
Verifica se a tabela é compartilhada
Arg: cAlias -> string, nome da tabela
Ret: lRet -> logico, tabela é compartilhada
--------------------------------------------------------------------------------------
*/
function DWTableShared(cAlias)
return ascan(ATAB_SHARED, { |x| cAlias == x }) != 0

/*
--------------------------------------------------------------------------------------
Inicializa o acesso a uma tabela especificia
Arg: acTableName -> string, nome da tabela
	  alLog -> logico, apresentar log
Ret: 
--------------------------------------------------------------------------------------
*/       
function NewTable(acTablename, acAlias, alExclusive)
	local oRet, cRotTable, cMsg := ""
	
	cRotTable := acTablename + "('"+acAlias+"')"
	oRet := &(cRotTable)
                                               
	if valType(oRet) == "O" .and. !oRet:IsOpen()
		oRet:Open(alExclusive)
	endif
		
return (oRet)

static function trataTablename(acTablename)
	local cRet := acTablename
	
	if !empty(__DWPrefixo) .and. !DWTableShared(acTablename) .and. substr(acTablename, 3, 1) == "0"
	   cRet := left(cRet, 2) + __DWPrefixo + substr(cRet, 4)
	endif
	
return cRet

static function InitDS(acTablename, alReuse)
	local oRet, cRotTable, cTabOrig := acTablename

	default alReuse := .t.
	
	acTablename := trataTablename(acTablename)
	
	if type("oSigaDW") == "O" .and. alReuse
		oRet := oSigaDW:SearchTable(acTableName)
	endif

	if valType(oRet) == "U"
		cRotTable := cTabOrig + "()"
		oRet := &(cRotTable)
		if type("oSigaDW") == "O" .and. alReuse
			oSigaDW:AddTable(oRet)
		endif            
	endif

return (oRet)

function InitTable(acTablename, alLog, alExclusive, alDropIndex)
	local oRet := InitDS(acTablename)
	
	default alExclusive := .f.
	default alDropIndex := .f.

	if valType(oRet) == "O" .and. !oRet:IsOpen()
		if alDropIndex
			oRet:IndexOff()
		endif
		oRet:IndexOff()
		oRet:Open(alExclusive)
		if oRet:ChkStruct(.t.)
			oRet:ChkStruct()
		endif
		oRet:IndexOn()
		if alDropIndex  
			oRet:DropIndexes()
			oRet:Close()
			oRet:IndexOn()
			oRet:Open(alExclusive)
		endif			
	else
		oRet:Refresh()
		//####TODO - verificar a necessidade de goTop
		//           interfere na carga de consulta (TAB_WHERE)
		//oRet:GoTop()
	endif
		
return (oRet)
                          
function InitQuery(acQueryname, alOpen)
	local oRet := InitDS(acQueryname, .f.)
	
	default alOpen := .f.
                                              
	if alOpen .and. valType(oRet) == "O" .and. !oRet:IsOpen()
		oRet:Open()
	endif
		
return (oRet)

/*
-----------------------------------------------------------------------
Cria o arquivo fisicamente se o mesmo não existir
-----------------------------------------------------------------------
*/
function createTable(poTable)
	local lRet := !poTable:Exists()

	if lRet
		DWLog(STR0016 + poTable:Tablename()) //"Inicializando "

		poTable:CreateTable()
		poTable:Open(.t.)
		poTable:Close()                   
	endif

return lRet

/*
-----------------------------------------------------------------------
Inicializa a tabela TAB_BUILD
-----------------------------------------------------------------------
*/
static function DW00000() //TAB_BUILD
	local oTable := TTable():New(TAB_BUILD)
	
	oTable:Descricao(STR0287)  //"Controle de versão"
	oTable:addFieldID()
	oTable:AddField(nil, "version", "C", 2)
	oTable:AddField(nil, "release", "C", 2)
	oTable:AddField(nil, "build", "C", 8)
	oTable:AddField(nil, "environ", "C", 2)
	oTable:AddField(nil, "applied", "D")
	
	oTable:AddIndex2(nil, { "build" } )
	oTable:AddIndex2(nil, { "environ", "build" } )
	
	createTable(oTable)
                           
return oTable

/*
-----------------------------------------------------------------------
Inicializa a QUERY SEL_BUILD (QW00000)
-----------------------------------------------------------------------
*/
static function QW00000() //SEL_BUILD
	local oQuery 
  
  initTable(TAB_BUILD)
               
  oQuery := TQuery():New(SEL_BUILD) // QW00000
	oQuery:FromList(trataTableName(TAB_BUILD))
	oQuery:FieldList("VERSION, RELEASE, BUILD, ENVIRON, APPLIED")
	oQuery:WhereClause("BUILD = (select max(BUILD) from " + TAB_BUILD + ")")

return oQuery

/*
-----------------------------------------------------------------------
Inicializa a tabela TAB_DW
-----------------------------------------------------------------------
*/
static function DW00001() //TAB_DW
	local oTable := TTable():New(TAB_DW)
	
	oTable:Descricao("Datawarehouse")
	oTable:addFieldID()
	oTable:addField(nil, "nome", "C", 15)
	oTable:addField(nil, "descricao", "C", 50)
	oTable:addField(nil, "icone", "C", 20)
	oTable:addField({ || date() }, "criado", "D")
	oTable:addField({ || .t.}, "disp", "L")

	oTable:AddIndex2(nil, { "nome" }, .t.)
	createTable(oTable)
                           
return oTable

/*
-----------------------------------------------------------------------
Inicializa a tabela DWConfig
-----------------------------------------------------------------------
*/
static function DW00100()
	local oTable := TTable():New(TAB_CONFIG)
	
	oTable:Descricao(STR0288)  //"Configurações"
	oTable:addFieldID()
	oTable:addField(nil, "grupo", "C", 10)
	oTable:addField(nil, "nome", "C", 10)
	oTable:addField(nil, "valor", "C", 255)

	oTable:AddIndex2(nil, { "grupo", "nome" } )
	if valType(__SIGADWINST) == "U"
		__SIGADWINST := createTable(oTable)
	else                                  
		createTable(oTable)
	endif
                           
return oTable

/*
-----------------------------------------------------------------------
Inicializa a tabela TAB_CONEXAO
-----------------------------------------------------------------------
*/
static function DW00200() //TAB_CONEXAO
	local oTable := TTable():New(TAB_CONEXAO)

	oTable:Descricao(STR0289)  //"Conexões"
  oTable:Events({ |oTable, nMoment, nOper, lCond, aValues| DW00200Ev(oTable, nMoment, nOper, lCond, aValues)})

	oTable:addFieldID()        
	oTable:addFieldDW()
	oTable:addField(nil, "nome", "C", 12)
	oTable:addField(nil, "descricao", "C", 30)
	oTable:addField(nil, "tipo", "C", 1)
	oTable:addField(nil, "server", "C", 30 )
	oTable:addField(nil, "conex_srv", "C", 10)
	oTable:addField(nil, "banco_srv", "C", 10)
	oTable:addField(nil, "alias", "C", 20)
	oTable:addField(nil, "ambiente", "C", 20)
	oTable:addField(nil, "empresa", "C", 2)
#ifdef VER_P10
	oTable:addField(nil, "filial", "C", 2)
#else
	oTable:addField(nil, "filial", "C", 12)
#endif
	oTable:addField(nil, "caminho", "C", 255)
	oTable:addField(nil, "novo", "L")
	oTable:addField(nil, "id_docto", "N")
	oTable:addField(nil, "docto", "C", 0, 0, { || DWConcatWSep(CRLF, DWDetail(TAB_EXPR, id_docto, "linha", "id", 1))}, nil) 

	oTable:AddIndex2(nil, { "tipo", "nome" }, .t. )

	oTable:AddListVal("tipo", { conexionType() })

	oTable:AddListVal("conex_srv", { { "TCPIP", "TCP/IP"},;
									 { "LOCAL", "Local"},;
									 { "APPC", "APPC"},;
									 { "BRIDGE", "Bridge"},;
									 { "NPIPE", "NPipe"} })

	oTable:AddListVal("banco_srv", { { "MSSQL", "Sql Server"},;
									 { "ORACLE", "Oracle"},;
									 { "SYBASE", "Sybase"},;
									 { "INFORMIX", "Informix"},;
									 { "POSTGRES", "Postgres"},;
									 { "MYSQL", "MySQL"},;
									 { "DB2", "DB2"},;
									 { "MSADO", "MS ADO"} })

	oTable:SetAttField("nome", STR0019) //"Nome"
	oTable:SetAttField("descricao", STR0020) //"Descrição"
	oTable:SetAttField("tipo", STR0021) //"Tipo"
	oTable:SetAttField("server", STR0022) //"Servidor"
	oTable:SetAttField("conex_srv", STR0023) //"Conexão Servidor"
	oTable:SetAttField("banco_srv", STR0024) //"Tipo do Banco"
	oTable:SetAttField("alias", STR0025) //"Alias"
	oTable:SetAttField("ambiente", STR0026) //"Ambiente"
	oTable:SetAttField("empresa", STR0027) //"Empresa"
	oTable:SetAttField("filial", STR0028) //"Filial"
	oTable:SetAttField("caminho", STR0029) //"Caminho"
	
	oTable:SetVisible("novo", .f.)
	oTable:SetVisible("id_docto", .f.)
	oTable:setVisible("docto", .f.)
	
	createTable(oTable)
                           
return oTable

function conexionType(acConnType)
	
	Local aConnType := { { TC_TOP_CONNECT, "Top Connect"}, 	;
						 { TC_AP_SX, "Protheus - SX"}, 		;
						 { TC_AP_DIRETO, "Protheus - Direto"} }
	Local nPos
	Local xRet
	
	if !empty(acConnType)
		nPos := aScan(aConnType, {|aElem| aElem[1] == acConnType})
		xRet := aConnType[nPos, 2]
	else
		xRet := aConnType
	endif
	
return xRet

static function DW00200Ev(poTable, pnMoment, pnOper, plCond, paValues)

	local oTable

	if pnMoment == FE_BEFORE
		if pnOper == FE_DELETE
			oTable := InitTable(TAB_DSN)
			if oTable:Seek(3, { poTable:value("id") })
			   while !oTable:eof() .and. (poTable:value("id") == oTable:value("id_connect"))
			      oTable:Delete()
			      oTable:_Next()
			   end
			endif
			
		endif
	endif
	
return					

/*
-----------------------------------------------------------------------
Inicializa a tabela DWCalend
-----------------------------------------------------------------------
*/
static function DW01000(acAlias) //TAB_CALEND
	local oTable
	default acAlias := TAB_CALEND

	oTable := TTable():New(TAB_CALEND, acAlias)
	oTable:Descricao(STR0290)  //"Calendário"
	
	oTable:addFieldID()
	oTable:addField(nil, "dt", "D")
	oTable:addField(nil, "dow", "N", 1)
	oTable:addField(nil, "doy", "N", 3)
	oTable:addField(nil, "ano", "N", 4)
	oTable:addField(nil, "semestre", "N")
	oTable:addField(nil, "quadmestre", "N")
	oTable:addField(nil, "estacao", "N", 1)
	oTable:addField(nil, "trimestre", "N")
	oTable:addField(nil, "bimestre", "N")
	oTable:addField(nil, "mes", "N", 2)
	oTable:addField(nil, "quinzena", "N")
	oTable:addField(nil, "semana", "N")
	oTable:addField(nil, "dia", "N", 2)
	oTable:addField(nil, "diautil", "L")
	oTable:addField(nil, "feriado", "L")
	oTable:addField(nil, "s_dia", "N")
	oTable:addField(nil, "s_mes", "N")
	oTable:addField(nil, "s_ano", "N")
	oTable:addField(nil, "s_semana", "N")
	oTable:addField(nil, "s_quinzena", "N")
	oTable:addField(nil, "s_bimestre", "N")
	oTable:addField(nil, "s_trimestr", "N")
	oTable:addField(nil, "s_quadmest", "N")
	oTable:addField(nil, "s_semestre", "N")
	oTable:addField(nil, "observacao", "C", 30)

	oTable:SetAttField("dow", STR0031) //"Dia da semana"
	oTable:SetAttField("doy", STR0032) //"Dia Juliano"
	oTable:SetAttField("diautil", STR0033) //"Dia Útil"
	oTable:SetAttField("estacao", STR0034) //"Estação"

	oTable:AddIndex2(nil, { "dt" } )
	oTable:AddIndex2(nil, { "s_ano" } )
	oTable:AddIndex2(nil, { "s_semestre" } )
	oTable:AddIndex2(nil, { "s_quadmest" } )
	oTable:AddIndex2(nil, { "s_trimestr" } )
	oTable:AddIndex2(nil, { "s_bimestre" } )
	oTable:AddIndex2(nil, { "s_mes" } )
	oTable:AddIndex2(nil, { "s_quinzena" } )
	oTable:AddIndex2(nil, { "s_semana" } )
	oTable:AddIndex2(nil, { "s_dia" } )
                                	
	createTable(oTable)
                           
return oTable

/*
-----------------------------------------------------------------------
Inicializa a view VIE_CALEND
-----------------------------------------------------------------------
*/
static function DT01000() //VIE_CALEND
	local aSQL := {}
	
	aAdd(aSQL, "create view " + VIE_CALEND + " as")
	aAdd(aSQL, "select DW01000.*, (DW01200.DESCRICAO) PERIODO")
	aAdd(aSQL, "from DW01000, DW01200")
	aAdd(aSQL, "where DW01000.DT <= DW01200.DT_FINAL AND DW01000.DT >= DW01200.DT_INICIO AND DW01200." + DWDelete() + " <> '*'")
	DWSQLExec(aSQL)
	
return

/*
-----------------------------------------------------------------------
Inicializa a tabela TAB_PERIODO
-----------------------------------------------------------------------
*/
static function DW01200() //TAB_PERIODO
	local oTable

	oTable := TTable():New(TAB_PERIODO)
	oTable:Descricao(STR0291)  //"Períodos"
	
	oTable:addFieldID()
	oTable:addField(nil, "descricao", "C", 15)
	oTable:addField(nil, "dt_inicio", "D")
	oTable:addField(nil, "dt_final", "D")

	oTable:SetAttField("descricao", STR0038) //"Descrição|"
	oTable:SetAttField("dt_inicio", STR0039) //"Data Inicial"
	oTable:SetAttField("dt_final", STR0040) //"Data Final"

	oTable:AddIndex2(nil, { "dt_inicio" } )

	createTable(oTable)
                           
return oTable

/*
-----------------------------------------------------------------------
Inicializa a tabela DWEvents
-----------------------------------------------------------------------
*/
static function DW01100()
	local oTable := TTable():New(TAB_EVENTS)

	oTable:Descricao(STR0292)  //"Eventos"
	
	oTable:addFieldID()
	oTable:addField(nil, "ID_CALEND", "N")
	oTable:addField(nil, "Texto", "C", 255)

	oTable:AddIndex2(nil, { "ID_CALEND" } )

	oTable:SetAttField("texto", STR0178)
  
  oTable:addParent(TAB_CALEND, "ID_CALEND")
  
	createTable(oTable)
                           
return oTable
	
/*
-----------------------------------------------------------------------
Inicializa a tabela log de mensagens
-----------------------------------------------------------------------
*/
static function DW02000()
	local oTable := TTable():New(TAB_LOG)
	
	oTable:Descricao("Log")
	oTable:addFieldID()
	oTable:addFieldDW()
	oTable:addField({ || date() }, "dt", "D")
	oTable:addField({ || time() }, "hr", "C", 8)
	oTable:addField(nil, "mensagem", "C", 255)

	oTable:SetAttField("dt", STR0179)  //"Data"
	oTable:SetAttField("hr", STR0180)  //"Hora"
	oTable:SetAttField("mensagem", STR0248)  //"Mensagem"

	oTable:AddIndex2(nil, { "dt", "hr" } )
                          
	createTable(oTable)
return oTable

/*
-----------------------------------------------------------------------
Inicializa a tabela de mensagens
-----------------------------------------------------------------------
*/
static function DW02002() //TAB_MSG
	local oTable := TTable():New(TAB_MSG)
	
	oTable:Descricao(STR0293)  //"Mensagens"
	oTable:Events({ |oTable, nMoment, nOper, lCond, aValues| DW02002Ev(oTable, nMoment, nOper, lCond, aValues) })
	
	oTable:addFieldID()
	oTable:addField(NIL, "dt_pub_ini", 	"D",   8)
	oTable:addField(NIL, "hr_pub_ini", 	"C",   8)
	oTable:addField(NIL, "dt_pub_fin", 	"D",   8)
	oTable:addField(NIL, "hr_pub_fin", 	"C",   8)
	oTable:addField(NIL, "data_incl", 	"D",   8)
	oTable:addField(NIL, "mensagem",	"C", 255)
	oTable:addField(NIL, "autor",		"C",  30)
	oTable:addField(NIL, "exibir",		"L")
	
	// só por compatibilidade - ###TODO retirar em versões futuras
	oTable:addField({ || date() }, "dt", "D")
	oTable:addField({ || time() }, "hr", "C", 8)
	
	oTable:SetAttField("dt_pub_ini", 	STR0294)  //"Data Inicial de Publicação"
	oTable:SetAttField("hr_pub_ini", 	STR0295)  //"Horário Inicial de Publicação"
	oTable:SetAttField("dt_pub_fin", 	STR0296)  //"Data Final de Publicação"
	oTable:SetAttField("hr_pub_fin", 	STR0297)  //"Horário Final de Publicação"
	oTable:SetAttField("data_incl", 	STR0298)  //"Data de Inclusão"
	oTable:SetAttField("mensagem", 		STR0248)  //"Mensagem"
	oTable:SetAttField("autor", 		STR0299)  //"Autor"
	oTable:SetAttField("exibir", 		STR0249)  //"Exibir"
	
	oTable:AddIndex2(nil, { "data_incl" } )
	
	oTable:SetVisible("dt", .f.)
	oTable:SetVisible("hr", .f.)
	
	createTable(oTable)

return oTable

static function DW02002Ev(aoTable, anMoment, anOper, alCond, aaValues)

	Local oMsgUser := InitTable(TAB_MSG_USER)
	Local nInd
	
	if anMoment == FE_AFTER .and. alCond
		if anOper == FE_APPEND
			for nInd := 1 to len(aaValues)
				if aaValues[nInd][1] == "ID_USER"
					oMsgUser:append({ { "ID_MSG", aoTable:value("id") }, { "ID_USER", aaValues[nInd][2] } })
				endif
			next
		elseif anOper == FE_UPDATE
			// exclui todos os registros
			oMsgUser:Seek(2, { aoTable:value("id") })
			while !oMsgUser:EoF() .and. oMsgUser:value("ID_MSG") == aoTable:value("id")
				oMsgUser:Delete()
				oMsgUser:_Next()
			enddo
			
			// re-insere os registros alterados
			for nInd := 1 to len(aaValues)
				if aaValues[nInd][1] == "ID_USER"
					oMsgUser:append({ { "ID_MSG", aoTable:value("id") }, { "ID_USER", aaValues[nInd][2] }, { "lido", .F. } })
				endif
			next			
		elseif anOper == FE_DELETE
			while !oMsgUser:EoF() .and. oMsgUser:value("ID_MSG") == aoTable:value("id")
				oMsgUser:Delete()
				oMsgUser:_Next()
			enddo
		endif
	endif

return aoTable

/*
-----------------------------------------------------------------------
Inicializa a tabela de mensagens x usuário
-----------------------------------------------------------------------
*/
static function DW02102() // TAB_MSG_USER
	local oTable := TTable():New(TAB_MSG_USER)
	
	oTable:Descricao(STR0300)  //"Mensagens por usuário"
	oTable:addFieldID()
	oTable:addField(NIL, "ID_MSG",		"N")
	oTable:addField(NIL, "ID_USER",		"N")
	oTable:addField(NIL, "lida",		"L")
	oTable:addField(NIL, "dt_leitura",	"D")
	oTable:addField(NIL, "hr_leitura",	"C")
	
	oTable:SetAttField("ID_MSG", 	STR0301)  //"Identificador da Mensagem"
	oTable:SetAttField("ID_USER", 	STR0302)  //"Identificador do Usuário"
	oTable:SetAttField("lida", 		STR0303)  //"Lida"
	oTable:SetAttField("dt_leitura",STR0304)  //"Data da Leitura"
	oTable:SetAttField("hr_leitura",STR0305)  //"Horário da Leitura"
	
	oTable:AddIndex2(NIL, { "ID_MSG" } )
	oTable:AddIndex2(NIL, { "ID_USER" } )

  oTable:addParent(TAB_MSG, "ID_MSG")
  oTable:addParent(TAB_USER, "ID_USER")
  	
	createTable(oTable)

return oTable                            

/*
-----------------------------------------------------------------------
Inicializa a seleção SEL_MSG_LER (QW02102)
. Mensagens não lidas pelo usuário
-----------------------------------------------------------------------
*/
static function QW02102() // SEL_MSG_LER
	local oQuery := TQuery():New(SEL_MSG_LER) // QW02102
	local oAux   

	oAux := InitTable(TAB_MSG)
	oAux := InitTable(TAB_MSG_USER)

	oQuery:addFieldID()
	oQuery:AddField(nil, "dt_pub_ini", "D")
	oQuery:AddField(nil, "hr_pub_ini", "C", 8)
	oQuery:AddField(nil, "dt_pub_fin", "D")            
	oQuery:AddField(nil, "hr_pub_fin", "C", 8)
 	oQuery:AddField(nil, "data_incl", "D")
 	oQuery:AddField(nil, "mensagem", "C", 255)
	
	oQuery:FromList(trataTableName(TAB_MSG) + " A," + trataTableName(TAB_MSG_USER) + " B")
	oQuery:FieldList("B.ID, A.DT_PUB_INI, A.HR_PUB_INI, A.DT_PUB_FIN, A.HR_PUB_FIN, A.MENSAGEM, A.DATA_INCL")
	oQuery:WhereClause("A.ID = B.ID_MSG and B.ID_USER = [P1] and B.LIDA = 'F' and " + ;
	                   "A.DT_PUB_INI <= [P2] and " +; 
	                   "A.DT_PUB_FIN >= [P3]")

	oQuery:OrderBy("A.DT_PUB_INI")

return oQuery

/*
-----------------------------------------------------------------------
Inicializa a tabela de processos
-----------------------------------------------------------------------
*/
static function DW02200()//TAB_PROCESS
	local oTable := TTable():New(TAB_PROCESS)

	oTable:Descricao(STR0306)  //"Processos"
	oTable:Events({ |oTable, nMoment, nOper, lCond, aValues| DW02200Ev(oTable, nMoment, nOper, lCond, aValues)})

	oTable:addFieldID()
	oTable:addField(nil, "sessao", "C", 10)
	oTable:addField(nil, "tipo", "C", 5)
	oTable:addField(nil, "id_parent", "N", 10)
	oTable:addField(nil, "processo", "C", 50)
	oTable:addField(nil, "descricao", "C", 255)
	oTable:addField(nil, "compl", "C", 255)
	oTable:addField(nil, "logfile", "C", 255)
	oTable:addField(nil, "tot_proc", "N", 10, 0)
	oTable:addField(nil, "qtd_proc", "N", 10, 0)

	oTable:SetAttField("tipo", STR0021)  //"Tipo"
	oTable:SetAttField("processo", STR0307)  //"Processo"
	oTable:SetAttField("descricao", STR0020)  //"Descrição"
	oTable:SetAttField("compl", STR0152)  //"Complemento"

	oTable:AddIndex2(nil, { "sessao", "tipo", "id_parent" } )

	oTable:SetVisible("sessao", .f.)
	oTable:SetVisible("id_parent", .f.)
	oTable:SetVisible("tipo", .f.)
	oTable:SetVisible("logfile", .f.)
	
	createTable(oTable)

return oTable

static function DW02200Ev(poTable, pnMoment, pnOper, plCond, paValues)
	local oTable, oFile
	local cSessionID := iif(valType(HttpCookies->SessionID)=="U", dwInt2Hex(0,10), dwInt2Hex(dwVal(HttpCookies->SessionID),10))
	
	if pnMoment == FE_DURING
		if pnOper == FE_SYNC
			DWDelAllRec(poTable:Tablename(), "SESSAO = '" + cSessionID + "'")

			oTable := InitTable(TAB_DSN)
			oTable:Seek(1)
			while !oTable:eof()          
				oFile := TDWFileIO():New(DwTempPath() + "\DWIMP" + dwInt2Hex(oTable:value("id"), 8) + dwInt2Hex(oSigaDW:DWCurr()[1], 8) + ".LOG")
				if oFile:Exists()
					if oFile:Open()
						oFile:Close()
					else 
						poTable:append( { { "sessao", cSessionID },  ;
									{ "tipo"     , JOB_IMPORTACAO } ,;
									{ "id_parent", oTable:value("id") } ,;
									{ "processo", STR0308 + " - " + iif(oTable:value("tipo") == "D", STR0063, STR0309) } ,;  //"Importação de dados"   //"Dimensão"  //"Fato"
									{ "descricao", oTable:value("nome") + " " + oTable:value("descricao") } ,;
									{ "compl", STR0310 }, ;  //"(indica tipo de conexão)"
									{ "logfile", oFile:filename() } })
					endif					
				endif
			   oTable:_Next()
			enddo
			oTable:close()

			oTable := InitTable(TAB_EXPORT)
			oTable:Seek(1)
			while !oTable:eof()          
				oFile := TDWFileIO():New(DwTempPath() + "\DWEXP" + dwInt2Hex(oTable:value("id"), 8) + dwInt2Hex(oSigaDW:DWCurr()[1], 8) + ".LOG")
				if oFile:Exists()
					if oFile:Open()
						oFile:Close()
					else 
						poTable:append( { { "sessao", cSessionID },  ;
									{ "tipo"     , JOB_EXPORTACAO } ,;
									{ "id_parent", oTable:value("id") } ,;
									{ "processo", STR0311 } ,;  //"Exportação de dados"  
									{ "descricao", iif(oTable:value("tipo") == EX_CON, "Consulta", iif(oTable:value("tipo") == EX_DIM, STR0063, STR0309) ) } ,;  //"Dimensão"  //"Fato"    //traduzir
									{ "compl", "" } ,; 
									{ "logfile", oFile:filename() }})
					endif					
				endif
			   oTable:_Next()
			enddo
			oTable:close()
		endif
	endif

return

/*
-----------------------------------------------------------------------
Inicializa a tabela de IPC
-----------------------------------------------------------------------
*/
static function DW02210()//TAB_IPC
	local oTable 	:= TTable():New(TAB_IPC)
	local cInfoLen  := If(TcGetDB() == "INFORMIX", 255, 400)  

	oTable:Descricao("IPC")
	oTable:addFieldID()
	oTable:addField(nil, "logfile", "C", 40)
	oTable:addField(nil, "rectype", "N", 10)
	oTable:addField(nil, "info1", "C", cInfoLen)
	oTable:addField(nil, "info2", "C", cInfoLen)
	oTable:addField(nil, "info3", "C", cInfoLen)
	oTable:addField({|| seconds() }, "stamp", "N", 10)

	oTable:AddIndex2(nil, { "logfile", "stamp" } )
	
	createTable(oTable)

return oTable

/*
-----------------------------------------------------------------------
Inicializa a seleção SEL_IPC (QW02210)
. Informações sobre um processo
-----------------------------------------------------------------------
*/
static function QW02210(acLogFile) // SEL_IPC
	local oQuery := TQuery():New(SEL_IPC)

	oQuery:FromList(TAB_IPC)
	oQuery:FieldList("ID, LOGFILE, RECTYPE, INFO1, INFO2, INFO3")
	oQuery:WhereClause("LOGFILE = [P1] and STAMP < [P2]")
	oQuery:OrderBy("STAMP asc")

return oQuery

/*
-----------------------------------------------------------------------
Inicializa a tabela de açoes
-----------------------------------------------------------------------
*/
static function DW02300()//TAB_ACTIONS
	local oTable := TTable():New(TAB_ACTIONS)

	oTable:Descricao(STR0312)  //"Ações"
	oTable:addFieldID()
	oTable:addFieldDW()
	oTable:addField(nil, "dt", "D")
	oTable:addField(nil, "hr", "C", 8)
	oTable:addField(nil, "id_user", "N")
	oTable:addField(nil, "id_action", "N")
	oTable:addField(nil, "compl", "C", 50)

	oTable:SetAttField("dt", STR0035)  //"Data"
	oTable:SetAttField("hr", STR0180)  //"Hora"
	oTable:SetAttField("id_action", STR0313)  //"Ação"
	oTable:SetAttField("id_user", STR0098)  //"Usuário"
	oTable:SetAttField("compl", STR0152)  //"Complemento"

	oTable:AddIndex2(nil, { "dt", "hr" } )

  oTable:addParent(TAB_USER, "ID_USER")
  
	createTable(oTable)

return oTable

/*
-----------------------------------------------------------------------
Inicializa a tabela DWCubeList
-----------------------------------------------------------------------
*/
static function DW05000()
	local oTable := TTable():New(TAB_CUBESLIST)
	
	oTable:Descricao(STR0314)  //"Cubos"
	oTable:Events({ |oTable, nMoment, nOper, lCond, aValues| DW05000Ev(oTable, nMoment, nOper, lCond, aValues)})

	oTable:addFieldID()
	oTable:addFieldDW()
	oTable:addField(nil, "nome", "C", 15)
	oTable:addField(nil, "descricao", "C", 30)
	oTable:addField({ || date() }, "dt_create", "D")
	oTable:addField({ || time() }, "hr_create", "C", 8)
	oTable:addField(nil, "dt_process", "D")
	oTable:addField(nil, "hr_process", "C", 8)
	oTable:addField({ || .f. }, "importado", "L")
	oTable:addField({ || .f. }, "notificar", "L")
	oTable:addField(nil, "id_docto", "N")
	oTable:addField(nil, "docto", "C", 0, 0, { || DWConcatWSep(CRLF, DWDetail(TAB_EXPR, id_docto, "linha", "id", 1))}, nil) 
	oTable:addField(nil, "impCon", "N")
	//oTable:addField(nil, "link", "C", 10)
	
	oTable:AddIndex2(nil, { "nome" }, .t. )

	oTable:SetAttField("descricao", STR0020) //"Descrição"
	oTable:SetAttField("dt_create" , STR0051) //"Data Criação"
	oTable:SetAttField("hr_create" , STR0052) //"Hora Criação"
	oTable:SetAttField("dt_process", STR0053) //"Data Proc."
	oTable:SetAttField("hr_process", STR0054) //"Hora Proc."
	oTable:SetAttField("notificar", STR0090) //"Notificar"
	//oTable:SetAttField("link", "Link")  //## NEWSTR ##

//	oTable:SetVisible("dt_process", .f.)
//	oTable:SetVisible("hr_process", .f.)
	oTable:SetVisible("importado", .f.)
	oTable:SetVisible("id_docto", .f.)
	oTable:setVisible("docto", .f.)
	oTable:setVisible("impCon", .f.)

	createTable(oTable)                  
                           
return oTable

static function DW05000Ev(poTable, pnMoment, pnOper, plCond, paValues)

	local oTable
	
	if pnMoment == FE_BEFORE
		if pnOper == FE_DELETE

			oTable := InitTable(TAB_FACTFIELDS)
			if oTable:Seek(2, { poTable:value("id") })
			   while !oTable:eof() .and. (poTable:value("id") == oTable:value("id_cubes"))
				  oTable:Delete()
				  oTable:_Next()
			   end
			endif

			oTable := InitTable(TAB_FACTVIRTUAL )
			if oTable:Seek(2, { poTable:value("id") })
			   while !oTable:eof() .and. (poTable:value("id") == oTable:value("id_cubes"))
				  oTable:Delete()
				  oTable:_Next()
			   end
			endif
			
			oTable := InitTable(TAB_DIM_CUBES)
			if oTable:Seek(2, { poTable:value("id") })
			   while !oTable:eof() .and. (poTable:value("id") == oTable:value("id_cube"))
				   oTable:Delete()
				   oTable:_Next()
			   end
			endif
			
			// privilégios/acesso do usuário
			oTable := InitTable(TAB_USER_PRIV)
			if oTable:Seek(4, { "C", oTable:value("id_cube") })
			   while !oTable:eof() .and. (poTable:value("id") == oTable:value("id_cube"))
				   oTable:Delete()
				   oTable:_Next()
			   end
			endif

			oTable := InitTable(TAB_DSN)
			if oTable:Seek(2, { "F", poTable:value("id") })
			   while !oTable:eof() .and. ( (oTable:value("tipo") == "F") .and. (poTable:value("id") == oTable:value("id_table")) )
				   oTable:Delete()
				   oTable:_Next()
			   end
			endif
			
			// excluí os filtros padrão/diretos para o cubo
			oTable := InitTable(TAB_FACT_WHERE)
			oTable:Seek(2, { poTable:value("id") })
			while !oTable:EoF() .and. oTable:value("id_cube") == poTable:value("id")
				oTable:Delete()
				oTable:_Next()
			enddo
			
		endif
	endif

return

/*
-----------------------------------------------------------------------
Inicializa a seleção SEL_FACT_INFO (QW05101)
. Informações sobre fatos
-----------------------------------------------------------------------
*/
static function QW05101() // SEL_FACT_INFO
	local oQuery := TQuery():New(SEL_FACT_INFO)
	local oAux, aSQL := {}

	oAux := InitTable(TAB_CUBESLIST)
	oAux := InitTable(TAB_FACTFIELDS)
	oAux := InitTable(TAB_DIM_CUBES)
           
	oQuery:AddField(nil, "id", "N", 10)
	oQuery:AddField(nil, "dim", "N", 10)
	oQuery:AddField(nil, "ind", "N", 10)
	oQuery:AddField(nil, "dados", "N", 10)
	
	if SGDB() == DB_INFORMIX
		aAdd(aSQL, "select * from table ( multiset ( ")
	else			
		aAdd(aSQL, "select * from ( ")
	endif
	aAdd(aSQL, "select A.ID, count(*) as DIM, 0 as IND, 0 as DADOS from")
	aAdd(aSQL, "       " + trataTablename(TAB_CUBESLIST) + " A, " + trataTablename(TAB_DIM_CUBES) + " B")
	aAdd(aSQL, " where A." + DWDelete() + " <> '*' and B." + DWDelete() + " <> '*' and A.ID = B.ID_CUBE")
	aAdd(aSQL, " group by A.ID")
	aAdd(aSQL, "union")
	aAdd(aSQL, "select A.ID, 0 AS DIM, count(*) as IND, 0 as DADOS from")
	aAdd(aSQL, "       " + trataTablename(TAB_CUBESLIST) + " A, " + trataTablename(TAB_FACTFIELDS) + " B")
	aAdd(aSQL, " where A." + DWDelete() + " <> '*' and B." + DWDelete() + " <> '*' and A.ID = B.ID_CUBES")
	aAdd(aSQL, "   and B.DIMENSAO = 0")
	aAdd(aSQL, " group by A.ID")
	if SGDB() == DB_INFORMIX
		aAdd(aSQL, "              )) x")
	else			
		aAdd(aSQL, "              ) x")
	endif
  aAdd(aSQL, "order by ID")
  
  oQuery:SQL(, dwConcatWSep(CRLF, aSQL))
  
return oQuery

/*
-----------------------------------------------------------------------
Inicializa a tabela DWFactFields
-----------------------------------------------------------------------
*/
static function DW05110()
	local oTable := TTable():New(TAB_FACTFIELDS)
	
	oTable:Descricao(STR0186)  //"Indicadores"
	oTable:Events({ |oTable, nMoment, nOper, lCond, aValues| DW05110Ev(oTable, nMoment, nOper, lCond, aValues)})

	oTable:addFieldID()
	oTable:addField(nil, "ID_CUBES", "N")
	oTable:addField(nil, "nome", "C", 10)
	oTable:addField(nil, "descricao", "C", 30)
	oTable:addField(nil, "tipo", "C", 1)
	oTable:addField(nil, "tam", "N", 4)
	oTable:addField(nil, "ndec", "N", 4)
	oTable:addField(nil, "classe", "C", 1) // D-dimensão A-aditivo S-semi-aditivo M-mini-dimensão C-calculado
	oTable:addField(nil, "dimensao", "N") 
	oTable:addField(nil, "mascara", "C", 30) 
	oTable:addField(nil, "keyseq", "N", 3)
	oTable:addField(nil, "dimName", "C", 30, 0, { || DWLookup(TAB_DIMENSAO, dimensao, "nome") }, nil)
	oTable:addField(nil, "virtual", "L")
	oTable:addField(nil, "visible", "L")
	oTable:addField(nil, "id_docto", "N")
	oTable:addField(nil, "docto", "C", 0, 0, { || DWConcatWSep(CRLF, DWDetail(TAB_EXPR, id_docto, "linha", "id", 1))}, nil) 

  	oTable:addParent(TAB_CUBESLIST, "id_cubes")

	oTable:AddListVal("tipo", { { "N", STR0055},; //"Numérico"
										 { "C", STR0056},; //"Caracter"
										 { "D", STR0035},; //"Data"
										 { "L", STR0057},; //"Lógico"
										 { "M", STR0058} }) //"Memo"

	oTable:AddIndex2(nil, { "ID_CUBES", "nome" }, .t. )
	oTable:AddIndex2(nil, { "ID_CUBES", "id" } )
	oTable:AddIndex2(nil, { "ID_CUBES", "dimensao" } )
	oTable:AddIndex2(nil, { "dimensao" } )
	oTable:AddIndex2(nil, { "ID_CUBES", "descricao" } )

	oTable:SetAttField("descricao", STR0020) //"Descrição"
	oTable:SetAttField("tam", STR0059) //"Tamanho"
	oTable:SetAttField("ndec", STR0068) //"#Decimais"
	oTable:SetAttField("dimName", STR0063)  //"Dimensão"
	oTable:SetAttField("mascara", STR0069) //"Máscara"
	oTable:SetAttField("visible", STR0250)  //"Visível"

	oTable:SetVisible("id_cubes", .f.)
	oTable:SetVisible("classe", .f.)
	oTable:SetVisible("dimensao", .f.)
	oTable:SetVisible("keyseq", .f.)
	oTable:SetVisible("virtual", .F.)
	oTable:SetVisible("id_docto", .F.)
	oTable:setVisible("docto", .f.)

	createTable(oTable)

return oTable

static function DW05110Ev(poTable, pnMoment, pnOper, plCond, paValues)
	local owf, nPos
	
	if pnMoment == FE_DURING
		
		if pnOper == FE_VALIDATE
			
			if (nPos := ascan(paValues, { |x| upper(x[1]) == "TIPO" } )) != 0				
				/*Verifica se o campo é DATA ou CARACTER*/
				if ( paValues[nPos, 2] == "D" ) .OR. ( paValues[nPos, 2] == "C" )
					/*Para campo DATA*/
					If ( paValues[nPos, 2] == "D" )
					    /*Define o tamanho como OITO*/
						If (nPos := ascan(paValues, { |x| upper(x[1]) == "TAM" } )) != 0
							paValues[nPos, 2] := 8
						endif					
					EndIf					
					/*Inclui no array os valores que não são enviados no POST [disabled = true]*/				        
					aAdd(paValues, {"NDEC", 0}) 					
				endif
			endif
		endif		
	endif
	
	if pnMoment == FE_BEFORE
		if pnOper == FE_DELETE
			oTable := InitTable(TAB_DSNCONF)
			if oTable:Seek(3, { poTable:value("id") })
			   while !oTable:eof() .and. (poTable:value("id") == oTable:value("id_field"))
				  oTable:Delete()
				  oTable:_Next()
			   end
			endif
		endif
	endif		          
	
return

/*
-----------------------------------------------------------------------
Inicializa a tabela DWFactVirtual
-----------------------------------------------------------------------
*/
static function DW05120()  
	local oTable := TTable():New(TAB_FACTVIRTUAL)
	
	oTable:Descricao(STR0315)  //"Indicadores virtuais"
	oTable:Events({ |oTable, nMoment, nOper, lCond, aValues| DW05120Ev(oTable, nMoment, nOper, lCond, aValues)})

	oTable:addFieldID()
	oTable:addField(nil, "ID_CUBES", "N")
	oTable:addField(nil, "nome", "C", 10)
	oTable:addField(nil, "descricao", "C", 30)
	oTable:addField(nil, "tam", "N", 4)
	oTable:addField(nil, "ndec", "N", 4)
	oTable:addField(nil, "mascara", "C", 30) 
	oTable:addField(nil, "id_expr", "N") 
	oTable:addField(nil, "expressao", "C", 255, 0, { || DWConcatWSep(CRLF, DWDetail(TAB_EXPR, ID_EXPR, "linha", "id", 1))}, nil) 
	oTable:addField(nil, "isSQL", "L",,, { || DWLookup(TAB_EXPR, ID_EXPR, "isSQL")}, nil) 
	oTable:addField(nil, "id_docto", "N") 
	oTable:addField(nil, "docto", "C", 0, 0, { || DWConcatWSep(CRLF, DWDetail(TAB_EXPR, id_docto, "linha", "id", 1))}, nil) 

	oTable:AddIndex2(nil, { "ID_CUBES", "nome" }, .T. )
	oTable:AddIndex2(nil, { "ID_CUBES", "id" } )
	oTable:AddIndex2(nil, { "ID_CUBES", "descricao"} )     

  	oTable:addParent(TAB_CUBESLIST, "id_cubes")

	oTable:setVisible("id_cubes", .f.)
	oTable:setVisible("id_expr", .f.)
	oTable:setVisible("id_docto", .f.)
	oTable:setVisible("docto", .f.)
    
	oTable:setAttField("nome", STR0264)  //"Nome"
	oTable:setAttField("descricao", STR0020) //"Descrição"
	oTable:setAttField("tam", STR0059) //"Tamanho"
	oTable:setAttField("ndec", STR0068) //"#Decimais"
	oTable:setAttField("mascara", STR0069)  //"Máscara"
	oTable:setAttField("expressao", STR0072) //"Expressão"

	createTable(oTable)

return oTable

static function DW05120Ev(poTable, pnMoment, pnOper, plCond, paValues)
	local oQuery, nID, lAtzCalc := .f., nIDCube
			
	if pnMoment == FE_AFTER
		if pnOper == FE_APPEND .or. pnOper == FE_UPDATE 
			nID := poTable:value("id")
			nIDCube := poTable:value("id_cubes")
			lAtzCalc := .t.
		endif
	elseif pnMoment == FE_BEFORE
		if pnOper == FE_DELETE
			nID := poTable:value("id")
			oQuery := TQuery():New()
			oQuery:FromList(TAB_CALC)
			oQuery:WhereClause("ID_VIRTUAL = "+dwStr(nID))
			oQuery:ExecDel()
			oQuery:Close()
		endif
	endif

	if lAtzCalc                     
		sincVirtualFlds(poTable, nIDCube)
	endif	

return

/*
-----------------------------------------------------------------------
Sincroniza os campos virtuais do cubo com as consultas
Args: poTable, objeto, tabela de campos virtuais do cubo
      anIDCube, numerico, cubo utilizado pela consulta
      anIDCons, numerico (opcional), consulta a ser sincronizada. 
                Se não informada, todas serão processadas.
Retorno: nil
-----------------------------------------------------------------------
*/
function sincVirtualFlds(poTable, anIDCube, anIDCons)
local oTabCalc, oCons
local aValues

default anIDCons := 0

oTabCalc := initTable(TAB_CALC)
oCons := initTable(TAB_CONSULTAS)

oCons:savePos()

if anIDCons <> 0
	if oCons:Seek(1, { anIDCons })
		poTable:Seek(2, { anIDCube })
		while !poTable:eof() .and. poTable:value("id_cubes") == anIDCube
			
			/*Alimenta o array com valores a serem apendados ou atualizados.*/
			aValues := { { "ID_CONS", oCons:value("id") },;
			{ "nome", poTable:value("nome") },;
			{ "descricao", poTable:value("descricao") },;
			{ "tipo", "N" },;
			{ "tam", poTable:value("tam") },;
			{ "ndec", poTable:value("ndec") },;
			{ "mascara", poTable:value("mascara") },;
			{ "id_expr", poTable:value("id_expr") },;
			{ "id_virtual", poTable:value("id")  } }
			 
			/*Verifica se a expressão já existe para determinada consulta na tabela.*/			
			if oTabCalc:seek(4, {oCons:value("id"), poTable:value("id_expr")})
				oTabCalc:update(aValues)
			else
				oTabCalc:append(aValues)
			endif   
			
			poTable:_Next()
		enddo
	endif
else	
	if oCons:Seek(9, { anIDCube })
		while !oCons:eof() .and. oCons:value("id_cube") == anIDCube
		
			/*Alimenta o array com valores a serem apendados ou atualizados.*/
			aValues := { { "ID_CONS", oCons:value("id") },;
			{ "nome", poTable:value("nome") },;
			{ "descricao", poTable:value("descricao") },;
			{ "tipo", "N" },;
			{ "tam", poTable:value("tam") },;
			{ "ndec", poTable:value("ndec") },;
			{ "mascara", poTable:value("mascara") },;
			{ "id_expr", poTable:value("id_expr") },;
			{ "id_virtual", poTable:value("id")  } }
			 	
			/*Verifica se a expressão já existe para determinada consulta na tabela.*/			
			if oTabCalc:seek(4, {oCons:value("id"), poTable:value("id_expr")})
				oTabCalc:update(aValues)
			else  
				/*Impede a inclusão de registro em branco na TAB_CALC.*/
				if (anIDCons <> 0)
					oTabCalc:append(aValues)
		   		endif 
			endif      
			
			/*Invalida a consulta.*/
			invalCons(oCons:value("id"), .f., .f., oCons)
			
			oCons:_Next()
		enddo
	endif
endif

oCons:restPos()

return

/*
-----------------------------------------------------------------------
Inicializa a tabela de TAB_FACT_WHERE (DW05130)
-----------------------------------------------------------------------
*/
static function DW05140() // TAB_FACT_WHERE
	local oTable := TTable():New(TAB_FACT_WHERE)
	
	oTable:Descricao(STR0316)  //"Filtros por cubo"
	oTable:Events({ |oTable, nMoment, nOper, lCond, aValues| DW05140Ev(oTable, nMoment, nOper, lCond, aValues)})
	
	oTable:addFieldID()
	oTable:addField(nil, "id_cube", "N")
	oTable:addField(nil, "nome", "C", 15)
	oTable:addField(nil, "descricao", "C", 60)
	oTable:addField(nil, "id_expr", "N") 
	oTable:addField(nil, "expressao", "C", 255, 0, { || DWConcatWSep(CRLF, DWDetail(TAB_EXPR, ID_EXPR, "linha", "id", 1))}, nil) 
	oTable:addField(nil, "issql", "L", 1, 0, { || DWLookup(TAB_EXPR, ID_EXPR, "issql")}, nil) 
	oTable:addField(nil, "tipo", "C", 1)

	oTable:AddIndex2(nil, { "id_cube", "tipo", "nome" } )

  oTable:addParent(TAB_CUBESLIST, "id_cube")

	oTable:setAttField("nome", STR0264)  	  //"Nome"
	oTable:setAttField("descricao", STR0020)  //"Descrição"
	oTable:setAttField("expressao", STR0219)  //"Expressão"
	
	oTable:SetVisible("id_cube", .F.)
	oTable:SetVisible("id_expr", .F.)
	oTable:SetVisible("tipo", .F.)
	
	createTable(oTable)
	
return oTable

static function DW05140Ev(poTable, pnMoment, pnOper, plCond, aValues)
	
	Local oQryWhere 	:= InitTable(TAB_WHERE)
	Local oQuery 		:= InitTable(TAB_CONSULTAS)
	Local oWhereCond	:= InitTable(TAB_WHERE_COND)
	Local aTableValues, aTabValAux, aAux
	Local nInd
	
	if pnMoment == FE_BEFORE
		if pnOper == FE_DELETE
		    oTable := InitTable(TAB_WHERE)
		    aAux := {}
		  	if oTable:Seek(3, { poTable:value("id") })
		  		while !oTable:eof() .and. DwVal(oTable:value("id_virtual")) == poTable:value("id")
	  				aAdd(aAux, oTable:value("id"))
		  			oTable:_Next()
		     	enddo
		  	endif
		  	
		  	for nInd := 1 to len(aAux)
		  		oTable := InitTable(TAB_WHERE)
		  		if oTable:Seek(1, { aAux[nInd] })
		  			oTable:Delete()
		  		endif
		  	next
		   	
		  	oTable := InitTable(TAB_EXPR)
		  	if oTable:Seek(2, { poTable:value("id_expr") })
		  		while !oTable:eof() .and. (poTable:value("id_expr") == oTable:value("id"))
		        	oTable:Delete()
		        	oTable:_Next()		  
		     	end
		  	endif
		  
		  	oTable := InitTable(TAB_WHERE_COND)
		  	if oTable:Seek(2, { poTable:value("id") })
		    	while !oTable:eof() .and. (poTable:value("id") == oTable:value("id_where"))
		        	oTable:Delete()
		        	oTable:_Next()		  
		     	end
		  	endif
			
		endif
	elseif pnMoment == FE_AFTER
		if pnOper == FE_APPEND
			// cria o array contendo os valores do filtro criado
			aTableValues := {	{"nome"			, poTable:value("nome")}, ;
								{"descricao"	, poTable:value("descricao")}, ;
								{"id_expr"		, poTable:value("id_expr")}, ;
								{"tipo"			, poTable:value("tipo")}, ;
								{"virtual"		, .T.}, ;
								{"id_virtual"	, poTable:value("id")} ;
							}
			// verifica se existem consultas relacionadas com o cubo para o qual está sendo criado o filtro,
			// adicionando o novo filtro para cada consulta encontrada
			oQuery:Seek(9, { poTable:value("id_cube") })
			while !oQuery:EoF() .and. oQuery:value("id_cube") == poTable:value("id_cube")
				// adiciona o filtro criado no relação de filtros para a consulta
				aTabValAux := aClone(aTableValues)
				aAdd(aTabValAux, {"id_cons", oQuery:value("id")} )

				// realiza a inclusão
				oQryWhere:Append(aTabValAux)
				
				oQuery:_Next()
			enddo
		
		elseif pnOper == FE_UPDATE
			// cria o array contendo os valores do filtro criado
			aTableValues :=	{	{"nome"			, poTable:value("nome")}, ;
								{"descricao"	, poTable:value("descricao")}, ;
								{"id_expr"		, poTable:value("id_expr")}, ;
								{"tipo"			, poTable:value("tipo")}, ;
								{"virtual"		, .T.}, ;
								{"id_virtual"	, poTable:value("id")} ;
							}
			// verifica se existem filtros para consultas correspondentes a este filtro padrão que está sendo atualizado
			oQryWhere:Seek(3, { poTable:value("id") })
			while !oQryWhere:EoF() .and. oQryWhere:value("id_virtual") == poTable:value("id")
				
				// verifica se o filtro padrão que está sendo alterado possue expressão por QBE (expressão não sql)
				if poTable:value("id_expr") == 0
					// exluí todas as condições para o filtro da consulta específica
					oWhereCond:Seek(2, { oQryWhere:value("id") })
				  	while !oWhereCond:EoF() .and. oWhereCond:value("id_where") == oQryWhere:value("id")
				  		oWhereCond:Delete()
				  		oWhereCond:_Next()
				  	enddo
					
					// incluí as condições para os filtros da consula específica,
					// com base nos filtros do filtro padrão que está sendo alterado
					oWhereCond:Seek(2, { poTable:value("id") })
					aAux := {}
					while !oWhereCond:EoF() .and. oWhereCond:value("id_where") == poTable:value("id")
						aTabValAux :=	{	{"id_where"		, oQryWhere:value("id")}, ;
											{"id_dim"		, oWhereCond:value("id_dim")}, ;
											{"id_field"		, oWhereCond:value("id_field")}, ;
											{"seq"			, oWhereCond:value("seq")}, ;
											{"qbe"			, oWhereCond:value("qbe")}, ;
											{"last_value"	, oWhereCond:value("last_value")} ;
										}
						aAdd(aAux, aTabValAux)
						oWhereCond:_Next()
					enddo
					
					// adiciona os registros para o filtro
					for nInd := 1 to len(aAux)
						oWhereCond:Append(aAux[nInd])
					next
				endif
				
				// atualiza o filtro
				aTabValAux := aClone(aTableValues)
				aAdd(aTabValAux, {"id_cons", oQryWhere:value("id_cons")} )

				oQryWhere:Update(aTabValAux)
				
				oQryWhere:_Next()
			enddo
			
		endif
	endif
	
return

/*
-----------------------------------------------------------------------
Inicializa a tabela Consultas 
-----------------------------------------------------------------------
*/
static function DW05200()
	local oTable := TTable():New(TAB_CONSULTAS)

	oTable:Descricao(STR0317)  //"Consultas"
	oTable:Events({ |oTable, nMoment, nOper, lCond, aValues| DW05200Ev(oTable, nMoment, nOper, lCond, aValues)})
	
	oTable:addFieldID()
	oTable:addFieldDW()
	oTable:addField(nil, "tipo", "C", 1)
	oTable:addField(nil, "nome", "C", 15)
	oTable:addField(nil, "publica", "L", 1)
	oTable:addField(nil, "sogrupo", "L", 1)
	oTable:addField(nil, "export", "L", 1)
	oTable:addField(nil, "descricao", "C", 60)
	oTable:addField(nil, "id_cons", "N")
	//oTable:addField(nil, "conspai", "C", 15, 0, { || DWLookup(TAB_CONSULTAS, id_cons, "nome") }, nil) 
	oTable:addField(nil, "id_cube", "N")
	oTable:addField(nil, "cube_desc", "C", 30,0, { || DWLookup(TAB_CUBESLIST, id_cube, "descricao") }, nil) 
	oTable:addField(nil, "valida", "L") 
	oTable:addField(nil, "valgra", "L") 
	oTable:addField(nil, "erro", "L") 
	oTable:addField(nil, "id_user", "N")
	oTable:addField(nil, "user_name", "C", 15, 0, { || DWLookup(TAB_USER, id_user, "nome") }, nil) 
	oTable:addField(nil, "id_grupo", "N", , , { || DWLookup(TAB_USER, id_user, "id_grupo") }, nil) 
	oTable:addField(nil, "login", "C", 15, 0, { || DWLookup(TAB_USER, id_user, "login") }, nil) 
	oTable:addField({||.t.}, "excel", "L") 
	oTable:addField(nil, "id_docto", "N")
	oTable:addField(nil, "docto", "C", 0, 0, { || DWConcatWSep(CRLF, DWDetail(TAB_EXPR, id_docto, "linha", "id", 1))}, nil) 
	oTable:addField(nil, "puburl", "L", 1)
	oTable:addField(nil, "grupo", "C", 15) // Integração com P9 R1 para controle de Indicadores Nativo
	oTable:addField(nil, "habPOnl","L", 1)
//	oTable:addField(nil, "definition","M") //
                         
	oTable:AddIndex2(nil, { "tipo", "id" } )
	oTable:AddIndex2(nil, { "tipo", "id_cons", "nome" } )
	oTable:AddIndex2(nil, { "id_cons", "nome" } )
	oTable:AddIndex2(nil, { "tipo", "nome" } )
	oTable:AddIndex2(nil, { "tipo", "id_user", "id_cons" })
	oTable:AddIndex2(nil, { "id_user", "tipo", "id_cons" } )
	oTable:AddIndex2(nil, { "tipo", "id_user", "nome" }, .T. )
	oTable:AddIndex2(nil, { "id_cube" } )

	oTable:SetAttField("publica", STR0070) //"Pública"
	oTable:SetAttField("export", STR0318) //"Exportar"
	oTable:SetAttField("sogrupo", STR0215) //"Somente Grupo"
	oTable:SetAttField("descricao", STR0020) //"Descrição"
	oTable:SetAttField("user_name", STR0071)  //"Proprietário"
	oTable:SetAttField("excel", STR0244)
	oTable:SetAttField("login", STR0319) //"Login Prop."
	oTable:SetAttField("puburl", STR0260) //"Permitir acceso via URL"

	oTable:SetVisible("tipo", .F.)
	oTable:SetVisible("id_cons", .F.)
	oTable:SetVisible("id_user", .F.)
	oTable:SetVisible("id_docto", .F.)
	oTable:setVisible("docto", .f.)
	oTable:setVisible("id_cube", .f.)

  oTable:addParent(TAB_CUBESLIST, "ID_CUBE")
  oTable:addParent(TAB_USER, "id_user")
  	
	createTable(oTable)
                    
return oTable

static function DW05200Ev(poTable, pnMoment, pnOper, plCond, paValues)
	local oTable, oTableAux
	local oTableWhere, oTableWheCond
	local aValues, aValuesAux, nID, lAtualCubFilter
	local aAux, nInd, oTabCalc
	local lPublica, lSoGrupo
	
	if pnMoment == FE_BEFORE
		if pnOper == FE_UPDATE
			// tratamento de consultas de usuários
			If poTable:value("tipo") == QUERY_USER
				For nInd := 1 to len(paValues)
					If Upper(paValues[nInd, 1]) == "PUBLICA"
						lPublica := paValues[nInd, 2]
					ElseIf Upper(paValues[nInd, 1]) == "SOGRUPO"
						lSoGrupo := paValues[nInd, 2]
					EndIf
				Next
				
				// se era pública e está sendo redefinida para não pública OU se era somente para o grupo e está sendo redefinida
				If (poTable:value("publica") .AND. !lPublica) .OR. poTable:value("sogrupo") .AND. !lSoGrupo
					oTable 		:= InitTable(TAB_USER_DSKTOP)
					oTableAux 	:= InitTable(TAB_USER)
					// índices de pesquisa "id_no", "tipo_cons", "dw", "id_user"
					IF oTable:Seek(7, { poTable:value("id"), QUERY_USER, oSigaDW:DWCurr()[2] })
						While !oTable:EoF() .AND. oTable:value("id_no") == poTable:value("id") .AND. ;
							oTable:value("tipo_cons") == QUERY_USER .AND. ;
							oTable:value("dw") == oSigaDW:DWCurr()[2]
							If !lPublica .AND. !lSoGrupo .AND. !(oTable:value("id_user") == poTable:value("id_user"))
								oTable:Delete()
							ElseIf !lPublica .AND. lSoGrupo
								If oTableAux:Seek(1, { oTable:value("id_user") }) .AND. oTableAux:value("id") == oTable:value("id_user")
									If !(oTableAux:value("id_grupo") == poTable:value("id_grupo"))
										oTable:Delete()
									EndIf
								EndIf
							EndIf
							
							oTable:_Next()
						EndDo
					EndIf
				EndIf
			EndIf
		ElseIf pnOper == FE_DELETE
			oTable := InitTable(TAB_CONSTYPE)
			if oTable:Seek(2, { poTable:value("id") })
				while !oTable:eof() .and. (poTable:value("id") == oTable:value("id_cons"))
					oTable:Delete()
					oTable:_Next()
				end
			endif
			
			oTable := InitTable(TAB_ALERT)
			if oTable:Seek(2, { poTable:value("id") })
				while !oTable:eof() .and. (poTable:value("id") == oTable:value("id_cons"))
					oTable:Delete()
					oTable:_Next()
				end
			endif
			
			oTable := InitTable(TAB_CALC)
			if oTable:Seek(2, { poTable:value("id") })
				while !oTable:eof() .and. (poTable:value("id") == oTable:value("id_cons"))
					oTable:Delete()
					oTable:_Next()
				end
			endif
			
			// privilégios/acesso do usuário
			oTable := InitTable(TAB_USER_PRIV)
			if oTable:Seek(4, { "Q", oTable:value("id_cons") })
				while !oTable:eof() .and. (poTable:value("id") == oTable:value("id_cons"))
					oTable:Delete()
					oTable:_Next()
				end
			endif
			
			oTable := InitTable(TAB_USER_DSKTOP)
			if oTable:Seek(3, { 3, poTable:value("id"), poTable:value("tipo") })
				while !oTable:eof() .and. (oTable:value("tipo") == 3 .and. poTable:value("id") == oTable:value("id_cons") .and. poTable:value("tipo") == oTable:value("tipo_cons"))
					oTable:Delete()
					oTable:_Next()
				end
			endif
			
			oTable := InitTable(TAB_WHERE)
			if oTable:Seek(2, { poTable:value("id") })
				while !oTable:eof() .and. (poTable:value("id") == oTable:value("id_cons"))
					//-----------------------------------------------------------------------
					//  Caso o filtro seja proveniente do cubo, ele não pode ser deletado.
					//----------------------------------------------------------------------- 
					If !oTable:value("virtual")
						oTable:Delete()
					EndIf
					oTable:_Next()
				end
			endif
			
			oTable := InitTable(TAB_CONS_WHE)
			if oTable:Seek(2, { poTable:value("id") })
				while !oTable:eof() .and. (oTable:value("id_cons") == poTable:value("id"))
					oTable:Delete()
					oTable:_Next()
				end
			endif
			
		endif
	elseif pnMoment == FE_AFTER
		if pnOper == FE_UPDATE
			oTable 			:= InitTable(TAB_FACT_WHERE)
			oTableWhere 	:= InitTable(TAB_WHERE)
			oTableWheCond 	:= InitTable(TAB_WHERE_COND)
			
			// verifica se já realizou o processo de atualização dos filtros do cubo para a consulta
			lAtualCubFilter := .T.
			oTableWhere:Seek(2, { poTable:value("id") })
			while !oTableWhere:EoF() .and. oTableWhere:value("id_cons") == poTable:value("id")
				if oTableWhere:value("virtual")
					lAtualCubFilter := .F.
					exit
				endif
				oTableWhere:_next()
			enddo
			
			if lAtualCubFilter
				// procura por filtros relacionados com o cubo utilizado por esse consulta
				oTable:Seek(2, { poTable:value("id_cube") })
				
				while !oTable:EoF() .and. oTable:value("id_cube") == poTable:value("id_cube")
					// cria o array contendo os valores do filtro
					aValues := 	{	{"id_cons"		, poTable:value("id")}, ;
					{"nome"			, oTable:value("nome")}, ;
					{"descricao"	, oTable:value("descricao")}, ;
					{"id_expr"		, oTable:value("id_expr")}, ;
					{"tipo"			, oTable:value("tipo")}, ;
					{"virtual"		, .T.}, ;
					{"id_virtual"	, oTable:value("id")} ;
					}
					// recria o filtro para esta nova consulta
					oTableWhere:Append(aValues)
					nID := oTableWhere:value("id")
					
					// procura por expressões qbe para o filtro específico
					aAux := {}
					oTableWheCond:Seek(2, { oTable:value("id") })
					while !oTableWheCond:EoF() .and. oTableWheCond:value("id_where") == oTable:value("id")
						// cria o array contendo os valores do filtro
						aValuesAux := 	{	{"id_where"		, nID}								, ;
						{"id_dim"  		, oTableWheCond:value("id_dim")}	, ;
						{"id_field"		, oTableWheCond:value("id_field")}	, ;
						{"seq"			, oTableWheCond:value("seq")}		, ;
						{"qbe"			, oTableWheCond:value("qbe")}		, ;
						{"last_value"	, oTableWheCond:value("last_value")}  ;
						}
						aAdd(aAux, aValuesAux)
						oTableWheCond:_Next()
					enddo
					
					for nInd := 1 to len(aAux)
						oTableWheCond:Append(aAux[nInd])
					next
					
					oTable:_Next()
				enddo
			endif
			
			if poTable:value("id_cube") <> 0
				oTabCalc := InitTable(TAB_FACTVIRTUAL)
				sincVirtualFlds(oTabCalc, poTable:value("id_cube"), poTable:value("id"))
			endif			
		endif
	endif
return

/*
-----------------------------------------------------------------------
Inicializa a seleção SEL_CONS_DIM (QW05200)
. Consultas cujo conteúdo foi afetado pela importação de dimensão
-----------------------------------------------------------------------
*/
static function QW05200() // SEL_CONS_DIM
	local oQuery := TQuery():New(SEL_CONS_DIM) // QW05200

	InitTable(TAB_DIMENSAO)
	InitTable(TAB_DIM_FIELDS)
	InitTable(TAB_CONS_DIM)
	InitTable(TAB_CONSULTAS)
	InitTable(TAB_CONSTYPE)

	oQuery:FromList(trataTableName(TAB_DIMENSAO) + " A," + trataTableName(TAB_DIM_FIELDS) + " B,"+ trataTableName(TAB_CONS_DIM) + " C," + trataTableName(TAB_CONSTYPE) + " D,"+trataTableName(TAB_CONSULTAS) + " E")
	oQuery:FieldList("E.ID, E.NOME, D.TIPO")
	oQuery:WhereClause("A.ID = [P1] and " + ;
						"A.ID = B.ID_DIM and B.ID = C.ID_DIM and " + ;
						"C.ID_CONS = D.ID and D.ID_CONS = E.ID")
	oQuery:OrderBy("E.ID")
	
return oQuery

/*
-----------------------------------------------------------------------
Inicializa a seleção SEL_QRY_INFO (QW05201)
-----------------------------------------------------------------------
*/
static function QW05201() // SEL_QRY_INFO
	local oQuery := TQuery():New(SEL_QRY_INFO) // QW05201

	InitTable(TAB_CONSULTAS)
	InitTable(TAB_CONSTYPE)
	oQuery:FieldList("ID, ID_CUBE, "+;
                   "case when (select count(ID) from " + trataTableName(TAB_CONSTYPE) + " B WHERE A.ID = B.ID_CONS AND B.TIPO = '1' AND B." + DWDelete() + " = ' ') = 0 then 'F' else 'T' end HAVETABLE, "+;
                   "case when (select count(ID) from " + trataTableName(TAB_CONSTYPE) + " B WHERE A.ID = B.ID_CONS AND B.TIPO = '2' AND B." + DWDelete() + " = ' ') = 0 then 'F' else 'T' end HAVEGRAPH")
	oQuery:FromList(trataTableName(TAB_CONSULTAS) + " A ")
	
return oQuery
/*
-----------------------------------------------------------------------
Inicializa a tabela Consultas x Tipo
-----------------------------------------------------------------------
*/
static function DW05205()
	local oTable := TTable():New(TAB_CONSTYPE)
	
	oTable:Descricao(STR0320)  //"Consultas (tabela/gráfico)"
	oTable:Events({ |oTable, nMoment, nOper, lCond, aValues| DW05205Ev(oTable, nMoment, nOper, lCond, aValues)})
	
	oTable:addFieldID()
	oTable:addField(nil, "id_cons", "N")
	oTable:addField(nil, "tipo", "C", 1)
	oTable:addField(nil, "classe", "C", 1)
	oTable:addField(nil, "props", "C", 255)
	oTable:addField(nil, "props_y", "C", 255)
	oTable:addField(nil, "props_y2", "C", 255)
	oTable:addField(nil, "consulta", "C", 20, 0, { || dwLookup(TAB_CONSTYPE, id_cons, "nome") }, nil) 

	oTable:AddIndex2(nil, { "id_cons", "tipo" } )

  oTable:addParent(TAB_CONSULTAS, "id_cons")

	createTable(oTable)
                           
return oTable

static function DW05205Ev(poTable, pnMoment, pnOper, plCond, paValues)

	local oTable
	
	if pnMoment == FE_BEFORE
		if pnOper == FE_DELETE

		   oTable := InitTable(TAB_CONS_PROP)
		   if oTable:Seek(2, { poTable:value("id") })
		      while !oTable:eof() .and. (poTable:value("id") == oTable:value("id_cons"))
		         oTable:Delete()
		         oTable:_Next()		  
		      end
		  endif

		  oTable := InitTable(TAB_CONS_IND)
		  if oTable:Seek(2, { poTable:value("id") })
		     while !oTable:eof() .and. (poTable:value("id") == oTable:value("id_cons"))
		        oTable:Delete()
		        oTable:_Next()		  
		     end
		  endif

		  oTable := InitTable(TAB_CONS_DIM)
		  if oTable:Seek(2, { poTable:value("id") })
		     while !oTable:eof() .and. (poTable:value("id") == oTable:value("id_cons"))
		        oTable:Delete()
		        oTable:_Next()		  
		     end
		  endif

 			oTable := InitTable(TAB_CONS_ALM)
			if oTable:Seek(2, { poTable:value("id") })
			   while !oTable:eof() .and. (poTable:value("id") == oTable:value("id_cons"))
				   oTable:Delete()
				   oTable:_Next()
			   end
			endif

 			oTable := InitTable(TAB_CONS_WHE)
			if oTable:Seek(2, { poTable:value("id") })
			   while !oTable:eof() .and. (poTable:value("id") == oTable:value("id_cons"))
				   oTable:Delete()
				   oTable:_Next()
			   end
			endif

		  oTable := InitTable(TAB_CONS_USR)
		  if oTable:Seek(2, { poTable:value("id") })
		     while !oTable:eof() .and. (poTable:value("id") == oTable:value("id_cons"))
		        oTable:Delete()
		        oTable:_Next()		  
		     end
		  endif

		endif
	endif
	
return

/*
-----------------------------------------------------------------------
Inicializa a tabela de propriedades da Consultas 
-----------------------------------------------------------------------
*/
static function DW05210()
	local oTable := TTable():New(TAB_CONS_PROP)
	
	oTable:Descricao(STR0321)  //"Propriedades da consulta (tabela/gráfico)"
	oTable:addFieldID()
	oTable:addField(nil, "id_cons", "N")
	oTable:addField(nil, "nome", "C", 8)
	oTable:addField(nil, "seq", "N", 3)
	oTable:addField(nil, "valor", "C", 195)

	oTable:AddIndex2(nil, { "id_cons", "nome", "seq"} )

	createTable(oTable)
                          
return oTable

static function DW05250()
	local oTable := TTable():New(TAB_CONSCRW)
	
	oTable:Descricao(STR0322)  //"Consulta x Crystal Report"
	oTable:Events({ |oTable, nMoment, nOper, lCond, aValues| DW05205Ev(oTable, nMoment, nOper, lCond, aValues)})
	
	oTable:addFieldID()
	oTable:addField(nil, "id_cons", "N")
	oTable:addField(nil, "nome", "C", 15)
	oTable:addField(nil, "descricao", "C", 60)
	oTable:addField(nil, "url", "C", 255)

	oTable:AddIndex2(nil, { "id_cons" , "nome" } )

	oTable:addParent(TAB_CONSTYPE, "id_cons") 

	createTable(oTable)
                           
return oTable

static function DW05255()
	local oTable := TTable():New(TAB_CRWPARAMS)
	
	oTable:Descricao(STR0323)  //"Consulta x Crystal Report (parametros)"
	oTable:Events({ |oTable, nMoment, nOper, lCond, aValues| DW05205Ev(oTable, nMoment, nOper, lCond, aValues)})
	
	oTable:addFieldID()
	oTable:addField(nil, "id_crw", "N")
	oTable:addField(nil, "ordem", "C", 2)
	oTable:addField(nil, "campo", "C", 12)

	oTable:AddIndex2(nil, { "id_crw" , "ordem" } )

	oTable:addParent(TAB_CONSCRW, "id_CRW")

	createTable(oTable)
                           
return oTable

/*
-----------------------------------------------------------------------
Inicializa a tabela de indicadores por Consultas 
-----------------------------------------------------------------------
*/
static function DW05260() // TAB_CONS_IND
	local oTable := TTable():New(TAB_CONS_IND)
	
	oTable:Descricao(STR0324)  //"Indicadores por Consulta"
	oTable:addFieldID()
	oTable:addField(nil, "id_cons", "N")
	oTable:addField(nil, "oper", "N", 2)
	oTable:addField(nil, "color", "C", 14)
	oTable:addField(nil, "id_ind", "N")
	oTable:addField(nil, "sh_ind", "C", 25)
	
	oTable:AddIndex2(nil, { "id_cons", "oper", "id_ind" } )
	oTable:AddIndex2(nil, { "id_ind", "oper", "id_cons" } )
	oTable:AddIndex2(nil, { "id_cons", "id" } )

	oTable:addParent(TAB_CONSTYPE, "id_cons")
	oTable:addParent(TAB_FACTFIELDS, "ID_IND", , "ID_IND > 0")

	createTable(oTable)
                           
return oTable

/*
-----------------------------------------------------------------------
Inicializa a tabela de dimensoes por Consultas 
-----------------------------------------------------------------------
*/
static function DW05270() // TAB_CONS_DIM
	local oTable := TTable():New(TAB_CONS_DIM)
	
	oTable:Descricao(STR0325)  //"Dimensões por Consulta"
	oTable:addFieldID()
	oTable:addField(nil, "id_cons", "N")
	oTable:addField(nil, "id_dim", "N")
	oTable:addField(nil, "temporal", "N")
	oTable:addField(nil, "drillgraph", "C", 2)	
	oTable:addField(nil, "eixo", "C", 1)
	oTable:addField(nil, "drilldown", "L")
	oTable:addField({ || .t. }, "subtotal", "L")	

	oTable:AddIndex2(nil, { "id_cons", "id_dim" } )
	oTable:AddIndex2(nil, { "id_dim", "id_cons" } )
	oTable:AddIndex2(nil, { "id_cons", "id" } )

	oTable:addParent(TAB_CONSTYPE, "id_cons")
	oTable:addParent(TAB_DIMENSAO, "id_DIM")

	createTable(oTable)
                           
return oTable

/*
-----------------------------------------------------------------------
Inicializa a tabela de filtros (where) por Consultas 
-----------------------------------------------------------------------
*/
static function DW05280() // TAB_CONS_WHE
	local oTable := TTable():New(TAB_CONS_WHE)
	
	oTable:Descricao(STR0326)  //"Filtros por Consulta"
	oTable:addFieldID()
	oTable:addField(nil, "id_cons", "N")
	oTable:addField(nil, "id_where", "N")

	oTable:AddIndex2(nil, { "id_cons", "id_where" } )
	oTable:AddIndex2(nil, { "id_where", "id_cons" } )

	oTable:addParent(TAB_CONSTYPE, "id_cons")
	oTable:addParent(TAB_WHERE, "id_WHERE")

	createTable(oTable)
                           
return oTable

/*
-----------------------------------------------------------------------
Inicializa a tabela de "prompts" para filtros obrigatótios por consultas
-----------------------------------------------------------------------
*/
static function DW05285() // TAB_CONS_USR
	local oTable := TTable():New(TAB_CONS_USR)
	
	oTable:Descricao(STR0327)  //"Aplicabilidade de filtros obrigatórios"
	oTable:addFieldID()
	oTable:addField(nil, "id_cons", "N")
	oTable:addField(nil, "id_user", "N")
	oTable:addField(nil, "prompt", "C", 30)
	oTable:addField(nil, "valor", "C", 255)

	oTable:AddIndex2(nil, { "id_cons", "id_user", "prompt" } )
	oTable:AddIndex2(nil, { "id_user", "id_cons", "prompt" } )

	oTable:addParent(TAB_CONSTYPE, "id_cons")
	oTable:addParent(TAB_USER, "id_USER")

	createTable(oTable)
                           
return oTable

/*
-----------------------------------------------------------------------
Inicializa a tabela de alertas por Consultas 
-----------------------------------------------------------------------
*/
static function DW05290() // TAB_CONS_ALM
	local oTable := TTable():New(TAB_CONS_ALM)
	
	oTable:Descricao(STR0328)  //"Alertas aplicados por Consultas"
	oTable:addFieldID()
	oTable:addField(nil, "id_cons", "N")
	oTable:addField(nil, "id_alert", "N")

	oTable:AddIndex2(nil, { "id_cons", "id_alert" } )
	oTable:AddIndex2(nil, { "id_alert", "id_cons" } )

	oTable:addParent(TAB_CONSTYPE, "id_cons")
	oTable:addParent(TAB_ALERT, "id_ALERT")

	createTable(oTable)
                           
return oTable

/*
-----------------------------------------------------------------------
Inicializa a tabela DWAlert
-----------------------------------------------------------------------
*/
static function DW05220()
	local oTable := TTable():New(TAB_ALERT)
	
	oTable:Descricao(STR0329)  //"Alertas por Consulta"
	oTable:Events({ |oTable, nMoment, nOper, lCond, aValues| DW05220Ev(oTable, nMoment, nOper, lCond, aValues)})

	oTable:addFieldID()
	oTable:addField(nil, "ID_CONS", "N")
	oTable:addField(nil, "tipo", "C", 1)
	oTable:addField(nil, "nome", "C", 12)
	oTable:addField(nil, "id_expr", "N") 
	oTable:addField(nil, "corTF", "C", 10)
	oTable:addField(nil, "corTB", "C", 10)
	oTable:addField(nil, "fonteT", "C", 1)
	oTable:addField(nil, "corFF", "C", 10)
	oTable:addField(nil, "corFB", "C", 10)
	oTable:addField(nil, "fonteF", "C", 1)
	oTable:addField(nil, "expressao", "C", 255, 0, { || DWLookup(TAB_EXPR, ID_EXPR, "linha")}, nil) 
	oTable:addField(nil, "msgT", "C", 255)
	oTable:addField(nil, "msgF", "C", 255)

	oTable:AddIndex2(nil, { "ID_CONS", "tipo", "nome" } )

	oTable:SetAttField("nome", STR0019) //"Nome"

	oTable:SetAttField("expressão", STR0082) //"Condição"
	oTable:SetAttField("msgT", STR0083) //"Mensagem (V)"
	oTable:SetAttField("msgF", STR0084) //"Mensagem (F)"
	oTable:SetAttField("corTF", STR0085) //"Cor Fonte (V)"
	oTable:SetAttField("corFF", STR0086) //"Cor Fonte (F)"
	oTable:SetAttField("corTB", STR0087) //"Cor Fundo (V)"
	oTable:SetAttField("corFB", STR0261) //"Cor Fundo (F)"
	oTable:SetAttField("fonteT", STR0088) //"Fonte (V)"
	oTable:SetAttField("fonteF", STR0089) //"Fonte (F)"
	
	oTable:SetVisible("ID_CONS", .F.)
	oTable:SetVisible("tipo", .F.)
	oTable:SetVisible("id_expr", .F.)
	                                      
	oTable:addParent(TAB_CONSULTAS, "id_cons")

	createTable(oTable)
                           
return oTable

static function DW05220Ev(poTable, pnMoment, pnOper, plCond, paValues)

	local oTable

	if pnMoment == FE_BEFORE
		if pnOper == FE_DELETE
 			
 			oTable := InitTable(TAB_EXPR)
			if oTable:Seek(2, { poTable:value("id_expr") })
			   while !oTable:eof() .and. (poTable:value("id_expr") == oTable:value("id"))
				   oTable:Delete()
				   oTable:_Next()
			   end
			endif
						
 			oTable := InitTable(TAB_CONS_ALM)
			if oTable:Seek(3, { poTable:value("id") })
			   while !oTable:eof() .and. (poTable:value("id") == oTable:value("id_alert"))
				   oTable:Delete()
				   oTable:_Next()
			   end
			endif

		endif
	endif

return

/*
-----------------------------------------------------------------------
Inicializa a tabela de campos calculados
-----------------------------------------------------------------------
*/
static function DW05230()
	local oTable := TTable():New(TAB_CALC)
	
	oTable:Descricao(STR0330)  //"Indicadores virtuais por Consulta"
	oTable:Events({ |oTable, nMoment, nOper, lCond, aValues| DW05230Ev(oTable, nMoment, nOper, lCond, aValues)})

	oTable:addFieldID()
	oTable:addField(nil, "ID_CONS", "N")
	oTable:addField(nil, "nome", "C", 10)
	oTable:addField(nil, "descricao", "C", 30)
	oTable:addField(nil, "tipo", "C", 1)
	oTable:addField(nil, "tam", "N", 4)
	oTable:addField(nil, "ndec", "N", 4)
	oTable:addField(nil, "mascara", "C", 30) 
	oTable:addField(nil, "id_expr", "N") 
	oTable:addField(nil, "expressao", "C", 255, 0, { || DWConcatWSep(CRLF, DWDetail(TAB_EXPR, ID_EXPR, "linha", "id", 1))}, nil) 
	oTable:addField(nil, "id_virtual", "N") 

	oTable:addField(nil, "isSQL", "L",,, { || DWLookup(TAB_EXPR, ID_EXPR, "isSQL")}, nil) 

	oTable:AddListVal("tipo", { { "N", STR0055},; //"Numérico"
										 { "C", STR0056},; //"Caracter"
										 { "D", STR0035},; //"Data"
										 { "L", STR0057},; //"Lógico"
										 { "M", STR0058} }) //"Memo"

	oTable:AddIndex2(nil, { "ID_CONS", "nome" }, .T. )
	oTable:AddIndex2(nil, { "ID_CONS", "id" } )
	oTable:AddIndex2(nil, { "ID_CONS", "id_expr"} )
	
	oTable:setAttField("descricao", STR0020) //"Descrição"
	oTable:setAttField("tam", STR0059) //"Tamanho"
	oTable:setAttField("ndec", STR0068) //"#Decimais"
	oTable:setAttField("mascara", STR0069)  //"Máscara"
	oTable:setAttField("expressao", STR0072) //"Expressão"

	oTable:SetVisible("ID_CONS", .F.)
	oTable:SetVisible("id_expr", .F.)
	oTable:SetVisible("id_virtual", .F.)

	oTable:addParent(TAB_CONSULTAS, "id_cons")
	oTable:addParent(TAB_FACTVIRTUAL, "id_virtual")
	
	createTable(oTable)

return oTable

static function DW05230Ev(poTable, pnMoment, pnOper, plCond, aValues)

	local oTable

	if pnMoment == FE_BEFORE
		if pnOper == FE_DELETE

 			oTable := InitTable(TAB_EXPR)
			if !(poTable:value("id_virtual") > 0) .and. oTable:Seek(2, { poTable:value("id_expr") })
			   while !oTable:eof() .and. (poTable:value("id_expr") == oTable:value("id"))
				   oTable:Delete()
				   oTable:_Next()
			   end
			endif
			
		endif
	endif

return

/*
-----------------------------------------------------------------------
	Inicializa a tabela TAB_EXPR (DW05240)
-----------------------------------------------------------------------
*/
static function DW05240() // TAB_EXPR
	local oTable := TTable():New(TAB_EXPR)
	
	oTable:Descricao(STR0331)  //"Expressões"
	oTable:addFieldID()
	oTable:addField(nil, "seq", "N")
	oTable:addField(nil, "issql", "L")
	oTable:addField(nil, "linha", "C", 255)

	oTable:AddIndex2(nil, { "id", "seq" } )

	createTable(oTable)
                           
return oTable

/*
-----------------------------------------------------------------------
Inicializa a tabela de TAB_WHERE (DW05300)
-----------------------------------------------------------------------
*/
static function DW05300() // TAB_WHERE
	local oTable := TTable():New(TAB_WHERE)
	
	oTable:Descricao(STR0326)  //"Filtros por Consulta"
	oTable:Events({ |oTable, nMoment, nOper, lCond, aValues| DW05300Ev(oTable, nMoment, nOper, lCond, aValues)})

	oTable:addFieldID()
	oTable:addField(nil, "id_cons", "N")
	oTable:addField(nil, "nome", "C", 15)
	oTable:addField(nil, "descricao", "C", 60)
	oTable:addField(nil, "id_expr", "N") 
	oTable:addField(nil, "expressao", "C", 255, 0, { || DWConcatWSep(CRLF, DWDetail(TAB_EXPR, ID_EXPR, "linha", "id", 1))}, nil) 
	oTable:addField(nil, "issql", "L", 1, 0, { || DWLookup(TAB_EXPR, ID_EXPR, "issql")}, nil) 
	oTable:addField(nil, "tipo", "C", 1)
	oTable:addField(nil, "virtual", "L")
	oTable:addField(nil, "id_virtual", "N")

	oTable:AddIndex2(nil, { "id_cons", "tipo", "nome" } )
	oTable:AddIndex2(nil, { "id_virtual" } )

	oTable:setAttField("nome", STR0264)  //"Nome"
	oTable:setAttField("descricao", STR0020) //"Descrição"
	oTable:setAttField("expressao", STR0219) //"Expressão"
	oTable:setAttField("virtual", STR0332)   //"Filtro do cubo"
	
	oTable:SetVisible("id_cons", .F.)
	oTable:SetVisible("id_expr", .F.)
	oTable:SetVisible("tipo", .F.)
	oTable:SetVisible("id_virtual", .F.)
	
	oTable:addParent(TAB_CONSULTAS, "id_cons")

	createTable(oTable)
                           
return oTable

static function DW05300Ev(poTable, pnMoment, pnOper, plCond, aValues)

	if pnMoment == FE_BEFORE
		if pnOper == FE_DELETE

		  oTable := InitTable(TAB_EXPR)
		  if oTable:Seek(2, { poTable:value("id_expr") })
		     while !oTable:eof() .and. (poTable:value("id_expr") == oTable:value("id"))
		        oTable:Delete()
		        oTable:_Next()		  
		     end
		  endif
		  
		  oTable := InitTable(TAB_WHERE_COND)
		  if oTable:Seek(2, { poTable:value("id") })
		     while !oTable:eof() .and. (poTable:value("id") == oTable:value("id_where"))
		        oTable:Delete()
		        oTable:_Next()		  
		     end
		  endif

 			oTable := InitTable(TAB_CONS_WHE)
			if oTable:Seek(2, { poTable:value("id") })
			   while !oTable:eof() .and. (poTable:value("id") == oTable:value("id_where"))
				   oTable:Delete()
				   oTable:_Next()
			   end
			endif

		endif
	endif
	
return

/*
-----------------------------------------------------------------------
Inicializa a tabela de TAB_WHERE_COND (DW05310)
-----------------------------------------------------------------------
*/
static function DW05310() // TAB_WHERE_COND
	local oTable := TTable():New(TAB_WHERE_COND)
	
	oTable:Descricao(STR0333)  //"Parâmetros dos Filtros por Consulta"
	oTable:addFieldID()
	oTable:addField(nil, "id_where", "N")
	oTable:addField(nil, "id_dim", "N")
	oTable:addField(nil, "id_field", "N")
	oTable:addField(nil, "seq", "N")
	oTable:addField(nil, "qbe", "C", If(TcGetDB() == "INFORMIX", 255, 1000)) 
	oTable:addField(nil, "last_value", "C", 255) 
	oTable:addField(nil, "dimName", "C", 15, 0, { || iif(id_dim==0, "", DWLookup(TAB_DIMENSAO, id_dim, "nome")) }, nil)
	oTable:addField(nil, "fieldName", "C", 15, 0, { || iif(id_dim==0, "", DWLookup(TAB_DIM_FIELDS, { id_dim, id_field}, "nome", 3)) }, nil)
	oTable:addField(nil, "indName", "C", 15, 0, { || iif(id_dim!=0, "", DWLookup(TAB_FACTFIELDS, { id_field }, "nome", 1)) }, nil)

	oTable:AddIndex2(nil, { "id_where", "id_dim", "id_field" } )
	oTable:AddIndex2(nil, { "id_where", "id_dim", "seq" } )
	oTable:AddIndex2(nil, { "id_dim", "seq" } )
	oTable:AddIndex2(nil, { "id_where", "id_dim", "id_field", "seq" } )
	
	oTable:SetVisible("id_where", .F.)
	oTable:SetVisible("id_dim", .F.)
	oTable:SetVisible("id_field", .F.)
	oTable:SetVisible("seq", .F.)
	oTable:SetVisible("qbe", .F.) 
	oTable:SetVisible("last_value", .F.) 
	
	oTable:addParent(TAB_WHERE, "id_where")
	oTable:addParent(TAB_DIMENSAO, "id_dim", "ID_DIM <> 0 AND QBE <> ''")
	oTable:addParent(TAB_DIM_FIELDS, "id_field", "ID_DIM <> 0 AND QBE <> ''")
	oTable:addParent(TAB_FACTFIELDS, "id_field", "ID_DIM = 0 AND QBE <> ''")

	createTable(oTable)
                           
return oTable

/*
-----------------------------------------------------------------------
Inicializa a tabela TAB_DIMENSAO
-----------------------------------------------------------------------
*/
static function DW06000()
	local oTable := TTable():New(TAB_DIMENSAO)
	            
	oTable:Descricao(STR0334)  //"Dimensões"
	oTable:Events({ |oTable, nMoment, nOper, lCond, aValues| DW06000Ev(oTable, nMoment, nOper, lCond, aValues)})

	oTable:addFieldID()
	oTable:addFieldDW()
	oTable:addField(nil, "nome", "C", 15)
	oTable:addField(nil, "descricao", "C", 40)
	oTable:addField({ || date() }, "dt_create", "D")
	oTable:addField({ || time() }, "hr_create", "C", 8)
	oTable:addField(nil, "dt_process", "D")
	oTable:addField(nil, "hr_process", "C", 8)
	oTable:addField({ || .f. }, "importado", "L")
	oTable:addField({ || .f. }, "notificar", "L")
	oTable:addField({ || .f. }, "autoupd", "L")
	oTable:addField(nil, "id_docto", "N")
	oTable:addField(nil, "docto", "C", 0, 0, { || DWConcatWSep(CRLF, DWDetail(TAB_EXPR, id_docto, "linha", "id", 1))}, nil) 
	oTable:addField(nil, "impCon", "N")	

	oTable:AddIndex2(nil, { "nome" }, .t. )

	oTable:SetVisible("id", .f.)
	oTable:setVisible("importado", .f.)
	oTable:setVisible("id_docto", .f.)
	oTable:setVisible("docto", .f.)
	oTable:setVisible("impCon", .f.)

	oTable:setAttField("dimensao", STR0063) //"Dimensão"
	oTable:setAttField("descricao", STR0020) //"Descrição"
	oTable:SetAttField("dt_create" , STR0051) //"Data Criação"
	oTable:SetAttField("hr_create" , STR0052) //"Hora Criação"
	oTable:SetAttField("dt_process", STR0053) //"Data Proc."
	oTable:SetAttField("hr_process", STR0054) //"Hora Proc."
	oTable:SetAttField("notificar", STR0090) //"Notificar"
	oTable:SetAttField("autoupd", STR0091) //"Atz.Automática"

	createTable(oTable)
                           
return oTable

static function DW06000Ev(poTable, pnMoment, pnOper, plCond, paValues)

	local oTable

	if pnMoment == FE_BEFORE
		if pnOper == FE_DELETE

			oTable := InitTable(TAB_DIM_FIELDS)
			if oTable:Seek(2, { poTable:value("id") })
			   while !oTable:eof() .and. (poTable:value("id") == oTable:value("id_dim"))
			      oTable:Delete()
			      oTable:_Next()
			   end
			endif

			oTable := InitTable(TAB_DIM_CUBES)
			if oTable:Seek(3, { poTable:value("id") })
			   while !oTable:eof() .and. (poTable:value("id") == oTable:value("id_dim"))
			      oTable:Delete()
			      oTable:_Next()
			   end
			endif

			oTable := InitTable(TAB_DSN)
			if oTable:Seek(2, { "D", poTable:value("id") })
			   while !oTable:eof() .and. ( (oTable:value("tipo") == "D") .and. (poTable:value("id") == oTable:value("id_table")) )
			      oTable:Delete()
			      oTable:_Next()
			   end
			endif

		endif
	endif

return

/*
-----------------------------------------------------------------------
Inicializa a seleção SEL_DIM_INFO (QW06001)
. Informações sobre dimensões
-----------------------------------------------------------------------
*/
static function QW06001() // SEL_DIM_INFO
	local oQuery := TQuery():New(SEL_DIM_INFO)
	local oAux   

	oAux := InitTable(TAB_DIMENSAO)
	oAux := InitTable(TAB_DIM_FIELDS)
           
	oQuery:AddField(nil, "id", "N", 10)
	oQuery:AddField(nil, "keyatt", "N", 10)
	oQuery:AddField(nil, "att", "N", 10)
	
  oQuery:SQL(, "select A.ID, count(*) as KEYATT, 0 as ATT from " +;
                        trataTablename(TAB_DIMENSAO) + "  A, " + trataTablename(TAB_DIM_FIELDS) + " B " +;
                        "where A.ID = B.ID_DIM " +;
                        "and B.KEYSEQ <> 0 " +;
                        "group by A.ID " +;
                    "union select A.ID, 0 AS KEYATT, count(*) as ATT from " +;
                        trataTablename(TAB_DIMENSAO) + "  A, " + trataTablename(TAB_DIM_FIELDS) + " B " +;
                        "where A.ID = B.ID_DIM " +;
                        "and B.KEYSEQ = 0 " +;
                 "group by A.ID")

return oQuery

/*
-----------------------------------------------------------------------
Inicializa a tabela TAB_DIM_FIELDS (DW06100)
-----------------------------------------------------------------------
*/
static function DW06100()
	local oTable := TTable():New(TAB_DIM_FIELDS) //DW06100
	
	oTable:Descricao(STR0335)  //"Atributos das Dimensões"
	oTable:Events({ |oTable, nMoment, nOper, lCond, aValues| DW06100Ev(oTable, nMoment, nOper, lCond, aValues)})

	oTable:addFieldID()
	oTable:addField(nil, "keyseq", "N", 3)
	oTable:addField(nil, "ID_DIM", "N")
	oTable:addField(nil, "nome", "C", 30)
	oTable:addField(nil, "descricao", "C", 30)
	oTable:addField(nil, "visible", "L", 1)
	oTable:addField(nil, "tipo", "C", 1)
	oTable:addField(nil, "tam", "N", 4)
	oTable:addField(nil, "ndec", "N", 4)
	oTable:addField(nil, "mascara", "C", 30)

	oTable:AddListVal("tipo", { { "N", STR0055},; //"Numérico"
								 { "C", STR0056},; //"Caracter"
								 { "D", STR0035},; //"Data"
								 { "L", STR0057},; //"Lógico"
								 { "M", STR0058} }) //"Memo"

	oTable:AddIndex2(nil, { "ID_DIM", "nome" }, .T. )
	oTable:AddIndex2(nil, { "ID_DIM", "id" } )
	oTable:AddIndex2(nil, { "ID_DIM", "keyseq" } )
	oTable:AddIndex2(nil, { "nome" } )
	oTable:AddIndex2(nil, { "ID_DIM", "descricao"} )

	oTable:SetVisible("id_dim", .f.)
	oTable:SetAttField("descricao", STR0020) //"Descrição"
	oTable:SetAttField("tam", STR0059, dwMask("999")) //"Tamanho"
	oTable:SetAttField("ndec", STR0068, dwMask("999")) //"#Decimais"
	oTable:SetAttField("dimensao", STR0063) //"Dimensão"
	oTable:SetAttField("mascara", STR0069) //"Máscara"
	oTable:SetAttField("keyseq", STR0093, dwMask("999")) //"#Chave"
	oTable:SetAttField("visible", STR0250)  //"Visível"

	oTable:addParent(TAB_DIMENSAO, "id_dim")

	createTable(oTable)
                           
return oTable

static function DW06100Ev(poTable, pnMoment, pnOper, plCond, paValues)
	local aTasks := {}, aFields := {}
	local owf, nPos
	local oTable, oTableAux 

	if pnMoment == FE_DURING 
	
		if pnOper == FE_VALIDATE
		
			if (nPos := ascan(paValues, { |x| upper(x[1]) == "TIPO" } )) != 0 
			    /*Verifica se o campo é DATA ou CARACTER*/
				If ( paValues[nPos, 2] == "D" ) .OR. ( paValues[nPos, 2] == "C" )
					/*Para campo DATA*/
					If ( paValues[nPos, 2] == "D" )
					    /*Define o tamanho como OITO*/
						If (nPos := ascan(paValues, { |x| upper(x[1]) == "TAM" } )) != 0
							paValues[nPos, 2] := 8
						Endif					
					EndIf					
					/*Inclui no array os valores que não são enviados no POST [disabled = true]*/				        
					aAdd(paValues, {"NDEC", 0}) 
				EndIf
			endif
		endif		
	endif		

	if pnMoment == FE_BEFORE
		if pnOper == FE_DELETE
			oTable := InitTable(TAB_DSNCONF)
			if oTable:Seek(3, { poTable:value("id") })
				while !oTable:eof() .and. poTable:value("id") == oTable:value("id_field")
					oTable:Delete()
				    oTable:_Next()
				end
			endif
			oTable := InitTable(TAB_WHERE_COND)
			if oTable:Seek(4, { poTable:value("id_dim"), poTable:value("id") })
				while !oTable:eof() .and. ( (poTable:value("id_dim") == oTable:value("id_dim")) .and. (poTable:value("id") == oTable:value("id_field")) )
					oTable:Delete()
					oTable:_Next()
				end
			endif
		endif
	endif

return

/*
-----------------------------------------------------------------------
Inicializa a tabela TAB_DIM_CUBES (DW06200)
-----------------------------------------------------------------------
*/
static function DW06200()
	local oTable := TTable():New(TAB_DIM_CUBES) // DW06200

	oTable:Descricao(STR0336)  //"Dimensões associadas a Cubos"
	oTable:Events({ |oTable, nMoment, nOper, lCond, aValues| DW06200Ev(oTable, nMoment, nOper, lCond, aValues)})
	
	oTable:addFieldID()
	oTable:addField(nil, "id_cube", "N")
	oTable:addField(nil, "id_dim", "N")
	oTable:addField(nil, "seq", "N")

	oTable:AddIndex2(nil, { "id_cube", "id_dim" } )
	oTable:AddIndex2(nil, { "id_dim", "id_cube" } )
	oTable:AddIndex2(nil, { "id_cube", "seq" } )

	oTable:addParent(TAB_DIMENSAO, "id_dim")
	oTable:addParent(TAB_CUBESLIST, "id_CUBE")

	createTable(oTable)
	                           
return oTable

static function DW06200Ev(poTable, pnMoment, pnOper, plCond, paValues)
	local oTable

	if pnMoment == FE_BEFORE
		if pnOper == FE_DELETE
			oTable := InitTable(TAB_FACTFIELDS)
 			if oTable:Seek(4, { poTable:value("id_cube"), poTable:value("id_dim") })
				while !oTable:eof() .and. poTable:value("id_cube") == oTable:value("id_cubes") .and. poTable:value("id_dim") == oTable:value("dimensao")
					oTable:Delete()
				    oTable:_Next()
				end
			endif
		endif
	endif

return

/*
-----------------------------------------------------------------------
Inicializa a seleção SEL_DIM_CUBES (SW06200)
-----------------------------------------------------------------------
*/
static function QW06200()
	local oQuery := TQuery():New(SEL_DIM_CUBES) // QW06200
	
	oQuery:AddField(nil, "id_cube", "N")
	oQuery:AddField(nil, "id_dim", "N")
	oQuery:AddField(nil, "nome", "C", 10)
	oQuery:AddField(nil, "descricao", "C", 30)
	oQuery:FieldList("ID_CUBE, ID_DIM, NOME, DESCRICAO")
	oQuery:FromList(trataTableName(TAB_DIMENSAO) + " A, " + trataTableName(TAB_DIM_CUBES) + " B")
	oQuery:WhereClause("A.ID = B.ID_DIM AND ID_CUBE = [P1]")
	oQuery:OrderBy("NOME")
	                           
return oQuery

/*
-----------------------------------------------------------------------
Inicializa a tabela TAB_USER (DW07000)
-----------------------------------------------------------------------
*/
static function DW07000()
	local oTable := TTable():New(TAB_USER)
	local aUsrPad := {;       
				 { "GRP_ADM", DWCripto(pswencript("_ADM_"), PASSWORD_SIZE, 0), STR0094, "G", 0, "", "", "", 0, .F., .T., .F., 0 }, ; //"Grupo Administrador"
				 { "GRP_USR", DWCripto(pswencript("_USR_"), PASSWORD_SIZE, 0), STR0095, "G", 0, "", "", "", 0, .F., .T., .F., 0 }, ; //"Grupo Usuários"
				 { "DWADMIN", DWCripto(pswencript("A"), PASSWORD_SIZE, 0)    , STR0097, "U", 1, "", "", "", 0, .T., .T., .F., 0 }  ; //"Administrador SigaDW"
			 }

	oTable:Descricao(STR0337)  //"Usuários"
	oTable:Events({ |oTable, nMoment, nOper, lCond, aValues| DW07000Ev(oTable, nMoment, nOper, lCond, aValues)})

	oTable:addFieldID()                   
	oTable:addField(nil, "login", "C", 25)
	oTable:addField(nil, "senha", "C", PASSWORD_SIZE * 2) //senha é gravada em hexa
	oTable:addField(nil, "nome", "C", 30)
	oTable:addField("U", "tipo", "C", 1)
	oTable:addField(nil, "id_grupo", "N")
	oTable:addField(nil, "email", "C", 60)
	oTable:addField(nil, "cargo", "C", 30)
	oTable:addField(nil, "admin", "L")
	oTable:addField(nil, "ativo", "L")
	oTable:addField(nil, "us_siga", "L")
	oTable:addField(nil, "grupo", "C", 10, 0, { || DWLookup(TAB_USER, id_grupo, "login") }, nil)
 	oTable:addField(nil, "id_cpPriv", "N")
	oTable:addField(nil, "copia", "C", 10, 0, {|| DWLookup(TAB_USER, id_cpPriv, "login")}, nil)
 	oTable:addField(nil, "lastdw", "N")
 	oTable:addField(nil, "lastMenu", "C", 60)
 	oTable:addField(nil, "lastAba", "C", 60)
 	oTable:addField(nil, "lastSubAba", "C", 60)
 	oTable:addField(nil, "lastNotify", "C", 20)
 	oTable:addField({ ||.T.}, "folderMenu", "L")
 	oTable:addField({ || ENABLE_PAGING_DEFAULT }, "paging", "C", 1)
	oTable:addField({ || "0"}, "usePanel", "C", 1)
	oTable:addField({ || "0"}, "shPageNav", "C", 1)
	oTable:addField(nil, "impSiga", "L", 1)
	oTable:addField(nil, "recLimit", "N", 18)
 	oTable:addField(nil, "impSigUser", "C", 25)
	
	oTable:setVisible("tipo", .f.)
	oTable:setVisible("id_grupo", .f.)
	oTable:setVisible("senha", .f.)
	oTable:setVisible("lastdw", .f.)
	oTable:setVisible("lastMenu", .f.)
	oTable:setVisible("lastAba", .f.)
	oTable:setVisible("lastSubAba", .f.)
	oTable:setVisible("folderMenu", .f.)
	oTable:setVisible("id_cpPriv", .f.)
	oTable:setVisible("paging", .f.)
	oTable:setVisible("usePanel", .f.)
	oTable:setVisible("shPageNav", .f.)
	oTable:setVisible("lastNotify", .f.)
	oTable:setVisible("impSigUser", .f.)
	oTable:setVisible("recLimit", .f.)
	
	oTable:AddIndex2(nil, { "tipo", "login" } )
	oTable:AddIndex2(nil, { "login" }, .t. )
	oTable:AddIndex2(nil, { "id_grupo" } )
	oTable:AddIndex2(nil, { "tipo", "impSigUser" } )

	oTable:AddListVal("tipo", { { "U", STR0098}, { "G", STR0099} } ) //"Usuário"###"Grupo"

	oTable:addParent(TAB_USER, "ID_GRUPO", "ID_GRUPO = 0", "ID_GRUPO <> 0")
	
	oTable:SetAttField("login", STR0263) //"Login"
	oTable:SetAttField("nome", STR0264) //"Nome"
	oTable:SetAttField("email", STR0265) //"Email"
	oTable:SetAttField("cargo", STR0266) //"Cargo"
	oTable:SetAttField("admin", STR0267) //"Administrador"
	oTable:SetAttField("ativo", STR0268) //"Ativo"
	oTable:SetAttField("us_siga", STR0269) //"Usuário Siga"
	oTable:SetAttField("impSiga", STR0270) //"Importado"
	
	if createTable(oTable)
		oTable:Open()
		aeval(aUsrPad, { |x|, oTable:Append( ;
								{ ;
									{ "login"   , x[1] }, ;
									{ "senha"   , x[2] }, ;
									{ "nome"    , x[3] }, ;
									{ "tipo"    , x[4] }, ;
									{ "id_grupo", x[5] }, ;
									{ "email"   , x[6] }, ;
									{ "cargo"   , x[8] }, ;
									{ "admin"   , x[10] }, ;
									{ "ativo"   , x[11] }, ;
									{ "us_siga" , x[12] }  ;
								} ) ;
							} )
		oTable:Close()                   
	endif
	                           
return oTable

static function DW07000Ev(poTable, pnMoment, pnOper, plCond, paValues)

	local nIdGrupo

	if pnMoment == FE_BEFORE
		if pnOper == FE_DELETE
			if (poTable:value("tipo") == "G")
				nIdGrupo := poTable:value("id")
				poTable:GoTop()
				while !poTable:eof()                                                                
					// força a troca do grupo para o grupo de usuário padrão. 
					if (poTable:value("tipo") == "U") .and. (poTable:value("id_grupo") == nIdGrupo)
						poTable:Update({{"ID_GRUPO",2}})
					endif
					poTable:_Next()
				end
				if poTable:seek(1, { nIdGrupo } )
				   DW07000Exec(poTable, pnMoment, pnOper, plCond)				
				endif
			elseif (poTable:value("tipo") == "U")
				DW07000Exec(poTable, pnMoment, pnOper, plCond)
			endif
		endif
	endif
return
			
static function DW07000Exec(poTable, pnMoment, pnOper, plCond)
	local oTable, oTableMsg
	local lDelMsg 	:= .T.
	local aMsgsUser := {}
	local nInd
	
    // privilégios/acesso do usuário
    oTable := InitTable(TAB_USER_PRIV)
    if oTable:Seek(3, { poTable:value("id") })
		while !oTable:eof() .and. (poTable:value("id") == oTable:value("id_user"))
			oTable:Delete()
			oTable:_Next()
		end
	endif
	
	oTable := InitTable(TAB_USER_RES)
	if oTable:Seek(2, { poTable:value("id") })
		while !oTable:eof() .and. (poTable:value("id") == oTable:value("id_user"))
			oTable:Delete()
			oTable:_Next()
		end
	endif
	
	oTable := InitTable(TAB_USER_DSKTOP)
	if oTable:Seek(2, { poTable:value("id") })
		while !oTable:eof() .and. (poTable:value("id") == oTable:value("id_user"))
			oTable:Delete()
			oTable:_Next()
		end
	endif
	
	oTable := InitTable(TAB_CONS_USR)
	if oTable:Seek(3, { poTable:value("id") })
		while !oTable:eof() .and. (poTable:value("id") == oTable:value("id_user"))
			oTable:Delete()
			oTable:_Next()
		end
	endif
	
	// exclui as mensagens do usuário
	oTable := InitTable(TAB_MSG_USER)
	if oTable:Seek(3, { poTable:value("id") })
		while !oTable:Eof() .and. oTable:value("ID_USER") == poTable:value("id")
			oTable:Delete()
			aAdd(aMsgsUser, oTable:value("ID_MSG"))
			oTable:_Next()
		enddo
		
		// verifica se a mensagem está associada à algun outro usuário
		// caso não esteja, exclui a mensagem
		for nInd := 1 to len(aMsgsUser)
			oTable:GoTop()
			oTable:Seek(2, { aMsgsUser[nInd] })
			if !oTable:EoF() .and. oTable:value("ID_MSG") == aMsgsUser[nInd]
				lDelMsg := .F.
			endif
			
			if lDelMsg
				oTableMsg := InitTable(TAB_MSG)
				oTableMsg:Seek(1, { aMsgsUser[nInd] })
				if !oTableMsg:EoF() .and. oTableMsg:value("id") == aMsgsUser[nInd]
					oTableMsg:Delete()
				endif
			endif
			lDelMsg := .T.
		next		
		
	endif

return

/*
-----------------------------------------------------------------------
Inicializa a seleção SEL_USER (QW07000)
-----------------------------------------------------------------------
*/
static function QW07000(nTipo) // SEL_USER
	local oQuery := TQuery():New(SEL_USER) // QW07000
	local aRet := {}

	if !__DWInitDB
		oQuery:addFieldID()
		oQuery:AddField(nil, "nome", "C", 10)
   	
		oQuery:FieldList("ID, NOME")
		oQuery:FromList(TAB_USER)
		oQuery:WhereClause("TIPO = 'G'")
		oQuery:OrderBy("NOME")
		oQuery:Open()
	
		while !oQuery:eof()
			if nTipo == 1
				aAdd(aRet, oQuery:value("nome"))
			else
				aAdd(aRet, oQuery:value("id"))
			endif

			oQuery:_Next()
		enddo
	
		oQuery:Close()
	endif

return aRet

/*
-----------------------------------------------------------------------
Inicializa a tabela TAB_USER_DW (DW07100)
-----------------------------------------------------------------------
*/
static function DW07100()
	local oTable := TTable():New(TAB_USER_DW)
	
	oTable:Descricao(STR0338)  //"Usuários por DW"
	oTable:addField(nil, "id", "N")
	oTable:addField(nil, "ID_USER", "N", 10)
	oTable:addField(nil, "DW", "C", 12)
	oTable:addField(nil, "STATUS", "L")

	oTable:AddIndex2(nil, { "id" } )
	oTable:AddIndex2(nil, { "ID_USER", "DW" } )
	oTable:AddIndex2(nil, { "DW", "ID_USER" } )
	
	oTable:addParent(TAB_USER, "ID_USER")

	createTable(oTable)
                           
return oTable

/*
-----------------------------------------------------------------------
Inicializa a tabela TAB_USER_CONS (DW07110)
-----------------------------------------------------------------------
*/
static function DW07110()
	local oTable := TTable():New(TAB_USER_CONS)
	
	oTable:Descricao(STR0339)  //"Usuários por Consultas"
	oTable:addField(nil, "id", "N")
	oTable:addField(nil, "ID_USER", "N", 10)
	oTable:addField(nil, "ID_CONS", "N", 10)
	oTable:addField(nil, "MANUT", "L", 1)
	oTable:addField(nil, "CONS", "L", 1)
	oTable:addField(nil, "EXPORT", "L", 1)

	oTable:AddIndex2(nil, { "id" } )
	oTable:AddIndex2(nil, { "ID_USER", "ID_CONS" } )
	oTable:AddIndex2(nil, { "ID_CONS" } )

	oTable:addParent(TAB_USER, "ID_USER")
	oTable:addParent(TAB_CONSULTAS, "ID_CONS")

	createTable(oTable)
                           
return oTable

/*
-----------------------------------------------------------------------
Inicializa a tabela TAB_USER_CUB (DW07120)
-----------------------------------------------------------------------
*/
static function DW07120()
	local oTable := TTable():New(TAB_USER_CUB)
	
	oTable:Descricao(STR0340)  //"Usuários por Cubos"
	oTable:addField(nil, "id", "N")
	oTable:addField(nil, "ID_USER", "N", 10)
	oTable:addField(nil, "ID_CUBE", "N", 10)
	oTable:addField(nil, "MANUT", "L", 1)
	oTable:addField(nil, "CONS", "L", 1)

	oTable:AddIndex2(nil, { "id" } )
	oTable:AddIndex2(nil, { "ID_USER", "ID_CUBE" } )
	oTable:AddIndex2(nil, { "ID_CUBE" } )

	oTable:addParent(TAB_USER, "ID_USER")
	oTable:addParent(TAB_CUBESLIST, "ID_CUBE")

	createTable(oTable)
                           
return oTable

/*
-----------------------------------------------------------------------
Inicializa a tabela TAB_USER_RES (DW07130)
-----------------------------------------------------------------------
*/
static function DW07130()
	local oTable := TTable():New(TAB_USER_RES)
	
	oTable:Descricao(STR0341)  //"Usuários (recursos)"
	oTable:addFieldID()
	oTable:addField(nil, "ID_USER", "N", 10)
	oTable:addField(nil, "Menu", "C", 20)
	oTable:addField(nil, "MANUT", "L", 1)
	oTable:addField(nil, "CONS", "L", 1)

	oTable:AddIndex2(nil, { "id_user", "menu" } )

	oTable:addParent(TAB_USER, "ID_USER")

	createTable(oTable)
                           
return oTable

/*
-----------------------------------------------------------------------
Inicializa a tabela TAB_USER_LOG (DW07200)
-----------------------------------------------------------------------
*/
static function DW07200()
	local oTable := TTable():New(TAB_USER_LOG)
	
	oTable:Descricao(STR0342)  //"Log por usuários"
	oTable:addFieldID()
	oTable:addField({ || date() }, "dt", "D")
	oTable:addField({ || time() }, "hr", "C", 8)
	oTable:addField(nil, "TIPO", "C", 1)
	oTable:addField(nil, "mensagem", "C", 80)

	oTable:AddIndex2(nil, { "dt", "hr" } )
                          
	createTable(oTable)
                           
return oTable

/*
-----------------------------------------------------------------------
Inicializa a tabela TAB_USER_DSKTOP (DW07210)
-----------------------------------------------------------------------
*/
static function DW07210()
	local oTable := TTable():New(TAB_USER_DSKTOP)

	oTable:Descricao(STR0343)  //"Desktop por Usuário"
	oTable:addFieldID()
	oTable:addField(nil, "id_user", "N")
	oTable:addField(nil, "id_parnt", "N")
	oTable:addField(nil, "id_no", "N")
	oTable:addField(nil, "DW", "C", 30)
	oTable:addField(nil, "name", "C", 100)
	oTable:addField(nil, "descricao", "C", 60, 0, { || DWLookup(TAB_CONSULTAS, id_no, "descricao") }, nil)

	if SGDB() == DB_POSTGRES
		oTable:addField(nil, "tipo", "N")
	else
		oTable:addField(nil, "type", "N")
	endif
	oTable:addField(nil, "tipo_cons", "C", 1)

	if SGDB() == DB_POSTGRES
		oTable:AddIndex2(nil, { "id_user", "id_parnt", "id_no", "tipo"} )
		oTable:AddIndex2(nil, { "tipo", "id_no", "tipo_cons"} )
		oTable:AddIndex2(nil, { "id_user", "DW"} )
		oTable:AddIndex2(nil, { "id_user", "id_parnt", "tipo", "name", "dw" } )
	else
		oTable:AddIndex2(nil, { "id_user", "id_parnt", "id_no", "type"} )
		oTable:AddIndex2(nil, { "type", "id_no", "tipo_cons"} )
		oTable:AddIndex2(nil, { "id_user", "DW"} )
		oTable:AddIndex2(nil, { "id_user", "id_parnt", "type", "name", "dw" } )
	endif
	oTable:AddIndex2(nil, { "id_user", "id_no", "tipo_cons", "dw" } )
	oTable:AddIndex2(nil, { "id_no", "tipo_cons", "dw" } ) 
	oTable:AddIndex2(nil, { "id_user", "id_parnt", "id_no", "type", "dw" } )
	
	oTable:addParent(TAB_USER, "ID_USER")
	oTable:addParent(TAB_CONSULTAS, "id_no")

	createTable(oTable)
                           
return oTable

/*
-----------------------------------------------------------------------
Inicializa a tabela TAB_USER_PRIV (DW07400)
-----------------------------------------------------------------------
*/
static function DW07400()
	local oTable := TTable():New(TAB_USER_PRIV)
	
	oTable:Descricao(STR0344)  //"Privilégios por Usuário"
	oTable:Events({ |oTable, nMoment, nOper, lCond, aValues| DW07400Ev(oTable, nMoment, nOper, lCond, aValues)})
	oTable:addFieldID()
	oTable:addFieldDW()								// id do dw
	oTable:addField(nil, "ID_USER", "N", 10)		// id do usuário
	oTable:addField(nil, "ID_OBJ", "N", 10) 		// id do objeto a ser verificado o privilégio
	oTable:addField(nil, "type_obj", "C", 2)		// tipo de objeto de acesso (ver defines - PRIV_OBJ_XXXX)
	oTable:addField(nil, "type_oper", "C", 1)		// tipo de operação de acesso (ver defines - PRIV_OPER_XXXX)
	oTable:addField(nil, "type_auth", "C", 1)		// tipo de autorização (ver defines - PRIV_AUTH_XXXX)
	
	oTable:AddIndex2(nil, { "id_user", "id_obj", "type_obj", "type_oper" } )
	oTable:AddIndex2(nil, { "id_user", "type_obj", "type_oper" } )
	oTable:AddIndex2(nil, { "type_obj", "id_obj" } )
 	
	oTable:addParent(TAB_USER, "ID_USER")
	oTable:addParent(TAB_CONSULTAS, "ID_OBJ", ,"TYPE_OBJ = '"+PRIV_OBJ_QUERY+"'")
	oTable:addParent(TAB_DW       , "ID_OBJ", ,"TYPE_OBJ = '"+PRIV_OBJ_DW+"'")
	oTable:addParent(TAB_CUBESLIST, "ID_OBJ", ,"TYPE_OBJ = '"+PRIV_OBJ_CUBE+"'")

 	createTable(oTable)
  	
return oTable

static function DW07400Ev(poTable, pnMoment, pnOper, plCond, paValues)
	Local oTable
	
	If pnMoment == FE_AFTER .AND. pnOper == FE_UPDATE
		If poTable:value("type_obj") == PRIV_OBJ_QUERY .AND. poTable:value("type_oper") == PRIV_OPER_ACESS ;
				.AND. poTable:value("type_auth") == PRIV_AUTH_DENIED
			oTable := InitTable(TAB_USER_DSKTOP)
			
			// indices da pesquisa: "id_user", "id_no", "tipo_cons"
			IF oTable:Seek(6, { poTable:value("id_user"), poTable:value("id_obj"), QUERY_PREDEF, oSigaDW:DWCurr()[2] })
				While !oTable:EoF() .AND. oTable:value("id_user") == poTable:value("id_user") .AND. ;
						oTable:value("id_no") == poTable:value("id_obj") .AND. ;
							oTable:value("tipo_cons") == QUERY_PREDEF .AND. oTable:value("dw") == oSigaDW:DWCurr()[2]
					oTable:Delete()
					oTable:_Next()
				EndDo
			EndIf
		EndIf
	EndIf
	
return

/*
-----------------------------------------------------------------------
Inicializa a tabela TAB_DSN (DW09000)
-----------------------------------------------------------------------
*/
static function DW09000() // TAB_DSN
	local oTable := TTable():New(TAB_DSN)
	local cbAux  := { { |oTab| DWStr(oTab:value('id')) } , ;
		 		      { |oTab| oTab:value('nome') } }

	oTable:Descricao(STR0345)  //"Fonte de dados"
	oTable:Events({ |oTable, nMoment, nOper, lCond, aValues| DW09000Ev(oTable, nMoment, nOper, lCond, aValues)})

	oTable:addFieldID()
	oTable:addField(nil, "tipo", "C", 1)
	oTable:addField(nil, "id_table", "N")
	oTable:addField(nil, "id_connect", "N")
	oTable:addField(nil, "nome", "C", 12)
	oTable:addField(nil, "descricao", "C", 80)
	oTable:addField(nil, "connector", "C", 15, 0, { || DWLookup(TAB_CONEXAO, id_connect, "nome") }, nil) 	
	oTable:addField(nil, "tipo_conn", "N", 1, 0, { || DWLookup(TAB_CONEXAO, id_connect, "tipo") }, nil) 	
	oTable:addField(nil, "tipo_text", "C", 15, 0, { || DWLookup(TAB_CONEXAO, id_connect, "tipo",, .t.) }, nil) 	
	oTable:addField(nil, "banco_srv", "C", 10, 0, { || DWLookup(TAB_CONEXAO, id_connect, "banco_srv") }, nil) 	
	oTable:addField(nil, "conex_srv", "C", 10, 0, { || DWLookup(TAB_CONEXAO, id_connect, "conex_srv") }, nil) 		
	oTable:addField(nil, "aliasTOP" , "C", 20, 0, { || DWLookup(TAB_CONEXAO, id_connect, "alias") }, nil) 		
	oTable:addField(nil, "server"   , "C", 30, 0, { || DWLookup(TAB_CONEXAO, id_connect, "server") }, nil) 	
	oTable:addField(nil, "ambiente" , "C", 20, 0, { || DWLookup(TAB_CONEXAO, id_connect, "ambiente") }, nil) 	

	oTable:addField(nil, "id_sql", "N")
	oTable:addField(nil, "id_sqlstru", "N")
	oTable:addField(nil, "SQL", "C", 0, 0, { || DWConcatWSep(CRLF, DWDetail(TAB_EXPR, id_sql, "linha", "id", 1))}, nil) 
	oTable:addField(nil, "sqlstruc",  "C", 0, 0, { || DWConcatWSep(CRLF, DWDetail(TAB_EXPR, id_sqlstru, "linha", "id", 1))}, nil) 
	oTable:addField(nil, "fullSQL", "C", 0, 0, { || DWConcatWSep(CRLF, DWDetail(TAB_EXPR, id_sql, "linha", "id", 1))}, nil) 
	oTable:addField(nil, "alias", "C", 3) 
#ifdef VER_P10
	oTable:addField(nil, "empFil", "C", 5) 
#else
	oTable:addField(nil, "empFil", "C", 15) 
#endif
	oTable:addField(nil, "caminho", "C", 255) 
	oTable:addField(nil, "arquivo", "C", 20) 
	oTable:addField(nil, "issql", "L", 255, 0, { || DWLookup(TAB_EXPR, id_filter, "issql")}, nil) 
	oTable:addField(nil, "id_filter", "N")
	oTable:addField(nil, "filter", "C", 255, 0, { || DWLookup(TAB_EXPR, id_filter, "linha")}, nil) 
	oTable:addField(nil, "id_b_exec", "N")
	oTable:addField(nil, "beforeExec", "C", 255, 0, { || DWConcatWSep(CRLF, DWDetail(TAB_EXPR, id_b_exec, "linha", "id", 1))}, nil) 
	oTable:addField(nil, "id_a_exec", "N")
	oTable:addField(nil, "afterExec", "C", 255, 0, { || DWConcatWSep(CRLF, DWDetail(TAB_EXPR, id_a_exec, "linha", "id", 1))}, nil) 
	oTable:addField(nil, "id_forzap", "N")
	oTable:addField(nil, "forZap", "C", 255, 0, { || DWConcatWSep(CRLF, DWDetail(TAB_EXPR, id_forZap, "linha", "id", 1))}, nil)
	oTable:addField(nil, "recLimit", "N")
	oTable:addField(nil, "id_valida", "N")
	oTable:addField(nil, "valida", "C", 255, 0, { || DWConcatWSep(CRLF, DWDetail(TAB_EXPR, id_valida, "linha", "id", 1))}, nil)
	oTable:addField(nil, "procinv", "C", 1)
	oTable:addField({|| UPDMET_DEFAULT }, "updmethod", "C", 1)
	oTable:addField({|| RPTINVAL_NONE }, "rptinval", "C", 1)
	oTable:addField(nil, "optimizer", "L")
	oTable:addField({||.f.}, "procCons", "L") 
	oTable:addField({||.f.}, "embedsql", "L") 

	oTable:AddIndex2(nil, { "tipo", "id_table", "id_connect" } )
	oTable:AddIndex2(nil, { "id_connect" } )
	oTable:AddIndex2(nil, { "tipo", "id_table", "nome" }, .t. )

	oTable:SetAttField("banco_srv", STR0024) // Tipo de Banco

	oTable:SetAttField("optimizer", STR0216) //"Otimizar"                
	oTable:SetAttField("procCons", STR0236) //"Proc. Consultas"
	oTable:SetAttField("tipo_text", STR0246) //"Via"
	oTable:SetAttField("procinv", STR0194) //"Rel.Invalidos"
	oTable:SetAttField("updmethod", STR0198) //"Metodo Atualização"
	oTable:SetAttField("rptinval", STR0199) //"Proc.invalidos"
	oTable:SetAttField("embedsql", "Embedded SQL")

	oTable:SetVisible("id_table", .f.)
	oTable:SetVisible("id_connect", .f.)
	oTable:SetVisible("updmethod", .f.)
	oTable:SetVisible("rptinval", .f.)
	oTable:SetVisible("tipo", .f.)
	oTable:SetVisible("id_sql", .f.)
	oTable:SetVisible("id_sqlstru", .f.)
	oTable:SetVisible("alias", .f.)
	oTable:SetVisible("empFil", .f.)
	oTable:SetVisible("caminho", .f.)
	oTable:SetVisible("arquivo", .f.)
	oTable:SetVisible("id_filter", .f.)
	oTable:SetVisible("filter", .f.)
	oTable:SetVisible("id_b_exec", .f.)
	oTable:SetVisible("beforeExec", .f.)
	oTable:SetVisible("id_a_exec", .f.)
	oTable:SetVisible("afterExec", .f.)
	oTable:setVisible("issql", .f.)
	oTable:SetVisible("tipo_conn", .f.)
	oTable:SetVisible("id_forzap", .f.)
	oTable:SetVisible("forZap", .f.)
	oTable:SetVisible("recLimit", .f.)
	oTable:SetVisible("id_valida", .f.)
	oTable:SetVisible("valida", .f.)
	oTable:SetVisible("fullsql", .f.)
	oTable:SetVisible("sql", .f.)
	oTable:SetVisible("sqlstruc", .f.)
	oTable:SetVisible("procinv", .f.)
	oTable:SetVisible("updmethod", .f.)
	oTable:SetVisible("optimizer", .f.)
	oTable:SetVisible("procCons", .f.)
	oTable:SetVisible("embedsql", .f.)

	oTable:addParent(TAB_CONEXAO, "id_connect")
	oTable:addParent(TAB_DIMENSAO, "ID_TABLE", , "TIPO = 'D'")
	oTable:addParent(TAB_CUBESLIST, "ID_TABLE", , "TIPO = 'F'")

	createTable(oTable)

return oTable

static function DW09000Ev(poTable, pnMoment, pnOper, plCond, paValues)

	local oTable

	if pnMoment == FE_BEFORE
		if pnOper == FE_DELETE

		  oTable := InitTable(TAB_DSNCONF)
		  if oTable:Seek(2, { poTable:value("id") })
		     while !oTable:eof() .and. (poTable:value("id") == oTable:value("id_dsn"))
		        oTable:Delete()
		        oTable:_Next()		  
		     end
		  endif
		  
		  oTable := InitTable(TAB_SXM)
		  if oTable:Seek(3, { poTable:value("id") })
		    while !oTable:eof() .and. (poTable:value("id") == oTable:value("id_dsn"))
		      oTable:Delete()
		      oTable:_Next()		  
		    end
		  endif

		  oTable := InitTable(TAB_EXPR)
		  if oTable:Seek(1, { poTable:value("id_sql") })
		     while !oTable:eof() .and. (poTable:value("id_sql") == oTable:value("id"))
		        oTable:Delete()
		        oTable:_Next()
		     end
		  endif
		  if oTable:Seek(1, { poTable:value("id_sqlstru") })
		     while !oTable:eof() .and. (poTable:value("id_sqlstru") == oTable:value("id"))
	           oTable:Delete()
 	           oTable:_Next()		  
 	     	  end
		  endif
		  if oTable:Seek(1, { poTable:value("id_filter") })
		     while !oTable:eof() .and. (poTable:value("id_filter") == oTable:value("id"))
	           oTable:Delete()
 	           oTable:_Next()		  
 	        end
		  endif
		  if oTable:Seek(1, { poTable:value("id_b_exec") })
		     while !oTable:eof() .and. (poTable:value("id_b_exec") == oTable:value("id"))
	           oTable:Delete()
 	           oTable:_Next()
 	        end
		  endif
		  if oTable:Seek(1, { poTable:value("id_a_exec") })
		     while !oTable:eof() .and. (poTable:value("id_a_exec") == oTable:value("id"))
	           oTable:Delete()
 	           oTable:_Next()		  
 	        end
		  endif
		  if oTable:Seek(1, { poTable:value("id_forzap") })
		     while !oTable:eof() .and. (poTable:value("id_forzap") == oTable:value("id"))
	           oTable:Delete()
 	           oTable:_Next()		  
 	        end
		  endif
		  if oTable:Seek(1, { poTable:value("id_valida") })
		     while !oTable:eof() .and. (poTable:value("id_valida") == oTable:value("id"))
	           oTable:Delete()
 	           oTable:_Next()		  
 	        end
		  endif

		endif
	endif

return

/*
-----------------------------------------------------------------------
Inicializa a seleção SEL_DSN_EMPFIL (QW09000)
-----------------------------------------------------------------------
*/
static function QW09000() // SEL_DSN_EMPFIL
	local oQuery := TQuery():New(SEL_DSN_EMPFIL) // QW09000

#ifdef VER_P10
	oQuery:AddField(nil, "empfil", "C", 5)	//##P11 - Estava com valor = 2
#else
	oQuery:AddField(nil, "empfil", "C", 15)
#endif
	oQuery:AddField(nil, "id_connect", "N")
	oQuery:MakeDistinct(.t.)
	oQuery:FieldList("EMPFIL, ID_CONNECT")
	oQuery:FromList(TAB_DSN + " A, " + TAB_DIMENSAO + " B")
	oQuery:WhereClause("A.TIPO = 'D' AND A.ID_TABLE = B.ID AND B.ID_DW = " + dwStr(oSigaDW:DWCurr()[1]))
	oQuery:WithDeleted(.f.)
	oQuery:OrderBy("EMPFIL")

return oQuery

/*
-----------------------------------------------------------------------
Inicializa a seleção SEL_DSN_ALIAS (QW09001)
-----------------------------------------------------------------------
*/
static function QW09001() // SEL_DSN_ALIAS
	local oQuery := TQuery():New(SEL_DSN_ALIAS) // QW09001

	oQuery:AddField(nil, "alias", "C", 2)
	oQuery:MakeDistinct(.t.)
	oQuery:FieldList("ALIAS")
	oQuery:FromList(TAB_DSN + " A, " + TAB_DIMENSAO + " B")
	oQuery:WhereClause("A.ALIAS <> '' AND A.TIPO = 'D' AND A.ID_TABLE = B.ID AND B.ID_DW = " + dwStr(oSigaDW:DWCurr()[1]))
	oQuery:WithDeleted(.f.)
	oQuery:OrderBy("ALIAS")

return oQuery

/*
-----------------------------------------------------------------------
Inicializa a seleção SEL_DSN_EMPCOMP (QW09002)
-----------------------------------------------------------------------
*/
static function QW09002() // SEL_DSN_EMPCOMP 
	local oQuery := TQuery():New(SEL_DSN_EMPCOMP) // QW09002

	oQuery:AddField(nil, "alias", "C", 2)
	oQuery:MakeDistinct(.t.)
	oQuery:FieldList("ALIAS")
	oQuery:FromList(TAB_SX2)
	oQuery:WhereClause("MODO = 'A' AND ID_DW = " + dwStr(oSigaDW:DWCurr()[1]))
	oQuery:WithDeleted(.f.)
	oQuery:OrderBy("ALIAS")

return oQuery

/*
-----------------------------------------------------------------------
Inicializa a tabela TAB_DSNCONF (DW09100)
-----------------------------------------------------------------------
*/
static function DW09100() // TAB_DSNCONF
	local oTable := TTable():New(TAB_DSNCONF)

	oTable:Descricao(STR0346)  //"Fonte de dados - configuração"
	oTable:Events({ |oTable, nMoment, nOper, lCond, aValues| DW09100Ev(oTable, nMoment, nOper, lCond, aValues)})

	oTable:addFieldID()
	oTable:addField(nil, "id_dsn", "N")
	oTable:addField(nil, "id_field", "N")
	oTable:addField(nil, "id_expr", "N")
	oTable:addField(nil, "cpoorig", "C", 20)
	oTable:addField(nil, "id_valida", "N")
	oTable:addField(nil, "expressao", "C", 0, 0, { || DWConcatWSep(CRLF, DWDetail(TAB_EXPR, id_expr, "linha", "id", 1))}, nil) 
	oTable:addField(nil, "valida", "C", 255, 0, { || DWLookup(TAB_EXPR, id_valida, "linha")}, nil) 
	oTable:addField(nil, "field", "C", 255, 0, { || DWLookup(TAB_FACTFIELDS, id_field, "nome")}, nil) 
	oTable:addField(nil, "isSQL", "L", , , { || DWLookup(TAB_EXPR, id_expr, "isSQL")}, nil) 

	oTable:AddIndex2(nil, { "id_dsn", "id_field" } )
	oTable:AddIndex2(nil, { "id_field" } )
	                          
	oTable:addParent(TAB_DSN, "id_DSN")
	oTable:addParent(TAB_FACTFIELDS, "id_FIELD")

	createTable(oTable)

return oTable

static function DW09100Ev(poTable, pnMoment, pnOper, plCond, paValues)

	local oTable

	if pnMoment == FE_BEFORE
		if pnOper == FE_DELETE

		  oTable := InitTable(TAB_EXPR)
		  if oTable:Seek(1, { poTable:value("id_expr") })
		     while !oTable:eof() .and. (poTable:value("id_expr") == oTable:value("id"))
	           oTable:Delete()
 	           oTable:_Next()		  
 	        end
		  endif

		endif
	endif

return

/*
-----------------------------------------------------------------------
Inicializa a tabela TAB_EXPORT (DW09200)
-----------------------------------------------------------------------
*/
static function DW09200() // TAB_EXPORT
	local oTable := TTable():New(TAB_EXPORT)

	oTable:Descricao(STR0347)  //"Parâmetros de exportação"
	oTable:addFieldID()
	oTable:addField(nil, "tipo", "N")  // Tipo - dimensao/consulta/...
	oTable:addField(nil, "idtipo", "N")  // Id - dimensao/consulta/...
	oTable:addField(nil, "formato", "C", 1)
	oTable:addField(nil, "mzp", "L")
	oTable:addField(nil, "maillist", "C", 255)
	oTable:addField(nil, "dtultima", "D")
	oTable:addField(nil, "hrultima", "C", 8)
	oTable:addField(nil, "separator", "C", 4)
	oTable:addField({ |x| .f.}, "showZero", "L" )
	oTable:addField({ |x| .t.}, "hideTotals", "L")
	oTable:addField({ |x| .t.}, "hideEquals", "L")
	oTable:addField({ |x| .f.}, "showheader", "L")
	oTable:addField({ |x| .f.}, "showFltrng", "L")
	oTable:addField({ |x| .f.}, "showformat", "L")
	oTable:addField({ |x| .f.}, "expAlert", "L")
	oTable:addField(nil, "ocorrenc", "C", 255)
	oTable:addField(nil, "arquivo", "C", 50)
	oTable:addField({ |x| .f.}, "percIsInd", "L")	
	oTable:addField({ |x| .f.}, "AttachFile", "L") /*Identifica se o gráfico deve ser exportado como anexo de email.*/
	
	oTable:AddIndex2(nil, { "tipo", "idtipo" } )

	oTable:addParent(TAB_DIMENSAO, "idTIPO", , "TIPO = 0")
	oTable:addParent(TAB_CONSTYPE, "idTIPO", , "TIPO = "+dwStr(TYPE_TABLE))
	oTable:addParent(TAB_CONSTYPE, "idTIPO", , "TIPO = "+dwStr(TYPE_GRAPH))

	createTable(oTable)

return oTable

/*
-----------------------------------------------------------------------
Inicializa a tabela DICIONÁRIO DE DADOS
-----------------------------------------------------------------------
*/
static function DW0B000() // TAB_DD
	local oTable := TTable():New(TAB_DD)
	
	oTable:Descricao(STR0348)  //"Dicionário de apoio (DD)"
	oTable:addFieldID()
	oTable:addField(nil, "tablename", "C", 12)
	oTable:addField(nil, "typeInfo", "C", 2)
	oTable:addField(nil, "info", "C", 255)

	oTable:AddIndex2(nil, { "tablename", "typeInfo" } )
                                	
	createTable(oTable)
                           
return oTable

/*
-----------------------------------------------------------------------
Inicializa a seleção SEL_DSNCONF (QW09100)
-----------------------------------------------------------------------
*/
static function QW09100() // SEL_DSNCONF
	local oQuery := TQuery():New(SEL_DSNCONF) // QW09100
	local oAux, aFromList := {}
	local cTabDimFields := TAB_DIM_FIELDS
	local cTabDimensao  := TAB_DIMENSAO 
	local cTabDsnConf   := TAB_DSNCONF
	
	oAux := InitTable(TAB_DIMENSAO)
	oAux := InitTable(TAB_DIM_FIELDS)
	oAux := InitTable(TAB_DSNCONF)
	
	oQuery:AddField(nil, "id_field", "N")
	oQuery:AddField(nil, "id_dsn", "N")
	oQuery:AddField(nil, "nome", "C", 10)
	oQuery:AddField(nil, "tipo", "C", 1)
	oQuery:AddField(nil, "tam", "N", 4)
	oQuery:AddField(nil, "ndec", "N", 4)
	oQuery:AddField(nil, "keyseq", "N", 3)
	oQuery:AddField(nil, "cpoOrig", "C", 20) 
	oQuery:AddField(nil, "roteiro", "C", 255, 0, { || left(DWStr(DWLookup(TAB_DSNCONF, { id_dsn, id_field }, "expressao", 2)), 255)}, nil) 
	oQuery:AddField(nil, "id_roteiro", "N", 10, 0, { || DWLookup(TAB_DSNCONF, { id_dsn, id_field }, "id_expr", 2)}, nil) 
	oQuery:AddField(nil, "valida", "C", 255, 0, { || left(DWStr(DWLookup(TAB_DSNCONF, { id_dsn, id_field }, "valida", 2)), 255)}, nil) 
	oQuery:AddField(nil, "id_valida", "N", 10, 0, { || DWLookup(TAB_DSNCONF, { id_dsn, id_field }, "id_valida", 2)}, nil) 
	oQuery:AddField(nil, "id_dsnconf", "N") 
	oQuery:AddField(nil, "isSQL", "L",,, { || DWLookup(TAB_DSNCONF, { id_dsn, id_field }, "isSQL", 2)}, nil) 

	oQuery:SetAttField("keyseq", STR0159) //"Seq.Chave"
	oQuery:SetAttField("ndec", STR0068) //"#Decimais"
	oQuery:SetAttField("tam", STR0059) //"Tamanho"
	oQuery:SetAttField("cpoorig", STR0160) //"Origem"

	oQuery:FieldList("A.ID ID_FIELD, A.NOME, A.TIPO, A.TAM, A.NDEC, A.MASCARA, A.KEYSEQ, B.ID_DSN, B.CPOORIG, B.ID ID_DSNCONF")

	cTabDimFields := trataTableName(TAB_DIM_FIELDS)
	cTabDimensao  := trataTableName(TAB_DIMENSAO)
	cTabDsnConf   := trataTableName(TAB_DSNCONF)
	
	if SGDB() == DB_INFORMIX
		oQuery:FromList(cTabDimFields + " A, OUTER(" + cTabDimensao + " C, " + cTabDsnConf + " B)")
	else
	  aAdd(aFromList, cTabDimFields + " A")
	  aAdd(aFromList, " LEFT OUTER JOIN")
	  aAdd(aFromList, cTabDsnConf   + " B ON")
	  aAdd(aFromList,   "A.ID = B.ID_FIELD AND")
	  aAdd(aFromList,   "B.ID_DSN = [P2] AND")
	  aAdd(aFromList,   "B." + DWDelete() + " = ' '")
	  aAdd(aFromList, " LEFT OUTER JOIN")
	  aAdd(aFromList, cTabDimensao  + " C ON")
	  aAdd(aFromList,   "A.ID_DIM = C.ID AND")
	  aAdd(aFromList,   "C." + DWDelete() + " = ' ' ")
		oQuery:FromList(dwConcatWSep(space(1), aFromList))
	endif
	if SGDB() == DB_INFORMIX
		oQuery:WhereClause("A." + DWDelete() + " = ' ' and A.ID_DIM = [P1] and C.ID = A.ID_DIM and A.ID = B.ID_FIELD AND B.ID_DSN = [P2]")
	else
	  oQuery:WhereClause("A.ID_DIM = [P1] AND A." + DWDelete() + " = ' '")
	endif                

	oQuery:WithDeleted(.t.)
	oQuery:OrderBy("A.NOME")

return oQuery

/*
-----------------------------------------------------------------------
Inicializa a seleção SEL_DSNCONF2 (QW09101)
-----------------------------------------------------------------------
*/
static function QW09101() // SEL_DSNCONF2
	local oQuery := TQuery():New(SEL_DSNCONF2) // QW09101
	local oAux, aFromList
	local cTabFactFields := TAB_FACTFIELDS
	local cTabDsnConf    := TAB_DSNCONF      
	
	oAux := InitTable(TAB_FACTFIELDS)
	oAux := InitTable(TAB_DSNCONF)
	
	oQuery:AddField(nil, "id_field", "N")
	oQuery:AddField(nil, "id_dsn", "N")
	oQuery:AddField(nil, "nome", "C", 10)
	oQuery:AddField(nil, "tipo", "C", 1)
	oQuery:AddField(nil, "tam", "N", 4)
	oQuery:AddField(nil, "ndec", "N", 4)
	oQuery:AddField(nil, "cpoOrig", "C", 20) 
	oQuery:AddField(nil, "roteiro", "C", 255, 0, { || left(DWStr(DWLookup(TAB_DSNCONF, { id_dsn, id_field }, "expressao", 2)), 255)}, nil) 
	oQuery:AddField(nil, "id_roteiro", "N", 10, 0, { || DWLookup(TAB_DSNCONF, { id_dsn, id_field }, "id_expr", 2)}, nil) 
	oQuery:AddField(nil, "valida", "C", 255, 0, { || left(DWStr(DWLookup(TAB_DSNCONF, { id_dsn, id_field }, "valida", 2)), 255)}, nil) 
	oQuery:AddField(nil, "id_valida", "N", 10, 0, { || DWLookup(TAB_DSNCONF, { id_dsn, id_field }, "id_valida", 2)}, nil) 
	oQuery:AddField(nil, "id_dsnconf", "N") 
	oQuery:AddField(nil, "isSQL", "L",,, { || DWLookup(TAB_DSNCONF, { id_dsn, id_field }, "isSQL", 2)}, nil) 
	
	oQuery:SetAttField("ndec", STR0068) //"#Decimais"
	oQuery:SetAttField("tam", STR0059) //"Tamanho"                       
	oQuery:SetAttField("cpoorig", STR0160) //"Origem"
	oQuery:FieldList("A.ID ID_FIELD, NOME, TIPO, TAM, NDEC, ID_DSN, CPOORIG, B.ID ID_DSNCONF")
	
	cTabFactFields := trataTableName(TAB_FACTFIELDS)
	cTabDsnConf    := trataTableName(TAB_DSNCONF)
	
	if SGDB() == DB_ORACLE
		oQuery:FromList(cTabFactFields + " A, " + cTabDsnConf + " B")  
		oQuery:WhereClause("A.ID_CUBES = [P1] and A.ID = B.ID_FIELD(+) and B.ID_DSN(+) = [P2] and A." + DWDelete() + " = ' ' and B." + DWDelete() + "(+) = ' '")
	else  
		oQuery:FromList(cTabFactFields + " A LEFT OUTER JOIN " + cTabDsnConf + " B ON A.ID = B.ID_FIELD AND B.ID_DSN = [P2] and B." + DWDelete() + " = ' '")
		oQuery:WhereClause("A." + DWDelete() + " = ' ' and A.ID_CUBES = [P1]")
	endif

	oQuery:WithDeleted(.t.)
	oQuery:OrderBy("NOME")
	
return oQuery

/*
-----------------------------------------------------------------------
Inicializa a tabela de agendamento DW0A000 (ponte com o SXM)
-----------------------------------------------------------------------
*/
static function DW0A000() // TAB_SXM
	local oTable := TTable():New(TAB_SXM)   

	oTable:Descricao(STR0349)  //"SXM (Espelho)"
	oTable:Events({ |oTable, nMoment, nOper, lCond, aValues| DW0A000Ev(oTable, nMoment, nOper, lCond, aValues)})

	oTable:addFieldID()
	oTable:addField(nil, "id_dsn", "N") // Para import, id fontededados, para export, id da exportacao e negativo para usuários SigaDW
	oTable:addField(nil, "agtipo", "N") // Tipo de agendamento
	oTable:addField(nil, "XM_TIPO"     , "N",   1)	// 0-Diario 1-Semanal 3-Mensal 4-Exporádico
	oTable:addField(nil, "XM_ATIVO"    , "L",   1)	// Ativo (SIM/NAO)
	oTable:addField(nil, "XM_DTINI"    , "D",   8)	// Data de inicio
	oTable:addField(nil, "XM_HRINI"    , "C",   5)	// Hora de inicio
	oTable:addField(nil, "XM_DTFIM"    , "D",   8)	// Data de termino
	oTable:addField(nil, "XM_HRFIM"    , "C",   5)	// Hora de termino
	oTable:addField(nil, "XM_INTERV"   , "C",   5)	// Intervalo entre execs
	oTable:addField(nil, "XM_SEMANA"   , "C",   7)	// Dias da semana
	oTable:addField(nil, "XM_SEMANAEXT", "C",  28, 0, {|| trataDiaSemana(XM_SEMANA) }, {|x| XM_SEMANA := trataDiaSemana(nil,x)})
	oTable:addField(nil, "XM_MENSAL"   , "C",  31)	// Dias do mes
	oTable:addField(nil, "XM_MENSALEXT", "C",  93, 0, {|| trataDiaMes(XM_MENSAL) }, {|x| XM_MENSAL := trataDiaMes(nil,x)})
    oTable:addField(nil, "XM_PROXEXEC" , "C",  17, 0, {|| getProxExec(ID, dwStr(XM_TIPO)) }) // Data da prox execucao
	oTable:addField(nil, "XM_TASKCODE" , "C",  12, 0, {|| "DW0" + DWInt2Hex(ID, 6) })
	oTable:addField(nil, "dsn"         , "C",  20, 0, {|| trataDsn(agTipo, id_dsn) })
	oTable:addField(nil, "info"        , "C",  20, 0, {|| trataInfo(agTipo, id_dsn) })

	oTable:AddIndex2(nil, { "agtipo", "id_dsn", "id" } )
	oTable:AddIndex2(nil, { "id_dsn", "id" } )

	oTable:setVisible("XM_SEMANA", .f.)
	oTable:setVisible("XM_MENSAL", .f.)

	oTable:SetAttField("id_dsn"      , STR0160) //"Origem"
	oTable:SetAttField("agTipo"      , STR0350) //"Procedimento"
	oTable:SetAttField("XM_TIPO"     , STR0162) //"Periodicidade"
	oTable:SetAttField("XM_ATIVO"    , STR0105) //"Ativo"
	oTable:SetAttField("XM_DTINI"    , STR0039) //"Data Inicial"
	oTable:SetAttField("XM_HRINI"    , STR0163) //"Hora Inicial"
	oTable:SetAttField("XM_DTFIM"    , STR0040) //"Data Final"
	oTable:SetAttField("XM_HRFIM"    , STR0164) //"Hora Final"
	oTable:SetAttField("XM_INTERV"   , STR0165) //"Intervalo"
	oTable:SetAttField("XM_SEMANAEXT", STR0166) //"Dias/Semana"
	oTable:SetAttField("XM_MENSALEXT", STR0167) //"Dias/Mês"
	oTable:SetAttField("XM_PROXEXEC" , STR0168) //"Prox.Execução"
	oTable:SetAttField("XM_TASKCODE" , STR0351) //"Código do Agendamento"

	oTable:addParent(TAB_DSN, "id_dsn", "ID_DSN > 0 AND AGTIPO = "+dwStr(AG_IMP))
	oTable:addParent(TAB_CONSULTAS, "id_dsn", "ID_DSN > 0 AND AGTIPO = "+dwStr(AG_EXP))

	createTable(oTable)

return oTable

static function DW0A000Ev(poTable, pnMoment, pnOper, plCond, paValues)
	Local aTasks := {}, aFields := {}
	Local owf, cTaskCod
 	Local oDSN  
 	Local oTable
 	Local cDescricao
 	
	if pnMoment == FE_AFTER       
		cTaskCod := poTable:value("XM_TASKCODE",.t.)
		owf := oSigaDW:WFObj()
		if (pnOper == FE_UPDATE .or. pnOper == FE_APPEND) .and. poTable:value("XM_ATIVO")
			aAdd(aFields, xFilial("sxm") )     		 // XM_FILIAL
			aAdd(aFields, cTaskCod )     // XM_CODIGO
			aAdd(aFields, cTaskCod )     // XM_NOME
			if poTable:value("agtipo") == AG_EXP
				aAdd(aFields, STR0212)   //"Exportação SigaDW"
			else   
	    
				oDSN := initTable(TAB_DSN)				
				oDSN:seek(1, { poTable:value("id_dsn") } )
				  
				/*Verifica se é fonte de dados de DIMENSAO.*/                 
                If (oDSN:value("TIPO") == "D") 
                	cDescricao := STR0063 /*Dimensão*/
					oTable := initTable(TAB_DIMENSAO) 					
				Else 
					/*Fonte de dados de CUBO.*/
					cDescricao :=  STR0357 /*Cubo*/
					oTable := initTable(TAB_CUBESLIST)
				EndIf       
				
				/*Posiciona no CUBO|DIMENSAO do qual a fonte de dados pertence.*/
				oTable:seek(1, { oDSN:value("ID_TABLE") } )
                
                /*Posiciona no DW do qual o CUBO|DIMENSAO pertence.*/                   
    			oDW := initTable(TAB_DW)				
				oDW:seek(1, { oTable:value("ID_DW") } )   
    			
    			/*Cria a descrição que será incluída no SXM.*/
				aAdd(aFields, 	STR0175 +; 			//"Importação SigaDW - "                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       
				 				dwStr( cDescricao  + ": " +;  
				   				oTable:value("NOME") + " "  +;  
				   				STR0362 + ": " +; 	//"Fonte: 
				    			oDSN:value("NOME") ) + "  [" + oDW:value("NOME") + "]" )   
				
				/*Destroi o objeto CUBO|DIMENSAO.*/    			
				oTable:Free()
				/*Destroi o objeto DW.*/ 
				oDW:Free()		   
		   	endif  
		   	
			aAdd(aFields, poTable:value("XM_TIPO"))
			aAdd(aFields, poTable:value("XM_DTINI"))
			aAdd(aFields, poTable:value("XM_HRINI"))
			aAdd(aFields, poTable:value("XM_DTFIM"))
			aAdd(aFields, poTable:value("XM_HRFIM"))
			aAdd(aFields, poTable:value("XM_INTERV"))
			aAdd(aFields, poTable:value("XM_SEMANA"))
			aAdd(aFields, poTable:value("XM_MENSAL"))
			aAdd(aFields, poTable:value("XM_DTINI"))  // XM_DTPROX
			aAdd(aFields, poTable:value("XM_HRINI"))  // XM_HRPROX
			aAdd(aFields, "" )	// XM_AMBIENT                    '
			aAdd(aFields, "DWImpExpMonitor(" +dwStr(!(poTable:value("agtipo") == AG_EXP),.t.)+ ", " +DWStr(poTable:value("id_dsn"))+ ",'"+ oSigaDW:DWCurr()[2]+ "','" + getWebHost() + "','" +getWebJob()+ "',," +DWSTR(poTable:value("agtipo"))+ ",,,'" +GetEnvServer()+ "'," + GetPvProfString("TCP", "PORT", dwStr(PORT_PROTHEUS), DWIniFile()) + ",'" +DWEmpresa()+ "','" + DWFilial() + "')")
			aAdd(aFields, "" ) 	// XM_ID
			aAdd(aFields, iif(poTable:value("XM_ATIVO"), "T", "F"))
			aAdd(aFields, "F" ) // XM_TIMEOUT
			aAdd(aTasks, aFields )   
			
			if (pnOper == FE_APPEND .and. !oWF:oScheduler:locatetask(cTaskCod)) .or. ;
				(pnOper == FE_UPDATE .and. !oWF:oScheduler:locatetask(cTaskCod))
				oWF:oscheduler:SaveTasks(aTasks)
			elseif pnOper == FE_UPDATE
		    	oWF:oScheduler:UpdateTask(cTaskCod, aFields)
		    	oWF:oScheduler:Recalc()
	      endif    
	      	   	      
   	elseif pnOper == FE_DELETE .or. poTable:value("XM_ATIVO") == .f.
			if oWF:oScheduler:locatetask(cTaskCod)
		    	oWF:oScheduler:DeleteTask(cTaskCod)
		 	endif
		endif
	endif
                                      	
return .t.

static function getProxExec(pnId, acPerio)
	local aFields := {}, cRet := "**/**/**** **:**"
	local cTaskCod, cOldAlias := select()

  	cTaskCod := "DW0"+DWInt2Hex(pnID, 6)  
  		
	if oSigaDW:WFObj():oScheduler:LocateTask( cTaskCod, aFields )  

		cRet := DWStr(aFields[13]) + " " + DWStr(aFields[14])      
		
		if left(cRet, 10) == dtoc(date())          
			cRet := STR0352 + ", " + right(cRet, 5) //"hoje"
		elseif left(cRet, 10) == dtoc(date()+1)             
			cRet := STR0353 +", " + right(cRet, 5) //"amanhã"
		else                      
			cRet := lower(left(diaextenso(ctod(left(cRet,10))),3) + ", " + left(cRet, 10)) + STR0252 + right(cRet, 5)  //" as "
		endif                                              
	endif        
	
	dbSelectArea(cOldAlias)
    
return cRet

static function trataDsn(anAgTipo, anId_dsn)
	local cRet := ""
	local oAux
	
	if anId_dsn < 0 // importação de usuários
		cRet := STR0354  //"Usuários SigaDW"
	elseif anAgTipo == AG_EXP
		oAux := initTable(TAB_EXPORT)
		if oAux:seek(1, { anId_dsn } )
			oAux2 := initTable(TAB_CONSULTAS)
			if oAux2:seek(1, { oAux:value("idtipo") } )
				cRet := STR0355 + oAux2:value("nome") //"Consulta: "
			else		
				cRet := STR0356 //"(não localizado)"
			endif
		else		
			cRet := STR0356 //"(não localizado)"
		endif
	else
		oAux := initTable(TAB_DSN)
		if oAux:seek(1, { anId_dsn } )
			cRet := iif(oAux:value("tipo") == "D", STR0063, STR0357) + ": " + oAux:value("nome") //"Dimensão"  //"Cubo"
		else		
			cRet := STR0356 //"(não localizado)"
		endif
	endif
	
return cRet

static function trataInfo(anAgTipo, anId_dsn)
	local cRet := ""
	local oAux
	
	if anId_dsn < 0 // importação de usuários
	elseif anAgTipo == AG_EXP
		oAux := initTable(TAB_EXPORT)
		if oAux:seek(1, { anId_dsn } )
			oAux2 := initTable(TAB_CONSULTAS)
			if oAux2:seek(1, { oAux:value("idtipo") } )
				cRet := strZero(oAux2:value("id_dw"),5) + oAux2:value("descricao")
			else		
				cRet := STR0356 //"(não localizado)"
			endif
		else		
			cRet := STR0356 //"(não localizado)"
		endif
	endif
	
return cRet

static function trataDiaSemana(pcValue, pcNewValue)
	local cRet := "", aAux
	local aDias := { 'Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab' }

	if valType(pcNewValue) == "C"                  
		aEval(aDias, { |x| cRet += iif(x $ pcNewValue, "X", " ") })
	else 
		aAux := {}
		aEval(aDias, { |x, i| iif(substr(pcValue,i,1)=="X", aAdd(aAux, x), nil) })
		cRet := DWConcatWSep(",", aAux)
	endif		

return cRet

static function trataDiaMes(pcValue, pcNewValue)
	local cRet := "", aAux, nInd

	if valType(pcNewValue) == "C"                  
		aAux := DWToken(pcNewValue, ',')
		aEval(aAux, { |x,i| aAux[i] := strzero(x,2) })
		pcNewValue := DWConcatWSep(',', aAux)
		for nInd := 1 to 31
			cRet += iif(strZero(nInd,2) $ pcNewValue, "X", " ")
		next
	else 
		aAux := {}
		for nInd := 1 to 31
			if substr(pcValue, nInd, 1) == "X"
				aAdd(aAux, strZero(nInd, 2))
			endif
		next
		cRet := DWConcatWSep(",", aAux)
	endif		

return cRet

/*
-----------------------------------------------------------------------
Inicializa a tabela de cache de compartilhamento DW0A100
-----------------------------------------------------------------------
*/
static function DW0A100() // TAB_SX2
	local oTable := TTable():New(TAB_SX2)

	oTable:Descricao(STR0358)  //"SX2 (Espelho)"
	oTable:addFieldID()
	oTable:addFieldDW()
	oTable:addField(nil, "ALIAS" , "C", 3)
#ifdef VER_P10
	oTable:addField(nil, "EMPFIL" , "C", 5)
#else
	oTable:addField(nil, "EMPFIL" , "C", 15)
#endif
	oTable:addField(nil, "MODO"  , "C", 1)	// E-Exclusivo, C-Comp.(Filial), A-Comp.(Empresa)

	oTable:AddIndex2(nil, { "ALIAS", "EMPFIL" } )

	createTable(oTable)

return oTable

								aAdd(aValues, { "dom" , aRet2[nInd2, 1] } )
								aAdd(aValues, { "cdom", aRet2[nInd2, 2] } )
								aAdd(aValues, { "expdom", aRet2[nInd2, 3] } )
								aAdd(aValues, { "expcdom", aRet2[nInd2, 4] } )

/*
-----------------------------------------------------------------------
Inicializa a tabela de cache para dominio/contra-dominio
-----------------------------------------------------------------------
*/
static function DW0A200() // TAB_SX9
	local oTable := TTable():New(TAB_SX9)

	oTable:Descricao(STR0359)  //"SX9 (Espelho)"
	oTable:addFieldID()
	oTable:addFieldDW()
	oTable:addField(nil, "CDOM"  , "C", 3)
	oTable:addField(nil, "DOM"   , "C", 3)
	oTable:addField(nil, "EXPDOM", "C", 255)
	oTable:addField(nil, "EXPCDOM", "C", 255)

	oTable:AddIndex2(nil, { "CDOM", "DOM" } )

	createTable(oTable)

return oTable

/*
-----------------------------------------------------------------------
Inicializa a tabela de estatisticas de consumo em disco DW0C000
-----------------------------------------------------------------------
*/
static function DW0C000() // TAB_ESTAT_SPC
	local oTable := TTable():New(TAB_ESTAT_SPC)

	oTable:Descricao(STR0360)  //"Estatísticas (disco)"
	oTable:addFieldID()
	oTable:addField(nil, "tipo", "C", 1) 
	oTable:addField(nil, "id_obj", "N")
	oTable:addField(nil, "data1"        , "D")
	oTable:addField(nil, "linhas1"      , "N", 10)
	oTable:addField(nil, "tamanho1"     , "N", 10)
	oTable:addField(nil, "data2"        , "D")
	oTable:addField(nil, "linhas2"      , "N", 10)
	oTable:addField(nil, "tamanho2"     , "N", 10)
	
	oTable:AddIndex2(nil, { "tipo", "id_obj" } )

	createTable(oTable)

return oTable

/*
-----------------------------------------------------------------------
Inicializa a tabela de estatisticas do DW
-----------------------------------------------------------------------
*/
static function DW0C100() // TAB_ESTAT
	local oTable := TTable():New(TAB_ESTAT)

	oTable:Descricao(STR0361)  //"Estatísticas"
	oTable:addFieldID()
	oTable:addFieldDW()
	oTable:addField(nil, "tipo"  , "C", 5)
	oTable:addField(nil, "id_obj", "N")
	oTable:addField(nil, "Valor" , "N", 13, 3)
	oTable:addField(nil, "Compl" , "C", 40)
	
	oTable:AddIndex2(nil, { "tipo", "id_obj" } )

	createTable(oTable)

return oTable

/*
--------------------------------------------------------------------------------------
Rotinas para salva, carga e remoçao de expressões em TAB_EXPR
--------------------------------------------------------------------------------------
*/                             

function DWEraseExpr(anID)
	local oDataset := InitTable(TAB_EXPR)

	DWDelAllRec(oDataset:Tablename(), "ID = " + dwStr(anID))

return

function DWSaveExpr(axSource, anID, alSQL, alSaveEmptyLine)
	local oDataset := InitTable(TAB_EXPR)
	local nInd, lOk := .f., aSource

	default alSaveEmptyLine := .f.

	if !(anID == 0)
		DWEraseExpr(anID)
	endif

	if valType(axSource) == "A"    
		aSource := axSource
	else  
		/*Verifica se o browser corrente é o Firefox.*/
		If(isFirefox())
			/*Tokeniza pelo caracter LF [CHR(10)]*/
			aSource := dwToken(axSource, LF, .F.)
	    Else 
	    	/*Tokeniza pelo caracter CR [CHR(13)]*/
	    	aSource := dwToken(strTran(axSource, LF, ""), CR, .F.)
	    EndIf
	
	endif
			
	for nInd := 1 to len(aSource)
		if alSaveEmptyLine .or. !empty(aSource[nInd])
			if anID == 0 
				lOk := oDataset:append( { { "seq", nInd }, { "linha", aSource[nInd]}, { "issql", alSQL } })
				anID := oDataset:value("id")
			else
				lOk := oDataset:append( { { "id", anID}, { "seq", nInd }, { "linha", aSource[nInd]}, { "issql", alSQL } })
			endif  
			if !lOk
				anID := -1
				exit
			endif
		endif
	next
				
return anID

function DWLoadExpr(anID)
	local oDataset := InitTable(TAB_EXPR)
	local aRet
		
	if oDataset:Seek(2, { anID })
		aRet := { oDataset:value("issql"), {} }
		while !oDataset:Eof() .and. oDataset:value("id") == anID
			aAdd(aRet[2], oDataset:value("linha"))
			oDataset:_Next()
		enddo
	endif

return aRet

/*
-----------------------------------------------------------------------
Rotinas para manipulação de transações
-----------------------------------------------------------------------
*/
static __DW_IN_TRANSACTION := .f.
                             
function DWInTransaction()

return __DW_IN_TRANSACTION

function beginTransaction()
	dbCommitAll()
	TCCOMMIT(1)          
	__DW_IN_TRANSACTION := .t.
return

function endTransaction(alCommit)
	default alCommit := .t.
	
	if alCommit
		TCCOMMIT(2,procname(1))
	else
		TCCOMMIT(3)
	endif
	TCCOMMIT(4)
	DbUnLockAll()              
	__DW_IN_TRANSACTION = .f.

return


/*
--------------------------------------------------------------------------------------
Fecha as tabelas, cujos nomes estejam relacionados a Dimensões, fatos ou sumarizações
--------------------------------------------------------------------------------------
*/
function DWCloseSomeTables()
  local nWorkArea, cPref
  
	for nWorkArea := 1 to 250
	  dbSelectArea(nWorkArea)
		if !(alias() == "")
		  cPref := left(dbInfo(DBI_FULLPATH),2)
		  if cPref $ "DD|DC|DG|DS"
			  dbCloseArea()
			 endif
		endif
	next

return
