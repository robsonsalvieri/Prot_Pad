// ######################################################################################
// Projeto: DATAWAREHOUSE
// Modulo : ImpExp
// Fonte  : MakeImp - Classe para execução de importações
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 13.12.05 | 0548-Alan Candido | Versão 3
// 18.01.08 | 0548-Alan Candido | BOPS 139342 - Implementação e adequação de código, 
//          |                   | em função de re-estruturação para compartilhamento de 
//          |                   | código.
// --------------------------------------------------------------------------------------

#include "dwincs.ch"
#include "tbiconn.ch"
#INCLUDE "makeimp.ch"
#include "dwmakeim.ch"
#include "dwidprocs.ch"

/*
--------------------------------------------------------------------------------------
Classe: TMakeImp
Uso   : Execução de importações
--------------------------------------------------------------------------------------
*/
class TMakeImp from TDWObject
  data fcIPCID
	data fcServer
	data fnPort         
	data fcEnvironment
	data fcWorkDir
	data fcFileType
	data fcEmpresa
	data fcFilial
	data fcFileSource
	data fcLastMsg
	data foRPC
	data fnDSNID
	data fnDimID
	data fnCubeID
	data fcSQL
	data fcSQLStruct
	data fcTopServer
	data fcTopTipo
	data fcTopBanco
	data fcTopAlias
	data fbBeforeExec
	data fbAfterExec
	data fbValidate
	data fcValidate
	data fcFilter
	data fcForZap
	data flUseSX
	data fnRecLimit
	data fcProcInv
	data fcRptInval
	data fcUpdMethod
	data fnOptLevel
	data flOptimizer
	data flProcCons
	data fcTitle
	data faEstatistica 
	data flEmbedSQL
	data fbExecEmbed
	data flAbort
	data flWarning

	method New(acIPCID) constructor
	method Free()
	method NewMakeImp(acIPCID)
	method FreeMakeImp()
	method LastMsg()
	method ResetMsg() 
	method Server(acValue)
	method Port(anValue)
	method Environment(acValue)
  method WorkDir(acWorkDir)
  method Empresa(acValue)
  method Filial(acValue)
  method FileSource(acValue)
	method Connect()
	method Disconnect()
	method FileExist()
	method FileType()
	method DSNID(anValue) 
	method DimID(anID)
	method CubeID(anID)
	method SQL(acSQL)
	method SQLStruct(alSQL)
	method ValidSQL()
	method TopServer(acValue)
	method TopTipo(acValue)
	method TopBanco(acValue)
	method TopAlias(acValue)
	method PrepWorkfile(abLog, abLogFile)
	method processImp(abLog, abLogFile, aoMakeImp) 
	method doDbf(abLog, abLogFile) 
	method doSQL(abLog, abLogFile) 
	method getSQLRemote()
	method BeforeExec(abValue)
	method AfterExec(abValue)
	method Validate(abValue)
	method ValidaStr(acValue)
	method Filter(acValue)
	method ForZap(acValue)
	method UseSX(alValue)
	method RecLimit(anValue)
	method ProcInv(acValue)
	method RptInval(acValue)
	method UpdMethod(acValue)
	method OptLevel(anValue)
	method Optimizer(alValue) 
	method ProcCons(alValue) 
	method prepEvent(acCode)
	method title(acValue)  
	method Estatistica()
	method startEstatistica(acText)
	method addEstatistica(anIDEstat, acText)
	method stopEstatistica(anIDEstat)
	method EmbedSQL(alValue)
	method ExecEmbed(abValue)
endclass

/*
--------------------------------------------------------------------------------------
Construtor e destrutor da classe
--------------------------------------------------------------------------------------
*/
method New(acIPCId) class TMakeImp

	::NewMakeImp(acIPCId)

return
	 
method Free() class TMakeImp

	::FreeMakeImp()

return

