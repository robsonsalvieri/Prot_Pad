// ######################################################################################
// Projeto: DATAWAREHOUSE
// Modulo : ImpExp
// Fonte  : MakeImpDBF - Classe para execução de importações DBF
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 13.12.05 | 0548-Alan Candido | Versão 3
// 23.01.08 | 0548-Alan Candido | BOPS 136637 - Implementação de importação otimizada
//          |                   | para o Informix e ajuste no calculo de acompanhmento
//          |                   | de importação (percentual executado). 
// 08.08.08 | 0548-Alan Candido | BOPS 151591
//          |                   | Ajuste de lay-out e apresentação de mensagens.
// 15.12.08 | 0548-Alan Candido | FNC 09025/2008 (8.11) e 09034/2008 (10)
//          |                   | . Adequação de geração de máscara em campos numéricos e datas, 
//          |                   | para respeitar o formato conforme idioma 
//          |                   | (chave RegionalLanguage na sessão do ambiente).
// --------------------------------------------------------------------------------------

#include "dwincs.ch"
#include "tbiconn.ch"   
#include "dwidprocs.ch"
#include "TopConn.ch"
#include "mkimpdbf.ch"

// esta constante é utilizada para definir o numero de registro de cada transação
#define LEN_TRANSACTION 2000
#define DIVISOR_LOTE_IPC 20
#define INTERVALO_ENV_PROGRESS 30 // tempo máximo sem enviar informação ao progressBar 
#define LOTE_INFORMIX 50

/*
--------------------------------------------------------------------------------------
Classe: TDoImpDBF
Uso   : Execução de importações DBF
--------------------------------------------------------------------------------------
*/
class TDoImpDBF from TDWObject

  data faTimes 
	data foSource
	data foTarget
	data fcFilename
	data fcForZap
	data faFields
	data fnRecLimit
	data flAbort
	data flWarning
		
	method New(aoMakeImp) constructor
	method Free()
	method NewDoImpDBF()
	method FreeDoImpDBF()

	method Open()
	method Close()
	method IsOpen()
	
	method Filename()	
	
	method CreateWF(abLog)
	method DropWF()
	method Filter(acValue)
	method RecCount()
	method buildCalend(dtMin, dtMax, abLog)
	method TransfData(abLog, abLogFile)
	method OraTransfCube(aoSource, aoTarget, abLog, aaDimID, aoCube)
	method InfTransfCube(aoSource, aoTarget, abLog, aaDimID, aoCube, anQtde, anIns, anAtz)
	method TransfDim(anDimID, abLog, abLogFile)
	method OraTransfDim(aoDim, abLog)
	method InfTransfDim(aoDim, abLog, anLidos, anIns, anUpd)
	method ForZap(acValue)
	method RecLimit(anValue)
	method VerCalend(aoDS, aDtMin, aDtMax, abLog)
	method getSource()
	method ImpInval()
	method ImpInvalB()
	method ImpInvalA()
	method Optimizer()
	method ProcCons()
	method EmbedSQL() 
	method Fields()
endclass

/*
--------------------------------------------------------------------------------------
Construtor e destrutor da classe
--------------------------------------------------------------------------------------
*/
method New(aoMakeImp) class TDoImpDBF

	::NewDoImpDBF(aoMakeImp)

return
	 
method Free() class TDoImpDBF

	::FreeDoImpDBF()

return

method NewDoImpDBF(aoMakeImp) class TDoImpDBF
  local dHoje := date()
  local cTime := time()
  
	::NewObject(aoMakeImp) 

	::fcFilename := ""
	::fcForZap := ""
	::fnRecLimit := 0
	::faTimes := { dHoje, cTime, dtoc(dHoje) + " " + cTime }
	
return
	 
method FreeDoImpDBF() class TDoImpDBF

	::FreeObject()
	
return

/*
--------------------------------------------------------------------------------------
Propriedade Optimizer
--------------------------------------------------------------------------------------
*/
method Optimizer() class TDoImpDBF

return ::Owner():Optimizer()

/*
--------------------------------------------------------------------------------------
Propriedade ProcCons
--------------------------------------------------------------------------------------
*/
method ProcCons() class TDoImpDBF

return ::Owner():ProcCons()

/*
--------------------------------------------------------------------------------------
Propriedade EmbedSQL
--------------------------------------------------------------------------------------
*/
method EmbedSQL() class TDoImpDBF

return ::Owner():EmbedSQL()

/*
--------------------------------------------------------------------------------------
Propriedade Filename
--------------------------------------------------------------------------------------
*/
method Filename(acValue) class TDoImpDBF

	property ::fcFilename := acValue

return ::fcFilename

/*
--------------------------------------------------------------------------------------
Abre a tabela
--------------------------------------------------------------------------------------
*/
method Open() class TDoImpDBF
	local lRet := .f., aFields, nInd

	if valType(::Owner()) == "U" .or. valType(::Owner():foRPC) == "U"
		::foSource := TTable():New(::Filename(), DWMakeName("IMP"))
	else
		::foSource := TRPCTable():New(::Owner():foRPC, ::Filename(), DWMakeName("IMP"), ::Owner():Empresa(), ::Owner():Filial())
	endif

	lRet := ::foSource:Open(, ::Owner():UseSX(), iif(::Owner():EmbedSQL(), ::Owner():ExecEmbed(), ""))

	if lRet
		aFields := ::foSource:Fields()
		for nInd := 1 to len(aFields)
			if aFields[nInd, FLD_TYPE] == "N" .and. aFields[nInd, FLD_DEC] == 0
   			::foSource:setField(aFields[nInd, FLD_NAME], "N", aFields[nInd, FLD_LEN], 8)
			endif
		next
	endif		
return lRet

/*
--------------------------------------------------------------------------------------
Identifica se a tabela esta aberta 
--------------------------------------------------------------------------------------
*/
method IsOpen() class TDoImpDBF

return valType(::foSource)=="O" .and. ::foSource:IsOpen()

/*
--------------------------------------------------------------------------------------
Fecha a tabela
--------------------------------------------------------------------------------------
*/
method Close() class TDoImpDBF

	::foSource:Close()
	::foSource := NIL

return

/*
--------------------------------------------------------------------------------------
Cria o arquivo de trabalho fisicamente
--------------------------------------------------------------------------------------
*/
method CreateWF(abLog) class TDoImpDBF
	local oCube, aDimID, cField
	local lErro := .f.
	
	private oDSNConf := InitQuery(SEL_DSNCONF2)
	private oTarget

	::foTarget := TTable():New(DWMakeName("TRA"))
	oTarget := ::foTarget 

	if oTarget:Exists()
		::foTarget:DropTable()
	endif

	if !empty(::Owner():CubeID())
	    eval(abLog, IPC_ETAPA, , IMP_ETA_1Q)
		oDSNConf:params(1, ::Owner():CubeID())
		oDSNConf:params(2, ::Owner():DSNID())

		oDSNConf:Open()
		while !oDSNConf:eof()
			cField := oDSNConf:value("nome",.t.)
			oTarget:AddField(nil, cField, oDSNConf:value("tipo",.t.), oDSNConf:value("tam",.t.), oDSNConf:value("ndec",.t.))
			oTarget:setOrigField(cField, oDSNConf:value("cpoorig", .t.))
			if oDSNConf:value("id_roteiro") != 0 .and. !empty(alltrim(oDSNConf:value("roteiro",.t.)))
				if SGDB() == DB_ORACLE
//####TODO Finalizar o roteiro por SP
					if oDSNConf:value("isSQL") != ::Optimizer()
            eval(abLog, IPC_ERRO, STR0001+" ["+cField+"] "+ STR0002) //"O roteiro do campo" "não esta de acordo com a opção de otimizar ou não."
						lErro := .t.
					endif
				else
					cRoteiro := iif(empty(oDSNConf:value("cpoorig", .t.)), cField, oDSNConf:value("cpoorig", .t.))
					cRoteiro := "{ || DW_Value := DWSinonimo('"+cRoteiro+"'), execRoteiro(" + DWStr(oDSNConf:value("id_roteiro"))+") }"
					oTarget:SetRoteiro(cField, &(cRoteiro))
				endif
			elseif !empty(oDSNConf:value("cpoorig"))
				cRoteiro := "{ || DWSinonimo('"+oDSNConf:value("cpoorig", .t.)+"') }"
				oTarget:SetRoteiro(cField, &(cRoteiro))
			endif
			oDSNConf:_Next()
		enddo						

    eval(abLog, IPC_ETAPA, , IMP_ETA_2Q)
		oCube := oSigaDW:OpenCube(::Owner():CubeID(),,.t.)
		aDimID := oCube:DimProp("ID")
		aEval(aDimID, { |x| oTarget:AddField({||-1}, DWKeyDimname(x), "N", 10, 0) })		
		oSigaDW:CloseCube(oCube)
	else
		aEval(::Fields(), { |x| aAdd(oTarget:Fields(), aclone(x))})
	endif
  eval(abLog, IPC_ETAPA, , IMP_ETA_3Q)
	oTarget:CreateTable()
	
	if SGDB() == DB_INFORMIX
		oTarget:DropRecnoIndex()
    if tcSQLExec("alter table " + lower(oTarget:TableName()) + " type (raw)") <> 0                          
      conout(tcSqlError())
      eval(abLog, IPC_ERRO, STR0003)  //"Não foi possivel desligar log da tabela de trabalho. Veja log de console para detalhes."
    endif
  endif
	
return !lErro
	
/*
--------------------------------------------------------------------------------------
Elimina o arquivo de trabalho fisicamente
--------------------------------------------------------------------------------------
*/
method DropWF() class TDoImpDBF

	::foTarget:DropTable()
	::foTarget := NIL

return

/*
--------------------------------------------------------------------------------------
Aplica filtro na origme
--------------------------------------------------------------------------------------
*/
method Filter(acValue) class TDoImpDBF
	local cRet := ::foSource:Filter()
		
	if valType(acValue) == "C"
		::foSource:Filter(acValue)	 
		::foSource:goTop()
	endif
	
return cRet

/*
--------------------------------------------------------------------------------------
Transfere os dados aplicando o roteiro se existir
--------------------------------------------------------------------------------------
*/                             
static function calcLote(anTotal)
	local nRet := 250

	if anTotal < 1
	elseif anTotal < 100
		nRet := 1
	else
		nRet := int(anTotal * 0.01)
		if nRet < 250
			nRet := 250
		endif
	endif
	
return nRet

static function prepZapCube(aoCube, acZapCond, aaAuxFrom)
	local cRet := acZapCond, aAux, nInd, cAux, nAlias := 0
	local aWhere := {}, cAlias
	
	aEval(aoCube:getIndicadores(), { |x, i|;
                   cRet := strTranIgnCase(cRet, "Fato->"+alltrim(x[2]), x[2])})
	
	aAux := aoCube:DimProp("ID")
	for nInd := 1 to len(aAux)
		cAux := aoCube:DimProp("NOME", nInd)
		if cAux+"->" $ cRet
			nAlias++
			cAlias := "A"+strzero(nAlias,2)
			if ascan(aaAuxFrom, {|x| x[1] == DWDimName(aAux[nInd]) + " " + cAlias}) == 0
				aAdd(aaAuxFrom, { DWDimName(aAux[nInd]) + " " + cAlias })
				aAdd(aWhere, { DWKeyDimname(aAux[nInd]) + "=" + cAlias+".ID" })
			endif
			cRet := strTran(cRet, cAux+"->", cAlias+".")
		endif
		cRet := strTranIgnCase(cRet, cAux, DWDimName(aAux[nInd]))
	next
	if len(aaAuxFrom) > 0
		cRet := "ID in (select C.ID from " + aoCube:Fact():TableName() + " C, " + dwConcatWSep(",", aaAuxFrom) + " where " + cRet
	endif
	if len(aWhere) != 0
		cRet := cRet + " and " + dwconcatWSep(" and ", aWhere)
	endif
	if len(aaAuxFrom) > 0
		cRet += ")"
	endif

return cRet

