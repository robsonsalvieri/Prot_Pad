// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : Ferramentas
// Fonte  : DWMakeSite - Rotinas para construção/manipulação dos arquivos estaticos do site
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 14.02.05 | 0548-Alan Candido |
// --------------------------------------------------------------------------------------

#include "dwincs.ch"

function DWUpdStat(anDWID)
	local oEstat := initTable(TAB_ESTAT)
	local oTabAux, oQuery := TQuery():New(DWMakeName("TRA"))
	local oTabAux2	
	
	oEstat:Open()

	oTabAux := oSigaDW:Admin():Users()
	updStat(anDWID, oEstat, ST_USERS_COUNT, 0, oTabAux:RecCount(.t., "ID_GRUPO <> 0"))
	updStat(anDWID, oEstat, ST_GROUPS_COUNT, 0, oTabAux:RecCount(.t., "ID_GRUPO = 0"))

	oTabAux := oSigaDW:Consultas()
	updStat(anDWID, oEstat, ST_QUERYS_COUNT, 0, oTabAux:RecCount(.t.))
	             
	oTabAux := oSigaDW:Dimensao()
	updStat(anDWID, oEstat, ST_DIMENSIONS_COUNT, 0, oTabAux:RecCount(.t.))

	oTabAux:gotop()

	oQuery:FieldList("count(ID) as cnt")
	oQuery:WithDeleted(.t.)
	
	oTabAux2 := initTable(TAB_DSN)
	while !oTabAux:eof() 
		updStat(anDWID, oEstat, ST_DIMENSIONS_DS_COUNT, oTabAux:value("id"), oTabAux2:recCount(.t., "ID_TABLE = " + dwStr(oTabAux:value("id")) + " and TIPO='D'"))

		if tcCanOpen(DWDimName(oTabAux:value("id")))
			oQuery:FromList(DWDimName(oTabAux:value("id")))         
			oQuery:WhereClause("")
			oQuery:Open()
			updStat(anDWID, oEstat, ST_DIMENSIONS_COUNT, oTabAux:value("id"), oQuery:value(1))
			oQuery:Close()
		endif
		oQuery:FromList(TAB_DIM_FIELDS)
		oQuery:WhereClause("ID_DIM = " + dwStr(oTabAux:value("id")))
		oQuery:Open()
		updStat(anDWID, oEstat, ST_DIMENSIONS_ATT_COUNT, oTabAux:value("id"), oQuery:value(1))
		oQuery:Close()
		oTabAux:_Next()
	enddo

	oTabAux := oSigaDW:Cubes():CubeList()
	updStat(anDWID, oEstat, ST_CUBES_COUNT, 0, oTabAux:RecCount(.t.))

	oTabAux:gotop()

	oQuery:FieldList("count(ID) as cnt")
	oQuery:WithDeleted(.t.)
	oTabAux2 := initTable(TAB_DSN)
			
	while !oTabAux:eof() 
		updStat(anDWID, oEstat, ST_CUBES_DS_COUNT, oTabAux:value("id"), oTabAux2:recCount(.t., "ID_TABLE = " + dwStr(oTabAux:value("id")) + " and TIPO='F'"))

		if tcCanOpen(DWCubeName(oTabAux:value("id")))
			oQuery:FromList(DWCubeName(oTabAux:value("id")))         
			oQuery:WhereClause("")
			oQuery:Open()
			updStat(anDWID, oEstat, ST_CUBES_COUNT, oTabAux:value("id"), oQuery:value(1))
			oQuery:Close()
		endif
		oQuery:FromList(TAB_FACTFIELDS)
		oQuery:WhereClause("ID_CUBES = " + dwStr(oTabAux:value("id")))
		oQuery:Open()
		updStat(anDWID, oEstat, ST_CUBES_ATT_COUNT, oTabAux:value("id"), oQuery:value(1))
		oQuery:Close()
		oTabAux:_Next()
	enddo

	oTabAux := initTable(TAB_CONEXAO)
	updStat(anDWID, oEstat, ST_CONNECTIONS_COUNT, 0, oTabAux:RecCount(.t.))
	updStat(anDWID, oEstat, ST_CONNECTIONS_TOP_COUNT, 0, oTabAux:RecCount(.t., "TIPO = '1'"))
	updStat(anDWID, oEstat, ST_CONNECTIONS_SX_COUNT, 0, oTabAux:RecCount(.t., "TIPO = '2'"))
	updStat(anDWID, oEstat, ST_CONNECTIONS_DIR_COUNT, 0, oTabAux:RecCount(.t., "TIPO = '3'"))
return
               
/*
-----------------------------------------------------------------------
Grava/atualiza as estatisticas
-----------------------------------------------------------------------
*/
static function updStat(anDWID, aoEstat, acTipo, anObjID, anValue)

	if !aoEstat:Seek(2, { anDWID, acTipo, anObjID })
       aoEstat:Append({ {"id_dw", anDWID } , ;
       					{"tipo", acTipo } , ;
       					{"id_obj", anObjID } , ;
       					{"valor", anValue } } )
	else
       aoEstat:Update({ {"valor", anValue } } )
	endif

return

/*
-----------------------------------------------------------------------
Grava/atualiza os logs efetuados
-----------------------------------------------------------------------
*/
function DWStatUser(anDWID, anUser, acAction, axCompl)
	local oEstat := initTable(TAB_ESTAT)
    local cCompl := dtos(date()) + " " + time()
	local nRet := 0

	if acAction == ST_USERS_LOGIN
	    oEstat:Append({ {"id_dw", anDWID } , ;
   						{"tipo", acAction } , ;
   						{"id_obj", anUser } , ;
	   					{"valor", 0  } , ;
   						{"compl", cCompl} } )
		nRet := oEstat:value("id")
	else 
		if oEstat:Seek( 1, { axCompl } )
		   dDTInic := stod(left(oEstat:value("compl",.t.),8))
		   cTMInic := right(oEstat:value("compl",.t.),8)
           dDTTerm := date()
           cTMTerm := time()          
           
		   oEstat:Update( { { "valor", DWElapSecs(dDTInic, cTMInic, dDTTerm, cTMTerm) } ,;
		   					{ "compl", oEstat:value("compl",.t.) + "-" + cCompl + iif(acAction==ST_USERS_TIMEOUT, "*","") } })
		endif
	endif

	if acAction == ST_USERS_LOGIN
		if oEstat:seek( 2, { anDWID, ST_LOGIN_TODAY, val(dtos(date())) } )
		    oEstat:Update( { {"valor", oEstat:value("valor") + 1} } )
		else			
		    oEstat:Append({ {"id_dw", anDWID } , ;
	   					{"tipo", ST_LOGIN_TODAY } , ;
   						{"id_obj", val(dtos(date()))} , ;
   						{"valor", 1} } )
	 	endif
	 endif
	 
return nRet