method NewMakeImp(acIPCId) class TMakeImp

	::NewObject() 

  ::fcIPCID := acIPCId
	::fcServer := ""
	::fnPort  := 0
	::fcEnvironment := ""
	::fcWorkDir := ""
	::fcFileType := ""
	::fcEmpresa := ""
	::fcFilial := ""
	::fcFileSource := ""
	::fcLastMsg := ""
	::fnDSNID := 0
	::fnDimID := 0
	::fnCubeID := 0
	::fcSQL := ""
	::fcSQLStruct := ""
	::fcTopServer := ""
	::fcTopTipo := ""
	::fcTopBanco := ""
	::fcTopAlias := ""
	::fbBeforeExec := NIL
	::fbAfterExec := NIL
	::fbValidate := NIL
	::fcValidate := ""
	::fcFilter := ""
	::fcForZap := ""
	::flUseSX := .f.
	::fnRecLimit := 0
	::fnOptLevel := -1
	::flOptimizer := .f.
	::flProcCons := .f.  
	::fcTitle := ""        
	::faEstatistica := {}
	::flEmbedSQL := .f.
	::fbExecEmbed := nil
	
return
	 
method FreeMakeImp() class TMakeImp

	::FreeObject()
	
return

/*
--------------------------------------------------------------------------------------
Propriedade LastMsg
--------------------------------------------------------------------------------------
*/
method LastMsg() class TMakeImp

return ::fcLastMsg

method ResetMsg() class TMakeImp

	::fcLastMsg := ""
	
return 

/*
--------------------------------------------------------------------------------------
Propriedade Server
--------------------------------------------------------------------------------------
*/
method Server(acValue) class TMakeImp
	local nPos
	
	if valType(acValue) == "C"
		if (nPos := at(":", acValue)) > 0
			::Port(val(substr(acValue, nPos+1)))
			acValue := substr(acValue, 1, nPos-1)
		endif
		property ::fcServer := acValue
	endif
	
return ::fcServer

/*
--------------------------------------------------------------------------------------
Propriedade Port
--------------------------------------------------------------------------------------
*/
method Port(anValue) class TMakeImp

	property ::fnPort := anValue
	
return ::fnPort

/*
--------------------------------------------------------------------------------------
Propriedade Environment
--------------------------------------------------------------------------------------
*/
method Environment(acValue) class TMakeImp

	property ::fcEnvironment := acValue
	
return ::fcEnvironment

/*
--------------------------------------------------------------------------------------
Propriedade WorkDir
--------------------------------------------------------------------------------------
*/
method WorkDir(acValue) class TMakeImp

	if valType(acValue) != "U"
		acValue :=dwFixPath(acValue)
		
		property ::fcWorkdir := acValue
	endif
		
return ::fcWorkdir

/*
--------------------------------------------------------------------------------------
Propriedade Empresa
--------------------------------------------------------------------------------------
*/
method Empresa(acValue) class TMakeImp

	property ::fcEmpresa := acValue
	
return ::fcEmpresa

/*
--------------------------------------------------------------------------------------
Propriedade Filial
--------------------------------------------------------------------------------------
*/
method Filial(acValue) class TMakeImp

	property ::fcFilial := acValue
	
return ::fcFilial

/*
--------------------------------------------------------------------------------------
Propriedade FileSource
--------------------------------------------------------------------------------------
*/
method FileSource(acValue) class TMakeImp

	property ::fcFileSource := acValue
	
return ::fcFileSource

/*
--------------------------------------------------------------------------------------
Conecta/disconecta-se do servidor SigaDW
--------------------------------------------------------------------------------------
*/
method Connect() class TMakeImp
	local lOk := .f.

	::ResetMsg()

	if empty(::Server()) .or. empty(::Environment()) .or. ;
		empty(::Empresa()) .or. empty(::Filial())
		::fcLastMsg := STR0001/*//"Parâmetros para conexão insuficientes/inválidos"*/
	else      
		::OptLevel(-2)
		if ::OptLevel() == 0
		   RPCSetType(3)
			create rpcconn ::foRPC;
				on server ::Server() port ::Port();
					environment ::Environment();
					empresa ::Empresa() filial ::Filial() clean
			errorBlock({|e| __webError(e)})
			if valType(::foRPC) != "O"
				::fcLastMsg := STR0002/*//"Erro na criação do RPC"*/
			endif  
		else
			lOk := .t.                                     
		endif	
	endif

return lOk .or. (valType(::foRPC) == "O")

method Disconnect() class TMakeImp

	::ResetMsg()

	close rpcconn ::foRPC

	::foRPC := NIL

return .T.