method TransfData(abLog, abLogFile) class TDoImpDBF   
	local oSource := ::foSource, oTarget := ::foTarget
	local oFato, nTotRec 
	local nQtde := 0, nIns := 0, nAtz := 0, nQtdeConf := 0, nInvalids := 0
	local cValues, nLote, oFile, nInd, aSQL, aValid, aSQLVar, aSQLCur1, aSQLCur2
	local oQuery, oQuery2, oCube, aDimID, oDim, aIndexInfo, nSecInic := 0, cPrev := ""
	local lAutoUpd := .f., lDimEmpFil := .f., aAux, aAux2, aAux3, aAux4, nPos
	local nTotRec2 := 0, aIgnSQL := {}, aValues, aFldsTarget, aRptKeys := {} 
	local aFields, nAux, aKeyNames := {}, aIndNames := {}, qAux, aDimNames := {}
	local aAuxFrom, cXXX
	local cProcExec := DWMakeName("DWPROC")
	local cProc := cProcExec // + "_" + DWEmpresa()
	local nRet := 0, x
	local lRet := .t., nRegTrans := 0
	local lFirst := .t., aDownList := {}, oArqLog
	local cDuracao := ""
	local nIDEstat := ::Owner():startEstatistica(STR0004)  //"Atualização do cubo"
  local nUltEnvio := seconds() + (INTERVALO_ENV_PROGRESS * 2) 
	local dtMin := stod("20991231"), dtMax := stod("19000101")
  local lAbort
  local xx

	private cSQL
	                                                  
	::flAbort := .F.
	::flWarning := .F.
	lAbort := .f.
	
	if valType(abLog) != "B" 
		abLog := { || }
	endif
	
	oCube := oSigaDW:OpenCube(::Owner():CubeID(),,.t.)
	aDimID := oCube:DimProp("ID")
	aEval(aDimID, { |x| oTarget:AddField(nil, DWKeyDimname(x), "N") })		
	oQuery := TQuery():New(DWMakeName("TRA"))

	eval(abLog, IPC_ETAPA, STR0005, IMP_ETA_INICIO)  //"Verificando a integridade das dimensões"
	eval(abLogFile, STR0005)  //"Verificando a integridade das dimensões"

	aAux3 := {}
	for nInd := 1 to len(aDimID)
		oSigaDW:Dimensao():seek(1, { aDimID[nInd] } )

		oDim := oCube:DimObj(oSigaDW:Dimensao():value("nome",.t.))

		eval(abLog, IPC_ETAPA, , nInd / len(aDimID))
		eval(abLog, IPC_AVISO, oDim:Descricao() + dwFormat("([999]/[999])", { nInd,len(aDimID)}))

		aIndexInfo := oDim:Indexes()[2]

		aSQL := {}
		if (SGDB() <> DB_INFORMIX)
			aEval(aIndexInfo[4], { |x| aAdd(aSql, x + ",") })
		endif
    aAdd(aSQL, "count(*) Z")

		oQuery:FieldList(DWConcatWSep(" ", aSQL))
		oQuery:FromList(DWDimName(aDimID[nInd]))		
		oQuery:WithDeleted(.t.)
		aSQL := {}
    aEval(aIndexInfo[4], { |x| aAdd(aSql, x + ",") })
    aSql[len(aSQL)] := left(aSQL[len(aSQL)], len(aSQL[len(aSQL)])-1)
		oQuery:GroupBy(DWConcatWSep(" ", aSQL))	   		
		oQuery:HavingClause("count(*) <> 1")

		oQuery2 := TQuery():New(DWMakeName("TRA"))
		oQuery2:FieldList("count(*)")
		if (SGDB() == DB_INFORMIX)
			oQuery2:FromList(DWDimName(aDimID[nInd]))
			oQuery2:WhereClause("0 < ("+oQuery:SQL()+")")
		else
			oQuery2:FromList("("+oQuery:SQL()+") X")
		endif
		oQuery2:WithDeleted(.t.)
		oQuery2:Open()

   	if oQuery2:value(1) > 0
     	::flAbort := .t.
			aAdd(aAux3, "[ " + oDim:Descricao()+" ] "+STR0006+" " + dwstr(oQuery2:value(1)) + " " + STR0007)  //"contem "  //"registro(s) duplicado(s)"
		else
			aAdd(aAux3, "[ " + oDim:Descricao()+" ] " + STR0008)  //"está integra"
    endif
	  oQuery2:close()   
	next
	eval(abLog, IPC_ETAPA, , IMP_ETA_FIM)
	
	oQuery:Clear()
	
	eval(abLogFile, STR0009) //"A verificacäo da integridade, apurou que ..."
	aEval(aAux3, { |x| eval(abLogFile, "&nbsp;&nbsp;&nbsp;... "+x)})

	if ::Optimizer() .and. !::flAbort
	  if SGDB() == DB_ORACLE
			lAbort := ::OraTransfCube(oSource, oTarget, abLog, aDimID, oCube)
	  elseif SGDB() == DB_INFORMIX
			lAbort := ::InfTransfCube(oSource, oTarget, abLog, aDimID, oCube, @nQtde, @nIns, @nAtz)
			nQtdeConf := nIns + nAtz
		endif
	endif
	
	if !::flAbort .and. !lAbort
		eval(abLog, IPC_ETAPA, STR0010, IMP_ETA_INICIO)  //"Transferindo os dados"
		eval(abLogFile, STR0010)  //"Transferindo os dados"

		resetRoteiro(oSource)    
		nTotRec := iif(::RecLimit()==0, ::RecCount(), min(::RecCount(), ::RecLimit()))
		if nTotRec < 0
			eval(abLog, IPC_AVISO, STR0011)  //"Não foi possivel determinar o número de registros a processar"
			eval(abLogFile, STR0011 )  //"Não foi possivel determinar o número de registros a processar"
			if ::RecLimit() != 0      
				nTotRec := ::RecLimit()
			endif
		endif
		nLote := calcLote(nTotRec)

		oTarget:Open()                    
		aFldsTarget := oTarget:Fields()

		beginTransaction()

		while !oSource:Eof() .and. !DWKillApp()
			if ::RecLimit() != 0 .and. nTotRec2 == ::RecLimit()
				exit
			endif                             
		
			nTotRec2++
			aValues := oSource:Record(1)
			for nInd := 1 to len(aValues)
				nPos := ascan(aFldsTarget, { |x| x[FLD_ORIGNAME] == aValues[nInd, 1]} )
				if nPos <> 0
					aValues[nInd, 1] := aFldsTarget[nPos, FLD_NAME]
				endif
			next   
			for nInd := 1 to len(aFldsTarget)
				if valType(aFldsTarget[nInd, 14]) == "B" // roteiro
					for nPos := 1 to len(aValues)
						x := aValues[nPos]
						if x[1] == aFldsTarget[nInd, 1]
							aValues[nPos, 2] := eval(aFldsTarget[nInd, 14])
							nPos := -1
							exit
						endif
					next
					if nPos != -1
						aAdd(aValues, { aFldsTarget[nInd, 1], eval(aFldsTarget[nInd, 14])})
					endif
				endif
			next
			oTarget:Append(aValues, .t.)
			nIns++
			nQtde++           

			nRegTrans++
			if nRegTrans > LEN_TRANSACTION
				endTransaction()
				beginTransaction()
				nRegTrans := 0
			endif	

			if mod(nQtde, nLote) == 0 .or. (seconds() - nUltEnvio) > INTERVALO_ENV_PROGRESS
				cPrev := ""
				cDuracao := ""
				nUltEnvio := seconds() 
				if nTotRec > 0
					dwPrevTime(::faTimes[1], ::faTimes[2], nTotRec, nQtde, @cPrev, @cDuracao)
				endif

				eval(abLog, IPC_BUFFER, .t.)
				eval(abLog, IPC_ETAPA, , nQtde / nTotRec)
				eval(abLog, IPC_TEMPO, ::faTimes[3], cDuracao, cPrev) //cDuracao
				eval(abLog, IPC_AVISO, STR0012 + dwFormat("[9,999,999]/[9,999,999] ([999.999%])", { nQtde, nTotRec, nQtde / nTotRec * 100 }))  //"Processando "
				eval(abLog, IPC_BUFFER, .f.)
			endif
			oSource:_Next()
		enddo
		endTransaction()
		eval(abLog, IPC_AVISO, STR0012 + dwFormat("[9,999,999]/[9,999,999] ([999.999]%)", {nQtde, nTotRec, nQtde / nTotRec }))  //"Processando "
		
		oTarget:Close()
		
		eval(abLog, IPC_ETAPA, , IMP_ETA_FIM)
		eval(abLog, IPC_ETAPA, STR0013 , IMP_ETA_INICIO)  //"Verificando o relacionamento entre fato e dimensões"
		eval(abLogFile, STR0013)  //"Verificando o relacionamento entre fato e dimensões"

		aValid := {}
	
		aSQLVar := {}
		aSQLCur1 := {}
		aSQLCur2 := {}

		aAdd(aSQLVar, "nRecno integer; ")
		
		for nInd := 1 to len(aDimID)            
			oSigaDW:Dimensao():seek(1, { aDimID[nInd] } )
			lAutoUpd := oSigaDW:Dimensao():value("autoupd")
			oDim := oSigaDW:OpenDim(aDimID[nInd])
			if !lDimEmpFil
				lDimEmpFil := oDim:value("nome") == DIM_EMPFIL
			endif
			aAdd(aValid, { oDim:Descricao(), DWKeyDimname(aDimID[nInd]) + ' = -1' })
			aAdd(aDimNames, { DWKeyDimname(aDimID[nInd]), oDim:Descricao() })
			if !oDim:Seek(1, { 0 }) // valida a existencia de registro vazio
				oDim:Append({ { "id", 0 } })
			endif

			eval(abLog, IPC_BUFFER, .t.)
			eval(abLog, IPC_ETAPA,  , nInd / len(aDimID))
			eval(abLog, IPC_AVISO,  STR0014 + oDim:Descricao() + dwFormat("([999]/[999])", { nInd, len(aDimID)}))  //"Dimensão "
			eval(abLog, IPC_BUFFER, .f.)
			eval(abLogFile, oDim:Descricao())
  
			aIndexInfo := oDim:Indexes()[2]
			if lAutoUpd
				eval(abLog, IPC_AVISO,  oDim:Descricao() + dwFormat("([999]/[999]) ", { nInd, len(aDimID)}) + "(" + STR0015 + ")")  //atualizando
				eval(abLogFile, replicate("&nbsp;", 10) + "[" + STR0015 + " ]") //"atualizando"
				aSQL := {}
				aAdd(aSQL, "(select max(ID) from " + DWDimName(aDimID[nInd]) + ")+max(A.R_E_C_N_O_)" )
				aEval(aIndexInfo[4], { |x| aAdd(aSQL, "A."+x)})
				if SGDB() == DB_POSTGRES
					aAdd(aSQL, "chr(0) as " + DWDelete())
				else
					aAdd(aSQL, "' ' as " + DWDelete())
				endif
				if !(SGDB() == DB_ORACLE)
					aAdd(aSQL, "(select max(R_E_C_N_O_) from " + DWDimName(aDimID[nInd]) + ")+max(A.R_E_C_N_O_)")
				endif

				oQuery:FieldList(DWConcatWSep(",",aSQL))
				oQuery:MakeDistinct(.t.)

				aSQL := {}
				if SGDB() == DB_ORACLE
					aAdd(aSQL, oTarget:Tablename()+" A, " + DWDimName(aDimID[nInd]) + " B")
					aAux := {}
					aEval(aIndexInfo[4], { |x| aAdd(aAux, "A."+x+" = B."+x+"(+)")})
					aEval(aIndexInfo[4], { |x| aAdd(aAux, "B."+ x +" is null" )})
				else
					aAdd(aSQL, oTarget:Tablename()+" A left join " + DWDimName(aDimID[nInd]) + " B on ")
					aAux := {}
					aEval(aIndexInfo[4], { |x| aAdd(aAux, "A."+x+" = B."+x)})
					aAdd(aSQL, dwConcatWSep(" and ", aAux ))
					aAux := {}
					aEval(aIndexInfo[4], { |x| aAdd(aAux, "B."+ x +" is null" )})
				endif
				oQuery:FromList(DWConcatWSep(" ", aSQL))
    	
				oQuery:WhereClause(dwConcatWSep(" and ", aAux ))

				aSQL := {}
				aEval(aIndexInfo[4], { |x| aAdd(aSQL, "A."+x )})
				oQuery:GroupBy(dwConcatWSep(", ", aSQL ))

				aSQL := {}
				aAdd(aSQL, "ID")
				aEval(aIndexInfo[4], { |x| aAdd(aSQL, x)})
				aAdd(aSQL, DWDelete() )
				aAdd(aSQL, "R_E_C_N_O_" )

				oQuery:WithDeleted(.t.)
				oQuery:ExecSQL(oQuery:InsertInto(aSQL ,DWDimName(aDimID[nInd]),,,.f. ))
			endif	

			aSQL := {}
		
			if SGDB() == DB_ORACLE       
				aAdd(aSQLVar, "vv" + DWKeyDimname(aDimID[nInd]) + " integer; ")
				for xx := 1 to len(aIndexInfo[4])
					if ascan(aSQLVar, { |x| left(x, len(aIndexInfo[4][xx])+2) == "vv"+aIndexInfo[4][xx]}) == 0
						aAdd(aSQLVar, "vv"+aIndexInfo[4][xx]+" " + iif(oTarget:Fields(aIndexInfo[4][xx])[2]=="D", "char(8)", iif(oTarget:Fields(aIndexInfo[4][xx])[2]=="N", "decimal("+dwstr(oTarget:Fields(aIndexInfo[4][xx])[3])+","+dwstr(oTarget:Fields(aIndexInfo[4][xx])[4])+")","char("+dwstr(oTarget:Fields(aIndexInfo[4][xx])[3])+")"))+ ";")
					endif
				next
				if nInd == len(aDimID)
					aAdd(aSQLVar, "vvXXX char(1); ")
				endif
            	
				aAdd(aSQLCur1, "cursor " + DWKeyDimname(aDimID[nInd]) + "_CURSOR is ")
				aAdd(aSQLCur1, "select distinct ")
				aAdd(aSQLCur1, "A.ID, ")
				aEval(aIndexInfo[4], { |x| aAdd(aSQLCur1, "A."+x+", ")})
				aAdd(aSQLCur1, "'1' ")
				aAdd(aSQLCur1, "FROM " + oTarget:Tablename() + ", " + DWDimName(aDimID[nInd]) + " A WHERE ")
				aAux4 := {}
				aEval(aIndexInfo[4], { |x| aAdd(aAux4, oTarget:Tablename() +"."+x+" = A."+x) })
				aAdd(aSQLCur1, dwConcatWSep(" and ", aAux4) + ";")

				aAdd(aSQLCur2, "nRecno := 0;")
				aAdd(aSQLCur2, "open " + DWKeyDimname(aDimID[nInd]) + "_CURSOR; ")
				aAdd(aSQLCur2, "fetch " + DWKeyDimname(aDimID[nInd]) + "_CURSOR ")				
				aAdd(aSQLCur2, "into ")
				aAdd(aSQLCur2, "vv" + DWKeyDimname(aDimID[nInd]) + ", ")
				aEval(aIndexInfo[4], { |x| aAdd(aSQLCur2, "vv"+x+", ")})
				aAdd(aSQLCur2, "vvXXX; ")
				aAdd(aSQLCur2, "<<parse"+DWStr(nInd)+">> ")
				aAdd(aSQLCur2, "while ((" + DWKeyDimname(aDimID[nInd]) + "_CURSOR%found)) loop ")
				aAdd(aSQLCur2, "update " + oTarget:Tablename() + " ")
				aAdd(aSQLCur2, "set " + DWKeyDimname(aDimID[nInd]) + " = vv" + DWKeyDimname(aDimID[nInd]) + " ")
				aAdd(aSQLCur2, "where ")				
				aAux4 := {}
				aEval(aIndexInfo[4], { |x| aAdd(aAux4, x+" = vv"+x) })
				aAdd(aSQLCur2, dwConcatWSep(" and ", aAux4) + ";")

				aAdd(aSQLCur2, "if nRecno > 2999 then ")
				aAdd(aSQLCur2, "   commit;")
				aAdd(aSQLCur2, "   nRecno := 0;")
				aAdd(aSQLCur2, "else")
				aAdd(aSQLCur2, "   nRecno := nRecno + 1;")
				aAdd(aSQLCur2, "end if;")
			
				aAdd(aSQLCur2, "fetch " + DWKeyDimname(aDimID[nInd]) + "_CURSOR ")				
				aAdd(aSQLCur2, "into ")
				aAdd(aSQLCur2, "vv" + DWKeyDimname(aDimID[nInd]) + ", ")
				aEval(aIndexInfo[4], { |x| aAdd(aSQLCur2, "vv"+x+", ")})
				aAdd(aSQLCur2, "vvXXX; ")
				aAdd(aSQLCur2, "end loop; ")
				aAdd(aSQLCur2, "close " + DWKeyDimname(aDimID[nInd]) + "_CURSOR; ")
				aAdd(aSQLCur2, "commit;")
				aEval(aIndexInfo[4], { |x| aAdd(aRptKeys, { DWDimName(aDimID[nInd]), x, .t. })})
				aAdd(aRptKeys, { DWDimName(aDimID[nInd]), DWKeyDimname(aDimID[nInd]), .f. })
			else
				aAdd(aSQL, "update " + oTarget:Tablename() )
				if (SGDB() == DB_POSTGRES) 
					aAdd(aSQL, "set " + DWKeyDimname(aDimID[nInd]) + " = ID ")
					aAdd(aSQL, "from " + DWDimName(aDimID[nInd]) + " A WHERE ")
				elseif (SGDB() == DB_DB2)
					aAdd(aSQL, "set " + DWKeyDimname(aDimID[nInd]) + " = ")
					aAdd(aSQL, "coalesce((select ID from " + DWDimName(aDimID[nInd]) + " A WHERE ")
				elseif (SGDB() == DB_INFORMIX)
					aAdd(aSQL, "set " + DWKeyDimname(aDimID[nInd]) + " = ")
					aAdd(aSQL, "(select ID from " + DWDimName(aDimID[nInd]) + " A WHERE ")
				else
					aAdd(aSQL, "set " + DWKeyDimname(aDimID[nInd]) + " = ID ")
					aAdd(aSQL, "from " + oTarget:Tablename() + ", " + DWDimName(aDimID[nInd]) + " A WHERE ")
				endif
				aEval(aIndexInfo[4], { |x| aAdd(aSQL, oTarget:Tablename() +"."+x+" = A."+x+" and ")})
				aEval(aIndexInfo[4], { |x| aAdd(aRptKeys, { DWDimName(aDimID[nInd]), x, .t. })})
				aAdd(aRptKeys, { DWDimName(aDimID[nInd]), DWKeyDimname(aDimID[nInd]), .f. })
				aAdd(aSQL, "1=1")
				if (SGDB() == DB_DB2)
					aAdd(aSQL, "),-1)")
				elseif (SGDB() == DB_INFORMIX)
					aAdd(aSQL, ")")
				endif

				oQuery:ExecSQL(DWConcatWSep(CRLF, aSQL))
			endif

			aAdd(aValid, { oDim:Descricao(), DWKeyDimname(aDimID[nInd]) + ' = -1' })
			
			::VerCalend(oDim, @dtMin, @dtMax, abLog)

		next

    ::buildCalend(dtMin, dtMax, abLog)

		if SGDB() == DB_ORACLE
			aSQL := {}
			aAdd(aSQL, "CREATE PROCEDURE " + cProc + "(OUT_RET out char) IS ")
			aeval(aSQLVar, { |x| aAdd(aSQL, x) })
			aeval(aSQLCur1, { |x| aAdd(aSQL, x) })
			aAdd(aSQL, "begin ")
			aAdd(aSQL, "OUT_RET := '0'; ")
			aeval(aSQLCur2, { |x| aAdd(aSQL, x) })
			aAdd(aSQL, "OUT_RET := '1'; ")
			aAdd(aSQL, "end;")
			aAdd(aSQL, "-- linha para eliminar o problema das aspas no final do arquivo")
			oQuery:Execute(EX_DROP_PROCEDURE, cProc)
			oQuery:ExecSQL(DWConcatWSep(LF, aSQL))
			aSql := DWExecSP(cProcExec)
			if aSQL[1] != "1"
				DWRaise(ERR_009, SOL_009, STR0016 + " [" + acSPname + "]") //"Ocorreu um erro durante a execução"  
			endif			
			if DWDropWF()
				oQuery:Execute(EX_DROP_PROCEDURE, cProc)
			endif
		endif

		eval(abLogFile, STR0017)  //"A verificação da tabela fato, apurou que ..."

		eval(abLog, IPC_ETAPA,  , IMP_ETA_FIM)

		eval(abLog, IPC_ETAPA, STR0018 , IMP_ETA_INICIO)  //"Verificando tabela fato"
		aAux := {}
		aEval(aValid, { |x| aAdd(aAux, "select '"+x[1]+"' C01, count(*) C02 from " + oTarget:Tablename() + " where " + x[2]  )})
		oQuery:Open(.t., DWConcatWSep(" union ", aAux))

		nInvalids := 0

		while !oQuery:Eof()                
			if oQuery:value("C02") != 0
				nInvalids += oQuery:value("C02")
				eval(abLogFile, "&nbsp;&nbsp;&nbsp;"+STR0019+DWFormat(" [@X] " + STR0020 + " [9,999,999] " + STR0021, { oQuery:value("C01"), oQuery:value("C02") }) )  //"... a dimensão"  //"possue"  //"registros inválidos"  //"registros inválidos"
			endif
			oQuery:_Next()
		end
		oQuery:close()   
		eval(abLog, IPC_ETAPA,  , IMP_ETA_FIM)
		::flAbort := .f.
		if nInvalids == 0
			eval(abLogFile, "&nbsp;&nbsp;&nbsp;"+STR0022)  //"... não há registros inválidos"
		else
			eval(abLog, IPC_ETAPA, STR0023, IMP_ETA_INICIO)  //"Gerando listagem de registros invalidos"
			if ::Owner():RptInval() != RPTINVAL_NONE
				eval(abLogFile, STR0023 + " - " + upper(dwComboOptions(RPTINV_OPTIONS)[dwval(::Owner():RptInval()), 1]))  //"Gerando listagem de registros invalidos"
				aAux := {}                  	
				if SGDB() <> DB_ORACLE .and. SGDB() <> DB_DB2
					aAdd(aAux, iif(::Owner():RptInval() == RPTINVAL_KEYSONLY .or. ::Owner():RptInval() == RPTINVAL_FULL, " top 500 ",""))
				endif
				aAux2 := {}
				aRptKeys := aSort(aRptKeys,,, { |x, y| x[1]+x[2] < y[1]+y[2]})
				aEval(aRptKeys, { |x| iif(x[3], aAdd(aAux2, x[2]), aAdd(aAux2, x[2]))})
				if ::Owner():RptInval() == RPTINVAL_FULL .or. ::Owner():RptInval() == RPTINVAL_FULL_SL
					for nInd := 1 to len(oTarget:Fields())
						if ascan(aRptKeys, { |x| oTarget:Fields()[nInd, FLD_NAME] == x[2] }) == 0
							aAdd(aAux2, oTarget:Fields()[nInd, FLD_NAME])
						endif
					next
    			endif
				aAdd(aAux, dwconcatWSep(",", aAux2))
				aAux2 := {}     
				aEval(aValid, { |x| aAdd(aAux2, x[2])})			

				dplItems(aAux2, .t.)
				oQuery:Clear()
				oQuery:FieldList(aAux)
				oQuery:FromList(oTarget:Tablename())
				oQuery:WithDeleted(.t.)
				if SGDB() == DB_DB2 .and. (::Owner():RptInval() == RPTINVAL_KEYSONLY .or. ::Owner():RptInval() == RPTINVAL_FULL)
					oQuery:WhereClause("("+dwConcatWSep(" or ", aAux2) +") fetch first 500 rows only" )
				elseif SGDB() == DB_ORACLE .and. (::Owner():RptInval() == RPTINVAL_KEYSONLY .or. ::Owner():RptInval() == RPTINVAL_FULL)
					oQuery:WhereClause("("+dwConcatWSep(" or ", aAux2) +") and rownum < 501" )
				else
					oQuery:WhereClause(dwConcatWSep(" or ", aAux2))
				endif
