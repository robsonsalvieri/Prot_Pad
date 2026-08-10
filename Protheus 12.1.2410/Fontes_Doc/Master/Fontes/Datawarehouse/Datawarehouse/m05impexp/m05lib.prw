/*
// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : SigaDW
// Fonte  : M05Lib - rotinas genéricas de uso pelos processos de imp/exportação
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 09.02.06 | 0548-Alan Candido | Versão 3
// 31.10.08 | 0548-Alan Candido | FNC 00000004062/2008 (8.11) e 00000004221/2008 (9.12)
//          |                   | Implementação na função de leitura de informações sobre
//          |                   | a importação, para adicionar informações sobre a fonte
//          |                   | de dados utilizada para acesso a usuários SigaAdv
// 15.12.08 | 0548-Alan Candido | FNC 09025/2008 (8.11) e 09034/2008 (10)
//          |                   | Adequação de geração de máscara em campos numéricos e datas, 
//          |                   | para respeitar o formato conforme idioma 
//          |                   | (chave RegionalLanguage na sessão do ambiente).
// --------------------------------------------------------------------------------------
*/              

#include "dwincs.ch"
#include "dwidprocs.ch"
#include "m5lib.ch"
#include "tbiconn.ch"

/*
-----------------------------------------------------------------------
Inicia o JOB de exportação
-----------------------------------------------------------------------
*/                          
function DWStartExp(pnID, acLogFile, alFalseStart)

	local oFile
	local lOk := .t.
	
	default alFalseStart := .f.	
	acLogFile := "DWEXP" + dwInt2Hex(pnID, 8) + dwInt2Hex(oSigaDW:DWCurr()[1], 8) + ".LOG"

 	oFile := TDWFileIO():New(DwTempPath() + "\" + acLogFile)
 	if oFile:Exists()
		lOk := oFile:Append(FO_EXCLUSIVE)
	else
		lOk := oFile:Create(FO_EXCLUSIVE + FO_WRITE)
	endif     
	
	if !lOk
		DWHttpSend(buildMessage(STR0001)) //"Processo já esta em execução"
	else
		oFile:Close()
		if !alFalseStart
			dwStartJob("DWImpExpMonitor", {.f., pnID, oSigaDW:DWCurr()[2], "", getWebJob(), acLogFile, EX_CON, oUserDW:UserId()}, GetEnvServer())
		endif
	endif

return .t.

/*
-----------------------------------------------------------------------
Inicia o JOB de importação
-----------------------------------------------------------------------
*/                          
function DWStartImp(pnID, acLogFile, alFalseStart)

	default alFalseStart := .f.	
	acLogFile := "DWIMP" + dwInt2Hex(pnID, 8) + dwInt2Hex(oSigaDW:DWCurr()[1], 8) + ".LOG"

	if !alFalseStart
		dwStartJob("DWImpExpMonitor", {.t., pnID, oSigaDW:DWCurr()[2], "", getWebJob(), acLogFile, 0, 0, .t.}, GetEnvServer())
	endif
	
return .t.

/*
-----------------------------------------------------------------------
Coordena a execução dos JOBS de importação/exportação
-----------------------------------------------------------------------
*/                          
function DWImpExpMonitor(alImport, pnID, pcDW, pcHost, pcJobName, acLogFile, anTipo, anUserID, alDelLogOnFinish, acEnvironmet, anPort, acEmpresa, acFilial)
	local lRet := .t.
	local cTo, oFile, lErro := .f.
	local cInic := time(), cDate := date()
	local cTitulo, aAux, lOk
	local cProcesso, cOrigem
	local cTypeName := "", cIdTemp := "", cNameTemp := "", cDescTemp := "", cTypeTemp := ""
	local lSendMail := .f., oDSN, oAux
	local cLogFile := ""
	local cServer := ""
	//Recupera todas as sessões do arquivo de configuração.
	local aIniSession := GetIniSessions(DWIniFile())
	
	default alDelLogOnFinish := .F.

	if valtype(alImport) == "A"
		if len(alImport) < 13
			aSize(alImport, 13)
		endif
			
		//Verifica se a chave 'DWSERVER' foi informada no arquivo de configuração;
		//A chave 'DWSERVER' deve conter o IP ou o URI do Server do DW.
		if ( len( cServer := GetPvProfString("GENERAL", "DWSERVER", "" , DWIniFile() ) ) > 0 )
			
			RPCSetType(3)
			
			//Os parâmetros 10, 11, 12 e 13 são utilizados apenas para estabelecer o RPC.
			create rpcconn oRPCServer;
			on server cServer PORT alImport[11];
			environment alImport[10];
			empresa alImport[12] filial alImport[13] clean
			
			if valType(oRPCServer) == "O"
				callproc in oRPCServer;
				function "DWImpExpMonitor";
				parameters alImport[1], alImport[2], alImport[3], alImport[4], alImport[5], alImport[6], alImport[7], alImport[8], alImport[9], alImport[10], alImport[11], alImport[12], alImport[13];
				result lRet
				
				close rpcconn oRPCServer
			else
				DWLog( STR0057, STR0058 + cServer, STR0059 + dwStr(alImport[11]), STR0060 + alImport[10], STR0061 + alImport[12], STR0062 + alImport[13]) /*"Não foi possível estabelacer conexão com o servidor do SIGADW"*/ /*"Servidor: "*/ /*"Porta: "*/ /*"Ambiente: "*//*"Empresa: "*/ /*"Filial: "*/
			endif
			
		else
			DWLog(STR0063) /*"Chave [ DWSERVER ] não especificada ou incorreta na sessão [ GENERAL ] do arquivo de configuração"*/
		endif
		
		return lRet
	endif
	
	if valType(acLogFile) == "U"
		acLogFile := "DW" + iif(alImport, "IMP", "EXP") + dwInt2Hex(int(pnID), 8) + pcDW + ".LOG"
	endif
	
	cProcesso := iif(alImport , STR0002, STR0003) //"IMPORTAÇÂO"   //"EXPORTAÇÃO"
	
	oFile := TDWFileIO():New(DwTempPath() + "\" + acLogFile)
	
	if oFile:Exists()
		lOk := oFile:Append(FO_EXCLUSIVE)
	else
		lOk := oFile:Create(FO_EXCLUSIVE + FO_WRITE)
	endif
	
	if lOk
		DWLog(cProcesso + " - " + STR0004, "DW:" + pcDW, "Log:" + oFile:Filename())
		SigaDWStart(pcJobName, .T.)
		
		if !(valType(oUserDW) == "O")
			oUserDW := TDWUser():New()
		endif
		
		if valType(oSigaDW) == "U"
			oFile:WriteLN(STR0005) //"ERRO: Não foi possivel inicializar gerenciador do SigaDW"
		elseif valType(oUserDW) == "U"
			oFile:WriteLN(STR0006) //"ERRO: Não foi possivel obter/inicializar informações sobre usuário"
			oFile:WriteLN("  ID: " + dwStr(anUserID))
		else
			if valType(anUserID) == "N"
				oUserDW:ChangeUser(anUserID)
			else
				oUserDW:foUsers:seek(2, { "DWADMIN" } )
				oUserDW:ChangeUser(oUserDW:foUsers:value("id"))
			endif
			
			cTo := oSigaDW:Notify()[2]
			oSigaDW:SelectDW(pcDW)
			oFile:WriteLN("------------------------------")
			oFile:WriteLN(STR0007 + dwFormat(" [99/99/99] - [@X] ", { date(), cInic}))  //"Iniciado em"
			oFile:WriteLN(dwConcatWSep(CRLF, cProcesso + " - " + STR0008, "Host:" + pcHost, "DW:" + pcDW))  //Iniciando processo
			       
			// caso seja importação, verifica se deve notificar ações da importação
			if alImport
				oDSN := InitTable(TAB_DSN) 
				if oDSN:Seek(1, {pnID})
					if oDSN:value("tipo") == OBJ_CUBE
						oAux := InitTable(TAB_CUBESLIST)
					elseif oDSN:value("tipo") == OBJ_DIMENSION
						oAux := InitTable(TAB_DIMENSAO)
					elseif oDSN:value("tipo") == "U"
						oAux := ""
					endif
					
					if valtype(oAux) == "O"
						if oAux:Seek(1, {oDSN:value("id_table")})
							lSendMail := oAux:value("notificar")
						else
							DWRaise(ERR_002, SOL_000, STR0009) //"Referência de objeto não encontrado"
						endif
					endif
				else
					DWRaise(ERR_002, SOL_000, STR0010) //"Fonte não encontrada"
				endif
			endif
			
			if lSendMail
				aAux := prepMsg(alImport, pnID, STR0011, pcHost, pcDW, .f., anTipo)  //"INICIADO"
				if len(aAux) > 0
					DWSendMail(dwFormat("\[SigaDW\] " + cProcesso + " - [@X] - [@X]", { iif(oSigaDW:isSched(), STR0012, ""), STR0013 }), dwConcatWSep("<br>", aAux), cTo)  //"agendada"  //"inicializado"
				endif
			endif
			
			begin sequence
			if alImport
				cLogFile := m05Import(pnID, CHKBOX_ON, acLogFile)
			else
				cLogFile := m05Export(pnID, CHKBOX_ON, acLogFile, anTipo, getExpInfo(anTipo, pnID))
			endif
			recover
			lErro := .t.
			end sequence
			
			if alImport
				cOrigem := STR0014 //"Fonte de dados"
				oTabTemp := initTable(TAB_DSN)
				if oTabTemp:seek( 1, { pnId } )
					cIdTemp := oTabTemp:value("id_table")
					cNameTemp := oTabTemp:value("nome")
					cDescTemp := oTabTemp:value("descricao")
					if oTabTemp:value("TIPO") == "D"
						cTypeTemp := STR0015 //"Dimensao"
						oTabAux := initTable(TAB_DIMENSAO)
						if oTabAux:seek(1, { dwVal(cIdTemp) } )
							cTypeName := oTabAux:value("nome")
						endif
					elseif oTabTemp:value("TIPO") == "C"
						cTypeTemp := STR0016 //"Cubo"
						oTabAux:=initTable(TAB_CUBESLIST)
						if oTabAux:seek(1, { dwval(cIdTemp) } )
							cTypeName := oTabAux:value("nome")
						endif
					endif
				endif
			else
				oTabTemp := initTable(TAB_EXPORT)
				if oTabTemp:seek( 1, { pnId } )
					cIdTemp := oTabTemp:value("idTipo")
					cNameTemp := oTabTemp:value("nome")
					cDescTemp := oTabTemp:value("descricao")
					if oTabTemp:value("TIPO") == EX_DIM
						cTypeTemp := STR0015 //"Dimensao"
						oTabAux := initTable(TAB_DIMENSAO)
						if oTabAux:seek(1, { dwVal(cIdTemp) } )
							cNameTemp := oTabAux:value("nome")
						endif
					elseif oTabTemp:value("TIPO") == EX_CUBE
						cTypeTemp := STR0016 //"Cubo"
						oTabAux:=initTable(TAB_CUBESLIST)
						if oTabAux:seek(1, { dwval(cIdTemp) } )
							cNameTemp := oTabAux:value("nome")
						endif
					else
						cTypeTemp := STR0017  //"Consulta"
						oTabAux:=initTable(TAB_CONSULTAS)
						if oTabAux:seek(1, { dwval(cIdTemp) } )
							cNameTemp := oTabAux:value("nome")
						endif
					endif
				endif
				cOrigem := cTypeTemp
			endif
			if lErro
				lRet := .f.
				cTitulo := dwFormat("\[SigaDW\] " + cProcesso + " - [@X] - [@X]", { iif(oSigaDW:isSched(), STR0012, ""), STR0018 })  //"agendada"   //"erro"
				
				DWLog(cTitulo, ;
				"Host .: " + pcHost, ;
				"DW ...: " + pcDW, ;
				STR0019 + cOrigem, ;   //"Origem ...: "
				cTypeTemp + " ...: " + cTypeName, ;
				STR0020 + cNameTemp)  //"Nome da fonte ...: "
				
				oFile:WriteLN(dwConcatWSep(CRLF, cTitulo, ;
				"Host .: " + pcHost, ;
				"DW ...: " + pcDW, ;
				STR0019 + cOrigem, ;  //"Origem ...: "
				cTypeTemp + " ...: " + cTypeName, ;
				STR0020 + cNameTemp))  //"Nome da fonte ...: "
				
				aAux := prepMsg(alImport, pnID, STR0021, pcHost, pcDW, .t.)  //"Finalizado com erro"
				
				if lSendMail
					if len(aAux) > 0
						DWSendMail(cTitulo,dwConcatWSep("<br>", aAux),cTo,,cLogFile)
					endif
				endif
			else
				aAux := prepMsg(alImport, pnID, STR0022 , pcHost, pcDW, .t.)  //"FINALIZADO"
				cTitulo := dwFormat("\[SigaDW\] " + cProcesso + " - [@X] - [@X]", { iif(oSigaDW:isSched(), STR0012, ""),  STR0022})  //"agendada"  //"finalizado"
				if lSendMail
					if len(aAux) > 0
						DWSendMail(cTitulo ,dwConcatWSep("<br>", aAux), cTo,, cLogFile)
					endif
				endif
				
				DWLog(cTitulo, ;
				"Host .: " + pcHost, ;
				"DW ...: " + pcDW, ;
				STR0019 + cOrigem, ;  //"Origem ...: "
				cTypeTemp + " ...: " + cTypeName, ;
				STR0020 + dwStr(cNameTemp))  //"Nome da fonte ...: "
				
				oFile:WriteLN(dwConcatWSep(CRLF, cTitulo, ;
				"Host .: " + pcHost, ;
				"DW ...: " + pcDW, ;
				STR0019 + cOrigem, ;  //"Origem ...: "
				cTypeTemp + " ...: " + cTypeName, ;
				STR0020 + dwStr(cNameTemp)))  //"Nome da fonte ...: "
			endif
		endif
		
		oFile:WriteLN("------------------------------")
		oFile:WriteLN(STR0023 + dwFormat(" [99/99/99] - [@X] ", { date(), time()}))  //"Finalizado em"
		oFile:WriteLN(STR0024 + dwFormat(" [@X]", { DWElapTime(cDate, cInic, date(), time())}))  //"Tempo total de processamento"
		oFile:WriteLN("##############################")
		oFile:Close()
		
		if alDelLogOnFinish
			DWLog(STR0025 + oFile:FileName())  //"Removendo arquivo "
			oFile:Erase()
		endif
	else
		DWLog(STR0026, "ID: " + dwStr(pnID), "Host:" + pcHost, "DW:" + pcDW)  //"Processo já esta em execução"
	endif
return lRet

/*
-----------------------------------------------------------------------
Prepara mensagem de e-mail
-----------------------------------------------------------------------
*/                          
static function prepMsg(plImport, pnID, pcPasso, pcHost, pcDW, alAnexo, anTipo)
	local aRet := {}, aAux

	if !empty(oSigaDW:Notify()[2])
		aAux := iif(plImport, getImpInfo(pnID), getExpInfo(anTipo, pnID))
		if len(aAux) > 0
			aAdd(aRet, STR0027)
			aAdd(aRet, "")
			if plImport
				aAdd(aRet, STR0028)
			else
				aAdd(aRet, STR0029)
			endif
			aAdd(aRet, "")
			aAdd(aRet, "Host: " + pcHost)
			aAdd(aRet, "DW:" + pcDW)
			aEval(aAux, { |x| aAdd(aRet, x)})
			aAdd(aRet, "")
			aAdd(aRet, STR0030 + dwFormat("[99/99/99] - [@X]", { date(), time()}) + STR0031)  //"Em"   //", o status deste passou para:"
			aAdd(aRet, pcPasso)
			aAdd(aRet, "")
			if alAnexo
				aAdd(aRet, STR0032)
			endif
			aAdd(aRet, "")
			aAdd(aRet, "--")
			if plImport
				aAdd(aRet, "<pre> __<br>/_/| SigaDW<br>|_|/ "+STR0033+"</pre>")  //"Processo de importação agendada"
			else
				aAdd(aRet, "<pre> __<br>/_/| SigaDW<br>|_|/ "+STR0034+"</pre>")  //"Processo de exportação agendada"
			endif
		endif
	endif
	
return aRet

/*
-----------------------------------------------------------------------
Prepara array com informações sobre a importação
-----------------------------------------------------------------------
*/                          
function getImpInfo(anID)
	local aRet := {}, oDSN := InitTable(TAB_DSN)
	local oConector := oSigaDW:Connections()
	local oDim := InitTable(TAB_DIMENSAO)
	local oCubes := InitTable(TAB_CUBESLIST)
		
	if oDSN:Seek(1, { anID })
		aAdd(aRet, STR0035 + dwFormat(" \[[@X]\]-[@X]", { oDSN:value("nome"), oDSN:value("descricao")}))  //"Fonte:"
		if oDSN:value("tipo")=="U"
      aAdd(aRet, STR0056 /*"Usuários SigaADV"*/)
		else		
			if oDSN:value("tipo")=="D"
				if oDim:Seek(1, { oDSN:value("id_table") } )
					aAdd(aRet, STR0015 + dwFormat(" \[[@X]\]-[@X]", { oDim:value("nome"), oDim:value("descricao")}))  //"Dimensão"
					lNotificar := oDim:value("notificar")
				else
					aAdd(aRet, STR0036)  //"Dimensão **** NÃO LOCALIZADO ****"
				endif
			else
				if oCubes:Seek(1, { oDSN:value("id_table") } )
					aAdd(aRet, STR0016 + dwFormat(" \[[@X]\]-[@X]", { oCubes:value("nome"), oCubes:value("descricao")}))  //"Cubo"
					lNotificar := oCubes:value("notificar")
				else
					aAdd(aRet, STR0037)  //"Cubo **** NÃO LOCALIZADO ****"
				endif
			endif
		endif

    if oDSN:value("id_connect") < 1 // conexão localhost
      aAdd(aRet, STR0040 + "(localhost)" + "//" + getWebJob()) //"Servidor/Ambiente "
      aAdd(aRet, STR0041 + dwEmpresa() + "//" + dwFilial())  //"Empresa/Filial "
    else
      aAdd(aRet, STR0038 + oDSN:value("connector")+'('+oDSN:value("tipo_text")+')')  //"Conexão: "
      oConector:Seek(1, { oDSN:value("id_connect") } )
      
      if oDSN:value("tipo_conn") == TC_TOP_CONNECT
        aAdd(aRet, STR0039 + oDSN:value("server") + "/" + oDSN:value("banco_srv") + "/" + oConector:value("alias"))  //"Banco/Alias "
      else
        
        if oDSN:value("tipo_conn") == TC_AP_SX
          aAdd(aRet, STR0040 + oConector:value("server") + "//" + oConector:value("ambiente")) //"Servidor/Ambiente "
          
          if empty(oDSN:value("empfil"))
            aAdd(aRet, STR0041 + oConector:value("empresa") + "//" + oConector:value("filial"))  //"Empresa/Filial "
          else
            aAdd(aRet, STR0041 + oDSN:value("empfil"))  //"Empresa/Filial: "
          endif
          
          if !empty(oDSN:value("alias"))
            aAdd(aRet, STR0042 + oDSN:value("alias"))  //"Alias "
          endif
          
        else  
          aAdd(aRet, STR0040 + "[ " + oConector:value("server") + " - " + oConector:value("ambiente") + " ]")  //"Servidor/Ambiente: "
          aAdd(aRet, STR0043 + "[ " +oDSN:value("caminho") + "\" +  oDSN:value("arquivo") + " ]")  //"Arquivo: "         
        endif
      
      endif
      
	  endif

	  if oDSN:value("optimizer")
	    aAdd(aRet, STR0044)  //"Processo sendo executado em modo OTIMIZADO"
	  endif
	endif
	
return aRet

/*
-----------------------------------------------------------------------
Prepara array com informações sobre a exportação
-----------------------------------------------------------------------
*/                          
static function getExpInfo(anTipo, anID)
	local aRet := {}
	local oExport := InitTable(TAB_EXPORT)
	local oTab
	
	if oExport:Seek(1, { anID })
		if oExport:value("tipo") == EX_DIM
			oTab := oSigaDW:OpenDim(oExport:value("idtipo"))
			formatExpInfo(aRet, oExport, STR0015, oTab:Alias(), oTab:Descricao())  //"Dimensão"
			oSigaDW:CloseDim(oExport:value("idtipo"))
		elseif oExport:value("tipo") == EX_CUBE
		 	oTab := oSigaDW:OpenCube(oExport:value("idtipo"))
      		formatExpInfo(aRet, oExport, "Cubo", oTab:Name(), oTab:Descricao())
			oSigaDW:CloseCube(oExport:value("idtipo"))
		else                                
			oTab := initTable(TAB_CONSULTAS)
			if oTab:Seek(1, { oExport:value("idtipo") } )
        		formatExpInfo(aRet, oExport, STR0017, oTab:value("nome"), oTab:value("descricao"))  //"Consulta"
			else
				aAdd(aRet, STR0045)  //"Consulta **** NÃO LOCALIZADA ****"
			endif
		endif
 	endif
	
return aRet

static function formatExpInfo(aaRet, aoExport, acTitle, acName, acDescricao)
	Local aFormatos := dwComboOptions(FILE_TYPES)

	aAdd(aaRet, dwFormat(acTitle +": \[[@X]\]-[@X]", { acName, acDescricao }))
	//aAdd(aaRet, STR0046 + dwFormat(" \[[@X]([@X])\]", { aFormatos[dwVal(aoExport:value("formato")), FT_DESC], aFormatos[dwVal(aoExport:value("formato")), FT_EXT] }))  //"Formato:"
	aAdd(aaRet, STR0046 + dwFormat(" \[[@X]([@X])\]", { aFormatos[1, FT_DESC], aFormatos[1, FT_EXT] }))  //"Formato:"	
	
	
	if aoExport:value("mzp")
		aAdd(aaRet, STR0047 + dwFormat(" \[[@X]\]", { STR0048 }))  //"Compactado (.mzp) "  //"Sim"
	endif
	if !empty(aoExport:value("separator"))
			aAdd(aaRet, STR0049 + dwFormat(" \[[@X]\]", { aoExport:value("separator") }))  //"Separador
	endif
	if aoExport:value("showZero")
		aAdd(aaRet, STR0050 + dwFormat(" \[[@X]\]", { aoExport:value("showZero") }))  //"BRANCO como 0
	endif
	if !aoExport:value("hideTotals")
		aAdd(aaRet, STR0051 + dwFormat(" \[[@X]\]", { STR0048 }))  //"Totais  //"Sim"
	endif
	if !aoExport:value("hideEquals")
		aAdd(aaRet, STR0052 + dwFormat(" \[[@X]\]", { STR0048 })) //"Repetir linhas:   //"Sim"
	endif
	if aoExport:value("showheader")
		aAdd(aaRet, STR0053 + dwFormat(" \[[@X]\]", { STR0048 })) //"Cabeçalhos "  //"Sim"
	endif

	if aoExport:value("showformat")
		aAdd(aaRet, STR0054 + dwFormat(" \[[@X]\]", { STR0048 }))  //"Formatar Indicadores "  //"Sim"
	endif

	if aoExport:value("expAlert")
		aAdd(aaRet, STR0055 + dwFormat(" \[[@X]\]", { STR0048 }))  //"Exportar Alerta "  //"Sim"
	endif

	if aoExport:value("percIsInd")
		aAdd(aaRet, STR0064 + dwFormat(" \[[@X]\]", { STR0048 }))  //"Percentual como indice"  //"Sim"
	endif
	
return

/*
-----------------------------------------------------------------------
Envia notificações via IPC
-----------------------------------------------------------------------
*/                          
static __BUFFER_ON := .f.
static __BUFFER := nil  
static __TOT_ETAPAS := 0
static __NUM_ETAPAS := 0
static __DT_INIC
static __HR_INIC

static function prepInfo(axInfo)
  local cRet := dwStr(axInfo, .t.)
  if len(cRet) > 245 .and. right(cRet,1) == ASPAS_D
    cRet := right(cRet, 245) + "..." + ASPAS_D

  endif
  
return cRet

function sendIpcMsg(acIPCId, anTypeRec, axP1, axP2, axP3)
	local lOk, lBufferOn := .f., oTabIPC := InitTable(TAB_IPC)

	if anTypeRec == IPC_PROCESSO .and. axP1 == IMP_PRO_INIT
		__TOT_ETAPAS := axP2+1
    __DT_INIC := date()
    __HR_INIC := time()
		dwDelAllRec(TAB_IPC, "LOGFILE = '" + acIPCId + "'")
		oTabIPC:refresh()
  elseif anTypeRec == IPC_ERRO .or. anTypeRec == IPC_TERMINO .or. anTypeRec == IPC_TERMINO_W_WARNING
    cAux := dtoc(date()) + " " + time()
		sendIpcMsg(acIPCId, IPC_TEMPO, dtoc(__DT_INIC) + " " + __HR_INIC, , cAux)
	elseif anTypeRec == IPC_ETAPA .and. axP2 == IMP_ETA_INICIO
		__NUM_ETAPAS++
		sendIpcMsg(acIPCId, IPC_BUFFER, .t.)
		sendIpcMsg(acIPCId, IPC_PROCESSO, __NUM_ETAPAS / __TOT_ETAPAS)
		lBufferOn := .t.
	elseif anTypeRec == IPC_BUFFER
		__BUFFER_ON := axP1
		if axP1
			__BUFFER := {}
		else
			axP1 := __BUFFER
		endif
	endif		

	if anTypeRec == IPC_BUFFER
		if !__BUFFER_ON
      //emula a função ipcGo()
			aEval(__BUFFER, { |x| ;
              oTabIPC:append( { { "logfile", acIPCId }, ;
                                { "rectype", x[1] }, ;
                                { "info1", prepInfo(x[2]) }, ;
                                { "info2", prepInfo(x[3]) }, ;
                                { "info3", prepInfo(x[4]) } }) } )
		endif
	else
		if __BUFFER_ON
			aAdd(__BUFFER, { anTypeRec, axP1, axP2, axP3 })
		else
      //emula a função ipcGo()
      oTabIPC:append( { { "logfile", acIPCId }, ;
                        { "rectype", anTypeRec }, ;
                        { "info1", prepInfo(axP1) }, ;
                        { "info2", prepInfo(axP2) }, ;
                        { "info3", prepInfo(axP3) } }) 
		endif
	endif
	
	if lBufferOn
		sendIpcMsg(acIPCId, IPC_BUFFER, .f.)
	endif

return
