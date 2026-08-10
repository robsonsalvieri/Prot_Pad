// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : M04 - Ferramentas
// Fonte  : m04UpdVersion - Efetua o processamento de atualização de versão
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 12.12.03 | 0548-Alan Candido |
// 22.11.07 | 0548-Alan Candido | BOPS 136453 - Correção no processo de migração de versões
//          |                   |   anteriores a R4
// 26.02.08 | 0548-Alan Candido | BOPS 141024 - Ajuste na atualização do campo ID_DW (diversas 
//          |                   |   tabelas, para compatibilização com Informix ou DB2
//          |                   |  (durante processo de migração R3 para R4)
// 29.05.08 | 0548-Alan Candido | BOPS 146059
//          |                   | Ajuste nos valores das propriedades de consulta, gravadas em TAB_CONS_PROP
// 09.12.08 | 0548-Alan Candido | FNC 00000149278/811 (8.11) e 00000149278/912 (9.12)
//          |                   | Implementação de rotina de migração das consultas com 
//          |                   | com ranking para ranking por nível de drill-down
// 30.12.08 |0548-Alan Candido  | FNC 00000011160/2008 (8.11) e 00000011201/2008 (P10)
//          |                   | Eliminação de código obsoleto e mensagens de apoio
// --------------------------------------------------------------------------------------

#include "dwincs.ch"
#include "dwUpdVersion.ch"

#define CONST_XML_FILE  "\dw2_dw3_"

static __OLD_VERSION := .f.

function DWBeforeUpdVersion(alFirst, acUsrBuild, alUpdIndex)
	default alFirst := .t.

//	if empty(acUsrBuild) .or. acUsrBuild < DWMakeBuild(3, 0, 060925)
//		conout(STR0007 + " 3.00.060925") //". Atualizando para a"
//		alUpdIndex := .t.
//	endif
return

function DWUpdVersion(acUsrBuild, alFirst)
	local nUsrBuild := acUsrBuild
	
	default alFirst := .t.
	
	if alFirst
		if !__SIGADWINST
			__OLD_VERSION := empty(nUsrBuild)
			conout(STR0001) //"Processo de atualização de versão"
			conout(STR0002 + dwStr(iif(__OLD_VERSION, STR0003 + " 3.00.061101", nUsrBuild))) //". Versão corrente instalada "###" anterior a"
			conout(STR0004 + DWBuild()) //". Versão corrente a instalar "
		else
			conout(STR0005) //"Instalação inicial"
			conout(STR0006 + DWBuild()) //". Versão instalada "
			nUsrBuild := DWLastBuild()
		endif
   	endif

	conout(".")

  	if empty(nUsrBuild)
    	nUsrBuild := DWMakeBuild(0, 0, 0)
	endif
	
	if nUsrBuild < DWMakeBuild(3, 0, 050927)
		if __OLD_VERSION
			U_DW2_DW3()
		endif
		nUsrBuild := DWMakeBuild(3, 0, 050927)
	elseif nUsrBuild < DWMakeBuild(3, 0, 070330)
		conout(STR0007 + " 3.00.070330") //". Atualizando para a"
		procUpdate( {||U070330()})
		nUsrBuild := DWMakeBuild(3, 0, 070330)
	elseif nUsrBuild < DWMakeBuild(3, 0, 070601)
		conout(STR0007 + " 3.00.070601") //". Atualizando para a"
		procUpdate( {||U070601()})
		nUsrBuild := DWMakeBuild(3, 0, 070601)
	elseif nUsrBuild < DWMakeBuild(3, 0, 080211)
		conout(STR0007 + " 3.00.080211") //". Atualizando para a"
		procUpdate( {||U080211()})
		nUsrBuild := DWMakeBuild(3, 0, 080211)						
	elseif nUsrBuild < DWMakeBuild(3, 0, 080527)
		conout(STR0007 + " 3.00.080527") //". Atualizando para a"
		procUpdate( {||U080527()})
		nUsrBuild := DWMakeBuild(3, 0, 080527)
	elseif nUsrBuild < DWMakeBuild(3, 0, 080701)
		conout(STR0007 + " 3.00.080701") //". Atualizando para a"
		procUpdate( {||U080701()})
		nUsrBuild := DWMakeBuild(3, 0, 080701)
	elseif nUsrBuild < DWMakeBuild(3, 0, 081115)
		conout(STR0007 + " 3.00.081115") //". Atualizando para a"
		procUpdate( {||U081115()})
		nUsrBuild := DWMakeBuild(3, 0, 081115) 
	elseif nUsrBuild < DWMakeBuild(3, 0, 100105)
		conout(STR0007 + " 3.00.100105") //". Atualizando para a"
		nUsrBuild := DWMakeBuild(3, 0, 100105)
	else
		nUsrBuild := DWLastBuild()
	endif

	if !DWKillApp() 
		if !(nUsrBuild == DWLastBuild())
			DWUpdVersion(nUsrBuild, .f.)
		endif
		if alFirst
		  conout(STR0008) //". O processo de re-organização de índices será executado"
		  InitDW_DB(.f. , .t.)
			conout(STR0009 + " 'TAB_CONSULTAS'") //". Invalidando as consultas em"
			procUpdate( {||InvalidarConsultas()})
		endif
	endif
	