/*
--------------------------------------------------------------------------------------
Verifica se o arquivo WorkPath + FileSource existe
--------------------------------------------------------------------------------------
*/
method FileExist() class TMakeImp
	local lRet
	
    if !::EmbedSQL()
    	CALLPROC IN ::foRPC;
			FUNCTION "RPCDWMain";
			PARAMETERS "FILEEXIST", nil, { ::WorkDir(), ::FileSource(), ::UseSX(), ::Empresa(), ::Filial() } ;
			RESULT lRet
		
		if valType(lRet) == "U"
			CALLPROC IN ::foRPC;
				FUNCTION "RPCDWMain";
				PARAMETERS "MSGERRO", nil;
				RESULT cMsg
			::fcLastMsg := cMsg
			lRet := .F.
		else
			lRet := .t.
		endif
	else
		lRet := .t.
	endif
	
return lRet

/*
--------------------------------------------------------------------------------------
Tipo do arquivo
--------------------------------------------------------------------------------------
*/
method FileType() class TMakeImp
	local cRet

	if !empty(::SQL())
		cRet := FT_SQL
	elseif ::UseSX()
		cRet := FT_SX
	else	
		CALLPROC IN ::foRPC;
			FUNCTION "RPCDWMain";
			PARAMETERS "FILETYPE", nil, { ::WorkDir() + "\" + ::FileSource() } ;
			RESULT cRet
	
		if valType(cRet) == "U"
			CALLPROC IN ::foRPC;
				FUNCTION "RPCDWMain", nil;
				PARAMETERS "MSGERRO";
				RESULT cMsg
			::fcLastMsg := cMsg
			cRet := FT_ERROR
		endif
	endif
		
return cRet

/*
--------------------------------------------------------------------------------------
Propriedade DSNID
--------------------------------------------------------------------------------------
*/
method DSNID(anValue) class TMakeImp

	property ::fnDSNID := anValue
	
return ::fnDSNID

/*
--------------------------------------------------------------------------------------
Propriedade Dimensao
--------------------------------------------------------------------------------------
*/
method DimID(anValue) class TMakeImp

	property ::fnDimID := anValue
	
return ::fnDimID

/*
--------------------------------------------------------------------------------------
Propriedade CubeID
--------------------------------------------------------------------------------------
*/
method CubeID(anValue) class TMakeImp

	property ::fnCubeID := anValue
	
return ::fnCubeID

/*
--------------------------------------------------------------------------------------
Propriedade SQL
--------------------------------------------------------------------------------------
*/
method SQL(acValue) class TMakeImp

	property ::fcSQL := acValue
	
return ::fcSQL

/*
--------------------------------------------------------------------------------------
Propriedade SQLStruct
--------------------------------------------------------------------------------------
*/
method SQLStruct(acValue) class TMakeImp

	property ::fcSQLStruct := acValue
	
return ::fcSQLStruct

/*
--------------------------------------------------------------------------------------
Valida a expressão SQL e a conexão
--------------------------------------------------------------------------------------
*/
method ValidSQL() class TMakeImp
	local lRet := .t.
	
	if empty(::SQL())
		lRet := .f.
		::fcLastMsg := STR0003/*//'Comando SQL não informado'*/
	endif
		
return lRet

/*
--------------------------------------------------------------------------------------
Propriedade TopServer
--------------------------------------------------------------------------------------
*/
method TopServer(acValue) class TMakeImp

	property ::fcTopServer := acValue
	
return ::fcTopServer

/*
--------------------------------------------------------------------------------------
Propriedade TopTipo
--------------------------------------------------------------------------------------
*/
method TopTipo(acValue) class TMakeImp

	property ::fcTopTipo := acValue
	
return ::fcTopTipo

/*
--------------------------------------------------------------------------------------
Propriedade TopBanco
--------------------------------------------------------------------------------------
*/
method TopBanco(acValue) class TMakeImp

	property ::fcTopBanco := acValue
	
return ::fcTopBanco

/*
--------------------------------------------------------------------------------------
Propriedade TopAlias
--------------------------------------------------------------------------------------
*/
method TopAlias(acValue) class TMakeImp

	property ::fcTopAlias := acValue
	
return ::fcTopAlias

/*
--------------------------------------------------------------------------------------
Propriedade BeforeExec
--------------------------------------------------------------------------------------
*/
method BeforeExec(abValue) class TMakeImp

	property ::fbBeforeExec := abValue
	
return ::fbBeforeExec

/*
--------------------------------------------------------------------------------------
Propriedade AfterExec
--------------------------------------------------------------------------------------
*/
method AfterExec(abValue) class TMakeImp

	property ::fbAfterExec := abValue
	
return ::fbAfterExec

/*
--------------------------------------------------------------------------------------
Propriedade Validate
--------------------------------------------------------------------------------------
*/
method Validate(abValue) class TMakeImp

	property ::fbValidate := abValue
	
return ::fbValidate

/*
--------------------------------------------------------------------------------------
Propriedade ValidaStr
--------------------------------------------------------------------------------------
*/
method ValidaStr(acValue) class TMakeImp

	property ::fcValidate := acValue
	
return ::fcValidate

/*
--------------------------------------------------------------------------------------
Propriedade Filter
--------------------------------------------------------------------------------------
*/
method Filter(acValue) class TMakeImp

	property ::fcFilter := acValue
	
return ::fcFilter

/*
--------------------------------------------------------------------------------------
Propriedade ForZap
--------------------------------------------------------------------------------------
*/
method ForZap(acValue) class TMakeImp

	property ::fcForZap := acValue
	
return ::fcForZap

/*
--------------------------------------------------------------------------------------
Propriedade UseSX
--------------------------------------------------------------------------------------
*/
method UseSX(alValue) class TMakeImp

	property ::flUseSX := alValue
	
return ::flUseSX

/*
--------------------------------------------------------------------------------------
Propriedade RecLimit
--------------------------------------------------------------------------------------
*/
method RecLimit(anValue) class TMakeImp

	property ::fnRecLimit := anValue
	
return ::fnRecLimit

/*
--------------------------------------------------------------------------------------
Processa a importação dos dados para o arquivo de trabalho
--------------------------------------------------------------------------------------
*/                               
method PrepWorkfile(abLog, abLogFile) class TMakeImp
	local lRet := .t.
	local cType := ::FileType()
    local nEstat 

	nEstat := ::startEstatistica(STR0016)  //"Preparação do arquivo de trabalho"
	::fcLastMsg := ""
		
	::OptLevel(-2)
  __DWErroCtrl := .t.
	begin sequence
		do case
			case cType == FT_XBASE .or. cType == FT_SX
				::doDbf(abLog, abLogFile)
			case cType == FT_SQL
				::doSQL(abLog, abLogFile)
			otherwise
				lRet := .f.
		endcase
	recover //using oE  //#### TODO - verificar condição de erro compilando com using
		::fcLastMsg := 'INTERNAL ERROR' //oE:Description()
	end sequence
  __DWErroCtrl := .f.
	lRet := empty(::fcLastMsg)

	::stopEstatistica(nEstat)
	
return lRet            

/*
--------------------------------------------------------------------------------------
Processa arquivos 
--------------------------------------------------------------------------------------
*/                               
method processImp(abLog, abLogFile, aoMakeImp) class TMakeImp
	local lOk := .t., cMsg
	local nEstat := ::startEstatistica(STR0017)  //"Processamento do arquivo de trabalho"
	
	//	eval(abLog, IPC_PROCESSO, IMP_PRO_WF_PREP)
	if valType(::BeforeExec()) == "B"
		eval(abLog, IPC_ETAPA, STR0018, IMP_ETA_INICIO)  //"Executando rotina de inicialização"
		eval(abLogFile, STR0004)  //"Executando rotina de inicialização do usuário"
		nEstat2:= ::startEstatistica(STR0019)  //"Rotina de inicialização do usuário"
		lOk := __runCB(::BeforeExec())
		::stopEstatistica(nEstat2)
		if lOk
			cMsg := STR0005  //"Rotina de inicialização do usuário executada"
		else
			cMsg := STR0020  //"Processo finalizado, por solicitação da rotina de inicialização do usuário"
			lOk := .f.
		endif
		eval(abLogFile, cMsg)
		eval(abLog, IPC_ETAPA, , IMP_ETA_FIM)
	endif
	
	if lOk
		aoMakeImp:ForZap(::ForZap())
		
		eval(abLog, IPC_ETAPA, STR0006, IMP_ETA_INICIO)  //"Abrindo arquivo origem"
		
		eval(abLogFile, STR0006 )  //"Abrindo arquivo origem"
		aoMakeImp:Open()
		aoMakeImp:RecLimit(::RecLimit())
		
		eval(abLog, IPC_ETAPA, , IMP_ETA_1Q)
		if !empty(::Filter())
			eval(abLogFile, STR0021)  //"Aplicando filtro na origem"
			eval(abLogFile, "<blockquote><code>" + strTran(::Filter(), CRLF,"<br>") + "</code></blockquote>")
			aoMakeImp:Filter(::Filter())
		endif
		
		eval(abLog, IPC_ETAPA, , IMP_ETA_2Q)
		if !empty(::Validate())
			eval(abLogFile, STR0014)  //"Aplicando validação"
			eval(abLogFile, "<blockquote><code>" + strTran(::ValidaStr(), CRLF,"<br>") + "</code></blockquote>")
		endif
		
		eval(abLog, IPC_ETAPA, , IMP_ETA_FIM)
		if !empty(::DimID())
			//		   eval(abLog, IPC_PROCESSO, IMP_PRO_PROCESS)
			eval(abLog, IPC_ETAPA, STR0022, IMP_ETA_INICIO)  //"Importando dados..."
			aoMakeImp:TransfDim(::DimID(), abLog, abLogFile)
			eval(abLog, IPC_ETAPA, "", IMP_ETA_FIM)
		else
			//		   eval(abLog, IPC_PROCESSO, IMP_PRO_PROCESS)
			eval(abLog, IPC_ETAPA, STR0007, IMP_ETA_INICIO)  //"Preparando arquivo de trabalho"
			if aoMakeImp:CreateWF(abLog)
				aoMakeImp:TransfData(abLog, abLogFile)
				if DWDropWF()
					aoMakeImp:DropWF()
				endif
			endif
		endif
		aoMakeImp:Close()
		
		if !aoMakeImp:flAbort .and. valType(::AfterExec()) == "B"
			eval(abLog, IPC_ETAPA, STR0023, IMP_ETA_INICIO)  //"Executando rotina de finalização"
			eval(abLogFile, STR0011)  //"Executando rotina de finalização do usuário"
			nEstat2 := ::startEstatistica(STR0024)  //"Rotina de finalização do usuário"
			__runCB(::AfterExec())
			nEstat2 := ::addEstatistica(nEstat2)
			cMsg := STR0012  //"Rotina de finalização do usuário executada"
			eval(abLog, IPC_AVISO, cMsg)
		endif
		eval(abLog, IPC_ETAPA, , IMP_ETA_FIM)
	endif
	
	::flAbort := aoMakeImp:flAbort
	::flWarning := aoMakeImp:flWarning
	::stopEstatistica(nEstat)

return

/*
--------------------------------------------------------------------------------------
Processa arquivos DBF
--------------------------------------------------------------------------------------
*/                               
method doDbf(abLog, abLogFile) class TMakeImp
	local oProc := TDoImpDBF():New(Self)
		
	oProc:Filename(::WorkDir() + ::FileSource())
	::processImp(abLog, abLogFile, oProc)

return

/*
--------------------------------------------------------------------------------------
Processa arquivos SQL
--------------------------------------------------------------------------------------
*/                               
method doSQL(abLog, abLogFile) class TMakeImp
	local oProc := ::getSQLRemote()

	::processImp(abLog, abLogFile, oProc)

	if oProc:flAbort
		::fcLastMsg := STR0025  //"Ocorreu um erro"
	endif
return

/*
--------------------------------------------------------------------------------------
Prepara acesso SQL remoto
--------------------------------------------------------------------------------------
*/                               
method getSQLRemote() class TMakeImp
	local oProc := TDoImpSQL():New(Self)

	if ::Optimizer() .and. SGDB() == DB_ORACLE .and. !empty(::SQLStruct())
		//oProc:SQL(::SQLStruct())
		oProc:SQL(::SQL())
	else	
		oProc:SQL(::SQL())
	endif

return oProc

/*
--------------------------------------------------------------------------------------
Propriedade ProcInv
--------------------------------------------------------------------------------------
*/                               
method ProcInv(acValue) class TMakeImp

	property ::fcProcInv := acValue

return ::fcProcInv

/*
--------------------------------------------------------------------------------------
Propriedade RptInval
--------------------------------------------------------------------------------------
*/                               
method RptInval(acValue) class TMakeImp

	property ::fcRptInval := acValue

return ::fcRptInval

/*
--------------------------------------------------------------------------------------
Propriedade UpdMethod
--------------------------------------------------------------------------------------
*/                               
method UpdMethod(acValue) class TMakeImp

	property ::fcUpdMethod := acValue

return ::fcUpdMethod

/*
--------------------------------------------------------------------------------------
Propriedade OptLevel
--------------------------------------------------------------------------------------
*/                               
method OptLevel(anValue) class TMakeImp

	if valType(anValue) == "N" .and. anValue == -2 // apurar opt
		anValue := 0 // sem otimização
	endif

	property ::fnOptLevel := anValue

return ::fnOptLevel

/*
--------------------------------------------------------------------------------------
Propriedade Optimizer
--------------------------------------------------------------------------------------
*/                               
method Optimizer(alValue) class TMakeImp

	property ::flOptimizer := alValue

return ::flOptimizer
                  
/*
--------------------------------------------------------------------------------------
Propriedade ProcCons
--------------------------------------------------------------------------------------
*/                               
method ProcCons(alValue) class TMakeImp

	property ::flProcCons := alValue

return ::flProcCons

/*
--------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------
*/                               
method prepEvent(acCode) class TMakeImp
	local cCode := acCode, nPos, cAux
	
	while (nPos := at("DWREMOTESP", upper(cCode))) <> 0
		cAux := substr(cCode, 1, nPos-1)
		cAux += 'XXRemoteSP("'+ ::TopServer() + '","' + ::TopTipo() + '","' + ::TopBanco() + '","' + ::TopAlias() + '",' + substr(cCode, nPos+11)
		cCode := cAux
	enddo

return __compstr(strTran(cCode, "XXRemoteSP", "DWRemoteSP"))

/*
--------------------------------------------------------------------------------------
Propriedade Title
--------------------------------------------------------------------------------------
*/                               
method title(acValue) class TMakeImp

	property ::fcTitle := acValue

return ::fcTitle

/*
--------------------------------------------------------------------------------------
Propriedade Estatistica
--------------------------------------------------------------------------------------
*/
method Estatistica() class TMakeImp
	local aRet := {}, nInd, aAux
                    
	::faEstatistica := aSort(::faEstatistica,,, {|x,y| x[8]<y[8]})	            

	for nInd := 1 to len(::faEstatistica)
		aAux := ::faEstatistica[nInd]
		aAdd(aRet, { aAux[2], aAux[3], aAux[4], aAux[5], aAux[6], aAux[7]})
		aEval(aAux[9], { |x| aAdd(aRet, x)})
	next
	
return aRet
                     
/*
--------------------------------------------------------------------------------------
Inicia/para ou adiciona uma estatistica
--------------------------------------------------------------------------------------
*/
method startEstatistica(acText) class TMakeImp
	local aAux := { 0, acText, date(), time(), nil, nil, nil, nil, {}}
	aAux[8] := dwElapSecs(stod('20000101'), "00:00:00", aAux[3], aAux[4])
	
	aAdd(::faEstatistica, aAux)
    
return len(::faEstatistica)

method addEstatistica(anIDEstat, acText) class TMakeImp
	local aAux := ::faEstatistica[anIDEstat][9]

	aAdd(aAux, acText)
    
return 

method stopEstatistica(anIDEstat) class TMakeImp
	local aAux := ::faEstatistica[anIDEstat]
	
	aAux[5] := date()
	aAux[6] := time()
	aAux[7] := dwElapTime(aAux[3], aAux[4], aAux[5], aAux[6])        
    
return 

/*
--------------------------------------------------------------------------------------
Propriedade EmbedSQL
--------------------------------------------------------------------------------------
*/                               
method EmbedSQL(alValue) class TMakeImp

	property ::flEmbedSQL := alValue

return ::flEmbedSQL

/*
--------------------------------------------------------------------------------------
Propriedade ExecEmbed
--------------------------------------------------------------------------------------
*/
method ExecEmbed(abValue) class TMakeImp

	property ::fbExecEmbed := abValue
	
return ::fbExecEmbed

/*
