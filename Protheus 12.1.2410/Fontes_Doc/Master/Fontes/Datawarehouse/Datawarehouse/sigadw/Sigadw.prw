// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : SigaDW
// Fonte  : TSigaDW - Define o objeto SigaDW
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 01.06.01 | 0548-Alan Candido |
// 28.09.05 | 0548-Alan Candido | Versão 3
// 23.11.07 | 0548-Alan Candido | BOPS 136453 - Tratamento de 'listas' qdo troca-se o DW
// 18.01.08 | 0548-Alan Candido | BOPS 139342 - Implementação e adequação de código, 
//          |                   | em função de re-estruturação para compartilhamento de 
//          |                   | código.
// 23.01.08 | 0548-Alan Candido | BOPS 136637 - Devido a inserção de dados por SP em uma
//          |                   | dimensão, força um "refresh" da tabela. 
// 20.02.08 | 0548-Alan Candido | BOPS 139342 - Implementação do método isPortal, para
//          |                   | compatibilização de código.
// 03.11.08 | 0548-Alan Candido | FNC 00000004062/2008 (8.11) e 00000004221/2008 (9.12)
//          |                   | Implementação do método UsrConnector, para identificar
//          |                   | a conexão para a importação de usuários SigaAdv
// 25.11.08 | 0548-Alan Candido | FNC 00000007374/2008 (10) e 00000007385/2008 (8.11)
//          |                   | Ajustes nos procedimentos de atualização e validação de build
// 15.12.08 | 0548-Alan Candido | FNC 09025/2008 (8.11) e 09034/2008 (10)
//          |                   | . Adequação de geração de máscara em campos numéricos e datas, 
//          |                   | para respeitar o formato conforme idioma 
//          |                   | (chave RegionalLanguage na sessão do ambiente).
// 30.12.08 |0548-Alan Candido  | FNC 00000011160/2008 (8.11) e 00000011201/2008 (P10)
//          |                   | Correção na obtenção de build instalada
// 19.02.10 | 0548-Alan Candido | FNC 00000003657/2010 (9.12) e 00000001971/2010 (11)
//          |                   | Implementação de visual para P11 e adequação para o 'dashboard'
// --------------------------------------------------------------------------------------
     
#include "dwincs.ch"
#include "Sigadw.ch"

/*
--------------------------------------------------------------------------------------
Classe: TSigaDW
Uso   : Objeto para gerenciamento do SigaDW
--------------------------------------------------------------------------------------
*/
class TSigaDW from TDWObject
	data faActionList 
	data faHelps
	data fcBuildDW
	data faNotify
	data fnDWIndex
	data foDWList
	data foCubes
	data foConsultas
	data foTableList
	data foConnections
	data fcHelpServer
	data flSched
	data foWFObj
	data fcShowFilter
	data fnUserURL
	data fcExcel
	data fnBlocked
	data fcLiberacaoPrevista
	data flNotifyUsers
	data fcRowColor
	data flLogOrder
	data fcUsePanels
	data fcShowPageNav
	data flShowMsg
	data flLogAct
	data flLogImpExp
	data flEnablePaging
	data flUsrProtheus
	data flUsrOnLine
	data fnDsnUsrSiga
	data flExpNotify
	data fnRecLimit
	data fnWidthColDD
	data foCalend
	data fnQueryRefresh
	data foError
	data fcTheme
	data flShowQbe 
	data fcAutoQbe
	data flShowCubeUpdate
	data flSortMeasure
	data flTypeCon // Tipo da consulta .T. = tamanho pelo título / tamanho do campo.
	
	method New() constructor
	method Free()

	method HelpServer(acValue)				// Nome do servidor de helps
	method Cubes()                      // Lista de cubos
	method TableLog()                   // Tabela de log de mensagens
	method DWList() 		
	method InitDW(acName, acDesc, acIcone, alUpdate) 
	method RenameDW(acIntName, acName)
	method DispDW(acIntName, alDisp)
	method SelectDW(acIntName, anID)
	method DeleteDW(anID)
	method Log(acMsg, acP1, acP2, acP3, acP4, acP5, acP6)
	method LogError(acaMsg, acTitle, acLogfile)
	method LogEvent(acaMsg, acTitle, acLogfile)
	method LogFile(acaMsg, acTitle, acLogFile)
	method Modified()
	method LoadCfg()
	method SaveCfg()
	method Finalize()
	method AddTable(aoDataset)
	method RemoveTable(aoDataset)
	method SearchTable(acTablename)
	method ReleaseTable()
	method CfgAttrib(alValue)
	method DefDimension(anCubeID, anDimNumber)
	method DefDimFields(anDimID, aaKeyList)
	method Dimensao() 
	method DimFields()
	method Connections() 
	method RecLimit(anValue)
	method RowColor(acValue)
	method Consultas()         // Lista de consultas
	method LoadStat(acTipoObj, nObjID, alFormated)	
	method ShowFilter(acValue)
	method Excel(acValue)
	method Blocked(anValue)
	method LiberacaoPrevista(acValue)
	method NotifyUsers(alValue)
	method Calend()                     // Calendário (tabela temporal)
	method QueryRefresh(anValue)
	
	method VerifyCube(anCubeID)
	method OpenCube(anCubeID, alInit, alForProcess)
	method OpenCubeRaise(anCubeID, alInit, alForProcess, alRaise)
	method CloseCube(anCubeID)
	method DefCube(anCubeID)

	method VerifyDim(anDimID)
	method OpenDim(anDimID, alInit)
	method CloseDim(anDimID)
	method InitDim(anDimID)
	method DefDim(anDimID)
	method DropConexao(anConexaoID)
	method DropDim(anDimID)
	method DropDS(anDSID) 
	method DropCube(anCubeID)
	method DropCons(anConsID)
	method Notify()
	method isSched(alValue)
	method WFObj() 
	method JarFile()	
	method LogReq() 
  method LogOrder(alValue)
  method UsePanels(acValue)
  method ShowPageNav(acValue)
  method UserURL(anValue)
	method ShowMsg(alValue)
	method LogAct(alValue)
	method LogImpExp(alValue)
	method EnablePaging(alValue)
	method ExpNotify(alValue)
	method UsrProtheus(alValue)
	method UsrOnLine(alValue)
	method DsnUsrSiga()
	method UsrConnector(anValue)
	method WidthColDD(anValue)
	method BuildDW()
	method BuildWeb()
	method updBuildDW()
	method registerActions()
	method registerHelp()
	method validAction(acAction)
	method logUsrAction(aaAction)
	method getAction(anActionPos) 
	method getActDesc(acAction) 
	method execAction(acAction, anMoment, aBuffer)
	method DWCurr()                     // DW corrente
	method DWCurrID()                   // ID do DW corrente
	method DWInfo(anID)
	method ShowHeader(acAction)
	method ShowFooter(acAction)
	method buildCabec(aBuffer)
	method buildHeader(aBuffer)
	method buildBeginBody(aBuffer) 
	method buildEndBody(aBuffer) 
	method buildFooter(aBuffer)
	method HaveDimEmpFil()
	method getTitle()
 	method getLibJS()
 	method error(aoError)
 	method ClearError() local
 	method isError()
 	method mountError(alAviso, alHtml)
 	method getMsgError()
	method theme(acValue) 
	method isPortal()          
	method showQbe(alValue)	
	method autoQbe(acValue)
	method showCubeUpdate(alValue)
	method TypeCon(alValue)
	method sortMeasure(alValue)
	method AdvEnvironment(lValue)  
	method AutoRefresh(anValue)
endclass

/*
--------------------------------------------------------------------------------------
Construtor e destrutor da classe
--------------------------------------------------------------------------------------
*/
method New() class TSigaDW

	_Super:New()
	
	::foCubes 			:= NIL
	::faNotify 			:= { "", "" }
	::fnDWIndex 		:= -1
	::foDWList 			:= nil
	::fcHelpServer 		:= GetPvProfString(GetEnvServer(), "HELPSERVER", "ERROR", DWIniFile())
	::foTableList 		:= {}
	::flSched 			:= .f.
	::fnRecLimit   		:= 50
	::fnWidthColDD 		:= DWWidthColDD()
	::fcShowFilter 		:= OPTION_SHOWNOTHING
	::fnUserURL    		:= -1
	::fcExcel 	   		:= EXCEL_NONE
	::fnBlocked 		:= 0
	::fcLiberacaoPrevista := ""
	::flNotifyUsers 	:= .f.
	::fcRowColor   		:= "1"
	::flLogOrder   		:= .t.
	::fcUsePanels  		:= PAN_SIMPLES
	::fcShowPageNav 	:= PAGE_NAV_DEFAULT
	::flShowMsg    		:= .f.
	::flLogAct 	   		:= .f.
	::flLogImpExp  		:= .t.
	::flEnablePaging 	:= .f.
	::flExpNotify  		:= .f.
	::flUsrProtheus 	:= .f.
	::flUsrOnLine  		:= .f.
	::fnDsnUsrSiga 		:= 0
	::foCalend 	   		:= TCalend():New(Self)
	::fnQueryRefresh 	:= 0
	::fcTheme 	   		:= DWDefaultTheme()
	::flShowQbe    		:= .f.
	::fcAutoQbe 		:= OPTION_NOTAPPLY
	::flShowCubeUpdate 	:= .f.
	::flTypeCon			:= .F.
	::flSortMeasure 	:= .F. 
	::LoadCfg()
	::BuildDW()
	
	if empty(GetGlbValue("DWConfigAtz"))
		::CfgAttrib(.t.)
	endif  
	
return

method Free() class TSigaDW

	_Super:Free()

return

/*
--------------------------------------------------------------------------------------
Propriedade TableLog
--------------------------------------------------------------------------------------
*/
method TableLog() class TSigaDW

return InitTable(TAB_LOG)

/*
--------------------------------------------------------------------------------------
Propriedade Cubes
--------------------------------------------------------------------------------------
*/
method Cubes() class TSigaDW

	if valtype(::foCubes) == "U"
		::foCubes := TCubes():New(Self)
	endif
	
return ::foCubes

/*
--------------------------------------------------------------------------------------
Propriedade Consultas
--------------------------------------------------------------------------------------
*/         
method Consultas() class TSigaDW

	if valtype(::foConsultas) == "U" .OR. !(::foConsultas:IsOpen())
		::foConsultas := InitTable(TAB_CONSULTAS)
	endif
	
return ::foConsultas

/*
--------------------------------------------------------------------------------------
Le informações de estatisticas sobre elementos do DW
--------------------------------------------------------------------------------------
*/         
method LoadStat(acTipoObj, anObjID, alFormated) class TSigaDW
	local nRet := 0
	local oEstat := initTable(TAB_ESTAT)

	default alFormated := .t.
	default anObjID := 0

	if oEstat:Seek(2, { ::DWCurrID(), acTipoObj, anObjID })
		nRet := oEstat:value("valor")
	endif
	
return iif(alFormated, transform(nRet, dwMask("999,999,999")), nRet)

/*
--------------------------------------------------------------------------------------
Propriedade HelpServer
--------------------------------------------------------------------------------------
*/
method HelpServer(acValue) class TSigaDW

	property ::fcHelpServer := acValue

return ::fcHelpServer

/*
--------------------------------------------------------------------------------------
Ambiente (environment) do SigaAdv
--------------------------------------------------------------------------------------
*/
method AdvEnvironment(lValue) class TSigaDW

	property ::fcAdvEnvironment := lValue

return (::fcAdvEnvironment)

/*
--------------------------------------------------------------------------------------
Inicializa um Datawarehouse
Args: acIntName -> string, nome interno
acName -> string, nome (descricao)
acServer -> string, servidor AP
acIcone -> string, nome do icone
alUpdate -> logico, indica atualização (rename)
Ret: nRet -> numérico, posição do DW
--------------------------------------------------------------------------------------
*/
method InitDW(acName, acDesc, acIcone, alUpdate) class TSigaDW
	local nRet := 0
	local oDW := initTable(TAB_DW)
	    
	default alUpdate := .f.
	                                       
	if alUpdate
		if oDW:seek(1, { ::DWCurrID() }) .and. ;
		   oDW:update({ { "nome", acName }, ;
                    { "descricao", acDesc } ,;
                    { "icone", acIcone } })
		   ::DWList():Items()[::fnDWIndex, DW_NAME] := acName
		   ::DWList():Items()[::fnDWIndex, DW_DESC] := acDesc
		   ::DWList():Items()[::fnDWIndex, DW_ICONE] := acIcone
		   nRet := ::DWCurrID()
		else
			DWRaise(ERR_002, SOL_000, oDW:Msg(.t.))
		endif
	elseif oDW:append({ { "nome", acName }, ;
                    { "descricao", acDesc } ,;
                    { "icone", acIcone } })
		if ::DWList():AddItem(oDW:value("id"), acName, acDesc, acIcone, oDW:value("disp"), oDW:value("criado"))
			nRet := oDW:value("id")
			::fnDWIndex := ::DWList():Count()
			if valtype(oUserDW) == "O"
				oUserDW:LastDW(nRet)
			endif
		endif
		::Log(STR0050, STR0051 + acName, STR0052 + acDesc) //###"Datawarehouse inicializado"###"Nome"###"Descrição"
	else
		DWRaise(ERR_002, SOL_000, oDW:Msg(.t.))
	endif

	oDW:Close()	

return nRet

/*
--------------------------------------------------------------------------------------
Renomeia um Datawarehouse
Args: acIntName -> string, nome interno
acName -> string, nome (descricao)
Ret: lRet -> logico, se .t. rename realizado, senão já existe um dw com este nome
--------------------------------------------------------------------------------------
*/
method RenameDW(acIntName, acName, acIcone) class TSigaDW
	
return ::InitDW(acIntName, acName, acIcone, .t.) > 0

/*
--------------------------------------------------------------------------------------
Ajusta a disponibilidade de um DW
Args: anID -> numerico, ID do DW a atualizar
      alDisp -> logico, indica se disponivel ou não
Ret: lRet -> logico, se .t. ajuste efetuado
--------------------------------------------------------------------------------------
*/
method DispDW(anID, alDisp) class TSigaDW
	local oDW := initTable(TAB_DW)
	local lRet := .f.
	
	if oDW:seek(1, { anID }) .and. ;
		   oDW:update({ { "disp", alDisp } })
		lRet := .t.
		::DWInfo(anID)[DW_DISP] := alDisp
	endif
			   		
return lRet

/*
--------------------------------------------------------------------------------------
Seleciona datawarehouse de trabalho
Args: acIntName -> string, nome interno OU
      anID -> numerico, ID do DW
Ret: lRet -> lógico, indica que o registro foi bem suescido
--------------------------------------------------------------------------------------
*/
method SelectDW(acIntName, anID) class TSigaDW
	local nPos 

	if valType(anID) == "N"
		if ::DWCurrID() != anID
			nPos := aScan(::DWList():Items(), { |x| x[DW_ID] == anID })
		else
			nPos := ::fnDWIndex
		endif
	else
		if !(lower(::DWCurr()[DW_NAME]) == lower(acIntName))
			nPos := aScan(::DWList():Items(), { |x| lower(x[DW_NAME]) == lower(acIntName) })
		else
			nPos := ::fnDWIndex
		endif
	endif
				
	if nPos != 0
		if valtype(::foCubes) != "U"
			::Cubes():Free()
		endif
    if valType(::foTableList) == "A"
			aEval(::foTableList, { |x| iif(valType(x) == "O", x:close(), nil) })
	  endif
    ::foTableList := {}
    ::foCubes := nil
		::fnDWIndex := nPos
		if valType(oUserDW) == "O"
			oUserDW:LastDW(::DWCurrID())
		endif
	endif