return             

static function procUpdate(acbFuncUpd)
	local lInit := .f.
	
	if valtype(oSigaDW) != "O"
		lInit := .t.
		OpenDB()
		oSigaDW := TSigaDW():New()
	endif
	
	DWProcAllDW(acbFuncUpd)

	if lInit
		oSigaDW := nil
   	endif

return

static function procCalend()
	local dInicial, dFinal, nTotReg	

	oQuery := TQuery():New("TRA")
	oQuery:Open(,"select min(DT) as dtMin, max(DT) as dtMax, count(*) as qtde from " + TAB_CALEND + " where " + DWDelete() + " <> '*'")
	dInicial := stod(oQuery:value("dtMin")	)
	dFinal := stod(oQuery:value("dtMax"))       
	nTotReg := oQuery:value("qtde")                     
	oQuery:Close()
	if nTotReg <> 0
		DWBuildCalend(initTable(TAB_CALEND), dInicial, dFinal)
	endif
return

function InvalidarConsultas()
	local oQuery
	local aFields := {}

	aAdd(aFields, {"VALIDA", "'F'"})
	aAdd(aFields, {"VALGRA", "'F'"})
	oQuery := TQuery():New()
	oQuery:FromList(TAB_CONSULTAS)
	oQuery:Update(aFields, -1)

return

#DEFINE M_SIZE        21
#DEFINE M_DIMENSAO     1
#DEFINE M_DIM_FIELDS   2
#DEFINE M_DSN          3
#DEFINE M_CONEXAO      4 
#DEFINE M_DSNCONF      5
#DEFINE M_SXM          6
#DEFINE M_CONEXAO      7
#DEFINE M_EXPR         8
#DEFINE M_CUBELIST     9
#DEFINE M_FACTVIRTUAL 10
#DEFINE M_FACTFIELDS  11
#DEFINE M_CONSULTAS   12
#DEFINE M_CONSTYPE    13
#DEFINE M_CONS_IND    14
#DEFINE M_CONS_DIM    15
#DEFINE M_DIM_CUBES   16
#DEFINE M_DW		  17
#DEFINE M_USER_DW 	  18
#DEFINE M_USER_CONS   19
#DEFINE M_USER_CUB	  20
#DEFINE M_WHERE_COND  21 