//####TODO colocar estapa
				oQuery:Open()
				
				oArqLog := TDWFileIO():New(DWErrorDir() + "\" + DWMakeName('INV') + ".htm")
				oArqLog:Create()
				::ImpInvalB(oQuery, abLogFile, aDimNames, oArqLog)
				dbEval({||::ImpInval(oQuery, abLog, oArqLog) })
				::ImpInvalA(oQuery, abLogFile, oArqLog)
				oQuery:close()
				oArqLog:Close()    
				aAdd(aDownList, { STR0021, oArqLog:Filename() })  //"registros inválidos"
			endif		

			if len(aDownList) > 0
				eval(abLog, IPC_AVISO, STR0024)  //"Existem registros inválidos"
				eval(abLogFile, STR0025,,.t. )  //"Listagem das chaves inválidas para download"
				cAux := ""
				aEval(aDownList, { |x| cAux += makeButton(NIL, BT_JAVA_SCRIPT, x[1], "doLoad("+ makeAction(AC_EXEC_DOWNLOAD, {{"file", DwEncode(x[2])}, {"forceDownload", .t.}}) + ",'_window',null,'WinImpDown'," + DwStr(TARGET_50_WINDOW) + "," + DwStr(TARGET_50_WINDOW) + ")")})
				eval(abLogFile, cAux)
			endif

			if ::Owner():ProcInv() == PROCINV_ALL
				eval(abLogFile, STR0026 )  //"Os registros inválidos foram ACEITOS"
				eval(abLog, IPC_AVISO, STR0026 )//"Os registros inválidos foram ACEITOS"
				
				// trata de forma a aceitar os registros inválidos
				// campo ID_DIM??? = -1
				oQuery := TQuery():New(oTarget:Alias())
				oQuery:FromList(oTarget:Tablename())
				dplItems(aValid, .t.)
				for nInd := 1 to len(aValid)
					oQuery:WhereClause(aValid[nInd, 2])
					oQuery:Update({{dwToken(aValid[nInd, 2], "=")[1], 0}}, -1)
				next			
				oQuery:Clear()
			elseif ::Owner():ProcInv() == PROCINV_IGNORE_INVALID
				eval(abLogFile, STR0027 ) //"Os registros inválidos foram IGNORADOS"
				eval(abLog, IPC_AVISO, STR0027) //"Os registros inválidos foram IGNORADOS"
				aAux := {}                                                                           
				if SGDB() == DB_DB2
					aEval(aValid, { |x| aAdd(aAux, "delete from " + oTarget:Tablename() + " where " + x[2]) ,;
										aAdd(aAux, "go")})
				else
					aEval(aValid, { |x| aAdd(aAux, "delete " + oTarget:Tablename() + " where " + x[2] ) ,;
										aAdd(aAux, "go")})
				endif
				DWSQLExec(aAux)
			elseif ::Owner():ProcInv() == PROCINV_IGNORE_ALL
				eval(abLogFile, STR0028 )  //"Todos os registros (válidos ou inválidos) IGNORADOS"
				eval(abLog, IPC_AVISO, STR0028 )  //"Todos os registros (válidos ou inválidos) IGNORADOS"
				::flAbort := .f.
			endif                                          	
		endif

		eval(abLog, IPC_ETAPA, , IMP_ETA_FIM)

		if !::flAbort
			eval(abLog, IPC_ETAPA, STR0029, IMP_ETA_INICIO )  //"Preparando confirmação dos dados"

			oQuery := TQuery():New(oTarget:Alias())
			oQuery:FromList(oTarget:Tablename())
			aAux := {{},{}}
			for nInd := 1 to len(oTarget:Fields())
				if left(oTarget:Fields()[nInd][FLD_NAME], 6) == "ID_DIM"
					aAdd(aKeyNames, oTarget:Fields()[nInd][FLD_NAME])
					aAdd(aAux[1], oTarget:Fields()[nInd][FLD_NAME])
				elseif oTarget:Fields()[nInd][FLD_TYPE] == "N"
					aAdd(aAux[2], "sum(" + oTarget:Fields()[nInd][FLD_NAME] + ") " + oTarget:Fields()[nInd][FLD_NAME])
					aAdd(aIndNames, oTarget:Fields()[nInd][FLD_NAME])
				else
					aAdd(aAux[2], "max(" + oTarget:Fields()[nInd][FLD_NAME] + ") " + oTarget:Fields()[nInd][FLD_NAME])
				endif
			next
			oQuery:FieldList(dwConcatWSep(",", aAux[1]) + "," + dwConcatWSep(",", aAux[2]))
			oQuery:GroupBy(dwConcatWSep(",", aAux[1]))
			oTarget := oQuery		
			oTarget:Open()              
			oFato := oCube:Fact()

			eval(abLog, IPC_ETAPA, , IMP_ETA_1Q )
    		
			if !empty(::ForZap())
				eval(abLog, IPC_AVISO, STR0030)  //"Descartando dados do destino (regra de usuário)"
				eval(abLogFile, STR0030)  //"Descartando dados do destino (regra de usuário)"
				eval(abLogFile, "<code>"+dwStr(::ForZap())+"</code>")

				cAux := ""
				aAuxFrom := {}                                                                        
				aAuxFrom := {}                        
				cXXX := prepZapCube(oCube, ::ForZap(), aAuxFrom)
				if DWIsDebug()
					eval(abLogFile, "<code>"+STR0031+"</code>")  //"Informação para debug"
					eval(abLogFile, "<code>"+cXXX+"</code>")
     			endif
				
				if DWDelAllRec(oFato:Tablename(), cXXX, {}, @cAux,,::EmbedSQL())
					eval(abLog, IPC_AVISO, 'Descarte executado')
					eval(abLogFile, replicate("&nbsp;", 5) + STR0032)  //"Descarte executado"
				else
					eval(abLogFile, STR0033)  //"Ocorreu um erro durante o processo de descarte"
					eval(abLogFile, "<code>"+cAux+"</code>")
					::flAbort := .t.
				endif
			elseif ::Owner():UpdMethod() == UPDMET_DEFAULT
				eval(abLog, IPC_AVISO, STR0034)  //"Descartando dados do destino (regra padräo)"
				eval(abLogFile, STR0034)  //"Descartando dados do destino (regra padräo)"
            if !(::EmbedSQL())
               if SGDB() $ DB_MSSQL_ALL .or. SGDB() == DB_ORACLE 
                  DWSQLExec("truncate table " + oFato:Tablename())
               else
                  DWDelAllRec(oFato:Tablename(), "1=1", {})		
               endif
            else
               if lDimEmpFil
               		cXXX := "EMPFIL->M0_CODIGO = '" + DWDSEmp() + "' AND EMPFIL->M0_CODFIL = '" + DWDSFil() + "'"
               else
               		cXXX := "1=1"
               endif
               cXXX := prepZapCube(oCube, cXXX, {})
               if !empty(cXXX)                                
                  cAux := ""
                  if Type('cFilAnt') == "U"
		             RPCSetType(3)
		             Prepare Environment Empresa  DWDSEmp() Filial DWDSFil()
                  endif
                  
                  if DWDelAllRec(oFato:Tablename(), cXXX, {}, @cAux,,::EmbedSQL())
                     eval(abLog, IPC_AVISO, STR0032)  //"Descarte executado"
                     eval(abLogFile, replicate("&nbsp;", 5) + STR0032)  //'Descarte executado'
                  else  
                     eval(abLogFile, STR0033)  //"Ocorreu um erro durante o processo de descarte"
                     eval(abLogFile, "<code>"+cAux+"</code>")
                     ::flAbort := .t.
                  endif
               endif
            endif
				eval(abLog, IPC_AVISO, STR0032)  //"Descarte executado"
				eval(abLogFile, replicate("&nbsp;", 5) + STR0032)  //"Descarte executado"
			endif
			if ::Owner():UpdMethod() == UPDMET_UPDATE
				eval(abLog, IPC_AVISO, STR0035)  //"Atualizando a tabela fato"
				eval(abLogFile, replicate("&nbsp;", 5) + STR0035)  //"Atualizando a tabela fato"

				qAux := TQuery():New(DWMakeName("TRA"))
				cSQL := "update " + oFato:tablename() + " set "
				aEval(aIndNames, { |x| cSQL += x + "=B."+x + ","})
				cSQL += DWDelete() + " = '*'"
				cSQL += " from " + oTarget:tablename() + " A, " + oFato:Tablename() + " B"
				cSQL += " where "
				aEval(aKeyNames, { |x| cSQL += "A." + x + "=B."+ x + " and "})
				cSQL += "A." + DWDelete() + "  = '' AND B." + DWDelete() + " = ''"
	
				qAux:execSQL(cSQL)
        	
				qAux:Clear()
				cSQL := "update " + oTarget:tablename() + " set "
				cSQL += DWDelete() + " = '*'"
				cSQL += " from " + oTarget:tablename() + " A, " + oFato:Tablename() + " B"
				cSQL += " where "
				aEval(aKeyNames, { |x| cSQL += "A." + x + "=B."+ x + " and "})
				cSQL += "A." + DWDelete() + " = '' AND B." + DWDelete() + " = ''"
				qAux:execSQL(cSQL)
				
				qAux:Clear()          
				qAux:WithDelete(.t.)
		        qAux:FieldList("count(*)")
        		qAux:FromList(oTarget:tablename())
        		qAux:whereClause(DWDelete() + " <> ''")
		        qAux:Open()
         
				nAtz := qAux:value(1)
		        nIns -= nAtz
        		qAux:Close()

				qAux:Clear()
				qAux:FromList(oFato:tablename())
				qAux:WithDelete(.t.)
				qAux:ExecDel()
				qAux:Close()

				eval(abLog, IPC_AVISO, STR0036)  //"Atualização concluída"
				eval(abLogFile, replicate("&nbsp;", 5) + STR0036)  //"Atualização concluída"

				qAux := nil
		   	endif

			eval(abLog, IPC_ETAPA, , IMP_ETA_FIM )
			if !::flAbort
				eval(abLog, IPC_ETAPA, STR0037, IMP_ETA_INICIO )  //"Confirmando a tabela fato"
				eval(abLogFile, replicate("&nbsp;", 5) + STR0037)  //"Confirmando a tabela fato"
				nQtdeConf := 0
				oTarget:close()
				oTarget:open()

				if SGDB() <> DB_INFORMIX
					nTotConf := oTarget:RecCount(.t.)
				else
					nTotConf := 0
				endif
				nLote := calcLote(nTotConf)

				oTarget:goTop()
				cPrev := ""
				nRegTrans := 0
				lFirst := .t.
				beginTransaction()
				while !oTarget:Eof() .and. !DWKillApp()
					oFato:Append(oTarget, .t.)
					nQtdeConf++  
					nRegTrans++
					if nRegTrans > LEN_TRANSACTION
						endTransaction()
						beginTransaction()
						nRegTrans := 0
					endif	
					if mod(nQtdeConf, nLote) == 1
						cPrev := ""
						cDuracao := ""
						if nTotRec > 0                             
							dwPrevTime(::faTimes[1], ::faTimes[2], nTotRec, nQtdeConf, @cPrev, @cDuracao)
						endif

						eval(abLog, IPC_BUFFER, .t.)
						eval(abLog, IPC_ETAPA, , nQtdeConf / nTotRec )
						eval(abLog, IPC_TEMPO, ::faTimes[3], cDuracao, cPrev)
						eval(abLog, IPC_AVISO, STR0038 + dwFormat("[9,999,999]([999.999]%)/[9,999,999]", {nQtdeConf, nQtdeConf / nTotRec * 100, nTotRec}))  //"Confirmando "
					endif
					oTarget:_Next()
				enddo
				endTransaction()

				oTarget:Close()
				::Owner():stopEstatistica(nIDEstat)
			endif

			eval(abLog, IPC_ETAPA, STR0039, IMP_ETA_FIM )  //"Confirmação concluída"
			eval(abLogFile, replicate("&nbsp;", 5) + STR0039)  //"Confirmação concluída"
		endif
	
		resetRoteiro()

	endif

  	if !::flAbort
  		/*As estatística não podem ser processadas durante a importação otimizada [ORACLE]*/
  		if !(::Optimizer())
			::Owner():addEstatistica(nIDEstat, STR0040 + dwFormat(" [99,999,999]", { nQtde })) //"Lidos: "
			::Owner():addEstatistica(nIDEstat, STR0041 + dwFormat(" [99,999,999]", { nIns }))  //"Novos: "
			::Owner():addEstatistica(nIDEstat, STR0042 + dwFormat(" [99,999,999]", { nQtdeConf }))  //"Confirmados: "
			::Owner():addEstatistica(nIDEstat, STR0043 + dwFormat(" [99,999,999]", { nQtde - nQtdeConf }))  //"Duplicados na fonte: "
			::Owner():addEstatistica(nIDEstat, STR0044 + dwFormat(" [99,999,999]", { nAtz }))  //"Atualizados: "
			nLote := (nQtde*2) / DWElapSecs(::faTimes[1], ::faTimes[2], date(), time()) * 60
			::Owner():addEstatistica(nIDEstat, STR0045 + dwFormat(" [999,999] reg/min", { nLote }))  //"Velocidade processamento: "
		EndIf		
	endif
		 
	oSigaDW:CloseCube(oCube)     

return
                                              
static function createSeq(acTablename, aaSQL)
	local nStartRecno, nStartID, oQuery
	                       
 	oQuery := TQuery():New(DWMakeName("TRA"))
 	oQuery:FieldList("max(ID), max(R_E_C_N_O_)")
	oQuery:FromList(acTablename)
	oQuery:Open()
	nStartID := oQuery:value(1) + 1
	nStartRecno := oQuery:value(2) + 1
	oQuery:Close()

	aAdd(aaSQL, "CREATE SEQUENCE "+acTablename+"_RECNO")
	aAdd(aaSQL, "   INCREMENT BY 1 START WITH " + dwStr(nStartRecno))
	aAdd(aaSQL, "   NOMAXVALUE NOMINVALUE NOCYCLE CACHE 2000 NOORDER")
	aAdd(aaSQL, "GO")
	aAdd(aaSQL, "CREATE SEQUENCE "+acTablename+"_ID")
	aAdd(aaSQL, "   INCREMENT BY 1 START WITH " + dwStr(nStartID))
	aAdd(aaSQL, "   NOMAXVALUE NOMINVALUE NOCYCLE CACHE 2000 NOORDER")
	aAdd(aaSQL, "GO")          

return

static function dropSeq(acTablename, aaSQL)

	aAdd(aaSQL, "DROP SEQUENCE "+acTablename+"_RECNO")
	aAdd(aaSQL, "GO")
	aAdd(aaSQL, "DROP SEQUENCE "+acTablename+"_ID")
	aAdd(aaSQL, "GO")

return

method OraTransfCube(aoSource, aoTarget, abLog, aaDimID, aoCube) class TDoImpDBF
	local oQuery, lRet, cMsg := ""
	local aSQL := {}, aKeyNames := {}, aKeyDims := {}
	local aFldsTarget, nInd, nInd2, lFirst, lAutoUpd, nPos
	local oDim, aIndexInfo, aDimNames := {}
	local aIndNames := {}, oFato, cKeyList
	local aDownList := {}, cAux 
	local aValid := {}, lAbort := .f.

	if valType(abLog) != "B"
		abLog := { || }
	endif
	
  	eval(abLog, IPC_AVISO, STR0046) //"Gerando arquivo de trabalho"
	nQtde := aoSource:recCount(::SQL())
  	eval(abLog, IPC_AVISO, STR0047 + transform(nQtde, "99,999,999")) //"Total de registros a processar"
	
	aFldsTarget := aoTarget:Fields()
	aFldsSource := aoSource:Fields()
	aFields := {}
	for nInd := 1 to len(aFldsSource)
		nPos := ascan(aFldsTarget, { |x| x[FLD_ORIGNAME] == aFldsSource[nInd, FLD_NAME]} )
		if nPos <> 0
			aAdd(aFields, { aFldsTarget[nPos, FLD_NAME] , aFldsSource[nInd, FLD_NAME] })
		else
			aAdd(aFields, { aFldsSource[nInd, FLD_NAME] , aFldsSource[nInd, FLD_NAME] })
		endif
	next
	
	// preparar a lista de campos e lista de dados
	for nInd := 1 to len(aaDimID)
		oDim := oSigaDW:OpenDim(aaDimID[nInd])
		aKeyNames := {}
		aEval(oDim:Indexes()[2, 4], { |x| aAdd(aKeyNames, x)})
		aAdd(aKeyDims, {aaDimID[nInd], aclone(aKeyNames), oDim:Descricao() })
	next
	aoTarget:addIndex2(nil, aKeyNames)
	aoTarget:DropRecnoIndex()
	aoTarget:Close()
	
	aAux := {}
	for nInd := 1 to len(aKeyDims)
		for nInd2 := 1 to len(aKeyDims[nInd, 2])
			nPos := ascan(aFields, { |x| x[2] == aKeyDims[nInd, 2, nInd2]})
			if nPos == 0
				aAdd(aAux, "d." + aKeyDims[nInd, 2, nInd2] + " = " + "s." + aKeyDims[nInd, 2, nInd2])
			else
				aAdd(aAux, "d." + aKeyDims[nInd, 2, nInd2] + " = " + "s." + aFields[nPos,1])
			endif
		next
	next
   
	cKeyList := dwConcatWSep(" and ", aAux) + "||'1_2'"
  	eval(abLog, IPC_AVISO, STR0048 ) //"Gerando o arquivo"
	aAdd(aSQL, "MERGE INTO " + aoTarget:Tablename() + " d")
	aAdd(aSQL, "USING (" + ::SQL() + ") s")
	aAdd(aSQL, "ON (" + cKeyList +")")   // FORÇA SEMPRE SER INCLUSÃO
	aAdd(aSQL, "WHEN MATCHED THEN UPDATE SET")
	aAux := {}
	
	for nInd := 1 to len(aFields)
		if !(aFields[nInd,1] $ cKeyList)
			aAdd(aAux, "d."+aFields[nInd,1] + "=" + "s."+aFields[nInd,2])
		endif
	next 
	
	aAdd(aSQL, dwConcatwSep(",", aAux))
	aAux := {}
	aEval(aFields, { |x| aAdd(aAux, "d."+x[1])})
	aAdd(aSQL, "WHEN NOT MATCHED THEN INSERT (" + dwConcatwSep(",", aAux) + ")")
	aAux := {}
	aEval(aFields, { |x| aAdd(aAux, "s."+x[2])})
	aAdd(aSQL, "VALUES ("+dwConcatwSep(",", aAux)+")")
	
	lRet := DWSQLExec(aSQL) == 0
	
	if lRet
		// Efetua a auto-atualização, se for o caso
		lFirst := .t.
		aSQL := {}
		oQuery := TQuery():New(DWMakeName("TRA"))
		for nInd := 1 to len(aaDimID)
			oSigaDW:Dimensao():seek(1, { aaDimID[nInd] } )
			lAutoUpd := oSigaDW:Dimensao():value("autoupd")
			if lFirst .and. lAutoUpd
        eval(abLog, IPC_AVISO, STR0049) //"Preparando a auto-atualização"
				lFirst := .f.
			endif
			oDim := oSigaDW:OpenDim(aaDimID[nInd])
			aAdd(aValid, { oDim:Descricao(), DWKeyDimname(aaDimID[nInd]) + ' = -1' })
			if !oDim:Seek(1, { 0 }) // valida a existencia de registro vazio
				oDim:Append({ { "id", 0 } })
			endif
			aAdd(aDimNames, { DWKeyDimname(aaDimID[nInd]), oDim:Descricao() })
			if lAutoUpd
				aIndexInfo := oDim:Indexes()[2]
				
				aSQL := {}
				createSeq(oDim:TableName(), aSQL)
				
				oQuery:MakeDistinct(.t.)
				oQuery:FromList(aoTarget:Tablename()+" A")
				aAux := {}
				aEval(aIndexInfo[4], { |x| aAdd(aAux, "A."+x)})
				oQuery:FieldList(dwConcatWSep(", ", aAux ))
				
				aAux := {}
				aEval(aIndexInfo[4], { |x| aAdd(aAux, "d."+x+" = s."+x)})
				aAdd(aSQL, "MERGE INTO " + oDim:Tablename() + " d")
				aAdd(aSQL, "USING (" + oQuery:SQL() + ") s")
				aAdd(aSQL, "ON ("+ dwConcatWSep(" and ", aAux) + ")")
				aAdd(aSQL, "WHEN MATCHED THEN UPDATE SET d.R_E_C_N_O_ = d.R_E_C_N_O_")
				aAux := {}
				aEval(aIndexInfo[4], { |x| aAdd(aAux, "d."+x)})
				aAdd(aSQL, "WHEN NOT MATCHED THEN INSERT (d.ID, d.R_E_C_N_O_," + dwConcatwSep(",", aAux) + ")")
				aAux := {}
				aEval(aIndexInfo[4], { |x| aAdd(aAux, "s."+x)})
				aAdd(aSQL, "VALUES ("+oDim:TableName()+"_ID.NEXTVAL, "+oDim:TableName()+"_RECNO.NEXTVAL, "+dwConcatwSep(",", aAux)+")")
				aAdd(aSQL, "GO")
				
				dropSeq(oDim:TableName(), aSQL)
				
        		eval(abLog, IPC_AVISO, STR0050+" [ " + oDim:Descricao() + " ]" )//"Atualizando dimensão"
				lRet := DWSQLExec(aSQL) == 0
				if !lRet
					exit
				endif
			endif
		next
		
		if lRet
      		eval(abLog, IPC_AVISO, STR0051) //"Montando o relacionamento do arquivo de trabalho com as dimensões"
			for nInd := 1 to len(aKeyDims)
				aSQL := {}
        		eval(abLog, IPC_AVISO,STR0014+" [ " + aKeyDims[nInd,3] + " ]") //"Dimensão"
				
				aAdd(aSQL, "merge into " + aoTarget:Tablename() + " d ")
				aAux := { "ID" }
				aEval(aKeyDims[nInd, 2], {|x| aAdd(aAux, x)})
				aAdd(aSQL, "USING (select "+dwConcatWSep(",", aAux)+" from "+DWDimname(aKeyDims[nInd, 1])+") s")
				aAux := {}
				aEval(aKeyDims[nInd, 2], {|x| aAdd(aAux, "d." + x + "=" + "s." + x)})
				aAdd(aSQL, "on ("+dwConcatWSep(" and ", aAux)+")")
				aAdd(aSQL, "WHEN MATCHED THEN UPDATE SET d."+DWKeyDimname(aKeyDims[nInd, 1])+" = s.ID")
				aAdd(aSQL, "WHEN NOT MATCHED THEN INSERT (d." + DWDelete() + ") values ('*')")
				
				lRet := DWSQLExec(aSQL) == 0
				
				aSQL := {}
				oQuery:Clear()
				aAdd(aSQL, "select count(*) from " + aoTarget:Tablename())
				aAdd(aSQL, "where " + DWDelete() + " <> '*' and " + DWKeyDimname(aKeyDims[nInd, 1])+"=0")
				oQuery:Open(, dwConcatWSep(CRLF, aSQL))
				nInvalids := oQuery:value(1)
				oQuery:Close()
				oQuery:Clear()
				if nInvalids != 0
           		eval(abLog, IPC_INFO, STR0052 + DWFormat(" [9,999,999] ", { nInvalids })+ STR0053 )   //"Existem"  //"registros inválidos"
					
					if ::Owner():RptInval() != RPTINVAL_NONE
						oArqLog := TDWFileIO():New(DWErrorDir() + "\" + DWMakeName('INV') + ".htm")
						oArqLog:Create()
						oQuery:Clear()
			            eval(abLog, IPC_AVISO, STR0023 + " - " + upper(dwComboOptions(RPTINV_OPTIONS)[dwval(::Owner():RptInval())]))  //"Gerando listagem de registros invalidos"
						aAux := {}
						aAux2 := {}
						aRptKeys := {}
						aEval(aKeyDims[nInd, 2], { |x| aAdd(aRptKeys, x)})
						aEval(aRptKeys, { |x| aAdd(aAux2, x)})
						if ::Owner():RptInval() == RPTINVAL_FULL .or. ::Owner():RptInval() == RPTINVAL_FULL_SL
							for nInd := 1 to len(oTarget:Fields())
								if ascan(aRptKeys, { |x| oTarget:Fields()[nInd, FLD_NAME] == x }) == 0
									aAdd(aAux2, oTarget:Fields()[nInd, FLD_NAME])
								endif
							next
						endif
						aAdd(aAux, dwconcatWSep(",", aAux2))
						aAux2 := {}
						aAdd(aAux2, DWKeyDimname(aKeyDims[nInd, 1])+"=0")
						if ::Owner():RptInval() == RPTINVAL_KEYSONLY .or. ::Owner():RptInval() == RPTINVAL_FULL
							oQuery:RecLimit(500)
						endif
						oQuery:FieldList(dwconcatwsep(",",aAux))
						oQuery:FromList(aoTarget:Tablename())
						oQuery:WhereClause(dwConcatWSep(" or ", aAux2))
						oQuery:OrderBy(oQuery:FieldList())
						oQuery:MakeDistinct(.t.)
						oQuery:Open(.t.)
						::ImpInvalB(oQuery, abLog, aDimNames, oArqLog, aKeyDims[nInd, 3])
						::ImpInval(oQuery, abLog, oArqLog)
						::ImpInvalA(oQuery, abLog, oArqLog)
						oQuery:close()
						oArqLog:Close()
						aAdd(aDownList, { aKeyDims[nInd, 3], oArqLog:Filename() })
					endif
				endif
				
				if !lRet
					exit
				endif
			next
		endif
		
		if lRet
       		eval(abLog, IPC_AVISO, STR0054) //"Verificando a integridade do arquivo de trabalho"
			lAbort := .f.
			aSQL := {}
			aAdd(aSQL, "select count(*) from " + aoTarget:Tablename())
			aAux := {}
			aEval(aKeyDims, { |x| aAdd(aAux, DWKeyDimname(x[1])+"=0")})
			aAdd(aSQL, "where " + DWDelete() + " <> '*' and (" + dwConcatWSep(" or ", aAux)+")")
			oQuery:Clear()
			oQuery:Open(, dwConcatWSep(CRLF, aSQL))
			nInvalids := oQuery:value(1)
			oQuery:Close()
			oQuery:Clear()
			if nInvalids == 0
        	eval(abLog, IPC_AVISO, STR0055) // "Não há registros inválidos"
			else
       	 	eval(abLog, IPC_AVISO, STR0052 + DWFormat(" [9,999,999] ", { nInvalids }) + STR0053) //"existem   //"registros inválidos"
				
				if ::Owner():ProcInv() == PROCINV_ALL
          		eval(abLog, IPC_AVISO, STR0026) //"Os registros inválidos foram ACEITOS"
				elseif ::Owner():ProcInv() == PROCINV_IGNORE_INVALID
          			eval(abLog, IPC_AVISO, STR0027,,.t.) //"Os registros inválidos foram IGNORADOS"
					aAux := {}
					aEval(aValid, { |x| aAdd(aAux, "delete " + aoTarget:Tablename() + " where " + x[2] ), aAdd(aAux, "go")})
					DWSQLExec(aAux)
				elseif ::Owner():ProcInv() == PROCINV_IGNORE_ALL
    				eval(abLog, IPC_ERRO, STR0028)//"Todos os registros (válidos ou inválidos) IGNORADOS"
					lAbort := .t.
				endif
			endif
		endif

		if len(aDownList) > 0
      		eval(abLog, IPC_AVISO, STR0057)  //"Listagem das chaves inválidas para <i>download</i>"
			cAux := ""
			aEval(aDownList, { |x| cAux += makeButton(NIL, BT_JAVA_SCRIPT, x[1], "doLoad("+ makeAction(AC_EXEC_DOWNLOAD, {{"file", DwEncode(x[2])}, {"forceDownload", .t.}}) + ",'_window',null,'WinImpDown'," + DwStr(TARGET_50_WINDOW) + "," + DwStr(TARGET_50_WINDOW) + ")")})
			eval(abLog, IPC_AVISO, cAux)
		endif

		if !lAbort
			aAux := {{},{}}
			aKeyNames := {}
			aIndNames := {}
			for nInd := 1 to len(aoTarget:Fields())
				if left(aoTarget:Fields()[nInd][FLD_NAME], 6) == "ID_DIM"
					aAdd(aKeyNames, aoTarget:Fields()[nInd][FLD_NAME])
					aAdd(aAux[1], aoTarget:Fields()[nInd][FLD_NAME])
				elseif aoTarget:Fields()[nInd][FLD_TYPE] == "N"
					aAdd(aAux[2], "sum(" + aoTarget:Fields()[nInd][FLD_NAME] + ") " + aoTarget:Fields()[nInd][FLD_NAME])
					aAdd(aIndNames, aoTarget:Fields()[nInd][FLD_NAME])
				else
					aAdd(aAux[2], "max(" + aoTarget:Fields()[nInd][FLD_NAME] + ") " + aoTarget:Fields()[nInd][FLD_NAME])
				endif
			next
			
			oFato := aoCube:Fact()
   			eval(abLog, IPC_AVISO, STR0058)//"Preparando o cubo para receber arquivo de trabalho"
			if !empty(::ForZap())
				eval(abLog, IPC_AVISO, STR0030)  //"Descartando dados do destino (regra de usuário)"
    			eval(abLog, IPC_AVISO, "<code>"+dwStr(::ForZap())+"</code>")
				cAux := ""
				aAuxFrom := {}
				if DWDelAllRec(oFato:Tablename(), prepZapCube(aoCube, ::ForZap(), aAuxFrom), {}, @cAux)//, aAuxFrom)
					eval(abLog, IPC_AVISO, STR0032)   //"Descarte executado"
				else
					eval(abLog, IPC_ERRO, STR0033+"<code>"+cAux+"</code>")  //"Ocorreu um erro durante o processo de descarte"
					lAbort := .t.
				endif
			elseif ::Owner():UpdMethod() == UPDMET_DEFAULT
				eval(abLog, IPC_AVISO, STR0030)  //"Descartando dados do destino (regra padrão)"
				DWSQLExec("truncate table " + oFato:Tablename())
				eval(abLog, IPC_AVISO, STR0032)  //"Descarte executado"
			endif
		endif
		if !lAbort
			eval(abLog, IPC_AVISO, STR0059) //"Confirmando o arquivo de trabalho"
			aSQL := {}
			
			createSeq(oFato:Tablename(), aSQL)
			lRet := DWSQLExec(aSQL) == 0
			if lRet
				aSQL := {}
				aAdd(aSQL, "MERGE INTO " + oFato:Tablename() + " d")
				aAdd(aSQL, "USING (select * from " + aoTarget:Tablename()+" where " + DWDelete() + " <> '*') s")
				aAux := {}
				aEval(aKeyNames, {|x| aAdd(aAux, "d." + x + "=" + "s." + x)})
				if ::Owner():UpdMethod() != UPDMET_DEFAULT
					aAdd(aAux, "1=0") // FORÇA EXECUTAR SOMENTE O INSERT
				endif
				aAdd(aSQL, "ON (" + dwConcatWSep(" and ", aAux) +")")
				aAux := {}
				aEval(aIndNames, {|x| aAdd(aAux, "d." + x + "=" + "s." + x)})
				aAdd(aSQL, "WHEN MATCHED THEN UPDATE SET "+dwConcatWSep(",", aAux))
				aAux := {}
				aEval(aKeyNames, {|x| aAdd(aAux, "d."+x)})
				aEval(aIndNames, {|x| aAdd(aAux, "d."+x)})
				aAdd(aSQL, "WHEN NOT MATCHED THEN INSERT (d.ID, d.R_E_C_N_O_, "+dwConcatWSep(",", aAux)+")")
				aAux := { oFato:Tablename()+"_ID.NEXTVAL", oFato:Tablename()+"_RECNO.NEXTVAL",  }
				aEval(aKeyNames, {|x| aAdd(aAux, "s."+x)})
				aEval(aIndNames, {|x| aAdd(aAux, "s."+x)})
				aAdd(aSQL, "VALUES ("+dwConcatWSep(",", aAux)+")")
				aAdd(aSQL, "GO")
				
				lRet := DWSQLExec(aSQL) == 0
				if !lRet
					cMsg := tcSQLError()
				endif
				aSQL := {}
				dropSeq(oFato:Tablename(), aSQL)
				DWSQLExec(aSQL)
			endif
		endif
	endif
	
	if !lRet
  	eval(abLog, IPC_ERRO, STR0060)  //"A importação otimizada falhou"
  	eval(abLog, IPC_BUFFER, .t.)
  	eval(abLog, IPC_INFO, { STR0061, ; //"A importação otimizada falhou. VerSifique o log de console e do TopConnect"
  	                        STR0062 } ) //"O processo de importação não otimizado, será executado."
  	eval(abLog, IPC_BUFFER, .f.)
  	 
  	Conout("*************************************") 
  	Conout(STR0060)  //"A importação otimizada falhou"
	Conout(STR0062)  //"O processo de importação não otimizado, será executado."  
  	If( DwIsDebug() )
	  	Conout(iif(empty(cMsg), tcSQLError(), cMsg))		
	EndIf
	Conout("*************************************")
	
	else    
		eval(abLog, IPC_TEMPO, ::faTimes[3], , dtoc(date()) + " " + time())
		nLote := nQtde / DWElapSecs(::faTimes[1], ::faTimes[2], date(), time()) * 60
    oFato:updStat()
	endif
      			            
return lRet
	
/*
--------------------------------------------------------------------------------------
Processa a carga de dimensoes
--------------------------------------------------------------------------------------
*/
static function prepZapDim(acZapCond, aoDim)
	local cRet := acZapCond
	local cDimName := aoDim:alias()
		
  cRet := strTranIgnCase(cRet, "Dimensao->", "")
  cRet := strTranIgnCase(cRet, cDimName+"->", "")
	cRet := strTran(cRet, "==", "=")         

return cRet

method TransfDim(anDimID, abLog, abLogFile) class TDoImpDBF
	local oSource := ::foSource, nRegTrans
	local oDim := oSigaDW:OpenDim(anDimID), oDSNConf := InitQuery(SEL_DSNCONF)
	local aIndexInfo := oDim:Indexes()[2], aKeyValues := {}, aKeyNames := {}, aDataNames := {}, aDataValues := {}
	local nQtde := 0, nIns := 0, nAtz := 0, cValues, nLote, cField
	local cTermino := "", cPrev := "", cDuracao := "", cID, nTotRec := 0
	local nTotRec2 := 0, cbOldValidate
	local aValues, nInd, nPos, nPos2, aFldsTarget, oFile, cAux
	local lAbort := .f.
	local lFirst := .t., nIDEstat, nIDEstat2
  	local nUltEnvio := seconds() + (INTERVALO_ENV_PROGRESS * 2) 
	local dtMin := stod("20991231"), dtMax := stod("19000101")
	local oSX2, cAlias, nPosEmp, nPosFil
  
	resetRoteiro(oSource)
	aFldsTarget := oDim:Fields()
                                 
	nIDEstat := ::Owner():startEstatistica(STR0063) //"Atualização da dimensão"

	oDSNConf:params(1, anDimID)
	oDSNConf:params(2, ::Owner():DSNID())
	oDSNConf:Open()
   
	while !oDSNConf:eof() .or. lAbort
		cField := oDSNConf:value("nome")
		oDim:setOrigField(cField, oDSNConf:value("cpoorig"))
		if SGDB() == DB_ORACLE
			if oDSNConf:value("id_roteiro") != 0 .and. !empty(alltrim(oDSNConf:value("roteiro",.t.)))
				if oDSNConf:value("isSQL") != ::Optimizer()
					eval(abLogFile, DWFormat("<br>      <b><big>"+STR0064+":</big></b> "+STR0065+" <b>[@X]</b> "+STR0066, { cField })) //"ATENÇÃO" //"O roteiro do campo" "não esta de acordo com a opção de otimização."
					lAbort := .t.
				endif
				cRoteiro := iif(empty(oDSNConf:value("cpoorig", .t.)), cField, oDSNConf:value("cpoorig", .t.))
				cRoteiro := "{ || DW_Value := DWSinonimo('"+cRoteiro+"'), execRoteiro(" + DWStr(oDSNConf:value("id_roteiro"))+") }"
				oDim:SetRoteiro(cField, &(cRoteiro))
			elseif !empty(oDSNConf:value("cpoorig",.t.)) .and. !(oDSNConf:value("cpoorig",.t.) == cField)
				cRoteiro := "{ || DWSinonimo('"+oDSNConf:value("cpoorig", .t.)+"') }"
				oDim:SetRoteiro(cField, &(cRoteiro))
			endif
		else
			if oDSNConf:value("id_roteiro") != 0 .and. !empty(oDSNConf:value("roteiro",.t.))
				cRoteiro := iif(empty(oDSNConf:value("cpoorig", .t.)), cField, oDSNConf:value("cpoorig", .t.))
				cRoteiro := "{ || DW_Value := DWSinonimo('"+cRoteiro+"'), execRoteiro(" + DWStr(oDSNConf:value("id_roteiro"))+") }"
				oDim:SetRoteiro(cField, &(cRoteiro))
			elseif !empty(oDSNConf:value("cpoorig")) .and. !(oDSNConf:value("cpoorig") == cField)
				cRoteiro := "{ || DWSinonimo('"+oDSNConf:value("cpoorig")+"') }"
				oDim:SetRoteiro(cField, &(cRoteiro))
			endif
		endif
		oDSNConf:_Next()
	enddo						
	oDSNConf:Close()

	if !lAbort
		if !::EmbedSQL()
			if ::RecLimit() != 0 .and. ::RecCount() < ::RecLimit()
				eval(abLogFile, DWFormat("<b>"+STR0067+"</b> " + STR0068+ " [9,999,999] "+STR0069, { ::RecLimit() })) //"Nota:"  //"O processamento esta limitado a"  //"registros"
			endif
		endif

		if !lAbort
			nTotRec := iif(::RecLimit()==0, ::RecCount(), min(::RecCount(), ::RecLimit()))
			if nTotRec < 0
				eval(abLogFile, '<b>Nota:</b> Em tabelas SQL, não é possivel determinar o número de registros a processar')
				if ::RecLimit() != 0
					nTotRec := ::RecLimit()
				endif
			endif
			nLote := calcLote(nTotRec)
	
			if !empty(::ForZap())
				eval(abLogFile, STR0070)  //"Descarte de dados, conforme condição informada"
				eval(abLogFile, "<code>"+dwStr(::ForZap())+"</code>")
				cAux := ""      
				nIDEstat2 := ::Owner():startEstatistica("Descarte")
				if DWDelAllRec(oDim:Tablename(), prepZapDim(::ForZap(), oDim), {}, @cAux,,::EmbedSQL())
					eval(abLog, IPC_AVISO, STR0071)  //"Descarte efetuado"
					oDim:Refresh()
				else
					eval(abLogFile, "<code>"+cAux+"</code>")
					::flAbort := .t.
				endif
				::Owner():stopEstatistica(nIDEstat2)
		   endif
		else
			eval(abLogFile, STR0072)  //"Não há descarte de dados definido"
		endif
	endif
	
	if ::Optimizer()
    	if SGDB() == DB_ORACLE
			lAbort := ::OraTransfDim(oDim, abLog)
    	elseif SGDB() == DB_INFORMIX
      		lAbort := ::InfTransfDim(oDim, abLog, @nQtde, @nIns, @nAtz)
		endif
	endif

	if !::flAbort .and. !lAbort
		eval(abLog, IPC_ETAPA, , IMP_ETA_INICIO)

		aKeyNames := {}
		aDataNames := {}
		aEval(aIndexInfo[4], { |x| aAdd(aKeyNames, { x, iif(empty(oDim:Fields(x)[FLD_ROTEIRO]),x, oDim:Fields(x)[FLD_ROTEIRO]) } )})

		for nInd := 1 to len(oDim:Fields())
			if !empty(oDim:Fields()[nInd][FLD_ROTEIRO]) .and. oDim:Fields()[nInd][FLD_NAME] != "ID"
				if aScan(aIndexInfo[4], oDim:Fields()[nInd][FLD_NAME]) = 0
					aAdd(aDataNames, { oDim:Fields()[nInd][FLD_NAME], oDim:Fields()[nInd][FLD_ROTEIRO] } )
				endif
			endif
		next
        
		if valType(::Owner():Validate()) == "B"
			cbOldValidate := oDim:Validate()
			oDim:Validate(::Owner():Validate())
		endif
        
		if !oDim:Seek(1, { 0 }) // valida a existencia de registro vazio
			oDim:Append({ { "id", 0 } })
		endif

		if oSigaDW:HaveDimEmpFil()
			eval(abLog, IPC_AVISO, STR0073)  //"Verificando a existência de registro <vazio> por empresa/filial"
			oSX2 := initTable(TAB_SX2)                               
			cAlias := ::owner():Filesource()
			if oSX2:recCount() == 0 .or. !oSX2:seek(2, { cAlias })
				eval(abLog, IPC_AVISO, STR0074)  //"Não há informações sobre o compartilhamento de arquivos entre empresas/filiais. Verificar log ao final do processamento."
				eval(abLogFile, "<div>")
				eval(abLogFile, "<span class='dw_subtitle'>"+STR0064+"</span> <span class='warning'>"+STR0075+"</span>")  //"ATENÇÃO:"   //Não há informações sobre o compartilhamento de arquivos entre empresas/filiais
				eval(abLogFile, STR0076)  //"Na importação do cubo, em caso de haver chaves em branco, estas poderão ser consideradas 'inválidas'."
				eval(abLogFile, STR0077)  //"Recomendamos a execução da opção 'Sinc.SigaMat', acessando-a pela opção 'Ferramentas' e após a execução desta refaça a importação das dimensões e cubos."
				eval(abLogFile, "</div>")
				::flWarning := .T.
			else
				eval(abLog, IPC_AVISO, STR0073)  //"Verificando a existência de registro <vazio> por empresa/filial"
				aKeyValues := array(len(aKeyNames))
				//aEval(aKeyNames, { |x,i| aValues[i] := { x[1], NIL } })
				nPosEmp := ascan(aKeyNames, { |x| x[1] == ATT_M0_CODIGO_NOME })
				nPosFil := ascan(aKeyNames, { |x| right(x[1], 7)  == "_FILIAL" })
				if !(nPosEmp == 0 .or. nPosFil == 0)
					aValues := { { aKeyNames[nPosEmp, FLD_NAME], nil }, { aKeyNames[nPosFil, FLD_NAME], nil } }

					while !oSX2:eof() .and. oSX2:value("alias") == cAlias
						if oSX2:value("modo") == MODO_COMP_EMPRESA
						else
							aKeyValues[nPosEmp] := ::owner():empresa()
							aValues[1, 2] := aKeyValues[nPosEmp]
							if oSX2:value("modo") == MODO_EXCLUSIVO   
								aKeyValues[nPosFil] := ::owner():filial()
							else
								aKeyValues[nPosFil] := ""
							endif
							aValues[2, 2] := aKeyValues[nPosFil]
							if !oDim:seek(2, aKeyValues, .f.)
								oDim:append(aValues)
							endif
						endif
						oSX2:_next()
					enddo
				endif                                                    
			endif
			oSX2:close()
		endif
		
		nRegTrans := 0		
		beginTransaction()
		
		while !oSource:Eof() .and. !DWKillApp()
			if ::RecLimit() != 0 .and. nTotRec2 == ::RecLimit()
				exit
			endif
			
			nTotRec2++
			aKeyValues := {}
			aDataValues := {}
			aEval(aKeyNames, { |x| aAdd(aKeyValues, iif(valType(x[2])=="B",eval(x[2]),oSource:value(x[2])) )})
			aEval(aDataNames, { |x| aAdd(aDataValues, iif(valType(x[2])=="B",eval(x[2]),oSource:value(x[2])) )})
			
			// prerara o registro origem para processamento
			aValues := oSource:Record(1)
			
			for nInd := 1 to len(aValues)
				nPos := ascan(aFldsTarget, { |x| x[FLD_ORIGNAME] == aValues[nInd, 1]} )
				if nPos <> 0
				  aValues[nInd, 1] := aFldsTarget[nPos, FLD_NAME]
				endif
	  		  	
	  		  	nPos2 := ascan(aKeyNames, { |x| x[1] == aValues[nInd, 1]} )
				
				if nPos2 <> 0
				   	aValues[nInd, 2] := aKeyValues[nPos2]
	  		  	endif
	  		  	
	  		  	nPos2 := ascan(aDataNames, { |x| x[1] == aValues[nInd, 1]} )
				
				if nPos2 <> 0
				   	aValues[nInd, 2] := aDataValues[nPos2]
	  		  	endif
	  		  	
			    if empty(aValues[nInd, 2])
					  aValues[nInd] := nil
				endif
			next
		
			aValues := packArray(aValues)

			for nInd := 1 to len(aDataNames)
				nPos := ascan(aValues, { |x| aDataNames[nInd, 1] == x[1] })
				if nPos <> 0
					aValues[nPos, 2] := eval(aDataNames[nInd, 2])
				else
					aAdd(aValues, { aDataNames[nInd, 1], eval(aDataNames[nInd, 2]) })
				endif
			next
						
			// gambiarra especifica para chaves com data vazia -- aguardando acerto
			if len(aKeyValues) == 1 .and. valType(aKeyValues[1]) == "D" .and. empty(aKeyValues[1])
				oDim:Seek(1, { 0 }, .f.)
				if oDim:Update(aValues, .t.)
					nAtz++
				endif
			else
			
				if !oDim:Seek(2, aKeyValues, .f.)
					
					for nInd := 1 to len(aKeyValues)
						nPos := ascan(aValues, { |x| aKeyNames[nInd, 1] == x[1] })
						if nPos == 0
							aAdd(aValues, { aKeyNames[nInd, 1], aKeyValues[nInd] })
						endif
					next
					
					if oDim:Append(aValues, .t.)
						nIns++
					endif
					
				elseif ::Owner():UpdMethod() != UPDMET_INSERT
					if oDim:Update(aValues, .t.)
						nAtz++
					endif
				endif
			endif

			nQtde++
			nRegTrans++
			if nRegTrans > LEN_TRANSACTION
				endTransaction()
				beginTransaction()
				nRegTrans := 0
			endif	
			if mod(nQtde, nLote) == 0 .or. (seconds() - nUltEnvio) > INTERVALO_ENV_PROGRESS
				cPrev := ""
				cDuracao := ""
				nUltEnvio := seconds()
				if nTotRec > 0                             
					dwPrevTime(::faTimes[1], ::faTimes[2], nQtde, nTotRec, @cPrev, @cDuracao)
				endif

				eval(abLog, IPC_BUFFER, .t.)
				eval(abLog, IPC_ETAPA, , nQtde / nTotRec)
				eval(abLog, IPC_TEMPO, ::faTimes[3], cDuracao, cPrev)
				eval(abLog, IPC_AVISO, STR0012 + dwFormat("[9,999,999]/[9,999,999] ([999.999]%)", {nQtde, nTotRec, nQtde / nTotRec * 100}))  //"Processando "
				eval(abLog, IPC_BUFFER, .f.)
			endif
			
			oSource:_Next()
		enddo

		eval(abLog, IPC_TEMPO, ::faTimes[3], cDuracao, dtoc(date()) + " " + time())

		endTransaction()
	endif

	if !DWKillApp()
		// verifica se ha campo data
		::VerCalend(oDim, @dtMin, @dtMax, abLog)
		::buildCalend(dtMin, dtMax, abLog)
		
		if ::Optimizer() .and. SGDB() == DB_INFORMIX
			eval(abLog, IPC_ETAPA, STR0078, IMP_ETA_INICIO)  //"Atualizando estatisticas"
			oDim:updStat()
			eval(abLog, IPC_ETAPA, STR0078, IMP_ETA_FIM)  //"Atualizando estatisticas"
		endif
		
		eval(abLog, IPC_ETAPA, STR0079, IMP_ETA_INICIO)  //"Verificando integridade"
		nIDEstat2 := ::Owner():startEstatistica(STR0079)  //"Verificando integridade"
		oQuery := TQuery():New(DWMakeName("TRA"))
		aSQL := {}
		
		if SGDB() <> DB_INFORMIX
			aEval(aIndexInfo[4], { |x| aAdd(aSql, x) })
		endif 
		
		aAdd(aSQL, "count(*) Z")
		oQuery:FieldList(DWConcatWSep(",", aSQL))
		oQuery:FromList(DWDimName(anDimID))
		aSQL := {}
		aEval(aIndexInfo[4], { |x| aAdd(aSql, x + ",") })
		aSql[len(aSQL)] := left(aSQL[len(aSQL)], len(aSQL[len(aSQL)])-1)
		oQuery:GroupBy(DWConcatWSep("", aSQL))
		oQuery:HavingClause("count(*) <> 1")
		
		oQuery2 := TQuery():New(DWMakeName("TRA"))
		oQuery2:FieldList("count(*)")
		
		if SGDB() == DB_INFORMIX
			oQuery2:FromList(DWDimName(anDimID))
			oQuery2:WhereClause("0 < (" + oQuery:SQL() + ")")
		else
			oQuery2:FromList("("+oQuery:SQL()+") X")
		endif
		
		oQuery2:WithDeleted(.t.)
		oQuery2:Open() 
		
		if oQuery2:value(1) > 0
			lAbort := .t.
			cMsg := STR0080 + dwFormat(" [9,999,999,999] ", { oQuery2:value(1) }) + STR0081 //"A dimensäo contem" //"registro(s) duplicado(s)"
			eval(abLog, IPC_INFO, { cMsg })
			eval(abLogFile, cMsg)
		endif
		
		oQuery2:close()
		::Owner():stopEstatistica(nIDEstat2)
		
		/*As estatística não podem ser processadas durante a importação otimizada [ORACLE]*/
		if !(::Optimizer())
			::Owner():addEstatistica(nIDEstat, STR0040 + dwFormat(" [99,999,999]", { nQtde }))  //"Lidos: "
			::Owner():addEstatistica(nIDEstat, STR0041 + dwFormat(" [99,999,999]", { nIns }))  //"Novos: "
			::Owner():addEstatistica(nIDEstat, STR0044 + dwFormat(" [99,999,999]", { nAtz }))  //"Atualizados: "
			nLote := DWElapSecs(::faTimes[1], ::faTimes[2], date(), time())
			nLote := nQtde / iif(nLote==0, 1, nLote) * 60
			::Owner():addEstatistica(nIDEstat, STR0045 + dwFormat(" [999,999] ", { nLote }) + STR0082) //"Velocidade processamento: "  //"reg/min"
		EndIf
		
		if !empty(cbOldValidate)
			oDim:Validate(cbOldValidate)
		endif  
		
		eval(abLog, IPC_ETAPA, , IMP_ETA_FIM)
	else
		::flAbort := .t.
		eval(abLogFile, STR0083)  //"Notificacäo KILLAPP recebida. O processo sera finalizado."
	endif
	
	oDim:Close()
	::Owner():stopEstatistica(nIDEstat)

return

method OraTransfDim(aoDim, abLog) class TDoImpDBF
	local aSQL := {}, aKeyNames := {}, aDataNames := {}
	local aIndexInfo := aoDim:Indexes()[2], nInd, aAux
	local nStartID, nStartRecno, nQtde
	local oQuery, lRet , cMsg := ""
	local nLote
	local dtMin := stod("20991231"), dtMax := stod("19000101")
	/*Armazenam o resultado da verificação de chave duplicada na origem.*/
	Local nDuplicados, lDuplicado, cSQL 
		
	if valType(abLog) != "B"
		abLog := { || }
	endif
	
	eval(abLog, IPC_AVISO, STR0084) //"Preparando importação otimizada"
	
	oQuery := TQuery():New(DWMakeName("TRA"))
	oQuery:FieldList("max(ID), max(R_E_C_N_O_)")
	oQuery:FromList(aoDim:Tablename())
	oQuery:Open()
	nStartID := oQuery:value(1) + 1
	nStartRecno := nStartID
	oQuery:Close()
	
	eval(abLog, IPC_AVISO, STR0085) //"Inicializando sequenciadores"
	
	createSeq(aoDim:TableName(), aSQL)	
	lRet := DWSQLExec(aSQL) == 0
 	
	aEval(aIndexInfo[4], { |x| aAdd(aKeyNames, "o." + x )})	  
	 
	/*Verifica se há registro duplicados na origem.*/   
	If (lRet)                    
	    cSQL := 'SELECT '
	    cSQL += dwConcatWSep(", ", aKeyNames) 
	    cSQL += ', COUNT(*) '
	    cSQL += ' FROM ' 
	    cSQL += '('
		cSQL += ::SQL()
		cSQL += ')o '
		cSQL += ' GROUP BY '
	    cSQL += dwConcatWSep(", ", aKeyNames) 
		cSQL += ' HAVING COUNT(*) > 1 '
	        
	    /*Recupera a quantidade de chaves duplicadas na origem.*/      
	    nDuplicados := ::foSource:recCount(cSQL)
	    /*Marca os FLAGs*/
	    lRet := (nDuplicados == 0)
	    lDuplicado := !lRet
	EndIf  
	
	If (lRet)
		aKeyNames := {}   
		nQtde := ::foSource:recCount(::SQL())
		eval(abLog, IPC_AVISO, STR0047 + transform(nQtde, "99,999,999")) //"Total de registros a processar"
		aSQL := {}
		aEval(aIndexInfo[4], { |x| aAdd(aKeyNames, "d."+x +" = s."+iif(empty(aoDim:Fields(x)[FLD_ROTEIRO]),x, aoDim:Fields(x)[FLD_ROTEIRO]) )})
		
		for nInd := 1 to len(aoDim:Fields())
			if aoDim:Fields()[nInd][FLD_NAME] != "ID"
				if aScan(aIndexInfo[4], aoDim:Fields()[nInd][FLD_NAME]) = 0
					aAdd(aDataNames, { "d." + aoDim:Fields()[nInd][FLD_NAME] , "s."+iif(empty(aoDim:Fields()[nInd][FLD_ORIGNAME]), aoDim:Fields()[nInd][FLD_NAME], aoDim:Fields()[nInd][FLD_ORIGNAME])} )
				endif
			endif
		next
		
		aoDim:DropRecnoIndex()
		
		eval(abLog, IPC_ETAPA, STR0086, IMP_ETA_INICIO)  //"Processando a importação"
		
		aAdd(aSQL, "MERGE INTO " + aoDim:Tablename() + " d")
		aAdd(aSQL, "USING (" + ::SQL() + ") s")
		aAdd(aSQL, "ON ("+ dwConcatWSep(" and ", aKeyNames) + ")")
		aAdd(aSQL, "WHEN MATCHED THEN UPDATE SET")
		aAux := {}  
		
		if ::Owner():UpdMethod() == UPDMET_INSERT
			aEval(aDataNames, { |x| aAdd(aAux, x[1] + "=" + x[1])})
		else
			aEval(aDataNames, { |x| aAdd(aAux, x[1] + "=" + x[2])})
		endif  
		
		if len(aAux) == 0
			aAux := { "d.R_E_C_N_O_ = d.R_E_C_N_O_" }
		endif  
		
		aAdd(aSQL, dwConcatwSep(",", aAux))
		aAux := {  }
		aEval(aKeyNames, { |x| aAdd(aAux, dwToken(x, "=")[1])})
		aEval(aDataNames, { |x| aAdd(aAux, x[1])})
		aAdd(aSQL, "WHEN NOT MATCHED THEN INSERT (ID, R_E_C_N_O_," + dwConcatwSep(",", aAux) + ")")
		aAux := {}
		aEval(aKeyNames, { |x| aAdd(aAux, dwToken(x, "=")[2])})
		aEval(aDataNames, { |x| aAdd(aAux, x[2])})
		aAdd(aSQL, "VALUES ("+aoDim:TableName()+"_ID.NEXTVAL, "+aoDim:TableName()+"_RECNO.NEXTVAL, "+dwConcatwSep(",", aAux)+")")
		
		lRet := DWSQLExec(aSQL) == 0
		cMsg := tcSqlError()
		aoDim:CreateRecnoIndex()
		eval(abLog, IPC_ETAPA, , IMP_ETA_FIM )
	endif
	
	aSQL := {}
	eval(abLog, IPC_AVISO, STR0087 ) //"Eliminando sequenciadores"
	dropSeq(aoDim:TableName(), aSQL)
	DWSQLExec(aSQL)
	
	if !lRet
		eval(abLog, IPC_BUFFER, .t.)
		eval(abLog, IPC_AVISO, STR0061) //"A importação otimizada falhou. Verifique o log de console e do TopConnect."
		eval(abLog, IPC_AVISO, STR0062) //"O processo de importação não otimizado, será executado."
		
		If (lDuplicado)	
			Conout("************************************************************") 
			Conout(ANSIToOEM (STR0062) )  			  	
			Conout(ANSIToOEM (STR0096 + DwStr(nDuplicado) + STR0097 + dwConcatWSep(" + ", aIndexInfo[4]) + STR0098 ) )  /*Existem n ocorrências ocorrências identicas para a chave [ cChave ] na origem da importação.*/
			Conout("************************************************************")			
		Else		
			eval(abLog, IPC_AVISO, "<code>"+cMsg+"</code>" )  
		EndIf
		
		eval(abLog, IPC_BUFFER, .f.)
	endif

return lRet

method InfTransfDim(aoDim, abLog, anQtde, anIns, anAtz) class TDoImpDBF
	// NOTAS SOBRE OTIMIZAÇÃO PARA INFORMIX
	//   1. O uso de tabela sem "log" (table type=raw), não surtiu muito efeito. O ganho foi insignificante
	//      e gerou efeitos colaterais.
	//   2. O comando "merge", só é disponível no Informix Extended Parallel Server (XPS)
	local aSQL := {}, aKeyNames := {}, aDataNames := {}
	local aIndexInfo := aoDim:Indexes()[2], nInd, aAux
	local nStartID, nStartRecno, nQtde
	local	oQuery := TQuery():New("tra"), cMsgErro := ""
	local nLote
	local cDimName := lower(aoDim:tablename())
	local dtMin := stod("20991231"), dtMax := stod("19000101")
  local lRet := .t.
  local cbMakeNotifySP := ;
  				{ |cIPCID, nTotalRec| ;
						aAdd(aSQL, "  let nIDIpc = null;"), ;
						aAdd(aSQL, "  let nRecnoIPC = null;"), ;
						aAdd(aSQL, "  select max(id) , max(r_e_c_n_o_) into nIDIPC, nRecnoIPC from " + TAB_IPC + ";"), ;
						aAdd(aSQL, "  if nIDIpc is null then"), ;
						aAdd(aSQL, "    let nIDIpc = 0;"), ;
						aAdd(aSQL, "  end if"), ;
						aAdd(aSQL, "  let nIDIpc = nIDIpc + 1;"), ;
						aAdd(aSQL, "  if nRecnoIPC is null then"), ;
						aAdd(aSQL, "    let nRecnoIPC = 0;"), ;
						aAdd(aSQL, "  end if"), ;
						aAdd(aSQL, "  let nRecnoIPC = nRecnoIPC + 1;"), ;
						aAdd(aSQL, "  insert into " + TAB_IPC + "(id, logfile, rectype, info1, info2, info3, stamp, d_e_l_e_t_, r_e_c_n_o_)") , ;
						aAdd(aSQL, "      values(nIDIPC, '" + cIPCID + "', " +dwStr(IPC_AVISO_SP) + ", out_ins + out_upd, '" + dwStr(nTotalRec) + "', '', to_char(CURRENT, '%H')*3600 + to_char(CURRENT, '%M')*60 + to_char(CURRENT, '%S'), '', nRecnoIPC);");
					}

  anQtde := 0
  anIns := 0
  anAtz := 0
  
	if valType(abLog) != "B"
		abLog := { || }
	endif
	
	eval(abLog, IPC_AVISO, STR0084) //"Preparando importação otimizada"
	
  nQtde := ::recCount()
	aSQL := {}
	aEval(aIndexInfo[4], { |x| aAdd(aKeyNames, { x, iif(empty(aoDim:Fields(x)[FLD_ROTEIRO]),x, aoDim:Fields(x)[FLD_ROTEIRO]) } )})
	for nInd := 1 to len(aoDim:Fields())
		if aoDim:Fields()[nInd][FLD_NAME] != "ID"
			if aScan(aIndexInfo[4], aoDim:Fields()[nInd][FLD_NAME]) = 0
				aAdd(aDataNames, { aoDim:Fields()[nInd][FLD_NAME] , iif(empty(aoDim:Fields()[nInd][FLD_ORIGNAME]), aoDim:Fields()[nInd][FLD_NAME], aoDim:Fields()[nInd][FLD_ORIGNAME])} )
			endif
		endif
	next
	
	oQuery:execute(EX_DROP_PROCEDURE, "sp_"+ cDimName)
	aoDim:DropRecnoIndex()
	
	if lRet
		aSQL := {}
		aAdd(aSQL, "alter table " + cDimName + " type(raw)")
	  lRet := oQuery:ExecSQL(DWConcatWSep(LF, aSQL)) == 0
	endif
			  
	if lRet
		aSQL := {}
    
		aAdd(aSQL, "create procedure sp_" + cDimName + "()")
		aAdd(aSQL, "returning char(1), float, float;")
		aAdd(aSQL, "define out_ret char(1);")
		aAdd(aSQL, "define out_ins float;")
		aAdd(aSQL, "define out_upd float;")
		aAdd(aSQL, "define cntLote int;")  // numero de registros do lote
		aAdd(aSQL, "define cntLoteSize int;")  // tamanho do lote
		aAdd(aSQL, "define cntRecno integer;") //número do recno a ser inserido
		aAdd(aSQL, "define nIDIPC integer;") //id da tabela IPC
		aAdd(aSQL, "define nRecnoIPC integer;") //recno da tabela IPC
		
		// definição dos campos de origem
		aAdd(aSQL, "define vTargetid like " + cDimName + ".id;")
		aEval(aKeyNames , { |x| aAdd(aSQL, "define v" + x[2] + " like " + cDimName + "." + x[1] +";")})
		aEval(aDataNames, { |x| aAdd(aSQL, "define v" + x[2] + " like " + cDimName + "." + x[1] +";")})
		aAdd(aSQL, "let out_ret = '0';")
		
		//inicialização de variaveis
		aAdd(aSQL, "let out_ins = 0;")
		aAdd(aSQL, "let out_upd = 0;")
		aAdd(aSQL, "select max(R_E_C_N_O_)")
		aAdd(aSQL, "  into cntRecno")
		aAdd(aSQL, "  from " + cDimName + ";")
		aAdd(aSQL, "if cntRecno is null then")
		aAdd(aSQL, "  let cntRecno = 0;")
		aAdd(aSQL, "end if")
		aAdd(aSQL, "let cntLote = 0;")
		aAdd(aSQL, "let cntLoteSize = " + dwStr(LOTE_INFORMIX) + ";")
    eval(cbMakeNotifySP, ::owner():fcIPCID, nQtde)
		aAdd(aSQL, "select *")
		aAdd(aSQL, "  from table ( multiset ( " + ::foSource:SQL() +") ) src")
		aAdd(aSQL, "  into temp " + cDimName + "_src;")
		aAux := {}		
		aEval(aKeyNames, { |x| aAdd(aAux, x[1])})
		aAdd(aSQL, "create index " + cDimName + "_src_00 on " + cDimName + "_src (" + dwConcatWSep(",", aAux) + ");")

		aAdd(aSQL, "foreach cursor1 with hold for")
		aAdd(aSQL, "  select")
		aAdd(aSQL, "      tar.id")
		aEval(aKeyNames , { |x| aAdd(aSQL, "      ,src." + x[2])})
		aEval(aDataNames, { |x| aAdd(aSQL, "      ,src." + x[2])})
		aAdd(aSQL, "    into")
		aAdd(aSQL, "      vTargetid")
		aEval(aKeyNames , { |x| aAdd(aSQL, "      ,v" + x[2])})
		aEval(aDataNames, { |x| aAdd(aSQL, "      ,v" + x[2])})
		aAdd(aSQL, "    from " + cDimName + "_src src")
		aAdd(aSQL, "    left join " + cDimName + " tar on")
		aAux := {}
		aEval(aKeyNames, { |x| aAdd(aAux, "src."+x[1]+"=tar."+x[2])})
		aAdd(aSQL, dwConcatWSep(LF+" and ", aAux))
		
		//controle do lote de transacao
		aAdd(aSQL, "let cntLote = cntLote + 1;")
		aAdd(aSQL, "if cntLote = "+dwStr(LOTE_INFORMIX)+" then")
		aAdd(aSQL, "  let cntLote = 0;")
    eval(cbMakeNotifySP, ::owner():fcIPCID, nQtde)
		aAdd(aSQL, "end if")
		
		//verifica se é inclusão ou atualização
		aAdd(aSQL, "  if vTargetid is null then") // faz a inclusão
		aAdd(aSQL, "    let out_ins = out_ins + 1;")
		aAdd(aSQL, "    let cntRecno =  cntRecno + 1;")
		aAdd(aSQL, "    insert into " + cDimName + "(")
		aAux := {}
		aAdd(aAux, "id")
		aEval(aKeyNames , { |x| aAdd(aAux, x[1])})
		aEval(aDataNames, { |x| aAdd(aAux, x[1])})
		aAdd(aAux, "d_e_l_e_t_")
		aAdd(aAux, "r_e_c_n_o_")
		aAdd(aSQL, dwConcatwSep(LF+",", aAux))
		aAdd(aSQL, "    )  values (")
		aAux := {}
		aAdd(aAux, "cntRecno")
		aEval(aKeyNames , { |x| aAdd(aAux, "v" + x[1])})
		aEval(aDataNames, { |x| aAdd(aAux, "v" + x[1])})
		aAdd(aAux, "' '")
		aAdd(aAux, "cntRecno);")                   
		aAdd(aSQL, dwConcatwSep(",", aAux))
		if len(aDataNames) > 0
			aAdd(aSQL, "    else")
			aAdd(aSQL, "      let out_upd = out_upd + 1;")
			aAdd(aSQL, "      update " + cDimName + " set")
			aAux := {}
			aEval(aDataNames, { |x| aAdd(aAux, x[1] + "=v" + x[1])})
			aAdd(aSQL, dwConcatwSep(LF + ",", aAux))
			aAdd(aSQL, "       where id = vTargetid;")
		endif
		aAdd(aSQL, "  end if;")
		aAdd(aSQL, "end foreach;")
		
    eval(cbMakeNotifySP, ::owner():fcIPCID, nQtde)

		// processamento finalizado e ok
		aAdd(aSQL, "let out_ret ='9';")
		aAdd(aSQL, "return out_ret, out_ins, out_upd;")

		aAdd(aSQL, "end procedure;")
		
		// ajusta as permissões
		lRet := oQuery:ExecSQL(DWConcatWSep(LF, aSQL)) == 0
	endif	
  if lRet
		eval(abLog, IPC_ETAPA, STR0086, IMP_ETA_INICIO)  //"Processando a importação"
		eval(abLog, IPC_AVISO, STR0086 ) //"Processando a importação"
		aRet := dwExecSP("sp_" + cDimName, , , , , , , , , , , , .t.)
		lRet := valType(aRet) == "A"
		if lRet
		  if aRet[1] == "9" // SP terminou
         anQtde := nQtde
         anIns := aRet[2]
         anAtz := aRet[3]
      else
        cMsgErro := STR0089 + "</p>"  //"Ocorreu um erro durante a execução de SP. Favor verificar log de console e/ou log do TopConnect"
      	lRet := .f.
      endif 		    
		endif
		eval(abLog, IPC_ETAPA, , IMP_ETA_FIM )
	endif

	if lRet
		aSQL := {}
		aAdd(aSQL, "alter table " + cDimName + " type(standard)")
	  lRet := oQuery:ExecSQL(DWConcatWSep(LF, aSQL)) == 0
	endif

  if lRet
    aoDim:CreateRecnoIndex()
	  oQuery:execute(EX_DROP_PROCEDURE, "sp_"+ cDimName)
  endif

	if !lRet
		cMsgErro += tcSqlError()
		eval(abLog, IPC_BUFFER, .t.)
		eval(abLog, IPC_AVISO, STR0061) //"A importação otimizada falhou. Verifique o log de console e do TopConnect."
		eval(abLog, IPC_AVISO, STR0062) //"O processo de importação não otimizado, será executado."
		eval(abLog, IPC_AVISO, STR0088 ) //"Mensagem de erro"
		eval(abLog, IPC_AVISO, "<code>"+cMsgErro+"</code>" )
		eval(abLog, IPC_BUFFER, .f.)
	endif

return lRet

method InfTransfCube(aoSource, aoTarget, abLog, aaDimID, aoCube, anQtde, anIns, anAtz) class TDoImpDBF
	local lRet := .t., cMsgErro := ""
	local aSQL := {}, aKeyNames := {}, aKeyDims := {}
	local aFldsTarget, nInd, nInd2, lFirst, lAutoUpd, nPos
	local oDim, aIndexInfo, aDimNames := {}
	local aIndNames := {}, oFato, cKeyList
	local aDownList := {}, cAux, aRet
	local aValid := {}, lAbort := .f.
  local	oQuery := TQuery():New("tra")
  local cCubeName := aoCube:fact():tablename()
  local aIntoVars := {}
  local cbMakeNotifySP := ;
  				{ |cIPCID, nTotalRec| ; 
						aAdd(aSQL, "  let nIDIpc = null;"), ;
						aAdd(aSQL, "  let nRecnoIPC = null;"), ;
						aAdd(aSQL, "  select max(id) , max(r_e_c_n_o_)"), ;
						aAdd(aSQL, "    into nIDIPC, nRecnoIPC"), ;
						aAdd(aSQL, "    from " + TAB_IPC + ";"), ;
						aAdd(aSQL, "  if nIDIpc is null then"), ;
						aAdd(aSQL, "    let nIDIpc = 0;"), ;
						aAdd(aSQL, "  end if"), ;
						aAdd(aSQL, "  let nIDIpc = nIDIpc + 1;"), ;
						aAdd(aSQL, "  if nRecnoIPC is null then"), ;
						aAdd(aSQL, "    let nRecnoIPC = 0;"), ;
						aAdd(aSQL, "  end if"), ;
						aAdd(aSQL, "  let nRecnoIPC = nRecnoIPC + 1;"), ;
						aAdd(aSQL, "  insert into " + TAB_IPC + "(id, logfile, rectype, info1, info2, info3, stamp, d_e_l_e_t_, r_e_c_n_o_)") , ;
						aAdd(aSQL, "      values(nIDIPC, '" + cIPCID + "', " +dwStr(IPC_AVISO_SP) + ", out_ins + out_upd, '" + dwStr(nTotalRec) + "', '', to_char(CURRENT, '%H')*3600 + to_char(CURRENT, '%M')*60 + to_char(CURRENT, '%S'), '', nRecnoIPC);");
					}

  anQtde := 0
  anIns := 0
  anAtz := 0
  
	if valType(abLog) != "B"
		abLog := { || }
	endif
	
  eval(abLog, IPC_AVISO, STR0046,,.t.) //"Gerando arquivo de trabalho"
	nQtde := aoSource:recCount(aoSource:sql())
  eval(abLog, IPC_AVISO, STR0047 + transform(nQtde, "99,999,999")) //"Total de registros a processar"
	
	aFldsTarget := aoTarget:Fields()
	aFldsSource := aoSource:Fields()
	aFields := {}
	for nInd := 1 to len(aFldsSource)
		nPos := ascan(aFldsTarget, { |x| x[FLD_ORIGNAME] == aFldsSource[nInd, FLD_NAME]} )
		if nPos <> 0
			aAdd(aFields, { aFldsTarget[nPos, FLD_NAME] , aFldsSource[nInd, FLD_NAME] })
	else
			aAdd(aFields, { aFldsSource[nInd, FLD_NAME] , aFldsSource[nInd, FLD_NAME] })
		endif
	next

	aoCube:Fact():DropRecnoIndex()
	oQuery:execute(EX_DROP_PROCEDURE, "sp_"+ cCubeName)
	
	if lRet
		aSQL := {}
		aAdd(aSQL, "alter table " + cCubeName + " type(raw)")
	  lRet := oQuery:ExecSQL(DWConcatWSep(LF, aSQL)) == 0
	endif

	if lRet
		aSQL := {}
		aAdd(aSQL, "create procedure sp_" + cCubeName + "()")
		aAdd(aSQL, "  returning char, float, float;")
		aAdd(aSQL, "  define out_ret char(1);")
		aAdd(aSQL, "  define out_ins float;")
		aAdd(aSQL, "  define out_upd float;")
		aAdd(aSQL, "  define cntLote int;")
		aAdd(aSQL, "  define cntLoteSize int;")
		aAdd(aSQL, "  define cntRecno integer;")
		aAdd(aSQL, "  define nIDIPC integer;")
		aAdd(aSQL, "  define nRecnoIPC integer;")
		aAdd(aSQL, "  define nIDAux integer;")
		aAdd(aSQL, "  define nRecnoAux integer;")

    for nInd := 1 to len(aaDimID)
		  oDim := oSigaDW:OpenDim(aaDimID[nInd])
		  aKeyNames := {}
		  aEval(oDim:Indexes()[2, 4], { |x| aAdd(aKeyNames, x)})
		  aAdd(aKeyDims, {aaDimID[nInd], aclone(aKeyNames), oDim:Descricao() })
  		aEval(aKeyNames, { |x| aAdd(aSQL, "  define v"+ x + " like " + oDim:tablename() + "." + x + ";") ,;
                                  aAdd(aIntoVars, "v" + x) })
  		aAdd(aSQL, "  define vID_DIM"+ dwInt2Hex(aaDimID[nInd],3) + " like " + cCubeName + ".ID_DIM" + dwInt2Hex(aaDimID[nInd],3) + ";")
      aAdd(aIntoVars, "vID_DIM"+ dwInt2Hex(aaDimID[nInd],3))
	  next
   
    aAux := aoCube:getIndicadores()
    for nInd := 1 to len(aAux)
  		aAdd(aSQL, "  define v"+ aAux[nInd, 2] + " like " + cCubeName + "." + aAux[nInd, 2] + ";")
  		aAdd(aIntoVars, "v"+ aAux[nInd, 2])
    next
    
 		aAdd(aSQL, "  let out_ret = '0';")
 		aAdd(aSQL, "  let out_ins = 0;")
 		aAdd(aSQL, "  let out_upd = 0;")
 		aAdd(aSQL, "  select max(R_E_C_N_O_) into cntRecno from " + cCubeName + ";")
 		aAdd(aSQL, "  if cntRecno is null then")
 		aAdd(aSQL, "    let cntRecno = 0;")
 		aAdd(aSQL, "  end if")
 		aAdd(aSQL, "  let cntLote = " + dwStr(LOTE_INFORMIX) + ";")
 		aAdd(aSQL, "  let cntLoteSize = cntLote;")

    eval(cbMakeNotifySP, ::owner():fcIPCID, nQtde)

		aAdd(aSQL, "  select *")
		aAdd(aSQL, "    from table ( multiset ( " + ::foSource:SQL() +") ) src")
		aAdd(aSQL, "    into temp " + cCubeName + "_src;")

    for nInd := 1 to len(aKeyDims)
	    aAux := {}
      aEval(aKeyDims[nInd, 2], { |x| aAdd(aAux, x)})
		  aAdd(aSQL, "  create index " + cCubeName + "_src_" + strZero(nInd,2)+ " on " + cCubeName + "_src (" + dwConcatWSep(",", aAux) + ");")
    next

 		aAdd(aSQL, "    foreach cursor1 with hold for select")
    aAux := {}
    for nInd := 1 to len(aaDimID)
		  oDim := oSigaDW:OpenDim(aaDimID[nInd])
		  aEval(oDim:Indexes()[2, 4], { |x| aAdd(aAux, "src."+x)})
 		  aAdd(aAux, "d" + dwInt2Hex(aaDimID[nInd], 3) + ".id")
	  next
    aEval(aoCube:getIndicadores(), { |x| aAdd(aAux, x[2]) })
    for nInd := 1 to len(aAux)
  		aAdd(aSQL, iif(nInd==1,"       ", "      ,")+ aAux[nInd])
    next
 		aAdd(aSQL, "    into")
    for nInd := 1 to len(aIntoVars)
  		aAdd(aSQL, iif(nInd==1,"       ", "      ,")+ aIntoVars[nInd])
    next
 		aAdd(aSQL, "    from " + cCubeName + "_src src,")
 		aAux := {}
    for nInd := 1 to len(aaDimID)
		  oDim := oSigaDW:OpenDim(aaDimID[nInd])
 		  aAdd(aAux, "      outer " + oDim:tablename() + " d" + dwInt2Hex(aaDimID[nInd], 3))
	  next

	  aAdd(aSQL, dwConcatWSep(","+CRLF, aAux))
	  aAdd(aSQL, "    where ")

    aAux := {}
    for nInd := 1 to len(aKeyDims)
      cAux := "d" + dwInt2Hex(aKeyDims[nInd, 1], 3) + "."
      aEval(aKeyDims[nInd, 2], { |x| aAdd(aAux, "src." + x + " = " + cAux + x)})
    next
    
    aAdd(aSQL, dwConcatWSep(" and " + CRLF, aAux))  

 		aAdd(aSQL, "  let cntLote = cntLote - 1;")
 		aAdd(aSQL, "  if cntLote = 0 then")
 		aAdd(aSQL, "    let cntLote = cntLoteSize;")
    eval(cbMakeNotifySP, ::owner():fcIPCID, nQtde)
 		aAdd(aSQL, "  end if")
 		aAdd(aSQL, "  let out_ins = out_ins + 1;")
 		aAdd(aSQL, "  let cntRecno =  cntRecno + 1;")

    for nInd := 1 to len(aaDimID)
		  oSigaDW:Dimensao():seek(1, { aaDimID[nInd] } )
		  cAux := dwInt2Hex(aaDimID[nInd], 3)
      aAdd(aSQL, "  if vID_DIM" + cAux + " is null then")
      if oSigaDW:Dimensao():value("autoupd")       
        aAux := {}
        aKeyNames := {}
		    oDim := oSigaDW:OpenDim(aaDimID[nInd])
		    aEval(oDim:Indexes()[2, 4], { |x| aAdd(aAux, x + " = v" + x ), aAdd(aKeyNames, x)})
        aAdd(aSQL, "    select id into vID_DIM" + cAux + " from " + oDim:tablename())
        aAdd(aSQL, "      where " + dwConcatWSep(" and ", aAux) + ";")
        aAdd(aSQL, "    if vID_DIM" + cAux + " is null then")
		    aAdd(aSQL, "      select max(id), max(r_e_c_n_o_) into nIDAux, nRecnoAux from " + oDim:tablename() + ";")
		    aAdd(aSQL, "      if nIDAux is null then")
		    aAdd(aSQL, "        let nIDAux = 0;")
		    aAdd(aSQL, "      end if")
		    aAdd(aSQL, "      if nRecnoAux is null then")
		    aAdd(aSQL, "        let nRecnoAux = 0;")
		    aAdd(aSQL, "      end if")
		    aAdd(aSQL, "      let nIDAux = nIDAux + 1;")
		    aAdd(aSQL, "      let nRecnoAux = nRecnoAux + 1;")
        aAdd(aSQL, "      insert into  " + oDim:tablename()+" (id, d_e_l_e_t_, r_e_c_n_o_," + dwConcatWSep(", ", aKeyNames))
        aAdd(aSQL, "           ) values (nIDAux, '', nRecnoAux, v" + dwConcatWSep(", v", aKeyNames) + ");")
        aAdd(aSQL, "      let vID_DIM" + cAux + " = nIDAux;")
        aAdd(aSQL, "    end if")
      else
        aAdd(aSQL, "    let vID_DIM" + cAux + " = -1;")
      endif
      aAdd(aSQL, "  end if")
    next

 		aAdd(aSQL, "  insert into " + cCubeName + "(id,")
 		aAux := {}
 		aEval(aoCube:fact():Fields(), { |x| aAdd(aAux, x[FLD_NAME])}, 2)
 		aAdd(aSQL, dwConcatWSep("    ,"+CRLF, aAux) + ", d_e_l_e_t_, r_e_c_n_o_)")
 		aAdd(aSQL, "    values(cntRecno")
 		aEval(aAux, { |x| aAdd(aSQL, ",v"+x) })
 		aAdd(aSQL, ", '', cntRecno);")
 		aAdd(aSQL, "end foreach;")
 		aAdd(aSQL, "let out_ret ='9';")
    eval(cbMakeNotifySP, ::owner():fcIPCID, nQtde)
		aAdd(aSQL, "return out_ret, out_ins, out_upd;")
 		aAdd(aSQL, "end procedure;")

		lRet := oQuery:ExecSQL(DWConcatWSep(LF, aSQL)) == 0
	endif	

  if lRet
		eval(abLog, IPC_ETAPA, STR0086, IMP_ETA_INICIO)  //"Processando a importação"
		aRet := dwExecSP("sp_" + cCubeName)
		lRet := valType(aRet) == "A"
		if lRet
		  if aRet[1] == "9" // SP terminou
         anQtde := nQtde
         anIns := aRet[2]
         anAtz := aRet[3]
      else
        cMsgErro := STR0089 + "</p>"  //"Ocorreu um erro durante a execução de SP. Favor verificar log de console e/ou log do TopConnect
      	lRet := .f.
      endif 		    
		endif
		eval(abLog, IPC_ETAPA, , IMP_ETA_FIM )
	endif

	if lRet
		aSQL := {}
		aAdd(aSQL, "alter table " + cCubeName + " type(standard)")
	  lRet := oQuery:ExecSQL(DWConcatWSep(LF, aSQL)) == 0
	endif

  if lRet
    aoCube:Fact():CreateRecnoIndex()
  endif

	if !lRet
		cMsgErro += tcSqlError()
		eval(abLog, IPC_BUFFER, .t.)
		eval(abLog, IPC_AVISO, STR0061) //"A importação otimizada falhou. Verifique o log de console e do TopConnect."
		eval(abLog, IPC_AVISO, STR0062) //"O processo de importação não otimizado, será executado."
		eval(abLog, IPC_AVISO, STR0088 ) //"Mensagem de erro"
		eval(abLog, IPC_AVISO, "<code>"+cMsgErro+"</code>" )
		eval(abLog, IPC_BUFFER, .f.)
	endif

return lRet

/*
--------------------------------------------------------------------------------------
Verifica se há campos datas e se o mesmo já esta no calendario
--------------------------------------------------------------------------------------
*/
method VerCalend(aoDS, aDtMin, aDtMax, abLog) class TDoImpDBF
	local nAux, nInd, nFields, oQuery2, aFields

	if !DWKillApp()
		if valType(abLog) != "B"
			abLog := { || }
		endif
		// verifica se ha campo data                           
		aFields := {}
		aEval(aoDS:Fields(), { |x| iif(x[FLD_TYPE]=="D", aAdd(aFields, x[FLD_NAME]), nil)})
		if len(aFields) > 0
			eval(abLog, IPC_ETAPA, STR0090, IMP_ETA_INICIO )  //"Verificando para atualizacäo"

			oQuery2 := TQuery():New("dtProc")
			aAux := {}              
			nFields := len(aFields)
			for nInd := 1 to nFields
				eval(abLog, IPC_ETAPA, , nInd / nFields)

				oQuery2:fieldList("min("+aFields[nInd]+") DT_MIN, max("+aFields[nInd]+") DT_MAX")
				oQuery2:fromList(aoDS:TableName())
				if SGDB() == DB_ORACLE
					oQuery2:whereClause("ID <> 0 and "+aFields[nInd]+" <> ' '")
				else
					oQuery2:whereClause("ID <> 0 and "+aFields[nInd]+" <> ''")
				endif
				oQuery2:Open()
				if !oQuery2:eof()
					if !empty(oQuery2:value("DT_MIN")) .and. stod(oQuery2:value("DT_MIN")) < aDtMin
						aDtMin := stod(oQuery2:value("DT_MIN"))
					endif
					if !empty(oQuery2:value("DT_MAX")) .and. stod(oQuery2:value("DT_MAX")) > aDtMax
						aDtMax := stod(oQuery2:value("DT_MAX"))
					endif
				endif
				oQuery2:Close()
			next
    	eval(abLog, IPC_ETAPA, , IMP_ETA_FIM )
		endif			
  endif
return

/*
--------------------------------------------------------------------------------------
Constroe o calendario, se necessário
--------------------------------------------------------------------------------------
*/
method buildCalend(aDtMin, aDtMax, abLog) class TDoImpDBF
  local dtMin := aDtMin
  local dtMax := aDtMax
  
	if year(dtMin) != 2099
		if dtMax < dtMin
			dtMax := dtMin + 365
		endif
		if empty(oSigaDW:Calend():DataInicial()) .or. ;
			 empty(oSigaDW:Calend():DataFinal()) .or. ; 
			 dtMin < oSigaDW:Calend():DataInicial() .or. ;
			 dtMax > oSigaDW:Calend():DataFinal()
		   eval(abLog, IPC_AVISO, STR0091 + dtoc(dtMin) + " - " + dtoc(dtMax) )  //"Gerando dimensäo [ Temporal ].<br>Periodo: "
			oSigaDW:Calend():StartProc(dtMin, dtMax)
		endif
   endif

return

/*
--------------------------------------------------------------------------------------
Propriedade RecCount
--------------------------------------------------------------------------------------
*/
method RecCount() class TDoImpDBF

return ::foSource:RecCount()

/*
--------------------------------------------------------------------------------------
Propriedade ForZap
--------------------------------------------------------------------------------------
*/
method ForZap(acCond) class TDoImpDBF

	property ::fcForZap := acCond
		
return ::fcForZap

/*
--------------------------------------------------------------------------------------
Propriedade RecLimit
--------------------------------------------------------------------------------------
*/
method RecLimit(anValue) class TDoImpDBF

	property ::fnRecLimit := anValue
		
return ::fnRecLimit

/*
--------------------------------------------------------------------------------------
Propriedade Fields
--------------------------------------------------------------------------------------
*/
method Fields() class TDoImpDBF
	local aRet 
	
	if ::IsOpen()
		aRet := ::foSource:Fields()
	endif
		
return aRet

/*
--------------------------------------------------------------------------------------
Obtem a fonte de dados
--------------------------------------------------------------------------------------
*/
method getSource() class TDoImpDBF
		
return ::foSource

/*
--------------------------------------------------------------------------------------
Métodos para formatação e impressão da lista de registros inválídos
--------------------------------------------------------------------------------------
*/
#define B_OUT iif(valType(aoArqLog) == "U", abLog, { |s,p| p := strTran(p,"  ", "&nbsp;&nbsp;"), iif(s,aoArqLog:writeln(p+"<br>"), aoArqLog:write(p)) })
method impInvalB(aoQuery, abLog, aaDimNames, aoArqLog, acDimName) class TDoImpDBF
	local nInd, aFields := aoQuery:Fields()
	local nCol := 0, nPos, aHeader := {}
	local bOut := B_OUT
	
	eVal(bOut, .t., "<html><body><h1 align=center>"+STR0092+"<br><small>"+STR0093+"</small></h1>")  //"Listagem de registros inválidos "  "apurados durante importação do cubo"
	if !(valType(acDimName) == "U")
		eVal(bOut, .t., "<h2!align=center>"+STR0014+" <b>"+acDimName+"</b></h2>") //"Dimensão "
	endif
	eVal(bOut, .t., "<p align=center>"+STR0094 + " " + dtoc(date()) + " " + STR0095 + " " + time()+ "</p><hr>")   //"Gerado em" //" às "
		
    eVal(bOut, .t., "<code>")        
/*
	for nInd := 1 to len(aFields)
		nPos := ascan(aaDimNames, { |x| x[1]==aFields[nInd, FLD_NAME] })
		nPos2 := ascan(aHeader, { |x| x[1]==aaDimNames[nPos, 1] })
		if nPos2 == 0
			aAdd(aHeader, { aaDimNames[nPos, 2], aFields[nInd, FLD_LEN] + aFields[nInd, FLD_DEC]} )
		else
			aHeader[nPos2, 2] += aFields[nInd, FLD_LEN] + aFields[nInd, FLD_DEC]
		endif
	next
	for nInd := 1 to len (aHeader)
		eVal(bOut, .f., padc(aHeader[nInd,1], aHeader[nInd,2]) + "  ")
	next
	eVal(bOut, .t., "")
*/
	for nInd := 1 to len(aFields)
		if left(aFields[nInd, FLD_NAME], 3) == "ID_"
			eVal(bOut, .f., "[ ]  ")
		else
			eVal(bOut, .f., padr(aFields[nInd, FLD_NAME], aFields[nInd, FLD_LEN]+aFields[nInd, FLD_DEC]) + "  ")
		endif
	next
	eVal(bOut, .t., "")
	for nInd := 1 to len(aFields)
		if left(aFields[nInd, FLD_NAME], 3) == "ID_"
			eVal(bOut, .f., "---  ")
		else
			eVal(bOut, .f., replicate("-", aFields[nInd, FLD_LEN] + aFields[nInd, FLD_DEC]) + "  ")
		endif
	next
	eVal(bOut, .t., "")
return .t.

method impInval(aoQuery, abLog, aoArqLog) class TDoImpDBF
	local nInd, aFields := aoQuery:Fields()
	local bOut := B_OUT

	while !aoQuery:eof() .and. !DWKillApp()
		for nInd := 1 to len(aFields)                                                              
			cAux := ""
			if aFields[nInd, FLD_NAME] == "R_E_C_N_O_" .or. aFields[nInd, FLD_NAME] == DWDelete()
			elseif left(aFields[nInd, FLD_NAME], 3) == "ID_"
				eval(bOut, .f., iif(aoQuery:value(nInd)==-1,"[X]","   "))
			else
				if aFields[nInd, FLD_TYPE] == "N"
					eval(bOut, .f., str(aoQuery:value(nInd),  aFields[nInd, FLD_LEN], aFields[nInd, FLD_DEC]))
				else
					eval(bOut, .f., aoQuery:value(nInd))
				endif
			endif
			eval(bOut, .f., "  ")
		next
		eVal(bOut, .t., "")
		aoQuery:_Next()
	enddo
	
return .t.

method impInvalA(aoQuery, abLog, aoArqLog) class TDoImpDBF
	local bOut := B_OUT

	eval(bOut, .t., "</code></body></html>")

return .t.

function __makeimpdbf()

return