return (nPos != 0)

/*
--------------------------------------------------------------------------------------
Deleta datawarehouse selecionado
Args: anID -> numerico, ID do DW
Ret: lRet -> lógico, indica que o registro foi bem suescido
--------------------------------------------------------------------------------------
*/
method DeleteDW(anID) class TSigaDW
	local nPos 		:= 0
	local nTab 		:= 0	         
	local aTables	:= {}    
	local oTable
	local nIndex	:= 0

	if valType(anID) == "N"
		if (nPos := aScan(::DWList():Items(), { |x| x[DW_ID] == anID })) > 0
			oSigaDW:SelectDW(,anID)
			aTables := DWTableList()

			For nTab := 1 to len(aTables)		
				oTable := initTable(aTables[nTab])
				if aTables[nTab] == TAB_DW
					while oTable:Seek( 1, {anID} )
						oTable:Delete()                                                             
					enddo
				else    
					if oTable:HaveDWField()
						while oTable:Seek( 2, {} )
							oTable:Delete()                                                             
						enddo
					endif 
				endif             
				oTable := NIL   
			next nTab
			
			::DWList():RemoveItem(anID)
			HttpSession->DWList := ::DWList()
			::fnDWIndex := -1
			oUserDW:LastDW(-1)
			resetDW(, 1)
		endif
	endif	
	
return (nPos != 0)