/* Implementação da rank por nivel (consulta de tabela) */
static function U081115() 
  local oConsType := InitTable(TAB_CONSTYPE)
  local oConsProp := InitTable(TAB_CONS_PROP)
  local aValues, aAux, aAux2, nInd
	local cStyle

  oConsType:GoTop()
	
  while !oConsProp:eof()
    if oConsProp:value("nome") == "RNK"
      if oConsType:seek(1, { oConsProp:value("id_cons") })
        oConsProp:savePos()
        aAux2 := {}
       	cStyle := ""
        if oConsType:value("tipo") == TYPE_GRAPH_S
          if "|" $ oConsProp:value("valor")
	         	aAux := dwToken(oConsProp:value("valor"), ";", .f.)
	         	for nInd := 1 to len(aAux)
          		aAux[nInd] := dwToken(aAux[nInd], "|", .f.)
						next
	         	cStyle := RNK_STY_LEVEL
	        else
	         	aAux := dwToken(oConsProp:value("valor"), ";", .f.)
	        endif 
         	if cStyle == RNK_STY_LEVEL
          	for nInd := 1 to len(aAux[1])
           		aAdd(aAux2, { dwVal(aAux[1, nInd]), dwVal(aAux[2, nInd]), aAux[3, nInd] })
            next
         	elseif aAux[3] == "x" //LIMPO (sem definição)
            cStyle := RNK_STY_CLEAR
         	else
            cStyle := RNK_STY_PADRAO
         		aAdd(aAux2, { aAux[1], aAux[2], aAux[3] })
          endif
        else
          aAux := dwToken(oConsProp:value("valor"), ";", .f.)
          aAux[1] := dwVal(aAux[1])
          aAux[2] := dwVal(aAux[2])
					
          if aAux[1] == 0 .or. aAux[2] == 0
            cStyle := RNK_STY_CLEAR
          elseif aAux[3] == "A"  // CURVA ABC
            cStyle := RNK_STY_CURVA_ABC
            aAux[3] := RNK_MAIORES
         		aAdd(aAux2, { aAux[1], aAux[2], aAux[3] })
          else
            cStyle := RNK_STY_PADRAO
         		aAdd(aAux2, { aAux[1], aAux[2], aAux[3] })
          endif
        endif  
        
        aValues := {}
				aAdd(aValues, { "ID_CONS", oConsProp:value("id_cons") })
        aAdd(aValues, { "NOME"   , "RANSTL" })
        aAdd(aValues, { "SEQ"    , 0 })
        aAdd(aValues, { "VALOR"  , cStyle })
        oConsProp:append(aValues)
					                
        for nInd := 1 to len(aAux2)
	        aValues := {}
  	      aAdd(aValues, { "ID_CONS", oConsProp:value("id_cons") })
    	    aAdd(aValues, { "NOME"   , "RNK2" })
      	  aAdd(aValues, { "SEQ"    , nInd })
        	aAdd(aValues, { "VALOR"  , dwStr(aAux2[nInd], .t.) })
          oConsProp:append(aValues)
			  next
												
        oConsProp:restPos()
      endif
    endif
    oConsProp:_next()
  enddo

return

/* CONTROLE DA BUILD DO SITE COM A BUILD DO SIGADW */
static function U080701()
	local oBuild := InitTable(TAB_BUILD)
	
	oBuild:Seek(3, { BUILD_ADVPL })
	If oBuild:EoF() .OR. !(oBuild:value("environ") == BUILD_ADVPL)
		oBuild:Append({ ;
				{ "version", VERSION } , ;
                { "release", RELEASE } , ;
                { "build", BUILD } , ;
                { "environ", BUILD_ADVPL } , ;
                { "applied", date() } ;
                	} )
		oSigaDW:BuildDW()
		oSigaDW:BuildWeb()
	EndIf
	
return

static function U080527()
	local oConsType := InitTable(TAB_CONS_PROP) 
  	local aValues
      
	oConsType:GoTop()

	While !oConsType:Eof()
    if oConsType:value("nome") == "RANOU" .and. oConsType:value("valor") == ".T."
      oConsType:savePos()
      aValues := {}
      aAdd(aValues, { "ID_CONS", oConsType:value("id_cons") })
      aAdd(aValues, { "NOME"   , "RANTO" })
      aAdd(aValues, { "SEQ"    , 0 })
      aAdd(aValues, { "VALOR"  , ".T." })
      oConsType:append(aValues)
      oConsType:restPos()
    endif
		oConsType:_next()
	enddo

return

static function U080211()
	
	local oConsType := InitTable(TAB_CONSTYPE)
	local cProps := ""
	oConsType:GoTop()

	While !oConsType:Eof()
		cProps := oConsType:value("PROPS") 
		if len(DWToken(cProps, ';')) <> 26
			cProps := ''
		else
			cProps += + ';0;TRUE;FALSE'
		endif
		oConsType:update({ {"PROPS", cProps} })
		oConsType:_next()
	enddo
	
return

static function U070601()
	local tempPassword
  local oUsr := InitTable(TAB_USER)
  
  oUsr:GoTop()
	while !oUsr:EOF()
		tempPassword := DwUncripto(alltrim(oUsr:value("senha")),0)
		tempPassword:= pswEncript(alltrim(tempPassword),1)
		tempNewPassword:= dwCripto(pswEncript(tempPassword),PASSWORD_SIZE,0)
		oUsr:update({ {"senha", tempNewPassword} })
		oUsr:_next()
	enddo

return

static function U070330()
	
	local oCons := InitTable(TAB_CONSULTAS)
	oCons:GoTop()
	while !oCons:EOF()
		if empty(oCons:value("GRUPO")) .and. oCons:value("D_E_L_E_T_") <> '*' .and. oCons:value("id_dw") == oSigaDW:DWCurr()[1]
		    oCons:update( { { "GRUPO", dwstr(oCons:value("cube_desc")) } } )
		endif
	  oCons:_next()
	enddo

return

static function U_DW2_DW3()
	local oTab, oTabAux, oTabCons, oTabCub, oUsers, aDWList := {}
	local aAux, bAux, cAux, nInd, nQtdeDW, nAux, nIdDw
	local aDW, oQuery := TQuery():New()
	local aMasterTab := array(M_SIZE)
	local oImpFile, aImpObjects := {}
				
	conout("-----------------------------------------------------------")
	conout(STR0010) //"  Processamentos genéricos"
	conout("-----------------------------------------------------------")
    
    // configura a exibição de mensagens de usuários
	oSigaDW:ShowMsg(.T.)
	oSigaDW:SaveCfg()

	// ------------------------------------------------------------------------
	// TAB_LOG ----------------------------------------------------------------
	conout(STR0011 + " TAB_LOG") //"  . Processando"
	oTab := InitTable(TAB_LOG)
	oTab:Reindex()

   	// ------------------------------------------------------------------------
  	// TAB_CONFIG - transf. 'cubos' para TAB_DW -------------------------------
	conout(STR0012) //"  . Inicializando 'datawarehouses'"
	bAux := { |x| strTran(strTran(DWStr(alltrim(x), .t.), '|', '"'), "$", "'") }
	oTab := InitTable(TAB_CONFIG)
	oTab:Reindex()
	
	if oTab:Seek(2, { "cubos", "len" } )
		oSigaDW:foDWList := TDWList():New()
		nQtdeDW := dwVal(oTab:Value('valor'))
		for nInd := 1 to nQtdeDW
			if oTab:Seek(2, { "cubos", strZero(nInd,5) } )
				cAux := eval(bAux, oTab:Value('valor'))
				aAux := &(cAux)
				aAdd(aDWList, { aAux[1], oSigaDW:InitDW(aAux[1], aAux[2], 'dw_new.gif', .f.) })
			endif
		next
	else //#### TODO remover este else após updversion 2->3 estiver ok
		aEval(oSigaDW:DWList():Items(), { |x| aAdd(aDWList, { x[DW_NAME], x[DW_ID] })})
	endif
	
	oSigaDW:fnDWIndex := -1 //indica que processamento não é especifico para um DW

	oTab:close()
	DWDelAllRec(TAB_CONFIG, "GRUPO = 'cubos'")
		
  	// ------------------------------------------------------------------------
  	// TAB_USER - transf. conteúdo do campo senha para valor em hexa ----------
	conout(STR0011 + " TAB_USER") //"  . Processando"

	oTab := InitTable(TAB_USER)
	oTab:Reindex()

	while !oTab:Eof()
		oTab:update({ {"senha", DWCripto(oTab:value("senha"), PASSWORD_SIZE, 0) }, { "folderMenu", .T. } })
		oTab:_Next()
	enddo

	oTab:close()
	
  	// ------------------------------------------------------------------------
  	// PROCESSAMENTO DO DW PRINCIPAL (1o. na lista)
  	// ------------------------------------------------------------------------

	conout("-----------------------------------------------------------")
	conout(STR0013) //"  Preparando as tabelas mestres"
	conout("-----------------------------------------------------------")
	aMasterTab[M_DIMENSAO]   := InitTable(TAB_DIMENSAO,,.t.,.t.)
	aMasterTab[M_DIM_FIELDS] := InitTable(TAB_DIM_FIELDS,,.t.,.t.)
	aMasterTab[M_DSN]        := InitTable(TAB_DSN,,.t.,.t.)
	aMasterTab[M_CONEXAO]    := InitTable(TAB_CONEXAO,,.t.,.t.)
	aMasterTab[M_DSNCONF]    := InitTable(TAB_DSNCONF,,.t.,.t.)
	aMasterTab[M_SXM]        := InitTable(TAB_SXM,,.t.,.t.)
	aMasterTab[M_CONEXAO]    := InitTable(TAB_CONEXAO,,.t.,.t.)
	aMasterTab[M_EXPR]       := InitTable(TAB_EXPR,,.t.,.t.)
	aMasterTab[M_CUBELIST]   := InitTable(TAB_CUBESLIST,,.t.,.t.)
	aMasterTab[M_FACTVIRTUAL]:= InitTable(TAB_FACTVIRTUAL,,.t.,.t.)
	aMasterTab[M_FACTFIELDS] := InitTable(TAB_FACTFIELDS,,.t.,.t.)
	aMasterTab[M_CONSULTAS]  := InitTable(TAB_CONSULTAS,,.t.,.t.)
	aMasterTab[M_CONSTYPE]   := InitTable(TAB_CONSTYPE,,.t.,.t.)
	aMasterTab[M_CONS_IND]   := InitTable(TAB_CONS_IND,,.t.,.t.)
	aMasterTab[M_CONS_DIM]   := InitTable(TAB_CONS_DIM,,.t.,.t.)
	aMasterTab[M_DIM_CUBES]  := InitTable(TAB_DIM_CUBES,,.t.,.t.)
	aMasterTab[M_DW]      	 := InitTable(TAB_DW,,.t.,.t.)
	aMasterTab[M_USER_DW]	   := InitTable(TAB_USER_DW,,.t.,.t.)
	aMasterTab[M_USER_CONS]  := InitTable(TAB_USER_CONS,,.t.,.t.)
	aMasterTab[M_USER_CUB]   := InitTable(TAB_USER_CUB,,.t.,.t.)
	aMasterTab[M_WHERE_COND] := InitTable(TAB_WHERE_COND,,.t.,.t.)
	
	aDW := aDWList[1]
	conout("-----------------------------------------------------------")
	conout(STR0011 + " " + aDW[1] + "(" + dwStr(aDW[2]) + ")") //"  . Processando"
	conout("-----------------------------------------------------------")
	
	// ------------------------------------------------------------------------
	// TAB_CONEXAO - ajuste do ID_DW ------------------------------------------
	conout(STR0011 + " TAB_CONEXAO") //"  . Processando"
	
	oQuery:FromList(TAB_CONEXAO)
	oQuery:WhereClause("ID_DW = 0")
	oQuery:Update({{"ID_DW", dwVal(aDW[2])}}, -1)

  	// ------------------------------------------------------------------------
  	// TAB_DIMENSAO - ajuste do ID_DW -----------------------------------------
	conout(STR0011 + " TAB_DIMENSAO") //"  . Processando"
	
	oQuery:FromList(TAB_DIMENSAO)
	oQuery:WhereClause("ID_DW = 0")
	oQuery:Update({{"ID_DW", dwVal(aDW[2])}}, -1)
	
  	// ------------------------------------------------------------------------
  	// TAB_CUBESLIST - ajuste do ID_DW ----------------------------------------
	conout(STR0011 + " TAB_CUBESLIST") //"  . Processando"
	
	oTab := InitTable(TAB_CUBESLIST)
	oTab:Reindex()
	oTab:close()

	oQuery:FromList(TAB_CUBESLIST)
	oQuery:WhereClause("ID_DW = 0")
	oQuery:Update({{"ID_DW", dwVal(aDW[2])}}, -1)

  	// ------------------------------------------------------------------------
  	// TAB_DSN - ajuste do tipo da fonte de dados do cubo----------------------
	conout(STR0011 + " TAB_DSN") //"  . Processando"
	oQuery:FromList(TAB_DSN)
	oQuery:WhereClause("TIPO = 'F'")
	oQuery:Update({{"TIPO", OBJ_CUBE}}, -1)

  	// ------------------------------------------------------------------------
  	// TAB_CONSULTAS - ajuste do ID_DW ----------------------------------------
	conout(STR0011 + " TAB_CONSULTAS") //"  . Processando"
	oTab := InitTable(TAB_CONSULTAS)
	oTab:Reindex()
	oTab:close()

	oQuery:FromList(TAB_CONSULTAS)
	oQuery:WhereClause("ID_DW = 0")
	oQuery:Update({{"ID_DW", dwVal(aDW[2])}}, -1)

  	// ------------------------------------------------------------------------
  	// TAB_WHERE_COND - ajuste do campo LAST_VALUE ----------------------------
	conout(STR0011 + " TAB_WHERE_COND") //"  . Processando"
	oTab := InitTable(TAB_WHERE_COND)
	
  	while !oTab:EOF()
  		oTab:update({ { "last_value", replace(oTab:value("last_value"),"'", "") }})
  		oTab:_next()
  	enddo
	
	oTab:close()
	
	// ------------------------------------------------------------------------
	// PROCESSAMENTO DOS DW´s SECUNDÁRIOS (2o. em diante na lista)
	// As informações destes DW´s serão transportados para o "principal"
	// ------------------------------------------------------------------------
	if len(aDWList) > 1
		conout("===============================================================")
		conout(STR0014) //"Preparando DW´s para atualização de versão"
		conout("===============================================================")
		
		for nInd := 2 to len(aDWList)
			aDW := aDWList[nInd]
			
			conout(STR0011 + " " + aDW[1] + "(" + dwStr(aDW[2]) + ")") //"  . Processando"
			conout("--------------------------------------------------")

			// ajusta para utilizar o nome prefixado		
			__DWPrefixo := chr(47 + nInd)
			__DWIDTemp := aDW[2]
            
			DWMetadados(CONST_XML_FILE + __DWPrefixo + ".xml")
		    
			CloseDB(.t.)
			__DWPrefixo := ""
			__DWIDTemp := -1
			
			conout("")
		next
		
		conout("===============================================================")
		conout(STR0015) //"Processando atualização de versão"
		conout("===============================================================")
		
		for nInd := 2 to len(aDWList)
			aDW := aDWList[nInd]
			
			conout(STR0016 + " " + aDW[1] + "(" + dwStr(aDW[2]) + ")") //". Atualizando"
			conout("--------------------------------------------------")

			// ajusta para utilizar o nome prefixado		
			oSigaDW:SelectDW(, aDW[2])
			oImpFile := TDWImportMeta():New(CONST_XML_FILE + chr(47 + nInd) + ".xml")
			
			conout(".. " + STR0017) //"Conexões"
			aAdd(aImpObjects, { "Conexões", oImpFile:ImportServes() })
	
			conout(".. " + STR0018) //"Dimensões"
			aAdd(aImpObjects, { "Dimensões", oImpFile:ImportDims(.t.)})

			conout(".. " + STR0019) //"Cubos"
			aAdd(aImpObjects, { "Cubos", oImpFile:importCubes(.t.)})

			conout(".. " + STR0020) //"Consultas"
			aAdd(aImpObjects, { "Consultas", oImpFile:importQuerys()})
			
			conout("")
		next
	endif
	
	conout("--------------------------------------------------")
	conout(STR0021) //"Migrando os privilégios de usuários"
	conout("--------------------------------------------------")
	
	// recupero e faço iteração por todos os DWs
	for nInd := 1 to len(aDWList)
		
		nIdDw := aDWList[nInd, 2]
		
		// tabelas de privilégios de acesso à DWs
		conout(STR0022 + DwStr(nIdDw) + " - " + aDWList[nInd, 1] ) //". Migrando Privilégios para o Datarehouse: "
		oTab := InitTable( TAB_USER_DW )
		oTab:open()
 		
		// itero pelos registros de privilégios de acesso para um determinado DW
		conout(STR0023) //".. Privilégios de acesso para o usuário"
		oTab:Seek(3, { aDWList[nInd, 1] })
		cAux := ""
		while !oTab:EoF() .and. aDWList[nInd, 1] == oTab:value("DW")
			cAux += "." + DwStr(oTab:value("id_user")) + "|" + DwStr(oTab:value("status"))
			// instancio o objeto responsável por abastrair os privilégios de um usuário
			oPrivileges := TDWPrivileges():New(nIdDw, oTab:value("id_user"))
			
			// crio o objeto que contém os privilégios do usuário
			oPrivilegOper := TDWPrivOper():New()
			oPrivilegOper:Acess(oTab:value("status"))
			
			// salvo os privilégios na nova base de dados
			oPrivileges:SaveDwPrivileges(nIdDw, oPrivilegOper)
			
			oTab:_Next()
		enddo
		conout("..." + cAux)
		
		// tabela de privilégios de consultas
		conout(STR0024) //".. Privilégios para consultas"
		oTab := TQuery():New( DWMakeName("7110") )
		oTab:FieldList("ID, ID_USER, ID_CONS, MANUT, CONS, EXPORT")
		oTab:FromList( "DW"+DwStr(nIdDw-1)+"7110" )
		oTab:OrderBy("ID")
		
		// itera pelos privilégios de criação de consulta
		conout(STR0025) //"... Privilégios para criação de consultas"
		oTab:WhereClause( "ID_CONS = '0'" )
		oTab:Open()
		cAux := ""
		while !oTab:EoF() .and. oTab:value("ID_CONS") == 0
			cAux += "." + DwStr(oTab:value("id_user")) + "|" + oTab:value("CONS")
			// instancio o objeto responsável por abstrair os privilégios de um usuário
			oPrivileges := TDWPrivileges():New(nIdDw, oTab:value("ID_USER"))
			
			// crio o objeto que contém o privilégio de criação de consulta do usuário
			oPrivilegOper := TDWPrivOper():New()
			oPrivilegOper:Create(DwConvTo("L", oTab:value("CONS")))
			
			// salvo os privilégios na nova base de dados
			oPrivileges:SaveCreatePrivileges(oPrivilegOper)
			
			oTab:_Next()
		enddo
		oTab:Close()
		conout("..." + cAux)
		
		// iteração pelas consultas de cada dw
		conout(STR0026) //"... Privilégios sobre consultas"
		oTabCons := TQuery():New( DwMakename("5200") )
		oTabCons:FieldList("ID, TIPO, NOME, ID_USER")
		oTabCons:FromList( "DW" + DwStr(nIdDw-1) + "5200" )
		oTabCons:WhereClause( "TIPO = 'P'" )
		oTabCons:Open()
		while !oTabCons:EoF()
			// itero pelos registros de privilégios para consultas
			oTab := TQuery():New( DWMakeName("7110") )
			oTab:FieldList("ID, ID_USER, ID_CONS, MANUT, CONS, EXPORT")
			oTab:FromList( "DW"+DwStr(nIdDw-1)+"7110" )
			oTab:WhereClause( "ID_CONS = " + DwStr(oTabCons:value("id")) )
			oTab:OrderBy("ID")
			oTab:Open()
			cAux := ""
			
			if nIdDw > 1
				nAux := -1
				// recupera o novo id para a consulta em questão
				oTabAux := InitTable( TAB_CONSULTAS )
				__DWIDTemp := nIdDw
				if oTabAux:Seek(8, { oTabCons:value("TIPO"), oTabCons:value("ID_USER"), oTabCons:value("NOME") })
					nAux := oTabAux:value("id")
				endif
				__DWIDTemp := -1
				oTabAux:Close()
			endif
			
			while !oTab:EoF() .and. oTab:value("ID_CONS") == oTabCons:value("ID")
				if nIdDw == 1
					nAux := oTab:value("ID_CONS")
				endif
				cAux += "." + DwStr(oTab:value("id_user")) + "|" + DwStr(nAux) + "|" + oTab:value("CONS") + "|" + oTab:value("MANUT") + "|" + oTab:value("EXPORT")
				// instancio o objeto responsável por abstrair os privilégios de um usuário
				oPrivileges := TDWPrivileges():New(nIdDw, oTab:value("ID_USER"))
				
				// crio o objeto que contém os privilégios do usuário
				oPrivilegOper := TDWPrivOper():New()
				oPrivilegOper:Acess(DwConvTo("L", oTab:value("CONS")))
				oPrivilegOper:Maintenance(DwConvTo("L", oTab:value("MANUT")))
				oPrivilegOper:Export(DwConvTo("L", oTab:value("EXPORT")))
				
				// salvo os privilégios na nova base de dados
				oPrivileges:SaveQueryPrivileges(nAux, oPrivilegOper)
				
				oTab:_Next()
			enddo
			conout("...." + oTabCons:value("nome") + "(" + DwStr(oTabCons:value("ID")) + ") (" + cAux + ".)")
			oTab:Close()
			
			oTabCons:_Next()
		enddo
		oTabCons:Close()
		
		// iteração por todos os privilégios de cubos
		conout(STR0027) //"... Privilégios sobre cubos"
		oTabCub := TQuery():New( DwMakeName("5000") )
		oTabCub:FieldList("ID, NOME")
		oTabCub:FromList( "DW"+DwStr(nIdDw-1)+"5000" )
		oTabCub:OrderBy("ID")
		oTabCub:open()
		while !oTabCub:EoF()
			// itero pelos registros de privilégios do usuário para um determinado cubo
			// tabela de privilégios de cubos
			oTab := TQuery():New( DwMakeName("7120") )
			oTab:FieldList("ID, ID_USER, ID_CUBE, CONS, MANUT")
			oTab:FromList( "DW"+DwStr(nIdDw-1)+"7120" )
			oTab:WhereClause( "ID_CUBE = " + DwStr( oTabCub:value("ID")) )
			oTab:Open()
			cAux := ""
			
			if nIdDw > 1
				nAux := -1
				oTabAux := InitTable( TAB_CUBESLIST )
				__DWIDTemp := nIdDw
				if oTabAux:Seek(2, { oTabCub:value("NOME") })
					nAux := oTabAux:value("id")
				endif
				__DWIDTemp := -1
				oTabAux:Close()
			endif
			
			while !oTab:EoF() .and. oTab:value("ID_CUBE") == oTabCub:value("ID")
				if nIdDw == 1
					nAux := oTab:value("ID_CUBE")
				endif
				cAux += "." + DwStr(oTab:value("id_user")) + "|" + DwStr(nAux) + "|" + oTab:value("CONS") + "|" + oTab:value("MANUT")
				// instancio o objeto responsável por abastrair os privilégios de um usuário
				oPrivileges := TDWPrivileges():New(nIdDw, oTab:value("ID_USER"))
				
				// crio o objeto que contém os privilégios do usuário
				oPrivilegOper := TDWPrivOper():New()
				oPrivilegOper:Acess(DwConvTo("L", oTab:value("CONS")))
				oPrivilegOper:Maintenance(DwConvTo("L", oTab:value("MANUT")))
				
				// salvo os privilégios na nova base de dados
				oPrivileges:SaveCubePrivileges(nAux, oPrivilegOper)
				
				oTab:_Next()
			enddo
			conout("...." + oTabCub:value("nome") + "(" + DwStr(oTabCub:value("ID")) + ") (" + cAux + ".)")
			oTab:Close()
			
			oTabCub:_Next()
		enddo
		oTabCub:Close()
		
	next
	
	// ------------------------------------------------------------------------
  	// TAB_MSG - ajuste das mensagens ----------------------------------------
	conout(STR0028) //". Processando TAB_MSG"
	
	oTab := InitTable(TAB_MSG)
	oTab:Reindex()
	oTab:close()
	
	oTab := InitTable(TAB_MSG_USER,,.t.,.t.)
	oTab:Reindex()
	oTab:close()
	
	aAux := {}
	oTabAux := InitTable(TAB_MSG_USER)
	oTab := InitTable(TAB_MSG)
	while !oTab:EoF()
		aAdd(aAux, { oTab:value("id"), ;
				   	{	{"dt_pub_ini", oTab:value("dt")}, ; // atualiza a data de publicação inicial como sendo a antiga data
						{"hr_pub_ini", oTab:value("hr")}, ; // atualiza a hora de publicação inicial como sendo a antiga hora
						{"dt_pub_fin", (date() + 30)}, ; // atualiza a data de publicação final como sendo HOJE + 30 dias
						{"hr_pub_fin", time()}, ; // atualiza a hora de publicação final como sendo AGORA
						{"data_incl", date()} ; // atualiza a data de inclusão como sendo HOJE
					}})
		oTab:_Next()
	enddo
	
	oTabAux := InitTable(TAB_USER)
	bAux := {}
	oTabAux:Seek(2, {""})
	while !oTabAux:EoF()
		aAdd(bAux, oTabAux:value("id"))
		oTabAux:_Next()
	enddo
	
	for nInd := 1 to len(aAux)
		oTab:Seek(1, {aAux[nInd, 1]})
		
		aEval(bAux, {|x| aAdd(aAux[nInd, 2], {"ID_USER", x})})
		
		oTab:Update(aAux[nInd, 2])
	next
	oTab:close()
	
	if len(aImpObjects) > 0 
		conout(STR0029) //".. Número de objetos processados"
		aEval(aImpObjects, { |x| conout("... " + padr(x[1], 12) + "-> " + strZero(iif(valType(x[2])=="U", 0, len(x[2])), 3)) } )
	endif
	
return

static function ApenasParaEleminarAvisosCompilador()
	if .f.
		procCalend()
		ApenasParaEleminarAvisosCompilador()
	endif
return