/*
--------------------------------------------------------------------------------------
Grava um log de atividade
Arg: acMsg -> string, mensagem a ser logada
	  acP1..6 -> string, parametros complementares a mensagems
Ret:
--------------------------------------------------------------------------------------
*/
method Log(acMsg, acP1, acP2, acP3, acP4, acP5, acP6) class TSigaDW
	local cAlias                            
	local aAux := { acMsg, acP1, acP2, acP3, acP4, acP5, acP6 }
	aEval(aAux, { |x,i| iif(empty(x), aAux[i] := nil, nil) })
	acMsg := alltrim(DWConcatWSep("|.", aAux ))
	if !empty(acMsg)
		cAlias := select()
		acMsg	:= strTran(acMsg, "\", "/") + "|"
		::TableLog():Append( { { "mensagem", acMsg } })
		select(cAlias)
	endif
	
return

/*
--------------------------------------------------------------------------------------
Grava um arquivo de log de atividade, gerando um registro de ERRO com link.
Arg: acaMsg -> string, array, mensagem a ser logada
	 acTitle -> opcional, string, titulo para o log
	 acLogfile -> opcional, string, nome do arquivo de log
Ret: string, nome do arquivo de log
--------------------------------------------------------------------------------------
*/
method LogError(acaMsg, acTitle, acLogfile) class TSigaDW
	
	default acLogFile := DWErrorDir() + "\" + DWMakeName('ERR') + ".htm"
	
return ::LogFile(acaMsg, acTitle, acLogfile)

/*
--------------------------------------------------------------------------------------
Grava um arquivo de log de atividade, gerando um registro de LOG com link.
Arg: acaMsg -> string, array, mensagem a ser logada
	 acTitle -> opcional, string, titulo para o log
	 acType -> opcional, string, tipo de evento
	 acLogfile -> opcional, string, nome do arquivo de log
Ret: string, nome do arquivo de log
--------------------------------------------------------------------------------------
*/
method LogEvent(acaMsg, acTitle, acType, acLogfile) class TSigaDW
	Local cReturn := NIL
	
	default acType := DWMakeName("LOG")
	default acLogFile := DWLogsDir() + "\" + acType + ".htm"
	
	cReturn := ::LogFile(acaMsg, acTitle, acLogfile)
	
return cReturn

/*
--------------------------------------------------------------------------------------
Grava um arquivo de log de atividade, gerando um registro de link. Por default gera um
log de erro na pasta ERROR_DIR
Arg: acaMsg -> string, array, mensagem a ser logada
	 acTitle -> opcional, string, titulo para o log
	 acLogfile -> opcional, string, nome do arquivo de log
Ret: string, nome do arquivo de log
--------------------------------------------------------------------------------------
*/
method LogFile(acaMsg, acTitle, acLogfile) class TSigaDW
	local oFile
	
	default acTitle := STR0018 //###"Verificar archivo de log"
	default acLogfile := DWErrorDir() + "\" + DWMakeName('ERR') + ".htm"

	if valType(acaMsg) != "A"
		acaMsg := { acaMsg }
	endif
	
	oFile := TDWFileIO():New(acLogfile)
	if oFile:Exists()
		oFile:Append()
	else
		oFile:Create()
	    ::Log(acTitle + "<@>" + acLogfile)
		oFile:WriteLN(buildTitle(acTitle))
	endif
	aEval(acaMsg, { |x| oFile:WriteLN(dwStr(x)) })
	oFile:Close()
	
return acLogfile

/*
--------------------------------------------------------------------------------------
Verifica se o arquivo de configuração foi modificado
Arg:
Ret: lRet -> lógico, indica que foi modificado desde a sua última carga
--------------------------------------------------------------------------------------
*/
method Modified() class TSigaDW

return !(::CfgAttrib() == GetGlbValue("DWConfigAtz"))

/*
--------------------------------------------------------------------------------------
Efetua a carga do configurador
Arg:
Ret:
--------------------------------------------------------------------------------------
*/
method LoadCfg() class TSigaDW
	local aAux, bAux, cAux, Nind
	local oTabConfig := InitTable(TAB_CONFIG)
	
	bAux := { |x| strTran(strTran(DWStr(alltrim(x), .t.), '|', '"'), "$", "'") }
	
	if oTabConfig:Seek(2, { "config", "userurl" } )  
		::UserURL(val(oTabConfig:value("valor")))
	endif
	if oTabConfig:Seek(2, { "config", "notify1" } )
		::Notify()[1] := oTabConfig:value("valor")
	endif
	if oTabConfig:Seek(2, { "config", "notify2" } )
		::Notify()[2] := oTabConfig:value("valor")
	endif
	
	if oTabConfig:Seek(2, { "config", "logorder" } )
		::flLogOrder := oTabConfig:value("valor")=="T"
	endif
	if oTabConfig:Seek(2, { "view", "recLimit" } )
		cAux := oTabConfig:value("valor", .t.)
		if len(cAux) > 3
			::RecLimit(999)
			::SaveCfg()
		else
			::RecLimit(dwVal(cAux))
		endif
	endif
	if oTabConfig:Seek(2, { "view", "rowColor" } )
		::RowColor(oTabConfig:value("valor"))
	endif

	if oTabConfig:Seek(2, { "view", "showFilter" } )
		if oTabConfig:value("valor") == "T"
			::ShowFilter(OPTION_SHOWFILTER)
		elseif oTabConfig:value("valor") == "F"
			::ShowFilter(OPTION_SHOWNOTHING)
		else
			::ShowFilter(oTabConfig:value("valor"))
		endif
	endif
	if oTabConfig:Seek(2, { "view", "excel" } )
		::Excel(oTabConfig:value("valor"))
	endif 
	if oTabConfig:Seek(2, { "view", "blocked" } )
		::Blocked(dwVal(oTabConfig:value("valor")))
	endif
	if oTabConfig:Seek(2, { "view", "liberaEm" } )
		::LiberacaoPrevista(oTabConfig:value("valor"))
	endif
	if oTabConfig:Seek(2, { "view", "notifyUsers" } )
		::NotifyUsers(oTabConfig:value("valor") == "T")
	endif
	if oTabConfig:Seek(2, { "view", "usePanels" } )
		::UsePanels(oTabConfig:value("valor"))
	endif
	if oTabConfig:Seek(2, { "view", "shPageNav" } )
		::ShowPageNav(oTabConfig:value("valor"))
	endif
	if oTabConfig:Seek(2, { "view", "widthColDD" } )
		::WidthColDD(DwVal(oTabConfig:value("valor")))
	endif
	if oTabConfig:Seek(2, { "view", "notifyUsers" } )
		::NotifyUsers(oTabConfig:value("valor", .t.) == "T")
	endif
	if oTabConfig:Seek(2, { "view", "queryRefresh" } )
		::QueryRefresh(oTabConfig:value("valor", .t.))
	endif   
	
	//Carrega as definições de execução automárica de pesquisa.
	if oTabConfig:Seek(2, { "view", "autoQbe" } )
	::AutoQbe(oTabConfig:value("valor"))
	endif     

	if oTabConfig:Seek(2, { "opt", "showmsg" } )
		::ShowMsg(oTabConfig:value("valor", .t.) == "T")
	endif
	if oTabConfig:Seek(2, { "opt", "logact" } )
		::LogAct(oTabConfig:value("valor", .t.) == "T")
	endif
	if oTabConfig:Seek(2, { "opt", "logimpexp" } )
		::LogImpExp(oTabConfig:value("valor", .t.) == "T")
	endif
	if oTabConfig:Seek(2, { "opt", "expNotify" } )
		::ExpNotify(oTabConfig:value("valor", .t.) == "T")
	endif
	if oTabConfig:Seek(2, { "opt", "usrProtheus" } )
		::UsrProtheus(oTabConfig:value("valor", .t.) == "T")
	endif
	if oTabConfig:Seek(2, { "opt", "usrOnLine" } )
		::usrOnLine(oTabConfig:value("valor", .t.) == "T")
	endif
	if oTabConfig:Seek(2, { "opt", "dsnUsrSiga" } )
		::fnDsnUsrSiga := dwVal(oTabConfig:value("valor"))
	endif  
	
	if oTabConfig:Seek(2, { "opt", "showQbe" } )
		::showQbe(oTabConfig:value("valor", .t.) == "T")
	endif 
	
	if oTabConfig:Seek(2, { "opt", "showCubeUpdate" } )
		::showCubeUpdate(oTabConfig:value("valor", .t.) == "T")
	endif
	
	if oTabConfig:Seek(2, { "view", "TypeCon" } )
		::TypeCon(oTabConfig:value("valor", .t.) == "T")
	endif
	
	if oTabConfig:Seek(2, { "opt", "sortMeasure" } )
		::sortMeasure(oTabConfig:value("valor", .t.) == "T")
	endif

return

/*
--------------------------------------------------------------------------------------
Efetua a salva do configurador
Arg:
Ret: lRet -> logico, indica que salva foi bem suscedida
--------------------------------------------------------------------------------------
*/
static function saveParam(aoTabConfig, acGrupo, acChave, acValue)
	local lRet := .f.

	if aoTabConfig:Seek(2, { acGrupo, acChave } )
		lRet := aoTabConfig:Update( { { "valor", acValue } } )
	else
		lRet := aoTabConfig:Append( { { "grupo", acGrupo },;
							         { "nome" , acChave },;
							         { "valor", acValue } } )
	endif

return lRet

method SaveCfg() class TSigaDW
	local oTabConfig := InitTable(TAB_CONFIG)
	local lRet := .t.
	
	lRet := lRet .and. saveParam(oTabConfig, "config", "logorder", DWStr(::LogOrder()))
	lRet := lRet .and. saveParam(oTabConfig, "config", "notify1", ::faNotify[1])
	lRet := lRet .and. saveParam(oTabConfig, "config", "notify2", ::faNotify[2])
	lRet := lRet .and. saveParam(oTabConfig, "config", "userurl", DWStr(::UserURL()))
	lRet := lRet .and. saveParam(oTabConfig, "view", "recLimit", dwStr(::recLimit()))
	lRet := lRet .and. saveParam(oTabConfig, "view", "rowColor", ::rowColor())
	lRet := lRet .and. saveParam(oTabConfig, "view", "showFilter", ::ShowFilter())
	lRet := lRet .and. saveParam(oTabConfig, "view", "excel", ::Excel())
	lRet := lRet .and. saveParam(oTabConfig, "view", "blocked", dwStr(::Blocked()))
	lRet := lRet .and. saveParam(oTabConfig, "view", "usePanels", ::UsePanels())
	lRet := lRet .and. saveParam(oTabConfig, "view", "shPageNav", ::showPageNav())
	lRet := lRet .and. saveParam(oTabConfig, "view", "widthColDD", DwStr(::WidthColDD()))
	lRet := lRet .and. saveParam(oTabConfig, "view", "liberaEm", ::LiberacaoPrevista())
	lRet := lRet .and. saveParam(oTabConfig, "view", "notifyUsers", iif(::NotifyUsers(), "T", "F"))
	lRet := lRet .and. saveParam(oTabConfig, "view", "queryRefresh", DwStr(::QueryRefresh()))
	lRet := lRet .and. saveParam(oTabConfig, "view", "autoQbe", ::AutoQbe())

	lRet := lRet .and. saveParam(oTabConfig, "opt", "showmsg", iif(::ShowMsg(), "T", "F"))
	lRet := lRet .and. saveParam(oTabConfig, "opt", "logact", iif(::LogAct(), "T", "F"))
	lRet := lRet .and. saveParam(oTabConfig, "opt", "logimpexp", iif(::LogImpExp(), "T", "F"))
	lRet := lRet .and. saveParam(oTabConfig, "opt", "expNotify", iif(::ExpNotify(), "T", "F"))
	lRet := lRet .and. saveParam(oTabConfig, "opt", "usrProtheus", iif(::UsrProtheus(), "T", "F"))
	lRet := lRet .and. saveParam(oTabConfig, "opt", "usrOnLine", iif(::UsrOnLine(), "T", "F"))
	lRet := lRet .and. saveParam(oTabConfig, "opt", "dsnUsrSiga", dwStr(::fnDsnUsrSiga))
	lRet := lRet .and. saveParam(oTabConfig, "opt", "showQbe", iif(::showQbe(), "T", "F"))
	lRet := lRet .and. saveParam(oTabConfig, "opt", "showCubeUpdate", iif(::showCubeUpdate(), "T", "F"))
	lRet := lRet .and. saveParam(oTabConfig, "view", "TypeCon", iif(::TypeCon(), "T", "F")) 
	lRet := lRet .and. saveParam(oTabConfig, "opt", "sortMeasure", iif(::sortMeasure(), "T", "F"))
	if lRet
		::CfgAttrib(.t.)
		DWLog(STR0001) //"Configuração foi salva"
	else
		DWLog(STR0002) //"Erro na salva da Configuração. Restaurando os valores"
		::LoadCfg()
	endif

return lRet

/*
--------------------------------------------------------------------------------------
Método responsável por finalizar o objeto sigadw
Arg:
Ret:
--------------------------------------------------------------------------------------
*/
method Finalize() class TSigaDW
	
	// salva o último Menu/Aba aonde o usuário estava
	if valType(oUserDW) == "O"
		oUserDW:LastAba(HttpSession->CurrentAba)
		oUserDW:FolderMenu(HttpSession->FolderMenu)
	endif
	
return

/*
--------------------------------------------------------------------------------------
Atualia a data/hora do configurador
Args: alValue -> logico, força atualização
Ret: acValue -> string, data/hora da atualização
--------------------------------------------------------------------------------------
*/
method CfgAttrib(alValue) class TSigaDW

	if valType(alValue) == "L" .and. alValue
		PutGlbValue("DWConfigAtz", dtos(date()) + " " + DWint2hex(seconds(), 4))
	endif

return getGlbValue("DWConfigAtz")

/*
--------------------------------------------------------------------------------------
Adiciona um tabela a lista de tabelas abertas
Args: aoDataset -> objeto, dataset a ser adicionado
--------------------------------------------------------------------------------------
*/
method AddTable(aoDataset) class TSigaDW

	if aoDataset:ClassName() == "TTABLE"
		if ascan(::foTableList, { |x| valType(x) != "U" .and. x == aoDataset } ) == 0
			nPos := ascan(::foTableList, { |x| valType(x) == "U" } )
			if nPos == 0
				aAdd(::foTableList, aoDataset)
			else
				::foTableList[nPos] := aoDataset
			endif
		endif
	endif
	
return

/*
--------------------------------------------------------------------------------------
Remove uma tabela da lista de tabelas abertas
Args: aoDataset -> objeto, dataset a ser adicionado
--------------------------------------------------------------------------------------
*/
method RemoveTable(aoDataset) class TSigaDW
	local nPos := ascan(::foTableList, { |x| x == aoDataset } )
	
	if nPos <> 0             
		aoDataset:Close()
		aDel(::foTableList, nPos)
	endif

return

/*
--------------------------------------------------------------------------------------
Busca o dataset de uma tabela especifica
Args: acTablename -> string, nome da tabela desejada
Ret: aoDataset -> objeto, dataset localizado
--------------------------------------------------------------------------------------
*/
method SearchTable(acTablename) class TSigaDW
	local nInd, oRet, cAux := upper(acTablename)
	
	for nInd := 1 to len(::foTableList)
		if valType(::foTableList[nInd]) != "U"
			if upper(::foTableList[nInd]:Tablename()) == cAux
				oRet := ::foTableList[nInd]
				exit
			endif
		endif
	next

return oRet

/*
--------------------------------------------------------------------------------------
Fecha os datasets abertos
Args: 
Ret: 
--------------------------------------------------------------------------------------
*/
method ReleaseTable() class TSigaDW
	local nInd

	for nInd := 1 to len(::foTableList)
		if valType(::foTableList[nInd]) != "U"
			::RemoveTable(::foTableList[nInd])
		endif
	next                             
	::foTableList := packArray(::foTableList)

return

/*
--------------------------------------------------------------------------------------
Tabela de dimensão (TAB_DIMENSAO - DW06000)
Args:
Ret: oRet -> objeto, tabela TAB_DIMENSAO
--------------------------------------------------------------------------------------
*/
method Dimensao() class TSigaDW

return InitTable(TAB_DIMENSAO)

/*
--------------------------------------------------------------------------------------
Tabela de campos da dimensão (TAB_DIM_FIELDS - DW06100)
Args:
Ret: oRet -> objeto, tabela TAB_DIM_FIELDS
--------------------------------------------------------------------------------------
*/
method DimFields() class TSigaDW

return InitTable(TAB_DIM_FIELDS)

/*
--------------------------------------------------------------------------------------
Inicializa a definição da dimensão 
Args: anCubeID -> numérico, ID do cubo
		anDimNumber -> numérico, número da dimensão 
Ret: lRet -> lógico, indica que esta Ok
--------------------------------------------------------------------------------------
*/
method DefDimension(anCubeID, anDimNumber) class TSigaDW
	local lRet := .T., oDimensao := ::Dimensao()
	
	if !oDimensao:Seek(2, {anCubeID, anDimNumber} )
		lRet := oDimensao:Append({;
							 { "ID_CUBES", anCubeID } , ;
							 { "dimensao", anDimNumber } , ;
							 { "nome", "Dim" + DWStr(anDimNumber) } , ;
							 { "descricao", STR0003 + DWStr(anDimNumber) } ; //"Dimensão "
						  } )
	endif

return lRet

/*
--------------------------------------------------------------------------------------
Inicializa os campos chaves da dimensão
Args: anDimID -> numérico, ID da dimensão
		aaKeyList -> array, lista de campos que compoem a chave
Ret: lRet -> lógico, indica que esta Ok
--------------------------------------------------------------------------------------
*/
method DefDimFields(anDimID, aaKeyList) class TSigaDW
	local lRet := .T., oDimFields := ::DimFields(), nInd

	for nInd := 1 to len(aaKeyList)
		if !oDimFields:Seek(2, { anDimID, aaKeyList[nInd, 1] })
			lRet := oDimFields:Append( { ;
										{ "ID_DIM", anDimID } , ;
										{ "nome"      , aaKeyList[nInd, 1] } , ;
				   					{ "descricao" , aaKeyList[nInd, 2] } , ;
										{ "tipo"      , aaKeyList[nInd, 3] } , ;
										{ "tam"       , aaKeyList[nInd, 4] } , ;
										{ "ndec"      , aaKeyList[nInd, 5] } ;
									} )	
			if !lRet
				exit
			endif
		endif
	next
	
return lRet

/*
--------------------------------------------------------------------------------------
Propriedade RecLimit
--------------------------------------------------------------------------------------
*/
method RecLimit(anValue) class TSigaDW
	
	property ::fnRecLimit := anValue

return ::fnRecLimit

/*
--------------------------------------------------------------------------------------
Propriedade WidthColDD - tamanho da coluna de DrillDowns
--------------------------------------------------------------------------------------
*/
method WidthColDD(anValue) class TSigaDW
	
	property ::fnWidthColDD := anValue
	
return ::fnWidthColDD

/*
--------------------------------------------------------------------------------------
Propriedade ShowFilter
--------------------------------------------------------------------------------------
*/
method ShowFilter(acValue) class TSigaDW
           
	property ::fcShowFilter := acValue

return ::fcShowFilter
  
/*
--------------------------------------------------------------------------------------
Propriedade AutoQbe
--------------------------------------------------------------------------------------
*/
method AutoQbe(acValue) class TSigaDW
           
	property ::fcAutoQbe := acValue

return ::fcAutoQbe 

/*
--------------------------------------------------------------------------------------
Propriedade Excel
--------------------------------------------------------------------------------------
*/
method Excel(acValue) class TSigaDW
           
	property ::fcExcel := acValue

return ::fcExcel

/*
--------------------------------------------------------------------------------------
Propriedade Blocked
--------------------------------------------------------------------------------------
*/
method Blocked(anValue) class TSigaDW
                  
	property ::fnBlocked := anValue

return ::fnBlocked

/*
--------------------------------------------------------------------------------------
Propriedade LiberacaoPrevista
--------------------------------------------------------------------------------------
*/
method LiberacaoPrevista(acValue) class TSigaDW
                  
	property ::fcLiberacaoPrevista := acValue

return ::fcLiberacaoPrevista

/*
--------------------------------------------------------------------------------------
Propriedade NotifyUsers
--------------------------------------------------------------------------------------
*/
method NotifyUsers(alValue) class TSigaDW
                  
	property ::flNotifyUsers := alValue

return ::flNotifyUsers

/*
--------------------------------------------------------------------------------------
Propriedade RowColor
--------------------------------------------------------------------------------------
*/
method RowColor(acValue) class TSigaDW
                  
	property ::fcRowColor := acValue

return ::fcRowColor

/*
--------------------------------------------------------------------------------------
Propriedade AutoRefresh
--------------------------------------------------------------------------------------
*/
method AutoRefresh(anValue) class TSigaDW
                  
	property ::fnAutoRefresh := anValue

return ::fnAutoRefresh

/*
--------------------------------------------------------------------------------------
Propriedade Connections
--------------------------------------------------------------------------------------
*/
method Connections() class TSigaDW

return InitTable(TAB_CONEXAO)

/*
--------------------------------------------------------------------------------------
Verifica a existencia fisica de um cubo
Args: anCubeID -> integer, ID do cubo
Ret: lRet -> logico, indica que o cubo existe fisicamente
--------------------------------------------------------------------------------------
*/
method VerifyCube(anCubeID) class TSigaDW
	local oTable
	
	oTable := TTable():New(DWCubeName(anCubeID))

return oTable:Exists()

/*
--------------------------------------------------------------------------------------
Abre um cubo
Args: anCubeID -> integer, ID do cubo
Ret: oRet -> objeto, retorna um objeto cubo
--------------------------------------------------------------------------------------
*/
method OpenCube(anCubeID, alInit, alForProcess) class TSigaDW
	
return ::OpenCubeRaise(anCubeID, alInit, alForProcess, .t.) 

method OpenCubeRaise(anCubeID, alInit, alForProcess, alRaise) class TSigaDW
	local oRet := ::DefCube(anCubeID)
	local oCubes := ::Cubes():CubeList()     
	local nInd, aDims
	
	default alInit := .f.
	default alForProcess := .f.
	default alRaise := .t.

	if oCubes:Seek(1, { anCubeID })
		if alInit
			oCubes:update({ {"dt_process", ctod("  /  /  ")}, {"hr_process",""} })
		endif
	else
		::Log(STR0019 + " ["+DWStr(anCubeID)+ "]")
	endif
	
	if createTable(oRet:Fact())
		::Log(STR0059 + dwFormat(" \[[@X]\] ([@X]) ", {oRet:Fact():Descricao(), oRet:Fact():Tablename() }) + STR0060)  //"Tabela fato"  //"inicializada"
	else
		oRet:Fact():IndexOff()
		oRet:Fact():Open()
		if oRet:Fact():ChkStruct(.t.)
			::Log(STR0006 + oRet:Fact():Tablename(), oRet:Fact():Msg()) //"Modificando tabela fato "
			oRet:Fact():ChkStruct(, { |x| ::Log(x), .t. } )
		elseif alInit
			oRet:Fact():Reindex()
		endif
		oRet:Fact():Close()
		oRet:Fact():IndexOn()
	endif		

	aDims := oRet:Dimension()
	for nInd := 1 to len(aDims)
		if aDims[nInd]:Tablename() != ::Calend():Tablename()
			if !aDims[nInd]:Exists()
				::Log(STR0007 + aDims[nInd]:Tablename(), aDims[nInd]:Msg()) //"Inicializando tabela dimensão "
				createTable(aDims[nInd])
			else
				aDims[nInd]:Open()
				if aDims[nInd]:ChkStruct(.t.)
					::Log(STR0008 + aDims[nInd]:Tablename()) //"Modificando dimensao "
					aDims[nInd]:ChkStruct(, { |x| ::Log(x), .t. } )
				endif
				aDims[nInd]:Close()
			endif
		endif
	next                

	if alForProcess
		oRet:Fact():Open()                                                        
		for nInd := 1 to len(aDims)
			aDims[nInd]:Open()
		next
	endif   

	if alInit
		oCubes:Seek(1, { anCubeID })
		oCubes:update({ {"dt_process", date()}, {"hr_process",time()} })		
		::Log(STR0009 +oCubes:value('nome')+ STR0010) //"Cubo ["###"] liberado"
	endif
	
return oRet

/*
--------------------------------------------------------------------------------------
Fecha um cubo
Args: anCubeID -> integer|object, ID do cubo ou o cubo
--------------------------------------------------------------------------------------
*/
method CloseCube(anCube) class TSigaDW
	local oRet := iif(valType(anCube)=="N", ::DefCube(anCube), anCube)
	local aTables, nInd
	
	aTables := aclone(oRet:Dimension())
	aAdd(aTables, oRet:Fact())
	for nInd := 1 to len(aTables)
		while !aTables[nInd]:Close()
			sleep(500)
		enddo
	next		
	
return 

/*
--------------------------------------------------------------------------------------
Inicializa a definição do cubo
Args: anCubeID -> integer, ID do cubo
aoCube -> objeto, definições e acesso ao cubo
Ret: oRet -> objeto, retorna um objeto dataset
--------------------------------------------------------------------------------------
*/
method DefCube(anCubeID) class TSigaDW
	local oRet, oTable, oAux
	local oCubes := ::Cubes():CubeList()
	local oFactFields, oDim, oDimFields, oDimCubes
	local aSum, aInd, aIndFld, aDimFields := {}
	local oFactVirtual
	oCubes:Seek(1, { anCubeID })
	
	oFactFields := InitTable(TAB_FACTFIELDS)
	oDim := ::Dimensao()
	oDimFields := ::DimFields()
	oDimCubes := InitQuery(SEL_DIM_CUBES)
	oDimCubes:params(1, anCubeID)
		
	oRet := TCube():New(anCubeID)
	oTable := TTable():New(DWCubename(anCubeID))
	oRet:Fact(oTable)
	
	oTable:AddFieldID()
	
	oDimCubes:Open()
	
	while !oDimCubes:eof()
		aAdd(aDimFields, DWKeyDimname(oDimCubes:value("id_dim")))
		oTable:AddField(nil, aDimFields[len(aDimFields)], "N")
		oDim:Seek(1, { oDimCubes:value("id_dim") })
		oDimFields:Seek( 4, { oDimCubes:value("id_dim") })
		aIndFld := {}
		while !oDimFields:eof() .and. oDimFields:value("id_dim") == oDimCubes:value("id_dim")
			if oDimFields:value("keyseq") != 0
				while len(aIndFld) < oDimFields:value("keyseq")
					aAdd(aIndFld, nil)
				enddo
				aIndFld[oDimFields:value("keyseq")] := oDimFields:value("nome")
			endif
			oDimFields:_Next()
		enddo							
                            
		oAux := ::OpenDim(oDimCubes:value("id_dim"))
		oRet:AddDimension(oAux, oDim:value("nome"), aIndFld, oDim:value("id"))
		::CloseDim(oAux)
		oDimCubes:_Next()
	enddo
	oDimCubes:Close()
	
	// Indices para melhorar desempenho fato
	aEval(aDimFields, { |x| oTable:AddIndex2(nil, {x}) })

	// Indicadores	
	if oFactFields:Seek( iIf( oSigaDw:sortMeasure() /*Em ordem alfabética?*/, 6, 3) , { anCubeID } )
		aIndFld := {}
		while !oFactFields:Eof() .and. oFactFields:value("ID_CUBES") == anCubeID
			// Verifica se a dimensão é válida para apresentar na análise de fragmentação.
			if oFactFields:value("dimensao") == 0 .or. oDim:Seek(1, {oFactFields:value("dimensao")})
				aAdd(oRet:Fields(), { oFactFields:value("nome"), oFactFields:value("tipo"), oFactFields:value("tam"), oFactFields:value("ndec"), oFactFields:value("classe"), oFactFields:value("dimensao"), oFactFields:value("id") } )
				if oFactFields:value("classe") != "D"
					aAdd(aIndFld, { oFactFields:value("id"), ;
									 oFactFields:value("nome"), ;
									 oFactFields:value("tam"), ;
									 oFactFields:value("ndec"), ;
									 oFactFields:value("descricao"), ;
									 oFactFields:value("mascara"), ;
									 oFactFields:value("tipo"),;
									 ,; //reservado para posterior uso
									 oFactFields:value("visible")} )
						cbAux := NIL
					
					oTable:AddField(nil, oFactFields:value("nome"), "N", oFactFields:value("tam") + 2, oFactFields:value("ndec"), cbAux)
					oTable:SetAttField(oFactFields:value("nome"), oFactFields:value("descricao"), oFactFields:value("mascara"), nil, oFactFields:value("id"))
				endif
			EndIf
			oFactFields:_Next()
		enddo
		oRet:SetIndicadores(aIndFld)
	endif

	// indicadores virtuais
	oFactVirtual := InitTable(TAB_FACTVIRTUAL)
	if oFactVirtual:Seek(iIf( oSigaDw:sortMeasure() /*Em ordem alfabética?*/, 4, 2), { anCubeID } )
		aIndFld := {}
		while !oFactVirtual:Eof() .and. oFactVirtual:value("ID_CUBES") == anCubeID
			aAdd(aIndFld, { oFactVirtual:value("id"), ;
							oFactVirtual:value("nome"), ;
							oFactVirtual:value("tam"), ;
							oFactVirtual:value("ndec"), ;
							oFactVirtual:value("descricao"), ;
							oFactVirtual:value("mascara"), ;
							"N"} )
			oFactVirtual:_Next()
		enddo
		oRet:SetIndVirtuais(aIndFld)
	endif		

return oRet


/*
--------------------------------------------------------------------------------------
Abre uma dimensão
Args: anDimID -> integer, ID da dimensão
Ret: oRet -> objeto, retorna um objeto dimensão
--------------------------------------------------------------------------------------
*/
method OpenDim(anDimID, alInit) class TSigaDW
	local oRet := ::DefDim(anDimID)
	local oDim := ::Dimensao()
	
	default alInit := .f.
		
	if alInit
		if oDim:Seek(1, { anDimID })
			oDim:update({ {"dt_process", ctod("  /  /  ")}, {"hr_process",""} })
		endif
	endif

	if createTable(oRet)
		::Log(STR0003 + dwFormat(" \[[@X]\] ([@X]) ", {oRet:Descricao(), oRet:Tablename() }) + STR0060, oRet:Msg())  //"Dimensão "  //"inicializada"
		oRet:Open()
	else     
    oRet:indexOff()
		oRet:Open()
		if oRet:ChkStruct(.t.)
			oRet:ChkStruct(.f.)
		elseif alInit
			oRet:Reindex()
		endif          
		oRet:indexOn()
	endif
  oRet:refresh()
	if !oRet:Seek(1, { 0 }) // valida a existencia de registro vazio
		oRet:Append({ { "id", 0 } })
	endif

	if alInit
		if oDim:Seek(1, { anDimID })
			oDim:update({ {"dt_process", date()}, {"hr_process",time()} })		
			::Log(STR0003 + dwFormat(" [@!] ", {oDim:value('nome')}) + STR0061)  //"Dimensão "  //"pronta para uso"
		endif
	endif
	
return oRet

/*
--------------------------------------------------------------------------------------
Fecha uma dimensão
Args: anDimID|aoDim -> integer, ID da dimensão ou o objeto
Ret: oRet -> objeto, retorna um objeto dimensão
--------------------------------------------------------------------------------------
*/
method CloseDim(anDimID, alInit) class TSigaDW
	local oRet := iif(valtype(anDimID) =="O", anDimID, ::DefDim(anDimID))

	oRet:Close()
	
return 

/*
--------------------------------------------------------------------------------------
Inicializa a definição da dimensao
Args: anDimID -> integer, ID da dimensão
Ret: oRet -> objeto, retorna um objeto dataset
--------------------------------------------------------------------------------------
*/
method DefDim(anDimID) class TSigaDW
	local oDim, oDimFields, oTable, oTabCal
   local aKeys := {}, nPos, nInd
	local cCpoData 
		
	oDim := ::Dimensao()
	oDimFields := ::DimFields()
	
	if oDim:Seek(1, { anDimID })
		oTable := TTable():New(DWDimname(anDimID), oDim:value("nome"))
		oTable:Descricao(oDim:value("descricao"))
		
		oTable:AddFieldID()

		oDimFields:Seek(2, { anDimID })
		while !oDimFields:eof() .and. oDimFields:value("id_dim") == anDimID
			if oDimFields:value("keyseq") <> 0
				aAdd(aKeys, { oDimFields:value("keyseq"), oDimFields:value("nome") })
			endif
			oTable:AddField(nil, oDimFields:value("nome"), oDimFields:value("tipo"), ;
										 oDimFields:value("tam"), oDimFields:value("ndec"))
			oTable:SetAttField(oDimFields:value("nome"), oDimFields:value("descricao"), ;
									oDimFields:value("mascara"), nil, oDimFields:value("id") )
			oDimFields:_Next()
		enddo
		      
		aKeys := aSort(aKeys,,, { |x,y| x[1] < y[1]})
		aEval(aKeys, { |x,i| aKeys[i] := alltrim(x[2]) })
		
		oTable:AddIndex2(nil, { "ID" })
		if len(aKeys) <> 0
			oTable:AddIndex2(nil, aKeys)
		endif
	endif

return oTable

/*
--------------------------------------------------------------------------------------
Remove uma dimensão
Args: anDimID -> integer, ID da dimensão
Ret: lRet -> logico, processo conluído com/sem sucesso
--------------------------------------------------------------------------------------
*/
method DropDim(anDimID) class TSigaDW
	local oTable		:= Nil 
	local oDim 			:= ::Dimensao() 
	local oDimFields 	:= ::DimFields()
	local oDS 			:= InitTable(TAB_DSN)
	local oDimCubes 	:= InitTable(TAB_DIM_CUBES)

	if !oDim:Seek(1, { anDimID })
      return .f.
 	endif
 	
	::Log(STR0012 + " [ " + dwStr(anDimID) + "-" + oDim:value("nome",.t.) + " ]")
	
	// Eliminar ligação com cubos
	If (oDimCubes:Seek(3, { anDimID}))
		DWDelAllRec(oDimCubes:Tablename(), "ID_DIM = " + cBIStr(anDimID))
	EndIf 

	// Eliminar campos dimensão       
	if oDimFields:Seek(2 , { anDimID })
		DWDelAllRec(oDimFields:Tablename(), "ID_DIM = " + dwStr(oDim:Value("id")))
	endif

	// Eliminar fonte de dados
	while oDS:Seek(2 , { "D", anDimID })
		::dropDS(oDS:value("id"))
	enddo
	
	oTable := TTable():New(DWDimName(anDimID),oDim:value("nome",.t.) )
	if oTable:Exists()
		oTable:DropTable()
	endif
	::Log(STR0003+ " [ " + dwStr(anDimID) + "-" + oDim:value("nome",.t.) + " ] " + STR0020)
	oDim:Delete()          
	oDim:_Next()
		
return .t.

/*
--------------------------------------------------------------------------------------
Remove uma fonte de dados
Args: anDSID -> integer, ID da fonte de dados
Ret: lRet -> logico, processo conluído com/sem sucesso
--------------------------------------------------------------------------------------
*/
method DropDS(anDSID) class TSigaDW
	local oDSN := InitTable(TAB_DSN)
	local oDSConf := InitTable(TAB_DSNCONF)

	if !oDSN:Seek(1, { anDSID })
      return .f.
 	endif
 	
	::Log(STR0021 + " [ " + dwStr(anDSID) + "-" + oDSN:value("nome",.t.) + " ]")
	
	// Eliminar configurações
	if oDSConf:Seek(2 , { anDSID })	
		DWDelAllRec(oDSConf:Tablename(), "ID_DSN = " + dwStr(anDSID))
	endif

	::Log(STR0022 + " [ " + dwStr(anDSID) + "-" + oDSN:value("nome",.t.) + " ] " + STR0020)
	oDSN:Delete()          
	oDSN:_Next()
		
return .t.

/*
--------------------------------------------------------------------------------------
Remove uma conexao
Args: anConectorID -> integer, ID da conexao
Ret: lRet -> logico, processo conluído com/sem sucesso
--------------------------------------------------------------------------------------
*/
method DropConexao(anConexaoID) class TSigaDW
	local oConexao := ::Connections()

	if !oConexao:Seek(1, { anConexaoID })
      return .f.
 	endif
 	
	::Log(STR0023 + " [ " + dwStr(anConexaoID) + "-" + oConexao:value("nome",.t.) + " ]")
	::Log(STR0024 + " [ " + dwStr(anConexaoID) + "-" + oConexao:value("nome",.t.) + " ] " + STR0020)
	oConexao:Delete()
	oConexao:_Next()
		
return .t.

/*
--------------------------------------------------------------------------------------
Remove um cubo
Args: anCubeID -> integer, ID do cubo a ser eliminado
Ret: lRet -> logico, processo concluído com/sem sucesso
--------------------------------------------------------------------------------------
*/
method DropCube(anCubeID) class TSigaDW
	local oTable, oCubes := ::Cubes():CubeList()
   	local oConsulta := InitTable(TAB_CONSULTAS), oFactFields := InitTable(TAB_FACTFIELDS)
	local oDimCubes := InitTable(TAB_DIM_CUBES)
	
	if !oCubes:Seek(1, { anCubeID })
		return .f.
	endif
	
	::Log(STR0025 + " [ " + dwStr(anCubeID) + "-" + oCubes:value("nome",.t.) + " ]")

	// Eliminar consultas
	while oConsulta:Seek(9, { anCubeID } )
		::dropCons(oConsulta:value("id"))
	enddo
	
	// Eliminar cubo x dim
	if oDimCubes:Seek(2, { anCubeID })
		DWDelAllRec(oDimCubes:Tablename(), "ID_CUBE = " + dwStr(anCubeID))
	endif

	// Eliminar cubo                 
	if oFactFields:Seek(2, { anCubeID })
		::Log(STR0011 + " [ " + dwStr(anCubeID) + "-" + oCubes:value("nome",.t.) + " ]")
		DWDelAllRec(oFactFields:Tablename(), "ID_CUBES = " + dwStr(anCubeID))
	endif
	
	oTable := TTable():New(DWCubeName(oCubes:value("id")), oCubes:value("nome",.t.) )
	if oTable:Exists()
		oTable:DropTable()
	endif
	::Log(STR0026 + " [ " + dwStr(anCubeID) + "-" + oCubes:value("nome",.t.) + " ] " + STR0027)
	oCubes:Delete()
	oCubes:_Next()
		
return .t.

/*
--------------------------------------------------------------------------------------
Remove uma consulta
Args: anConsID -> integer, ID da consulta a eliminada
Ret: lRet -> logico, processo concluído com/sem sucesso
--------------------------------------------------------------------------------------
*/
method DropCons(anConsID) class TSigaDW
	local oConsulta := InitTable(TAB_CONSULTAS)
	local oConsType := InitTable(TAB_CONSTYPE), oConsInd := InitTable(TAB_CONS_IND)
	local oConsDim   := InitTable(TAB_CONS_DIM), oConsWhe   := InitTable(TAB_CONS_WHE)
	local oWhereCond := InitTable(TAB_WHERE_COND), oConsAlert := InitTable(TAB_CONS_ALM)
	local oConsProp  := InitTable(TAB_CONS_PROP)
	
	if !oConsulta:Seek(1, { anConsID })
		return .f.
	endif
	
	::Log(STR0028 + " [ " + dwStr(anConsID) + "-" + oConsulta:value("nome",.t.) + " ]")

	if oConsAlert:Seek(2, { oConsType:value("id") } )
		DWDelAllRec(oConsAlert:Tablename(), "ID_CONS = " + dwStr(oConsulta:value("id")))
	endif

	while oConsType:Seek(2, { anConsID })
		if oConsInd:Seek(2, { oConsType:value("id") } )
			DWDelAllRec(oConsInd:Tablename(), "ID_CONS = " + dwStr(oConsType:value("id")))
		endif
		
		if oConsDim:Seek(2, { oConsType:value("id") } )
			DWDelAllRec(oConsDim:Tablename(), "ID_CONS = " + dwStr(oConsType:value("id")))
		endif

		if oConsWhe:Seek(2, { oConsType:value("id") } )
			while !oConsWhe:eof() .and. oConsWhe:value("id_cons") == oConsType:value("id")
				if oWhereCond:Seek(2, { oConsWhe:value("id") })
					DWDelAllRec(oWhereCond:Tablename(), "ID_WHERE = " + dwStr(oConsWhe:value("id")))
				endif
				oConsWhe:delete()			
				oConsWhe:_Next()
			enddo
		endif

		if oConsProp:Seek(2, { oConsType:value("id") } )
			DWDelAllRec(oConsProp:Tablename(), "ID_CONS = " + dwStr(oConsType:value("id")))
		endif   

		oConsType:Delete()
		oConsType:_Next()
	enddo

	::Log(STR0029 + " [ " + dwStr(anConsID) + "-" + oConsulta:value("nome",.t.) + " ] " + STR0020)  //"Consulta"
	oConsulta:Delete()
	oConsulta:_Next()
		
return .t.

/*
--------------------------------------------------------------------------------------
Indica quem deve ser notificado em caso de erros no sigadw
Ret: array, com 2 elementos. Onde o 1o. é o nome amigavel e o 2o. o endereço de e-mail
--------------------------------------------------------------------------------------
*/
method Notify(aaValue) class TSigaDW
      
	property ::faNotify := aaValue

return ::faNotify

/*
--------------------------------------------------------------------------------------
Propriedade isSched
--------------------------------------------------------------------------------------
*/
method isSched(alValue) class TSigaDW

	property ::flSched := alValue
	
return ::flSched

/*
--------------------------------------------------------------------------------------
Propriedade LogReq
--------------------------------------------------------------------------------------
*/
method LogReq() class TSigaDW

return DWLogReq()

/*
--------------------------------------------------------------------------------------
Propriedade LogOrder
--------------------------------------------------------------------------------------
*/
method LogOrder(alValue) class TSigaDW
    
    if valType(alValue) == "L"
		property ::flLogOrder := alValue
		::SaveCfg()
	endif
	
return ::flLogOrder

/*
--------------------------------------------------------------------------------------
Propriedade WFObj
--------------------------------------------------------------------------------------
*/
method WFObj() class TSigaDW

	if valType(::foWFObj) == "U"
		::foWFObj := twfobj( { DWEmpresa(), DWFilial() } )
	endif
	
return ::foWFObj

/*
--------------------------------------------------------------------------------------
Propriedade JarFile
--------------------------------------------------------------------------------------
*/
method JarFile() class TSigaDW
               
return URLFile("sigadw3.jar")

/*
--------------------------------------------------------------------------------------
Propriedade UsePanels
--------------------------------------------------------------------------------------
*/
method UsePanels(acValue) class TSigaDW
	
	property ::fcUsePanels := acValue
	
return ::fcUsePanels

/*
--------------------------------------------------------------------------------------
Propriedade showPageNav
--------------------------------------------------------------------------------------
*/
method showPageNav(acValue) class TSigaDW
	
	property ::fcShowPageNav := acValue
	
return ::fcShowPageNav

/*
--------------------------------------------------------------------------------------
Propriedade ShowFilter
--------------------------------------------------------------------------------------
*/
method UserURL(anValue) class TSigaDW
           
	property ::fnUserURL := anValue

return ::fnUserURL

/*
--------------------------------------------------------------------------------------
Propriedade showMsg
--------------------------------------------------------------------------------------
*/
method ShowMsg(alValue) class TSigaDW
                  
	property ::flShowMsg := alValue

return ::flShowMsg

/*
--------------------------------------------------------------------------------------
Propriedade LogAct
--------------------------------------------------------------------------------------
*/
method LogAct(alValue) class TSigaDW
                  
	property ::flLogAct := alValue

return ::flLogAct

/*
--------------------------------------------------------------------------------------
Propriedade LogImpExp
--------------------------------------------------------------------------------------
*/
method LogImpExp(alValue) class TSigaDW
                  
	property ::flLogImpExp := alValue

return ::flLogImpExp

/*
--------------------------------------------------------------------------------------
Propriedade EnablePaging
--------------------------------------------------------------------------------------
*/
method EnablePaging(alValue) class TSigaDW
                  
	property ::flEnablePaging := alValue

return ::flEnablePaging

/*
--------------------------------------------------------------------------------------
Propriedade ExpNotify
--------------------------------------------------------------------------------------
*/
method ExpNotify(alValue) class TSigaDW
                  
	property ::flExpNotify := alValue

return ::flExpNotify

/*
--------------------------------------------------------------------------------------
Propriedade UsrProtheus
--------------------------------------------------------------------------------------
*/
method UsrProtheus(alValue) class TSigaDW

	property ::flUsrProtheus := alValue

return ::flUsrProtheus

/*
--------------------------------------------------------------------------------------
Propriedade UsrOnLine
--------------------------------------------------------------------------------------
*/
method UsrOnLine(alValue) class TSigaDW

	property ::flUsrOnLine := alValue

return ::flUsrOnLine

/*
--------------------------------------------------------------------------------------
Propriedade DsnUsrSiga()
--------------------------------------------------------------------------------------
*/
method DsnUsrSiga() class TSigaDW
	local oDSN := initTable(TAB_DSN)

	if ::fnDsnUsrSiga == 0
		if oDSN:Seek(2, { "U", 0 } , .t.)
			::fnDsnUsrSiga := oDSN:value("id")
		else
			oDSN:append({ { "tipo", "U" }, { "id_table", 0}, {"id_connect", 0}, { "nome", "ImpUsers" }, { "descricao", STR0072 /*"Importação Usuário Protheus"*/}})
		endif
		::fnDsnUsrSiga := oDSN:value("id")
		::saveCfg()
	endif

return ::fnDsnUsrSiga

/*
--------------------------------------------------------------------------------------
Propriedade UsrConnector
--------------------------------------------------------------------------------------
*/
method UsrConnector(anValue) class TSigaDW
	local nIDDSN := ::DsnUsrSiga()
	local oDSN := initTable(TAB_DSN)

  if oDSN:Seek(1, { nIDDSN } )
    if valType(anValue) == "N"
			oDSN:update({ {"id_connect", anValue} })
		endif	
  else
	  dwRaise(ERR_005, SOL_002, STR0073 /*"Fonte de dados para 'Importação de Usuários' não foi localizada"*/)
	endif

return oDSN:value("id_connect")

/*
--------------------------------------------------------------------------------------
Propriedade BuildDW
--------------------------------------------------------------------------------------
*/
method BuildDW() class TSigaDW
	local oQuery

	if valType(::fcBuildDW) == "U"
		oQuery := initTable(SEL_BUILD)
		oQuery:open()

		if !oQuery:EoF()
			::fcBuildDW := oQuery:value("version") + "." + oQuery:value("release") + "." + oQuery:value("build")
		else
		  if tcCanOpen(TAB_CONFIG)
        ::fcBuildDW := "070330"
			else
        ::fcBuildDW := BUILD
			endif  
		endIf
		
 		oQuery:close()
  	endif
 
return ::fcBuildDW

/*
--------------------------------------------------------------------------------------
Atualiza a updBuildDW
--------------------------------------------------------------------------------------
*/
method updBuildDW() class TSigaDW
	local oTab := initTable(TAB_BUILD)

	::fcBuildDW := DWLastBuild()
	oTab:append({ { "version", VERSION } , ;
                  { "release", RELEASE } , ;
                  { "build", BUILD } , ;
                  { "environ", BUILD_ADVPL } , ;
                  { "applied", date() } } )
	oTab:close()
 
return 
 
return ::fcBuildDW

/*
--------------------------------------------------------------------------------------
Propriedade BuildWeb
--------------------------------------------------------------------------------------
*/
method BuildWeb() class TSigaDW

return BUILD_WEB

method registerHelp() class TSigaDW
      ::faHelps := {}
	if dwisWebEx()
           	// Helps chamados por abas           	
           	aAdd(::faHelps, { "definitions_dimensions"	, "dimensoes.htm" 	} )
			aAdd(::faHelps, { "definitions_cubes"		, "cubos.htm" 		} )
			aAdd(::faHelps, { "querys_predef"			, "consultas.htm" 	} )
			aAdd(::faHelps, { "querys_users"			, "consultas.htm" 	} )
			aAdd(::faHelps, { "apoio_conexao_all" 		, "conexoes.htm"	} )
			aAdd(::faHelps, { "apoio_conexao_top" 		, "conexoes.htm"	} )
			aAdd(::faHelps, { "apoio_conexao_sx" 		, "conexoes.htm"	} )
			aAdd(::faHelps, { "users_groups"			, "grupos.htm"		} )
			aAdd(::faHelps, { "users_users"				, "usuarios.htm"	} )
			aAdd(::faHelps, { "users_priv"				, "privilegios.htm"	} )
			aAdd(::faHelps, { "main_config"				, "tela_de_configuracao" } )
			
			// Helps chamados por actions
			aAdd(::faHelps, { "queryAlert"				, "alertas.htm" 	} )  
			aAdd(::faHelps, { "queryVirtFlds"			, "virtuais.htm" 	} )  
			aAdd(::faHelps, { "queryAndCubFilter"		, "filtro.htm" 		} )  
			
      endif
    
return
/*
--------------------------------------------------------------------------------------
Registra a lista de ações 
--------------------------------------------------------------------------------------
*/
method registerActions() class TSigaDW

	::faActionList := {}

	if DWisWebEx()
		aAdd(::faActionList, { AC_HELP          , ""                , "h_dwHelp()"          , "", STR0062 })  //"Ajuda sobre DW"
		aAdd(::faActionList, { AC_FORGET_PW     , ""                , "h_dwHelp()"          , "", STR0063 })  //"Gera nova senha de usuário"
		aAdd(::faActionList, { AC_SEND_PW       , ""                , "h_dwHelp()"          , "", STR0064 })  //"Envia nova senha ao usuário"
		aAdd(::faActionList, { AC_TEST_MAIL     , ""                , "h_dwHelp()"          , "", STR0171 })  //"Envia mensagem de validação de e-mail"
		aAdd(::faActionList, { AC_START_DW      , "verSite(), resetDW(,0)", ;
		                                                              "h_dwOpenDW()"        , "", STR0065 })  //"Inicializa DW"
		aAdd(::faActionList, { AC_LOGOUT        , ""    			 , "h_dwOpenDW()"      	, "finalizeDW()", STR0066 })   //"Sair"
		aAdd(::faActionList, { AC_LOGIN         , "h_dwValidLogin()", "h_dwSelectDW()"      , "", STR0067 })  //"Entrar"
		aAdd(::faActionList, { AC_CHANGEDW      , "resetDW(,1)"     , "h_dwSelectDW()"      , "", STR0068 })  //"Seleciona DW"
		aAdd(::faActionList, { AC_SELECT_DW     , "setDW()"         , "h_dwBuildAba()"      , "h_dwVerifyMessages()", STR0068 })  //"Seleciona DW"
		aAdd(::faActionList, { AC_SETUP_DW      , ""                , "h_dwSetupDW()"       , "", STR0069 })  //"Permite configurar a disponibilidade de datawarehouse"
		aAdd(::faActionList, { AC_NEW_DW        , ""                , "h_dwNewDW()"         , "", STR0070 })  //"Inicializa novo DW"
		aAdd(::faActionList, { AC_DELETE_DW     , ""         		, "h_dwSetupDW()"       , "", STR0071 })  //"Exclui DW"
		aAdd(::faActionList, { AC_SELECT_ABA    , "setAba()"        , "h_dwBuildAba()"      , "", STR0072 })  //"Seleciona opção aba/menu"
		aAdd(::faActionList, { AC_PROC_ABA      , ""                , "h_dwProcAba()"       , "", "" })
		aAdd(::faActionList, { AC_REC_NEW       , ""                , "h_dwProcAba()"       , "", STR0073 })  //"Adiciona novo objeto"
		aAdd(::faActionList, { AC_REC_MANUT     , ""                , "h_dwProcAba()"       , "", STR0074 })  //"Manutenção de objeto"
		aAdd(::faActionList, { AC_CHANGE_MENU   , "changeMenu()"    , "h_dwBuildAba()", "", STR0075 })  //"Troca visão de menu (aba/árvore)"
		aAdd(::faActionList, { AC_BROWSER       , ""                , "h_dwBuildAba()"      , "", STR0076 })  //"Navegação simples"
		aAdd(::faActionList, { AC_DIM_ATT       , ""                , "h_dwDimAtt()"        , "", STR0077 })  //"Manutenção de dimensão"
		aAdd(::faActionList, { AC_DIM_DS        , ""                , "h_dwDimDS()"         , "", STR0078 })  //"Manutenção de fonte de dados (dimensão)"
		aAdd(::faActionList, { AC_DIM_KEY       , ""                , "h_dwDimKey()"        , "", STR0079 })  //"Manutenção de chave única (dimensão)"
	  	aAdd(::faActionList, { AC_ATT_REC_MANUT , ""                , "h_dwDimAtt()"        , "", STR0080 })  //"Manutenção de atributos (dimensão)"
  		aAdd(::faActionList, { AC_KEY_REC_MANUT , ""                , "h_dwDimKey()"        , "", STR0079 })  //"Manutenção de chave única (dimensão)"
	  	aAdd(::faActionList, { AC_CUB_IND       , ""                , "h_dwCubInd()"        , "", STR0081 })  //"Manutenção de tabela fato"
  		aAdd(::faActionList, { AC_DIM_CUB_RECMAN, ""                , "h_dwCubDim()"        , "", STR0082 })  //"Associação da fato com dimensões"
	  	aAdd(::faActionList, { AC_DSN_CUB_RECMAN, ""                , "h_dwCubDS()"         , "", STR0083 })  //"Manutenção de fonte de dados (fato)"
  		aAdd(::faActionList, { AC_IMPORT_STRUC  , ""                , "h_dwImpStruc()"      , "", STR0084 })  //"Importação de estrutura"
//  	aAdd(::faActionList, { AC_TOOLS_META    , "addCSSLib('stx.css'), addJSLib('iecanvas.js'), addJSLib('starschema.js')";
	  	aAdd(::faActionList, { AC_TOOLS_META    , "addCSSLib('stx.css'), addJSLib('excanvas.js',.t.), addJSLib('starschema.js')";
	  	                                                            , "h_dwToolMeta()"      , "", STR0085 })  //"Geração/exportação de meta-dados"
	  	aAdd(::faActionList, { AC_TOOLS_IMPORT	, ""                , "h_dwBuildAba()"	    , "", STR0086 })  //"Importação de meta-dados"
	  	aAdd(::faActionList, { AC_DOWNLOAD      , ""                , "h_dwDownload()"      , "", STR0087 })  //"Download de arquivos"
	  	aAdd(::faActionList, { AC_TOOLS_CLEAN   , ""                , "h_dwBuildAba()"      , "", STR0088 })  //"Limpeza do DW"
	  	aAdd(::faActionList, { AC_IND_REC_MANUT , ""                , "h_dwCubInd()"        , "", STR0089 })  //"Manutenção de indicadores (fato)"
	  	aAdd(::faActionList, { AC_DSN_DIM_MANUT , ""                , "h_dwDSN()"           , "", STR0078 })  //"Manutenção de fonte de dados (dimensão)"
	  	aAdd(::faActionList, { AC_DSN_DIM_PARAM , ""                , "h_dwDSN()"           , "", STR0090 })  //"Manutenção de parâmetros da fonte de dados (dimensão)"
	  	aAdd(::faActionList, { AC_DSN_DIM_EVENT , ""                , "h_dwDSN()"           , "", STR0091 })  //"Manutenção de eventos da fonte de dados (dimensão)"
	  	aAdd(::faActionList, { AC_DSN_DIM_ROTEIRO, ""               , "h_dwDSN()"           , "", STR0092 })  //"Manutenção de roteiro da fonte de dados (dimensão)"
	  	aAdd(::faActionList, { AC_CUB_DSN_RECMAN, ""                , "h_dwDSN()"           , "", STR0083 })  //"Manutenção de fonte de dados (fato)"
	  	aAdd(::faActionList, { AC_DSN           , ""                , "h_dwDSN()"           , "", STR0093 })  //"Manutenção de fonte de dados"
	  	aAdd(::faActionList, { AC_DSN_IMPORT    , ""                , "h_dwAcompJob()"      , "", STR0094 })  //"Importação de dados, via fonte de dados"
	  	aAdd(::faActionList, { AC_DSN_SCHED     , ""                , "h_dwSched()"         , "", STR0095 })  //"Agendamento de importações"
	  	aAdd(::faActionList, { AC_EDT_SCHED     , ""                , "h_dwSched()"         , "", STR0096 })  //"Manutebção de agendamentos"
	  	aAdd(::faActionList, { AC_QUERY_SCHED	, ""				, "h_dwQrySched()"		, "", STR0097 })  //"Agendamento de Exportações de consultas"
	  	aAdd(::faActionList, { AC_EDTQRY_SCHED	, ""				, "h_dwEdtQrySched()"	, "", STR0098 })  //"Manutenção de agendamento de exportações de consultas"
	  	aAdd(::faActionList, { AC_VERIFY_MESSAGE, ""                , "h_dwVerifyMessages()", "", STR0099 })  //"Verificação de avisos"
	  	aAdd(::faActionList, { AC_EDT_EXPRESSION, ""                , "h_dwEdtExpr()"       , "", STR0100 })  //"Manutenção de expressão"
	  	aAdd(::faActionList, { AC_QUERY_DEFCUBE	, ""                , "h_dwQryCub()"        , "", STR0101 })  //"Manutenção de consultas"
	  	aAdd(::faActionList, { AC_QUERY_ALERT   , ""                ,"h_dwQryAlert()"      , "", STR0102 })  //"Manutenção de alertas"
	  	aAdd(::faActionList, { AC_REC_ALERT     , "addJSLib('alertsample.js')";
	                                                                , "h_dwQryAlert()"      , "", "" })
	  	aAdd(::faActionList, { AC_QUERY_VIRTFLD	, ""                , "h_dwQryVirtFld()"    , "", STR0103 })  //"Manutenção de campos virtuais"
	  	aAdd(::faActionList, { AC_QUERY_EXEC   	, "addCSSLib('pivot.css'),addJSLib('jspivot.js')";
	                                                                , "h_dwQryExec()"       , "", STR0104 })  //"Executa a consulta"
	  	aAdd(::faActionList, { AC_QRY_ONLINE_EXEC, "addCSSLib('pivot.css'),addJSLib('jspivot.js')";
	                                                              	, "h_dwQryOnlineExec()" , "", STR0105 })  //"Consulta Online: definição e executa na mesma ação"
	  	aAdd(::faActionList, { AC_QUERY_CFG_EXP	, ""                , "h_dwQryxport()"      , "", STR0106 })  //"Parâmetros de exportação de consultas"
	  	aAdd(::faActionList, { AC_BUILD_QUERY   , ""                , "h_dwAcompJob()"      , "", STR0107 })  //"Executa o processo de sumarização"
	  	aAdd(::faActionList, { AC_EXPORT_QUERY  , ""                , "h_dwAcompJob()"      , "", STR0108 })  //"Executa o processo de exportação"
	  	aAdd(::faActionList, { AC_REC_VIRTFLD	  , ""               , "h_dwQryVirtFld()"    , "", "" })
	  	aAdd(::faActionList, { AC_QRY_CUB_FILTER, ""                , "h_dwQryFilter()"     , "", STR0109 }) //"Manutenção de filtros"
	  	aAdd(::faActionList, { AC_REC_FILTER	  , ""              , "h_dwQryFilter()"     , "", "" })
	  	aAdd(::faActionList, { AC_QUERY_DECLFLTR, ""                , "h_dwQryDeclar()"     , "", STR0110 })  //"Manutenção de filtros (declarações)"
	  	aAdd(::faActionList, { AC_RESTORE_ALL	  , ""              , "h_dwQryDeclar()"     , "", STR0111 })  //"Resturando todos os dados de filtros"
	  	aAdd(::faActionList, { AC_QRY_FLTR_VALUE, ""                , "h_dwQryFltrValue()"  , "", STR0112 })  //"Definição de valores obrigatórios padrão"
	  	//aAdd(::faActionList, { AC_SAVE_FLTR_DECL, ""              , "h_dwQryDeclar()"		  , "", "Salvando manutenção de filtros no formato QBE" })
	  	aAdd(::faActionList, { AC_CLEAN_FLTR_DEC, ""                , "h_dwQryDeclar()"		  , "", STR0113 })  //"Limpando manutenção de filtros"
	  	aAdd(::faActionList, { AC_QRY_DECL_EXPR , ""                , "h_dwQryExpr()"       , "", STR0114 })  //"Manutenção de filtros (expressão)"
	  	aAdd(::faActionList, { AC_REC_EXPR      , ""                , "h_dwQryExpr()"		    , "", STR0115 })  //"Salvando manutenção de filtros no formato Expressão"
	  	aAdd(::faActionList, { AC_QRY_DESC_FLTR	, ""                , "h_dwQryDescFltr()"	  , "", "" })
	  	aAdd(::faActionList, { AC_QRY_DESC_FIELD, ""                , "h_dwQryDescFltr()"	  , "", "" })
	  	aAdd(::faActionList, { AC_PROCESS_VIEW  , ""                , "h_dwAcompJob()"      , "", STR0116 })  //"Acompanhamento de processos"
	  	aAdd(::faActionList, { AC_VIEW_LOG      , ""                , "h_dwViewLog()"       , "", STR0117 })  //"Visualização de log gerado em arquivo"
	  	aAdd(::faActionList, { AC_QUERY_DATA    , ""                , "h_dwViewData()"      , "", STR0118 })  //"Filtro de dados"
	  	aAdd(::faActionList, { AC_SHOW_DATA     , ""                , "h_dwViewData()"      , "", STR0119 })  //"Visualização de dados"
	  	aAdd(::faActionList, { AC_FILTER_DATA   , ""                , "h_dwViewData()"      , "", STR0120 })  //"Filtro de dados"
	  	aAdd(::faActionList, { AC_SELECT_DATA   , ""                , "h_dwViewData()"      , "", STR0121 })  //"Salvando pesquisa de dados na sessão"
	  	aAdd(::faActionList, { AC_QUERY_DEF     , ""                , "h_dwQryDef()"        , "", STR0122 })  //"Manutenção de consultas (propriedades)"
	  	aAdd(::faActionList, { AC_QUERY_DEF_STR	, ""                , "h_dwQryDStr()"       , "", STR0123 })  //"Manutenção de consultas (estrutura)"
	  	aAdd(::faActionList, { AC_QUERY_DEF_FIL , ""                , "h_dwQryDFil()"       , "", STR0124 })  //"Manutenção de consultas (seleção de filtros)"
	  	aAdd(::faActionList, { AC_QUERY_DEF_ALM , ""                , "h_dwQryDAlm()"       , "", STR0125 })  //"Manutenção de consultas (seleção de alarmes)"
	    aAdd(::faActionList, { AC_QUERY_DEF_RNK , ""                , "h_dwQryDRnk()"       , "", STR0126 })  //"Manutenção de consultas (ranking)"
	  	aAdd(::faActionList, { AC_QUERY_DEF_OPT , ""                , "h_dwQryDOpt()"       , "", STR0127 })  //"Manutenção de consultas (propriedades)"
	  	aAdd(::faActionList, { AC_SAVE_DW       , "finalizeDW()"    , "h_dwSave()"          , "", STR0128 })  //"Salvando configurações ao sair do DW"
	  	aAdd(::faActionList, { AC_SHOW_PRIVILEGE, ""                , "h_dwAcessPrivileges()"      , "", STR0129 })  //"Definindo privilégios para usuários"
	  	aAdd(::faActionList, { AC_SAVE_PRIVILEGE, ""                , "h_dwAcessPrivileges()"      , "", STR0130 })  //"Salvando privilégios para usuários"
	  	aAdd(::faActionList, { AC_RESET_PRIVILEGE,""                , "h_dwBuildAba()"      , "", STR0131 }) //"Resetando privilégios para usuários"
	  	aAdd(::faActionList, { AC_USER_PRIVILEGE, ""                , "h_dwAcessPrivileges()", "", STR0132 })  //"Definindo privilégios para usuários"
	  	aAdd(::faActionList, { AC_USER_IMPORT   , ""                , "h_dwAcompJob()"      , "", STR0133 }) //"Importação de usuário do SigaDW"
	  	aAdd(::faActionList, { AC_IMP_USR_SCHED , ""                , "h_dwSched()"         , "", STR0134 })  //"Agendamento de importações (usuários Protheus)"
	  	aAdd(::faActionList, { AC_VERIFY_CONECT , ""                , "h_dwApoioServer()"   , "", STR0135 })  //"Verificando conexão com um servidor TopConect"
	  	aAdd(::faActionList, { AC_ANALISAR_FRAG , ""                , "h_dwDataAnal()"      , "", STR0136 })  //"Analise de fragmentação de dados"
	  	aAdd(::faActionList, { AC_EXPORT_DATA   , ""                , "h_dwQryxport()"      , "", STR0137 })  //"Exportação de dados"
	  	aAdd(::faActionList, { AC_QUERY_GRAPH   , ""                , "h_dwQryGraph()"      , "", STR0138 })  //"Executa o grafico"
	  	aAdd(::faActionList, { AC_MARK_DATA     , ""                , "h_dwSelData()"       , "", STR0139 })  //"Executa o grafico"
	  	aAdd(::faActionList, { AC_QRY_CRW       , ""                , "h_dwQryCRW()"        , "", STR0140 })  //"Integracao Crystal"
	  	aAdd(::faActionList, { AC_USER_DESKTOP	, ""                , "h_dwDesktop()"       , "", STR0141 })  //"Salvando desktop do usuário"
	  	aAdd(::faActionList, { AC_UPLOAD_FILE   , ""                , "h_dwUplFile()"       , "", STR0142 })  //"Envia um arquivo ao servidor (upload)"
	  	aAdd(::faActionList, { AC_INTEGRATION_EXCEL, ""             , "h_dwExcel()"         , "", STR0143 })  //"Integracao Excel"
	  	aAdd(::faActionList, { AC_DW_USER		    , ""	        , "h_dwUsers()"         , "", STR0144})  //"Cadastro de usuario"
	  	aAdd(::faActionList, { AC_ALTER_DUPLI_FIELD, ""	            , "h_dwDimAtt()"	      , "", STR0145})  //"Cadastro de Campos"
	  	aAdd(::faActionList, { AC_DOCUMENTATION , "addCSSLib('stx.css')";
	  	                                                            , "h_dwEdtExpr()"      , "", STR0146 })  //"Edição de documentação" 
//  	aAdd(::faActionList, { AC_SHOW_SCHEMA   , "addCSSLib('stx.css'), addJSLib('iecanvas.js'), addJSLib('starSchema.js')";
	  	aAdd(::faActionList, { AC_SHOW_SCHEMA   , "addCSSLib('stx.css'), addJSLib('excanvas.js', .t.), addJSLib('starschema.js')";
	  	                                                            , "h_dwToolMeta()"     , "", STR0147 })  //"Apresenta esquema gráfico"
	  	aAdd(::faActionList, { AC_SYNC_EMPFIL   , ""                , "h_dwAcompJob()"      , "", STR0148 })  //"Sincronização de Empresas/Filiais e dicionários de dados"
		aAdd(::faActionList, { AC_INFORMATION   , ""                , "h_dwInformation()"      , "", STR0175 })  //"Informações"
    
	
	
	  	// as ações abaixo possuem tratamento especifico em SigaDWConnect()
	  	aAdd(::faActionList, { AC_EXEC_DOWNLOAD , "", "", "", "" })		
	  	aAdd(::faActionList, { AC_EXEC_UPLOAD , "", "", "", "" })		
	  	aAdd(::faActionList, { AC_VERIFY_PROCESS, "", "", "", "" })
	  	aAdd(::faActionList, { AC_VERIFY_PROCESS_LIST,"", "", "", "" })
	  	aAdd(::faActionList, { AC_ONLINE_NOTIFY,"", "", "", "" })
	  	aAdd(::faActionList, { AC_WS_REQUEST         , "", "", "", "" })
	  	aAdd(::faActionList, { AC_OPEN_URL   		 , "addJSLib('sigadw3.js')", "", "", "" })
	endif
return
	
/*
--------------------------------------------------------------------------------------
Valida uma ação
--------------------------------------------------------------------------------------
*/
method validAction(acAction) class TSigaDW
	local nPos := ascan(::faActionList, { |x| x[1]==acAction})
	
	if nPos <> 0 .and. ::LogAct()
		::logUsrAction(nPos)
	endif
	
return nPos <> 0

/*
--------------------------------------------------------------------------------------
Log um ação por usuário
--------------------------------------------------------------------------------------
*/
method logUsrAction(anActionPos) class TSigaDW
	local oTab := initTable(TAB_ACTIONS)
	local cCompl := "", lRet := .f.
    local nUserID := 0

	if valtype(oUserDW) == "O"
		nUserID := oUserDW:UserID()//iif(HttpSession->isLogged, oUserDW:UserID(), 0)
	endif
// layout de aaAction
// { 1actionCode, 2beforeAction, 3executeAction, 4afterAction, 5descricao })		
//####TODO montar o complemento da ação
	if !empty(::faActionList[anActionPos, 5])
		lRet := oTab:append({ { "dt", date() }, ;
					 { "hr", time() }, ;
					 { "id_user" , nUserID }, ;
					 { "id_action", anActionPos }, ;
					 { "compl", cCompl } } )
	endif

return lRet           

/*
--------------------------------------------------------------------------------------
Recupera a definição de uma ação com base no seu ID
--------------------------------------------------------------------------------------
*/
method getAction(anActionPos) class TSigaDW

return ::faActionList[anActionPos]
               
/*
--------------------------------------------------------------------------------------
Recupera a descrição de uma ação
--------------------------------------------------------------------------------------
*/
method getActDesc(acAction) class TSigaDW

return ::getAction(ascan(::faActionList, { |x| x[1]==acAction}))[5]

/*
--------------------------------------------------------------------------------------
Executa uma ação
--------------------------------------------------------------------------------------
*/
method execAction(acAction, anMoment, aBuffer) class TSigaDW
	local nActionID := ascan(::faActionList, { |x| x[1]==acAction})
	local cAction, xResult := nil
		       
	if !empty(::faActionList[nActionID, anMoment])
		cAction := ::faActionList[nActionID, anMoment]
		if anMoment == EXEC_ACTION .and. !("H_DWBUILDABA()" == upper(cAction) .or. "H_DWQRYGRAPH()" == upper(cAction)) ;
				 .AND. !(upper(isNull(HttpGet->origem, "")) == "JAVA")
			::buildBeginBody(aBuffer)
   	endif
		
		xResult := &(cAction)
		if valType(xResult) == "C" .and. (HttpGet->origem == "JAVA" .OR. len(xResult)>2)
			aAdd(aBuffer, xResult)
		endif 

		if anMoment == EXEC_ACTION .and. !("H_DWBUILDABA()" == upper(cAction) .or. "H_DWQRYGRAPH()" == upper(cAction)) ;
				.AND. !(upper(isNull(HttpGet->origem, "")) == "JAVA")
			::buildEndBody(aBuffer)
	    endif
	endif
	
return

/*
--------------------------------------------------------------------------------------
Propriedade DWList  
Parâmetros:
	lForceUpdate (Lógico) Define se deve ser realizada uma atualização forçada. 
------------------------------------------------------------------------------------
*/
method DWList(lForceUpdate) class TSigaDW
	local oDW
	
	Default lForceUpdate := .F.

	if ( valType(::foDWList) == "U" .or. (lForceUpdate) )
		oDW := initTable(TAB_DW)
		::foDWList := TDWList():New()
		oDW:seek(2)
		oDW:goTop()
		while !oDW:eof()
			::foDWList:AddItem(oDW:value("id"), oDW:value("nome"), oDW:value("descricao"), oDW:value("icone"), oDW:value("disp"), oDW:value("criado"))
			oDW:_next()
		enddo  
		oDW:close()
	endif
	
return ::foDWList

/*
--------------------------------------------------------------------------------------
Propriedade DWCurrID
--------------------------------------------------------------------------------------
*/
method DWCurrID() class TSigaDW
	
return iif(::fnDWIndex == -1 .OR. ::fnDWIndex > len(::DWList():Items()) , -1, ::DWList():Items()[::fnDWIndex, DW_ID] )

/*
--------------------------------------------------------------------------------------
Propriedade DWCurr
--------------------------------------------------------------------------------------
*/
method DWCurr() class TSigaDW

return ::DWInfo(::DWCurrID()) 

/*
--------------------------------------------------------------------------------------
Retorna informações sobre um DW especifico
--------------------------------------------------------------------------------------
*/
method DWInfo(anID) class TSigaDW
	local nPos := aScan(::DWList():Items(), { |x| x[DW_ID] == anID })
	
return iif(nPos==0, STRUCT_DW_VAZIO, ::DWList():Items()[nPos])

/*
--------------------------------------------------------------------------------------
Indica se existe ou não a dimensão reservada EmpFil
Arg:
Ret: lRet -> logico, Indica se existe (.T.) ou não (.F.) a dimensão reservada EmpFil
--------------------------------------------------------------------------------------
*/
method HaveDimEmpFil() class TSigaDW
	local oDim := ::Dimensao(), lRet
	
	oDim:savePos()
	lRet := oDim:seek(2, { DIM_EMPFIL })
	oDim:restPos()	
	
return lRet

/*
--------------------------------------------------------------------------------------
Propriedade Calend
Arg:
Ret: oRet -> objeto, retorna o objeto Calend
--------------------------------------------------------------------------------------
*/
method Calend() class TSigaDW

return ::foCalend

/*
--------------------------------------------------------------------------------------
Propriedade QueryRefresh
Arg: anValue -> numérico, retorna o tempo de refresh da página de consultas
Ret: nRet -> numérico, retorna o tempo de refresh da página de consultas
--------------------------------------------------------------------------------------
*/
method QueryRefresh(anValue) class TSigaDW

	property ::fnQueryRefresh := anValue

return ::fnQueryRefresh

method buildCabec(aBuffer) class TSigaDW
	local nInd       
	
	DWSendHeader()
	
	if isNull(HttpGet->Action, "") == AC_QUERY_EXEC .AND. DwVal(oSigaDW:QueryRefresh()) > 0
		aAdd(aBuffer, '<meta http-equiv="refresh" content="' + DwStr(DwVal(oSigaDW:QueryRefresh()) * 60) + '">')
	endif
	
	aAdd(aBuffer, "<!-- aph/apl: " + ::faActionList[ascan(::faActionList, { |x| x[1]==HttpGet->action}), EXEC_ACTION] +"-->" )
	aAdd(aBuffer, "<style type='text/css'>")     
	if (httpGet->Action != "startdw" .and. httpGet->Action != "logout")   
	aAdd(aBuffer, "@import url("+urlCSS("base.css")+");")
	aAdd(aBuffer, "@import url("+urlCSS(::theme()+".css")+");")
	aAdd(aBuffer, "@import url("+urlCSS()+");")
    EndIf 
	if !isNull(HttpSession->CSSLib)
  		for nInd := 1 to len(HttpSession->CSSLib)
			aAdd(aBuffer, "@import url("+urlCSS(HttpSession->CSSLib[nInd])+");")
		next
	endif
	aAdd(aBuffer, "</style>")
	
	if !isNull(HttpSession->JSLib)
		for nInd := 1 to len(HttpSession->JSLib)
			aAdd(aBuffer, tagJSLib(HttpSession->JSLib[nInd]))
		next
	endif
	
	aAdd(aBuffer, tagJS())
 	aAdd(aBuffer, "function getEditExpressionURL()")
 	aAdd(aBuffer, "{")                                                   
 	aAdd(aBuffer, "  return " + makeAction(AC_EDT_EXPRESSION, { { "obj", "" },{ "objID", "" }, { "options", "0001"}, { "isSQL", CHKBOX_OFF }, { "chg", CHKBOX_OFF }, { "caption", "" }, { "id_expr", -1}, { "id_base", -1 } , { "targetID", ""}, { "targetText", ""} }))
 	aAdd(aBuffer, "}")
 	aAdd(aBuffer, "function getImageList()")
	aAdd(aBuffer, "{")
	aAdd(aBuffer, "  var oImageList = Array();")
	aAdd(aBuffer, "  oImageList.push("+urlImage("ic_list_on.gif")+");")
	aAdd(aBuffer, "  oImageList.push("+urlImage("ic_mini_on.gif")+");")
	aAdd(aBuffer, "  oImageList.push("+urlImage("ic_toolbar_normal_on.gif")+");")
	aAdd(aBuffer, "  oImageList.push("+urlImage("ic_toolbar_label_on.gif")+");")
	aAdd(aBuffer, "  return oImageList;")
	aAdd(aBuffer, "}")
	aAdd(aBuffer, "</script>")
	aAdd(aBuffer, "</head>")

 	if isNull(HttpGet->iframe)
#ifdef VER_P11 	         
		//--------------------------------------------------------------------------
		// Se a origem da página for 'Consulta' a classe do CSS utilizada é a P11.
		//--------------------------------------------------------------------------
		If 	HttpGet->Action == AC_QRY_ONLINE_EXEC .Or.;
			HttpGet->Action == AC_QUERY_EXEC .Or.;
			HttpGet->Action == AC_QUERY_DEF .Or.;
			HttpGet->Action == AC_DSN_DIM_ROTEIRO
		
			aAdd(aBuffer, "<body " + iif(isNull("_w", CHKBOX_OFF)==CHKBOX_ON, "", " class='P11' ") + ;
		                         iif(!(HttpGet->Action == AC_QRY_ONLINE_EXEC) .and. !(HttpGet->Action == AC_QUERY_EXEC) .and. !(HttpGet->Action == AC_QUERY_DEF) .and. !(HttpGet->Action == AC_DSN_DIM_ROTEIRO), "", "") + " onload='body_load(false, true);' onUnload='body_unload(" + makeAction(AC_SAVE_DW, { { "headers", CHKBOX_OFF }, { "XEvent", CHKBOX_OFF } }) + ");'>")
		Else
			aAdd(aBuffer, "<body " + iif(isNull("_w", CHKBOX_OFF)==CHKBOX_ON, "", " class='background' ") + ;
		                         iif(!(HttpGet->Action == AC_QRY_ONLINE_EXEC) .and. !(HttpGet->Action == AC_QUERY_EXEC) .and. !(HttpGet->Action == AC_QUERY_DEF) .and. !(HttpGet->Action == AC_DSN_DIM_ROTEIRO), "", "") + " onload='body_load(false, true);' onUnload='body_unload(" + makeAction(AC_SAVE_DW, { { "headers", CHKBOX_OFF }, { "XEvent", CHKBOX_OFF } }) + ");'>")
		EndIf
#else
		aAdd(aBuffer, "<body " + iif(!(HttpGet->Action == AC_QRY_ONLINE_EXEC) .and. !(HttpGet->Action == AC_QUERY_EXEC) .and. !(HttpGet->Action == AC_QUERY_DEF) .and. !(HttpGet->Action == AC_DSN_DIM_ROTEIRO), "onResize='body_resize();'", "") + " onload='body_load();' onUnload='body_unload(" + makeAction(AC_SAVE_DW, { { "headers", CHKBOX_OFF }, { "XEvent", CHKBOX_OFF } }) + ");'>")
#endif
	else
		aAdd(aBuffer, "<body class='body_iframe' onload='body_load();' onUnload='body_unload(" + makeAction(AC_SAVE_DW, { { "headers", CHKBOX_OFF }, { "XEvent", CHKBOX_OFF } }) + ");'>")
	endif

/*
	aAdd(aBuffer, "<!-- frmModalForm begin -->")
	aAdd(aBuffer, "<div id='frmModalForm'>")
	aAdd(aBuffer, "  <div id='divModalForm'>")
	aAdd(aBuffer, "    <div id='divModalFormTitle'></div>")
	aAdd(aBuffer, "    <div id='divModalFormBody'></div>")
	aAdd(aBuffer, "    <div id='divModalFormMsg'></div>")
	aAdd(aBuffer, "    <div id='divModalFormButton'></div>")
	aAdd(aBuffer, "  </div>")
	aAdd(aBuffer, "</div>")
	aAdd(aBuffer, "<!-- frmModalForm end -->")
	aAdd(aBuffer, "<!-- waitInProcess begin -->")
	aAdd(aBuffer, "<div id='waitInProcess'>")
	aAdd(aBuffer, "  <div id='waitInProcessMsg'>Aguarde...</div>")
	aAdd(aBuffer, "</div>")
	aAdd(aBuffer, "<!-- waitInProcess end -->")
*/

return

//####TODO - documentar headers de métodos
method ShowHeader(acAction) class TSigaDW
	local aActions := { AC_LOGIN, AC_SELECT_DW, AC_SELECT_ABA, AC_TOOLS_CLEAN, AC_TOOLS_IMPORT, ;
                      AC_CHANGE_MENU, AC_NEW_DW, AC_CHANGEDW, AC_FORGET_PW, AC_SEND_PW }

return ascan(aActions, { |x| x == acAction}) <> 0

method ShowFooter(acAction) class TSigaDW
	local aActions := { AC_LOGIN, AC_SELECT_DW, AC_SELECT_ABA, AC_CHANGE_MENU }

return ascan(aActions, { |x| x == acAction}) <> 0

method buildHeader(aBuffer) class TSigaDW
	local lMiniHeader := isNull(HttpSession->miniHeader, CHKBOX_OFF) == CHKBOX_ON
	local cimg
	
	If __LANGUAGE == "SPANISH"
		cimg := "logo_cliente_esp.gif"
	Else
		If __LANGUAGE == "ENGLISH"
			cimg := "logo_cliente_en.gif"
		Else
			cimg := "logo_cliente.gif"
		Endif
	Endif
	
	if !DWisFlex()
		
		::buildCabec(aBuffer)
		
		if ::UsrOnline()
			aAdd(aBuffer, '<!-- online notify begin -->')
			aAdd(aBuffer, '<div id="onLineNotify" class="auxHiddenObjects"></div>')
			aAdd(aBuffer, '<!-- online notify end -->')
		endif
		
		aAdd(aBuffer, tagJS())
		aAdd(aBuffer, "function alterCadastro()")
		aAdd(aBuffer, "{")
		aAdd(aBuffer, "  doLoad('?action=alterCadastro&amp;id=" +dwstr(iif(valType(oUserDW) == "O",oUserDW:UserID(), 0))+"&amp;oper=3','_window',null,'winManu0CCBB',0.5,0.5,null,null,false);")
		aAdd(aBuffer, "}")
		aAdd(aBuffer, "</script>")
		
		aAdd(aBuffer, '<!-- buildHeader begin -->')
		aAdd(aBuffer, '<div id="page_header" class="page_header">')
		
		if !lMiniHeader
			// cabeçalho normal
			aAdd(aBuffer, '<div id="header_max" align="center" class="page_header">')
			aAdd(aBuffer, '<table width="100%" summary="" border="0" cellpadding="0" cellspacing="0">')
			aAdd(aBuffer, '<col width="30%">')
			aAdd(aBuffer, '<col>')
			aAdd(aBuffer, '<col width="30%">')
			aAdd(aBuffer, '<tr>')
			aAdd(aBuffer, '<td align="center" valign="top">' + TagImage("topo_01.gif", 280, 81) + '</td>')
			aAdd(aBuffer, '<td align="center" style="text-align: left;">')
			if HttpSession->CurrentDW == 0 // novo dw
				aAdd(aBuffer, 'DW:')
				aAdd(aBuffer, '<b>NOVO - </b>NOVO')
			endif
			if HttpSession->isLogged
				if ::DWCurrId() <> -1 .AND. HttpSession->isDWSelected
					aAdd(aBuffer, '<span class="StatusLabel"> DW: </span> <span class="StatusInfo"> ' + ::DWCurr()[DW_NAME] + ' - ' + ::DWCurr()[DW_DESC] + '</span><br>')
				else
					aAdd(aBuffer, '<span class="StatusLabel"> DW: </span> <span class="StatusInfo"> '+ '(' + STR0053 + ')' + '</span><br>') //###"Não selecionado"
				endif
				if oUserDW:userIsAdm()
					aAdd(aBuffer, '<span class="StatusLabel">' + STR0054 + ': </span><span class="StatusInfo">'+oUserDW:LoginName()+' - '+oUserDW:UserName()+'</span><br>') //###"Usuário"
				else
					aAdd(aBuffer, '<span class="StatusLabel">' + STR0054 + ': </span>'+; //###"Usuário"
					'<a href="javascript:alterCadastro();"'+ASPAS_S+ ;
					'onmouseOver='+ASPAS_S+'window.status="' + STR0055 + '"'+ASPAS_S+'><span class="StatusInfo">'+oUserDW:LoginName()+' - '+oUserDW:UserName()+'</a></span><br>') //###"Edição de Cadstro"
				endif
				aAdd(aBuffer, '<span class="StatusLabel">&nbsp;</span><a href='+makeAction(AC_LOGOUT)+ ;
				' onmouseover=' + ASPAS_D + "window.status='" + STR0056 + "';return true;" + ASPAS_D +;
				'><span class="StatusInfo"> Logout </span></a>') //###"Encerra a sessão atual"
			endif
			
			aAdd(aBuffer, '</td><td style="text-align:right" valign="top">')
			if valType(oUserDW) == "O"
				aAdd(aBuffer, tagImage(cimg, 228, 81, STR0057, ,, iif(oUserDW:UserIsAdm(), "doUploadLogo()", NIL)) + '</td></tr></table>') //###"Logo do cliente"
				aAdd(aBuffer, tagJS())
				aAdd(aBuffer, "function doUploadLogo()")
				aAdd(aBuffer, "{")
				if oUserDW:UserIsAdm()
					aAdd(aBuffer, "doLoad(" + makeAction(AC_UPLOAD_FILE, {{ "code", "1"}})+", '_window', null, 'winUpLoad', "+ dwStr(TARGET_50_WINDOW)+", "+dwStr(TARGET_25_WINDOW)+");")
				else
					aAdd(aBuffer, "alert('" + STR0058 + "');")
				endif
				aAdd(aBuffer, "}")
				aAdd(aBuffer, "</script>")
			else
				aAdd(aBuffer, tagImage(cimg, 280, 89, STR0057, ,,) + '</td></tr></table>') //###"Logo do cliente"
			endif
			aAdd(aBuffer, '</div>')
		else
			// cabeçalho pequeno
			aAdd(aBuffer, '<div id="header_min" class="page_header_mini">')
			aAdd(aBuffer, '<table summary="" width="100%" border="0" cellpadding="0" cellspacing="0">')
			aAdd(aBuffer, '<tr>')
			
			if HttpSession->isLogged
				aAdd(aBuffer, '<td class="StatusDwLabelMini">')
				if ::DWCurrId() <> -1
					aAdd(aBuffer, '<span class="StatusLabel">DW:</span> <span class="StatusInfo">' + ::DWCurr()[DW_NAME] + ' - ' + ::DWCurr()[DW_DESC] + '</span>')
				else
					aAdd(aBuffer, '<span class="StatusLabel">DW:</span> <span class="StatusInfo">(' + STR0053 + ')</span>') //###"Não selecionado"
				endif
				aAdd(aBuffer, '</td>')
				
				aAdd(aBuffer, '<td class="StatusUserLabelMini">' + ;
				'<span class="StatusLabel">' + STR0054 + '</span> ' + ;
				'<span class="StatusInfo">' + oUserDW:LoginName()+' - ' + oUserDW:UserName() + '</span></td>') //###"Usuário:"
				
				aAdd(aBuffer, '<td class="StatusLogoutLabelMini">' + ;
				'<span class="StatusLabel">' + ;
				'<a href=' + makeAction(AC_LOGOUT)+ ' onmouseover=' + ASPAS_D + "window.status='" + STR0056 + "';return true;" + ASPAS_D + '><span class="StatusInfo"> Logout </span></a></span></td>') //###"Encerra a sessão atual"
			endif
			
			aAdd(aBuffer, '</tr>')
			aAdd(aBuffer, "</table>")
			aAdd(aBuffer, "</div>")
		endif
		
		aAdd(aBuffer, '</div>')
		aAdd(aBuffer, '<!-- buildHeader end -->')
	endif
	
return
                           
method buildBeginBody(aBuffer) class TSigaDW
	local cAux := ""
	Local cMenuCSSClass := ""
	local cStyle := ""
	
	if !dwIsFlex()
		aAdd(aBuffer, '<!-- buildBody begin -->')
		
		// verifica se a navegação é por ÁRVORE e se a ação for a principal OU a página inicial vinda da seleção de DWs OU troca do tipo de menu (normal e vertical)
		if !HttpSession->FolderMenu .AND. (HttpGet->Action == AC_SELECT_ABA .OR. HttpGet->Action == AC_SELECT_DW .OR. HttpGet->Action == AC_CHANGE_MENU)
			cMenuCSSClass := ' page_body_tree_menu'
		endif
		
		if isNull(httpGet->_ow, CHKBOX_OFF) == CHKBOX_ON .or. isNull(HttpGet->isIFrame, CHKBOX_OFF) == CHKBOX_ON
			cStyle := "style='left:0px; top:0px; bottom:0px; right:0px;'"
		endif
		
		if isNull(HttpGet->isPrinting, CHKBOX_OFF) == CHKBOX_ON
			cAux := "<div id='page_body' class='page_body_preview' "
		else
		    If (httpGet->ACTION != "startdw" .and. httpGet->Action != "logout")
			cAux := "<div id='page_body' align='center' class='page_body" + cMenuCSSClass + "' "
			Else 
			   	cAux := "<div id='page_body' class='background" + cMenuCSSClass + "' "
			EndIf	
		endif
    		
		cAux += cStyle + ">"
		
		aAdd(aBuffer, cAux)
		aAdd(aBuffer, '<!-- buildBody beginData -->') //ao alterar esta marcação, revisar sigadw3.js, funcao handlerResponseData()
		
		aEval(aBuffer, { |x| HttpSend(x+CRLF) })
		aBuffer := {}
	endif
	
return

method buildEndBody(aBuffer) class TSigaDW
	   
	if !dwIsFlex()
	aAdd(aBuffer, '<!-- buildBody endData -->') //ao alterar esta marcação, revisar sigadw3.js, funcao handlerResponseData() 
	aAdd(aBuffer, "</div>")
	aAdd(aBuffer, '<!-- buildBody end -->')
	aEval(aBuffer, { |x| HttpSend(x+CRLF) })	
	aBuffer := {}
  endif
return
      

method buildFooter(aBuffer) class TSigaDW
#ifdef VER_P11
	local defHelp := Lower( __Language ) + "/sigadw_"
#endif

 	if !dwIsFlex()
#ifdef VER_P11
		aAdd(aBuffer, '<!-- buildFooter begin -->')
		aAdd(aBuffer, '<div id="page_footer" class="page_footer">')
		aAdd(aBuffer, '  <DIV style="WIDTH: 87px; BOTTOM: 0px; TOP: 0px; LEFT: 0px" class="wi-jqpanel pos-abs left"></DIV>')
		aAdd(aBuffer, '  <DIV style="BOTTOM: 0px; TOP: 0px; RIGHT: 135px; LEFT: 87px" class="wi-jqpanel pos-abs center"><DIV style="top:20px; right:50px;" class="pos-abs StatusInfo">' + DWBuild() + '&nbsp;&nbsp;' + DWBuildSite() + '</DIV></DIV>')
		aAdd(aBuffer, '  <DIV style="WIDTH: 135px; BOTTOM: 0px; TOP: 0px; RIGHT: 0px" class="wi-jqpanel pos-abs right">')
		aAdd(aBuffer, '  <DIV style="WIDTH: 45px; BOTTOM: 0px; TOP: 0px; LEFT: 0px" class="wi-jqpanel pos-abs right users" title="Cadastro de Usuários"'+;
		              "     onclick=alterCadastro()></DIV>")
		aAdd(aBuffer, '  <DIV style="WIDTH: 45px; BOTTOM: 0px; TOP: 0px; LEFT: 45px" class="wi-jqpanel pos-abs ajuda" title="Obtenha Ajuda"' +;
		              "     onclick=doHelp(this,'"+alltrim(oSigaDW:HelpServer())+"/"+defHelp+"introducao.htm')></DIV>")
		aAdd(aBuffer, '  <DIV style="WIDTH: 45px; BOTTOM: 0px; TOP: 0px; LEFT: 90px" class="wi-jqpanel pos-abs right security" title="Sair do Sistema"' +;
		              "     onclick='doLogout()'}></DIV>")
		aAdd(aBuffer, '</DIV>')
    aAdd(aBuffer, tagJS())
    aAdd(aBuffer, "function doLogout() {")
    aAdd(aBuffer, "  document.location.href="+makeAction(AC_LOGOUT)+";")
    aAdd(aBuffer, "}")
    aAdd(aBuffer, "</script>")
		aAdd(aBuffer, '<!-- buildFooter end -->')
#else	
		aAdd(aBuffer, '<!-- buildFooter begin -->')
		aAdd(aBuffer, '<div id="page_footer" class="page_footer">')
		aAdd(aBuffer, '<table summary="" width="100%" border="0" cellpadding="0" cellspacing="0">')
		aAdd(aBuffer, '<col width="33%">')
		aAdd(aBuffer, '<col width="33%">')
		aAdd(aBuffer, '<col width="34%">')
		aAdd(aBuffer, '<tbody>')
		aAdd(aBuffer, '<tr>')
		aAdd(aBuffer, '<td id=footer_esq width="26%" height="24">&nbsp;</td>')
		aAdd(aBuffer, '<td id=footer_meio width="48%" align="center">')
		aAdd(aBuffer, link2Siga())
		aAdd(aBuffer, '</td>')
		aAdd(aBuffer, '<td  id=footer_dir width="26%" align="right">')
		aAdd(aBuffer, DWBuild())
		aAdd(aBuffer, "&nbsp;")
		aAdd(aBuffer, DWBuildSite())
		aAdd(aBuffer, "&nbsp;&nbsp;")
		aAdd(aBuffer, "</td>")
		aAdd(aBuffer, "</tr>")
		aAdd(aBuffer, "</tbody>")
		aAdd(aBuffer, "</table>")
		aAdd(aBuffer, "</div>")
		aAdd(aBuffer, '<!-- buildFooter end -->')
#endif
	endif

return  




/*
--------------------------------------------------------------------------------------
Propriedade Title
--------------------------------------------------------------------------------------
*/
method getTitle() class TSigaDW
#ifdef DW_BETA_RELEASE
  return "Protheus - SigaDW (versão BETA)"
#else
  return "Protheus - SigaDW"
#endif

/*
--------------------------------------------------------------------------------------
Lista de biblioteca JS default
--------------------------------------------------------------------------------------
*/
method getLibJS() class TSigaDW

return { "jsoverlib.js", "sigadw3.js", "jstable.js", "jstree.js", "calendar.js", "choosecolor.js", "sigadw_" + IDIOMA2 + ".js" }

/*
--------------------------------------------------------------------------------------
Propriedade Error
--------------------------------------------------------------------------------------
*/
method error(aoError) class TSigaDW

  property ::foError := aoError
  
return ::foError

/*
--------------------------------------------------------------------------------------
Monta a mensagem de erro conforme os código passados
Arg: acErro -> string, bloco com o formato "EESS Complemento". 
					Onde: EE - código em hexa do erro
					    	SS - código em hexa da solução
							Complemento - Texto de complementação
     alHtml -> lógico, indica se o bloco deve ser HTML
Ret: cRet -> string, mensagem montada
--------------------------------------------------------------------------------------
*/                                 
method mountError(alAviso, alHtml) class TSigaDW
	local cRet := "", aErro := {}, aSol  := {}, nErro, nSol
	local lFatal := .f., oError := ::error()
	local cError := allTrim(substr(oError:Description, 2, 4))

	default alHtml := .f. 
	
	initListError(aErro, aSol)

	if !empty(cError) 
		nErro := DWhex2Int(left(cError, 2))  
		nSol := DWhex2Int(substr(cError, 3, 2))
		if left(aErro[nErro],1) == "#"
			lFatal := .t.
			aErro[nErro] := substr(aErro[nErro],2)
		endif
		if nErro != 0
			alAviso := left(aErro[nErro],6) == "AVISO:"
			cRet += STR0149 + " (" + left(cError, 2) + "-" + substr(cError, 3, 2) + ") "  //"Erro"
			cRet += aErro[nErro] + CRLF
			if substr(cError, 6) != ""
				cRet += " " + substr(cError, 6) + CRLF
			endif
			if nSol != 0
				cRet += STR0150 + aSol[nSol] + CRLF
			endif
		endif		                       
	endif		                       

return iif (lFatal, "#", "") + cRet

/*
--------------------------------------------------------------------------------------
Limpa Error
--------------------------------------------------------------------------------------
*/
method clearError() class TSigaDW

  ::foError := nil
  
return

/*
--------------------------------------------------------------------------------------
Indica se esta em condição de erro ou não
--------------------------------------------------------------------------------------
*/
method isError(aoError) class TSigaDW

return valType(::foError) == "O"

/*
--------------------------------------------------------------------------------------
Retorna a mensagem de erro
--------------------------------------------------------------------------------------
*/
method getMsgError() class TSigaDW
	local cRet := ""

  if ::isError()
    cRet := ::foError:Description
  endif
    
return cRet      

/*
--------------------------------------------------------------------------------------
Propriedade Theme
--------------------------------------------------------------------------------------
*/
method theme(acValue) class TSigaDW

 	property ::fcTheme := acValue
  
return ::fcTheme

/*
--------------------------------------------------------------------------------------
Método isPortal
--------------------------------------------------------------------------------------
*/
method isPortal() class TSigaDW
 
return .f.
 
/*
--------------------------------------------------------------------------------------
Propriedade showQbe
--------------------------------------------------------------------------------------
*/
method showQbe(alValue) class TSigaDW
                  
	property ::flShowQbe := alValue

return ::flShowQbe
 
/*
--------------------------------------------------------------------------------------
Propriedade ShowCubeUpdate
--------------------------------------------------------------------------------------
*/
method showCubeUpdate(alValue) class TSigaDW
                  
	property ::flShowCubeUpdate := alValue

return ::flShowCubeUpdate


method TypeCon(alValue) class TSigaDW
                  
	property ::flTypeCon := alValue

return ::flTypeCon

/*
--------------------------------------------------------------------------------------
Propriedade ShowCubeUpdate
--------------------------------------------------------------------------------------
*/
method sortMeasure(alValue) class TSigaDW
                  
	property ::flSortMeasure := alValue

return ::flSortMeasure

/*
--------------------------------------------------------------------------------------
Inicializa a lista de erros e soluções
Arg: paErro, array -> lista de erros
     paSol, array -> lista de soluções
Ret: 
--------------------------------------------------------------------------------------
*/                    
static function initListError(paErro, paSol)

	aAdd(paErro, STR0151) //ERR_001  //"Usuário ou senha inválido"
	aAdd(paErro, STR0152) //ERR_002  //"Operação inválida"
	aAdd(paErro, STR0153) //ERR_003  //"#Operação não implementada"
	aAdd(paErro, STR0154) //ERR_004  //"#Ação desconhecida"
	aAdd(paErro, STR0155) //ERR_005  //"Objeto não localizado"
	aAdd(paErro, STR0156) //ERR_006  //"Erro RPC. Ocorreu um erro durante uma tentativa de conexäo RCP."
	aAdd(paErro, STR0157) //ERR_007  //"#Objeto encontra-se bloqueado para uso."
	aAdd(paErro, STR0158) //ERR_008  //"Comando SQL inválido."
	aAdd(paErro, STR0159) //ERR_009  //"Erro interno."
	aAdd(paErro, STR0160) //ERR_010  //"DW sem acesso."
	aAdd(paErro, STR0161) //ERR_011  //"Chamada de procedimento não liberado"
	aAdd(paErro, STR0162) //ERR_012  //"URL de chamada inválida"
	aAdd(paErro, STR0163) //ERR_013  //"#SessionTimeOut expirada"
	aAdd(paErro, STR0176) //ERR_014  //"Este grupo não pode ser removido."

	aAdd(paSol, STR0164)  //SOL_001  //"Certifique-se que os dados estejam corretos ou entre em contato com o administrador do SigaDW"
	aAdd(paSol, STR0165)  //SOL_002  //"Entre em contato com o administrador do SigaDW e comunique esta ocorrência"
	aAdd(paSol, STR0166)  //SOL_003  //"Verifique se o objeto ainda existe"
	aAdd(paSol, STR0167)  //SOL_004  //"Verifique as propriedades de conexäo e se o servidor esta disponivel para este tipo de conexäo."
	aAdd(paSol, STR0168)  //SOL_005  //"Aguarde alguns instantes e tente novamente. Caso o erro persista, entre em contato com o administrador do SigaDW."
	aAdd(paSol, STR0169)  //SOL_006  //"Execute procedimento de liberação ou entre em contado com o administrador do SigaDW."
	aAdd(paSol, STR0170) // SOL_007  //"Efetue login novamente para reestabelecer conexão"
	aAdd(paSol, STR0177) // SOL_008  //"Apenas grupos criados por usuários podem ser removidos."

return

static function setDW(aBuffer)
    
	HttpSession->CurrentAba := oUserDW:LastAba()      
	
	// --------------------------------------------------------
	// Não permite a utilização de menu vertical na versão 11.
	// --------------------------------------------------------
	#ifdef VER_P11
		HttpSession->FolderMenu := .T. 
	#else
		HttpSession->FolderMenu := oUserDW:FolderMenu()
	#endif
	
	// --------------------------------------------------------
	// Validar o acesso ao DW .
	// --------------------------------------------------------              
	if !empty(HttpGet->dwname)        
		nPos := ascan(oSigaDW:DWList():faitems, {|x| x[DW_NAME] == HttpGet->dwname})		
		HttpSession->CurrentDW := oSigaDW:DWList():faitems[nPos][DW_ID]
	else
		HttpSession->CurrentDW := dwVal(HttpGet->dw)
	endif
	
	HttpSession->isDWSelected := .t.
	HttpSession->ColSort := 0
	
return

static function verSite()

  // verifica a validação do site do SigaDW
	if !isWebSiteUpdated()
    dwRaise(ERR_009, SOL_002, STR0174) //###"Site do SigaDW Desatualizado. Favor, atualizá-lo."
  endIf

return

static function resetDW(aBuffer, anReset)
    
	if anReset == 0 .OR. anReset == 2
		HttpSession->User := nil
		HttpSession->isLogged := .f.
		
		if !isNull(oUserDW) .AND. !(anReset == 2)
			if oUserDW:UserIsAdm()
				HttpSession->CurrentAba := { "main", "main_log" }
			else
				HttpSession->CurrentAba := { "desktopWorkspace", "" }
			endif
		endif
		
		HttpSession->Oper = nil
		HttpSession->SubOper = nil  
		HttpSession->FolderMenu := .T.
		addNavegMenu('', .T.)
	endif
	if anReset == 0 .or. anReset == 1 .OR. anReset == 2
		HttpSession->CurrentDW := nil
		HttpSession->isDWSelected := .f.
		HttpSession->DWImpStruc := nil
	endif
	
return

static function finalizeDW()

	oSigaDW:Finalize()
	resetDW(,2)
	HttpSession->UserDW := NIL
	oUserDW := NIL

return

static function changeMenu(alFolder)                               
	// --------------------------------------------------------
	// Não permite a utilização de menu vertical na versão 11.
	// --------------------------------------------------------
	#ifdef VER_P11
		HttpSession->FolderMenu := .T. 
	#else
		HttpSession->FolderMenu := !HttpSession->FolderMenu
	#endif
return

static function setAba()
	
	HttpSession->CurrentAba := aclone(tokenAba(HttpGet->Aba, 3))
	
return      

function addJSLib(aaLibList, alOnlyIE)
	                                   
	default alOnlyIE := .f.
	
	if alOnlyIE .and. isFireFox()
		return
	endif
		
	if !(valType(aaLibList) == "A")
		aAdd(HttpSession->JSLib, aaLibList)
	else
		aEval(aaLibList, { |x| aAdd(HttpSession->JSLib, x)})
	endif
	
return

static function addCSSLib(aaLibList)

	if !(valType(aaLibList) == "A")
		aAdd(HttpSession->CSSLib, aaLibList)
	else
		aEval(aaLibList, { |x| aAdd(HttpSession->CSSLib, x)})
	endif	
return

function tokenAba(aaAba, anLen)
	local aAbas := dwToken(aaAba, "_")
	local nInd, nInd2	

	for nInd2 := len(aAbas) to 2 step -1
		for nInd := nInd2 - 1 to 1 step -1
			aAbas[nInd2] := aAbas[nInd] + "_" +aAbas[nInd2]
		next
	next
		
	while len(aAbas) < anLen
		aAdd(aAbas, "")
	enddo

return aAbas

static function redirectPage(acURL)
	httpSend(tagJS())
	httpSend("location.href = " + acURL)
	httpSend("</script>")
return

static function ApenasParaEleminarAvisosCompilador()

	if .f.
		verSite(); addCSSLib(); changeMenu(); finalizeDw(); setAba(); setDw(); redirectPage()
		ApenasParaEleminarAvisosCompilador()
	endif
	
return		



