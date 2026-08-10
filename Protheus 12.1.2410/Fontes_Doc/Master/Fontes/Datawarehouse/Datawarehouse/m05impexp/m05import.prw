// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : M05 - ImpExp
// Fonte  : m05Import - Efetua a importação de dados em modo "on-line"
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 01.06.01 | 0548-Alan Candido |
// 13.12.05 | 0548-Alan Candido | Versão 3
// 31.10.08 | 0548-Alan Candido | FNC 00000004062/2008 (8.11) e 00000004221/2008 (9.12)
//          |                   | Implementação da importação de usuário SigaADV via RPC.
// 18.11.08 | 0548-Alan Candido | FNC 00000006227/2008 (8.11) e 00000006076/2008 (P10)
//          |                   | Adequação de chamada de função para tratamento de caracteres
//          |                   | especiais no processo de importação de usuários SigaADV.
// 15.12.08 | 0548-Alan Candido | FNC 09025/2008 (8.11) e 09034/2008 (10)
//          |                   | Adequação de geração de máscara em campos numéricos e datas, 
//          |                   | para respeitar o formato conforme idioma 
//          |                   | (chave RegionalLanguage na sessão do ambiente).
// 03.03.10 | 0548-Alan Candido | FNC 00000004214/2010 (P11) 
//          |                   | Adequação de importação de usuários Microsiga Protheus,
//          |                   | utilizando a função FWSFAllUsers()
// --------------------------------------------------------------------------------------

#include "dwincs.ch"
#include "dwidprocs.ch"
#include "m5import.ch"
#include "tbiconn.ch"

#define FLAG_NOTIFICAR "<!--NOTIFICAR "

#ifdef VER_P11
  #define IDX_LOGIN    3
  #define IDX_NOME     4
  #define IDX_MAIL     5
#else
  #define IDX_LOGIN    2
  #define IDX_SENHA    3
  #define IDX_NOME     4
  #define IDX_MAIL    26
#endif  					

function m05import(anID, acFlag, acIPCId)
	local oDSN := InitTable(TAB_DSN)
	local oDim := InitTable(TAB_DIMENSAO)
	local oCubes := InitTable(TAB_CUBESLIST)
	local oConector := oSigaDW:Connections()
	local cMsg := ""
	local aAux, nInd, cAux, nIDEstat, aEstat
	local oMakeImp, cTitle := ""
	local aParams := {}
	local cbAux := { | anTypeRec, axP1, axP2, axP3| ShowMsg(anTypeRec, axP1, axP2, axP3) }
	local cLogType
	local bLogFile
	local oConsulta, oConsDim, cNotificar := ""
	local aProcCons := {}
	local oQuery, lProc := .f.
	local oFileCubo
	local cPrev := "", cDuracao := ""
	local lAp5NoMv, aServer
	local dInic := date(), cInic := time()
	local oRPC  
	Local cSenha	:= ""
	
	default acIPCId := ""
	
	private cLogFile
	private aNotificar := oSigaDW:Notify()
	private cIPCId := upper(allTrim(acIPCId))
	
	if len(aNotificar) <> 2
		aSize(aNotificar,2)
		aeval(aNotificar, { |x,i| iif(valType(x)=="U", aNotificar[i] := "", nil)})
	endif
	
	do while .t.
		// Prepara titulos para apresentação
		if oDSN:Seek(1, { anID })
			oConector:Seek(1, { oDSN:value("id_connect") } )
			if oDSN:value("tipo") == "U"
				cLogType := "USR"
				showMsg(IPC_PROCESSO, IMP_PRO_INIT, IMP_PRO_USR) // Numero de etapas de todo o processo
				cTitle := oDSN:value("descricao")
			elseif oDSN:value("tipo") == "D"
				cLogType := "DIM"
				showMsg(IPC_PROCESSO, IMP_PRO_INIT, IMP_PRO_DIM) // Numero de etapas de todo o processo
				if oDim:Seek(1, { oDSN:value("id_table") } )
					cTitle := oDim:value("nome") + "-" + oDim:value("descricao",.t.)
					cLogType += oDim:value("nome") + DwInt2hex(oDim:value("id"), 8)
				endif
			else
				cLogType := "CUB"
				showMsg(IPC_PROCESSO, IMP_PRO_INIT, IMP_PRO_CUBE) // Numero de etapas de todo o processo
				if oCubes:Seek(1, { oDSN:value("id_table") } )
					cTitle := oCubes:value("nome") + "-" + oCubes:value("descricao")
					cLogType += oCubes:value("nome") + DwInt2hex(oCubes:value("id"), 8)
				endif
			endif
			cTitle := "[ " + cTitle + " ]"
			
			//	fixo para imp	horário da importação				  dw atual utilizado	        id do dw atual utilizado
			cLogType := "IMP" + strTran(Time(), ":", "") + cLogType + oSigaDW:DWCurr()[2] + DwInt2hex(oSigaDW:DWCurr()[1], 8)
			
			// Verifica a opção de gerar log de importações/exportações (propriedade "Log de Importação/Exportações")
			If oSigaDW:LogImpExp()
				cLogFile := oSigaDW:LogEvent("", STR0092 + dwFormat(" [@x]", { cTitle }), cLogType) //"Importação de "
				bLogFile := { |xMsg, cTitle| oSigaDW:LogEvent(xMsg+"</br>", cTitle, cLogType, cLogFile) }
			Else
				// limpa o code block de geração de evento
				bLogFile := { |xMsg, cTitle| NIL }
				// loga o evento no sigadw, para aparecer no menu Logs do SigaDW
				oSigaDW:Log(STR0092 + dwFormat(" [@x]", { cTitle })) //"Importação de "
			EndIf
			
			// Verifica os parametros de conexão
			atzInfo(getImpInfo(anID), bLogFile)
			
			if ( oDSN:value("tipo")=="U" )
				if oDSN:value("id_connect") < 1 // server: localhost
					lAp5NoMv := __Ap5NoMv(.t.)
					#ifdef VER_P11					
						aUsers := FWSFAllUsers()
					#else          
						aUsers := AllUsers()
					#endif					
					__Ap5NoMv(lAp5NoMv)
				else
					oConector:Seek(1, { oDSN:value("id_connect") } )
					aAux := DwToken(oConector:value("server"), ":", .f.)
					aSize(aAux,2)
					if valType(aAux[2]) == "U"
						aAux[2] := DWDefaultPort()
					endif
					
					create rpcconn oRPC;
					on server aAux[1] port dwVal(aAux[2]) ;
					environment oConector:value("ambiente");
					empresa oConector:value("empresa") filial oConector:value("filial")
					
					if valType(oRPC) == "O"
						callproc in oRPC;
						function "__Ap5NoMv" ;
						parameters .t.;
						result lAp5NoMv
						callproc in oRPC;
						function "allUsers" ;
						parameters nil;
						result aUsers
						callproc in oRPC;
						function "__Ap5NoMv" ;
						parameters lAp5NoMv;
						result lAp5NoMv
						close rpcconn oRPC
					else
						dwRaise(ERR_006, SOL_004, DWConcatWSep(" ", STR0124 /*"Não foi possivel executar RPC"*/, aAux[1], aAux[2], oConector:value("ambiente"), oConector:value("empresa") , oConector:value("filial") ), .f.)
					endif
				endif
				
				oUsers := initTable(TAB_USER)
				oUsers:Seek(2, { "G", "GRP_USR" })
				nIDGrupo := oUsers:value("id")

				for nInd := 1 to len(aUsers)
					
					#ifdef VER_P11
						aUser 	:= aUsers[nInd] 
						cSenha  := PswMD5GetPass( aUser[2] ) 
					#else					  
					    aUser 	:= aClone(aUsers[nInd][1])  
					    cSenha  := aUser[IDX_SENHA]
					#endif
					
					aEval(aUser, { |x,i| iif(valType(x) == "C", aUser[i] := removeSpecialCharacteres(x, .t.), nil) })    
					
					if oUsers:Seek(2, { "U", aUser[IDX_LOGIN] }, .f.) .or. oUsers:Seek(2, { "U", upper(aUser[IDX_LOGIN]) }, .f.)
						if oUsers:value("impSiga")
							oUsers:update({{ "login", Upper(aUser[IDX_LOGIN]) }, { "nome", aUser[IDX_NOME] }, {"recLimit", 50}, {"impSigUser", aUser[IDX_LOGIN]}, {"email", aUser[IDX_MAIL] } } )
						else
							eval(bLogFile, STR0093 + dwFormat(" [@!] - [@!] ", { aUser[IDX_LOGIN], aUser[IDX_NOME] }) + STR0097) //"Usuário do Protheus não importado: " "usuário já existente"
						endif
					else    
						oUsers:append({ {"login", Upper(aUser[IDX_LOGIN]) }, { "nome", aUser[IDX_NOME] }, { "tipo", "U" }, { "id_grupo", nIDGrupo }, { "ativo", .t.},;
                            {	"us_siga", .T. } , { "admin", .F. }, { "impSiga", .T. }, { "impSigUser", aUser[IDX_LOGIN] }, { "senha", DWCripto(PswEncript("_"+ cSenha +"_"), PASSWORD_SIZE, 0)}} )
					endif
				next

				eval(cbAux, IPC_BUFFER, .t.)
				eval(cbAux, IPC_ETAPA, , IMP_ETA_FIM)
				eval(cbAux, IPC_PROCESSO, IMP_PRO_FIM)
				eval(cbAux, IPC_BUFFER, .f.)
				sleep(3000)
				eval(cbAux, IPC_TERMINO, { cLogFile } ) 

				return iif(!empty(cNotificar), cLogFile, "")    
			endif
			
			oConector:Seek(1, { oDSN:value("id_connect") } )
			if oDSN:value("tipo")=="D"
				if oDim:Seek(1, { oDSN:value("id_table") } )
					cNotificar := iif(oDim:value("notificar"), FLAG_NOTIFICAR+aNotificar[2]+"--!>", "")
					oDim:update({ {"dt_process", date()}, {"hr_process",time()} })
					eval(cbAux, IPC_ETAPA, STR0094, IMP_ETA_INICIO) //"Preparando..."
					eval(cbAux, IPC_AVISO, STR0078 + dwFormat("[@!]-[@!]", { oDim:value("nome"), oDim:value("descricao")})) //"Dimensão:"
				else
					cMsg := STR0078 + dwFormat(" [@!] ", { oDSN:value("id_table") }) + STR0095 //"Dimensão: "  "não localizada"
					eval(cbAux, IPC_ERRO, cMsg)
					exit
				endif
			else
				if oCubes:Seek(1, { oDSN:value("id_table") } )
					cNotificar := iif(oCubes:value("notificar"), FLAG_NOTIFICAR+aNotificar[2]+"--!>", "")
					
					eval(cbAux, IPC_ETAPA, STR0094, IMP_ETA_INICIO) //"Preparando..."
					eval(cbAux, IPC_AVISO, STR0080 + dwFormat("[@!]-[@!]", { oCubes:value("nome"), oCubes:value("descricao")}) ) //" Cubo:"
				else
					cMsg := STR0096 + dwFormat(" [@X] ", { oDSN:value("id_table") }) + STR0098 //"Cubo (fato) "não localizado"
					eval(cbAux, IPC_ERRO, cMsg)
					//break
					exit
				endif
			endif
			
			if oConector:value("tipo") == TC_TOP_CONNECT
				eval(bLogFile, STR0010) //"Tipo conexão [ Top Connect ]"
				eval(bLogFile, STR0011 + dwFormat(" [@X] ", { oConector:value("server")}) + "]") //"Servidor ["
				eval(bLogFile, STR0012 + dwFormat(" [@X] ", { oConector:value("conex_srv")}) + "]") //"Tipo ["
				eval(bLogFile, STR0013 + dwFormat(" [@X] ", { oConector:value("banco_srv")}) + "]") //"Banco ["
				eval(bLogFile, STR0042 + dwFormat(" [@X] ", { oConector:value("alias")}) + "]") //"Alias ["
				if SGDB() == DB_ORACLE
					eval(bLogFile, STR0053 + ":" + iif(oDSN:value("optimizer"), STR0054, STR0055)) //"Processamento otimizado" //"Sim" //"Não"
				endif
				eval(bLogFile, "SQL")
				eval(bLogFile, "<code>" + oDSN:value("fullSQL")+"</code>" )
			elseif oConector:value("tipo") == TC_AP_SX
				eval(bLogFile, STR0014) //"Tipo conexão [ Protheus - SX ]"
				eval(bLogFile, STR0011 + dwFormat(" [@X] ", { oConector:value("server")}) + "]") //"Servidor ["
				eval(bLogFile, STR0017 + dwFormat(" [@X] ", { oConector:value("ambiente")}) + "]") //"Ambiente ["
				if empty(oDSN:value("empfil"))
					eval(bLogFile, STR0015 + dwFormat(" [@X]/[@X] ", { oConector:value("empresa"), oConector:value("filial")}) + "]") //"Empresa/Filial ["
				else
					eval(bLogFile, STR0015 + dwFormat(" [@X] ", { oDSN:value("empfil") }) + "]") //"Empresa/Filial ["
				endif
				if oDSN:value("embedsql")
					eval(bLogFile, STR0099 + dwFormat(" [@X] ", { oDSN:value("sql")}) + "]") //"EmbedSQL ["
				else
					eval(bLogFile, STR0042 + dwFormat(" [@X] ", { oDSN:value("alias")}) + "]") //"Alias ["
				endif
			else // TC_AP_DIRETO
				eval(bLogFile, STR0016) //"Tipo conexão [ Protheus - Direto ]"
				eval(bLogFile, STR0011 + dwFormat(" [@X] ", { oConector:value("server")}) + "]") //"Servidor ["
				eval(bLogFile, STR0017 + dwFormat(" [@X] ", { oConector:value("ambiente")}) + "]") //"Ambiente ["
				if empty(oDSN:value("empfil"))
					eval(bLogFile, STR0015 + dwFormat(" [@X]/[@X] ", { oConector:value("empresa"), oConector:value("filial")}) + "]") //"Empresa/Filial ["
				else
					eval(bLogFile, STR0015 + dwFormat(" [@X] ", { oDSN:value("empfil") }) + "]") //"Empresa/Filial ["
				endif
				eval(bLogFile, STR0043 + dwFormat(" [@X] ", { iif(!empty(oDSN:value("caminho")), oDSN:value("caminho"), oConector:value("caminho")) }) + "]") //"caminho ["
				eval(bLogFile, STR0044 + dwFormat(" [@X] ", { oDSN:value("arquivo")}) + "]") //"Arquivo ["
			endif
		else
			cMsg := STR0018 + dwformat(" [99,999] ", { anID }) +  STR0019 //"A conexão ["   //"] não foi localizada"
			eval(bLogFile, cMsg)
			eval(cbAux, IPC_ERRO, cMsg)
			//break
			exit
		endif
		
		oMakeImp := TMakeImp():New(cIPCId)
		
		nIDEstat := oMakeImp:startEstatistica(STR0100)  //"Processo de importação"
		oMakeImp:Title(cTitle)
		oMakeImp:RecLimit(oDSN:value("reclimit"))
		oMakeImp:ProcInv(oDSN:value("procinv"))
		oMakeImp:UpdMethod(oDSN:value("updMethod"))
		oMakeImp:RptInval(oDSN:value("rptInval"))
		
		if oMakeImp:RecLimit() > 0
			eval(bLogFile, DWFormat("<font color=red>"+STR0045+" [#,###,###] " + STR0046, { oMakeImp:RecLimit() })+"</font>") //"O processamento encontra-se limitado a"  //"registros"
		endif
		
		if oConector:value("tipo") == TC_TOP_CONNECT //Top Connect
			oMakeImp:Server('127.0.0.1')
			oMakeImp:Port(DWDefaultPort()) // pegar a porta que esta configurada
			oMakeImp:Environment(getEnvServer())
			oMakeImp:TopServer(oConector:value("server"))
			oMakeImp:TopTipo(oConector:value("conex_srv"))
			oMakeImp:TopBanco(oConector:value("banco_srv"))
			oMakeImp:TopAlias(oConector:value("alias"))
			oMakeImp:SQL(oDSN:value("sql"))
			oMakeImp:Empresa(DWEmpresa())
			oMakeImp:Filial(DWFilial())
			if !empty(oDSN:value("sqlstruc"))
				oMakeImp:SQLStruct(oDSN:value("sqlstruc"))
			endif
			if SGDB() == DB_ORACLE .or. SGDB() == DB_INFORMIX
				oMakeImp:Optimizer(oDSN:value("Optimizer"))
			endif
		else
			// se o nome do servidor ja tiver a porta, recupera a porta definida na conexão
			if at(":", oConector:value("server")) > 0
				aServer := DwToken(oConector:value("server"), ":", .f.)
				oMakeImp:Server(aServer[1])
				oMakeImp:Port(DWVal(aServer[2]))
			else
				oMakeImp:Server(oConector:value("server"))
				oMakeImp:Port(DWDefaultPort()) // pegar a porta que esta configurada
			endif
			oMakeImp:Environment(oConector:value("ambiente"))
			if oConector:value("tipo") == TC_AP_SX // Protheus - SX
				oMakeImp:ExecEmbed(oDSN:value("sql"))
				oMakeImp:EmbedSQL(oDSN:value("embedsql"))
				if empty(oDSN:value("empfil"))
					oMakeImp:Empresa(oConector:value("empresa"))
					oMakeImp:Filial(oConector:value("filial"))
				else
					oMakeImp:Empresa(dwEmpresa(oDSN:value("empfil")))
					oMakeImp:Filial(dwFilial(oDSN:value("empfil")))
				endif
				oMakeImp:FileSource(oDSN:value("alias"))
			else
				if empty(oDSN:value("empfil"))
					oMakeImp:Empresa(oConector:value("empresa"))
					oMakeImp:Filial(oConector:value("filial"))
				else
					oMakeImp:Empresa(dwEmpresa(oDSN:value("empfil")))
					oMakeImp:Filial(dwFilial(oDSN:value("empfil")))
				endif
				oMakeImp:WorkDir(iif(!empty(oDSN:value("caminho")), oDSN:value("caminho"), oConector:value("caminho")))
				oMakeImp:FileSource(oDSN:value("arquivo"))
			endif
		endif
		oMakeImp:ProcCons(oDSN:value("procCons"))
		oMakeImp:DSNID(anID)
		if oDSN:value("tipo") == "D"
			oMakeImp:DimID(oDim:value("id"))
			oMakeImp:CubeID(0)
		else
			oMakeImp:DimID(0)
			oMakeImp:CubeID(oCubes:value("id"))
		endif
		
		if oDSN:value("id_b_exec") != 0 .and. !empty(oDSN:value("beforeExec"))
			oMakeImp:BeforeExec(oMakeImp:prepEvent(oDSN:value("beforeExec")))
		endif
		if oDSN:value("id_a_exec") != 0 .and. !empty(oDSN:value("afterExec"))
			oMakeImp:AfterExec(oMakeImp:prepEvent(oDSN:value("afterExec")))
		endif
		if oDSN:value("id_filter") != 0 .and. !empty(oDSN:value("filter"))
			oMakeImp:Filter( prepZapFilter(oDSN:value("filter"), oDSN:value("id_table"), oDSN:value("tipo")) )
		endif
		if oDSN:value("id_forzap") != 0 .and. !empty(oDSN:value("forzap"))
			oMakeImp:ForZap(oDSN:value("forZap"))
		endif
		if oDSN:value("id_valida") != 0 .and. !empty(oDSN:value("valida"))
			oMakeImp:Validate(__compstr(oDSN:value("valida")))
			oMakeImp:ValidaStr(oDSN:value("valida"))
		endif
		
		eval(bLogFile, "</blockquote>"+buildSubTitle(STR0101)+"<blockquote>")  //"Ocorrências no processamento"
		
		eval(cbAux, IPC_ETAPA, , IMP_ETA_FIM)
		
		eval(cbAux, IPC_ETAPA, STR0102, IMP_ETA_INICIO)  //"Conectando ao servidor de dados"
		if oMakeImp:Connect()
			eval(bLogFile, STR0020) //"Conexão efetuada"
			
			if oConector:value("tipo") == TC_TOP_CONNECT
				if !oMakeImp:ValidSQL()
					cMsg := oMakeImp:LastMsg()
					exit
				endif
				cType := oMakeImp:FileType()
			else
				if oConector:value("tipo") == TC_AP_SX
					oMakeImp:UseSX(.t.)
				endif
				
				if oMakeImp:FileExist()
					cType := oMakeImp:FileType()
					do case
						case cType == FT_TEXT
						case cType == FT_XBASE
							eval(bLogFile, STR0103 + dwFormat(" [@X] ", { oMakeImp:WorkDir() +  oMakeImp:FileSource()}) + STR0104)   //"Arquivo xBase"   //"existe"
						case cType == FT_SX
							if !oMakeImp:EmbedSQL()
								eval(bLogFile, STR0105 + dwFormat(" [@X] ", { oMakeImp:WorkDir() + "\" + oMakeImp:FileSource()}) + STR0106)   //"Arquivo"   //"via SX, existe"
							endif
						case cType == FT_ARRAY
						otherwise
							cMsg := oMakeImp:LastMsg()
							eval(bLogFile, "<b>"+cMsg+"</b>")
							exit
					endcase
				else
					cMsg := oMakeImp:LastMsg()
					eval(bLogFile, "<b>"+cMsg+"</b>")
					exit
				endif
			endif
			
			//cria/verifica arquivo para controle de importação
			oFileCubo := TDWFileIO():New(DwTempPath() + "\DWIMP" + dwInt2Hex(oCubes:value("id"), 8) + ".dwCubo")
			if oFileCubo:Exists()
				oFileCubo:Append(FO_EXCLUSIVE)
			else
				oFileCubo:Create(FO_EXCLUSIVE + FO_WRITE)
			endif
			
			eval(cbAux, IPC_ETAPA, , IMP_ETA_FIM)
			
			if !oMakeImp:PrepWorkfile(cbAux, bLogFile)
				cMsg := oMakeImp:LastMsg()
				exit
			endif
			
			eval(cbAux, IPC_ETAPA, STR0107, IMP_ETA_INICIO)  //"Encerrando conexão ...."
			//fecha a conexão e apaga o arquivo de controle
			oMakeImp:Disconnect()
			oFileCubo:Close()
			oFileCubo:Erase()
			eval(bLogFile, STR0108)  //"Conexão encerrada"
			eval(cbAux, IPC_ETAPA, , IMP_ETA_MEIO)
			
			eval(cbAux, IPC_ETAPA, , IMP_ETA_FIM)
			eval(cbAux, IPC_ETAPA, STR0109, IMP_ETA_INICIO)  //"Invalidando consultas..."
			
			// Verifica se o processo nao foi abortado
			
			if !oMakeImp:flAbort
				oConsulta := InitTable(TAB_CONSULTAS)
				if oDSN:value("tipo")=="D"
					oQuery := InitQuery(SEL_CONS_DIM)
					oQuery:params(1, oDSN:value("id_table"))
					oQuery:Open()
					while !oQuery:Eof()
						aAdd(aProcCons, { oQuery:value("id"), oQuery:value("nome"), dwVal(oQuery:value("tipo")) })
						oQuery:_Next()
					enddo
					oQuery:Close()
				else
					oQuery := TQuery():New(DWMakeName("TRA"))
					oQuery:Makedistinct(.t.)
					oQuery:FromList(TAB_CONSULTAS + " B,"+ TAB_CONSTYPE + " C")
					oQuery:FieldList("B.ID, B.NOME, C.TIPO, B.EXCEL, B.ID_USER")
					oQuery:WhereClause("B.ID_CUBE = " + dwStr(oDSN:value("id_table")) + " and " + ;
					"C.ID_CONS = B.ID")
					oQuery:OrderBy("B.NOME")
					oQuery:Open()
					while !oQuery:Eof()
						aAdd(aProcCons, { oQuery:value("id"), oQuery:value("nome"), dwVal(oQuery:value("tipo")), oQuery:value("Excel") == "T", oQuery:value("ID_USER") })
						oQuery:_Next()
					enddo
					oQuery:Close()
				endif
				
				eval(bLogFile, STR0058) //"As sequintes consultas foram afetadas por esta importação."
				
				eval(cbAux, IPC_ETAPA, , IMP_ETA_FIM)
				eval(cbAux, IPC_ETAPA, STR0109, IMP_ETA_INICIO)  //"Invalidando consultas"
				nOldCons := iif(len(aProcCons) > 0, aProcCons[1, 1],0)
				cAux := iif(len(aProcCons) > 0, "... " + aProcCons[1, 2] + " ","")
				for nInd := 1 to len(aProcCons)
					if DWKillApp()
						exit
					endif
					if nOldCons <> aProcCons[nInd, 1]
						if oConsulta:Seek(1, { aProcCons[nInd, 1] })
							oConsulta:update({{ "valida", .f. }, { "valgra", .f. }})
						endif
						cAux := strTran(cAux, ")(", " e ")
						eval(cbAux, IPC_BUFFER, .t.)
						eval(cbAux, IPC_ETAPA, , nInd / len(aProcCons))
						eval(cbAux, IPC_AVISO, cAux)
						eval(cbAux, IPC_BUFFER, .F.)
						eval(bLogFile, cAux)
						nOldCons := aProcCons[nInd, 1]
						cAux := "... " + aProcCons[nInd, 2] + " "
					endif
					if aProcCons[nInd, 3] == 1
						cAux += "("+STR0061+")"  //"tabela"
					endif
					if aProcCons[nInd, 3] == 2
						cAux += "("+STR0062+")"  //"gráfico"
					endif
				next
				if !empty(cAux)
					if oConsulta:Seek(1, { nOldCons })
						oConsulta:update({{ "valida", .f. }, { "valgra", .f. }})
					endif
					eval(bLogFile, cAux)
				endif
				eval(cbAux, IPC_ETAPA, , IMP_ETA_FIM)
				
				// Verifica se nao foi abortado por erro
				
				if oMakeImp:ProcCons()
					eval(cbAux, IPC_ETAPA, STR0110, IMP_ETA_INICIO) //"Processando consultas..."
					eval(bLogFile, STR0111) //"Processando consultas apos importação"
					dwStatOn (STR0111) //"Processando consultas apos importação"
					
					for nInd := 1 to len(aProcCons)
						lProc := .f.
						oCons := TConsulta():New(aProcCons[nInd, 1], aProcCons[nInd, 3])
						eval(cbAux, IPC_BUFFER, .t.)
						if aProcCons[nInd, 3] == 1 .and. oCons:HaveTable()
							cMsg := aProcCons[nInd, 2] + " ("+STR0061+")"  //"tabela"
							eval(bLogFile, aProcCons[nInd, 2] + " ("+STR0061+")")  //"tabela"
							lProc := .t.
						endif
						if aProcCons[nInd, 3] == 2 .and. oCons:HaveGraph()
							cMsg := aProcCons[nInd, 2] + " ("+STR0062+")"  //"gráfico"
							lProc := .t.
						endif
						cPrev := ""
						cDuracao := ""
						if len(aProcCons) > 0
							dwPrevTime(dInic, cInic, nInd, len(aProcCons), @cPrev, @cDuracao)
						endif
						eval(cbAux, IPC_BUFFER, .t.)
						eval(cbAux, IPC_ETAPA, , nInd / len(aProcCons))
						//						eval(cbAux, IPC_TEMPO, ctod(dInic) + " " + cInic, cDuracao, cPrev)
						
						eval(cbAux, IPC_AVISO, STR0112 + cMsg + dwFormat("([999]/[999])", {nInd, len(aProcCons)}))  //"Processando "
						eval(bLogFile, STR0112 + cMsg)  //"Processando "
						eval(cbAux, IPC_BUFFER, .f.)
						
						if lProc
							__DWErroCtrl := .t.
							begin sequence
  							oCons:BuildTable()
	  					recover
		  					eval(bLogFile, STR0113)  //"Ocorrreu um erro durante o processamento da consulta"
			  				eval(bLogFile, "<blockquote>"+__DWHtml+"</blockquote>")
				  			eval(cbAux, IPC_ERRO, STR0113) //"Ocorrreu um erro durante o processamento da consulta"
							end sequence
							__DWErroCtrl := .f.
						endif
						if DWKillApp()
							eval(cbAux, IPC_AVISO, STR0114)  //"Processo cancelado por solicitação do servidor"
							exit
						endif
					next
					dwStatOff()					
				endif
                                                               
				If ( ! oDSN:value("tipo")=="D" .And. ( ! oMakeImp:flAbort .Or. oMakeImp:flWarning ) )
					dwStatOn(STR0125) //"Atualizando data de importação do cubo." 
					
					If ( oCubes:Seek(1, { oDSN:value("id_table") } ) )
						oCubes:update({ {"dt_process", date()}, {"hr_process",time()} })    
					Endif  
					
					dwStatOff()
				EndIf	
			endif
			
			eval(cbAux, IPC_ETAPA, , IMP_ETA_FIM)
			 
			//Verifica o status da importacao
			if !oMakeImp:flAbort .and. !oMakeImp:flWarning
				eval(bLogFile, STR0115) //"Processo concluído com sucesso"
			elseif oMakeImp:flWarning
				eval(bLogFile, STR0116) //"Processo concluído com <b>restrições</b>.<br>Favor verificar log."
			else
				eval(bLogFile, STR0117) //"Processo finalizado com erro. Favor verificar log."
			endif
   
			oMakeImp:stopEstatistica(nIDEstat)
			
			eval(cbAux, IPC_ETAPA, STR0118, IMP_ETA_INICIO)  //"Estatísticas"
			
			eval(bLogFile, "</blockquote>"+buildSubTitle(STR0119)+"<blockquote>")  //"Estatísticas de processamento"
			aEstat := oMakeImp:Estatisticas()
			eval(cbAux, IPC_ETAPA, , IMP_ETA_1Q)
			aAux := {}
			for nInd := 1 to len(aEstat)
				if valtype(aEstat[nInd]) == "A"
					eval(bLogFile, dwFormat("[@X]</br>&nbsp;&nbsp;&nbsp;[99/99/9999] [99:99:99] - [99/99/9999] [99:99:99] ([@X])", aEstat[nInd]))
				else
					eval(bLogFile, "&nbsp;&nbsp;&nbsp;.&nbsp;"+dwStr(aEstat[nInd]))
				endif
			next
			eval(cbAux, IPC_ETAPA, , IMP_ETA_2Q)
			for nInd := 1 to len(aAux)
				if valtype(aAux[nInd]) == "A"
					eval(bLogFile, dwFormat("[@X]</br>&nbsp;&nbsp;&nbsp;[99/99/9999] [99:99:99] - [99/99/9999] [99:99:99] ([@X])", aAux[nInd]))
				else
					eval(bLogFile, "&nbsp;&nbsp;&nbsp;.&nbsp;"+aAux[nInd])
				endif
			next
			eval(cbAux, IPC_ETAPA, , IMP_ETA_FIM)
			cMsg := ""
		else
			cMsg := "*"+oMakeImp:LastMsg()
			//break
			exit
		endif
		exit
		//recover using
	enddo
	
	if !empty(cMsg)
		eval(bLogFile, "</blockquote>"+buildSubTitle(STR0120)+"<blockquote>")  //"ERRO DURANTE PROCESSAMENTO"
		eval(bLogFile, STR0121) //"Ocorreu uma falha durante o processo de importação"
		eval(bLogFile, STR0122)  //"Entre em contato com o Administrador do sistema e comunique o erro abaixo"
		eval(bLogFile, cMsg)
		eval(cbAux, IPC_ERRO, { cLogFile })
	else
		eval(cbAux, IPC_BUFFER, .t.)
		eval(cbAux, IPC_ETAPA, , IMP_ETA_FIM)
		eval(cbAux, IPC_PROCESSO, IMP_PRO_FIM)
		eval(cbAux, IPC_BUFFER, .f.)
		sleep(3000)
		if oMakeImp:flWarning
			eval(cbAux, IPC_TERMINO_W_WARNING, { cLogFile } )
		else
			eval(cbAux, IPC_TERMINO, { cLogFile } )
		endif
	endif
	//end sequence
	
	//####TODO - verificar o processo de notificação
	//if !empty(cNotificar)
	//	eval(cbAux2, cNotificar )
	//endif
return iif(!empty(cNotificar), cLogFile, "")

static __aParams := array(IPC_SIZE_ARRAY)

static function ShowMsg(anTypeRec, axP1, axP2, axP3)

	if anTypeRec == IPC_PROCESSO .and. axP1 == IMP_PRO_INIT
		aFill(__aParams, nil)
	elseif anTypeRec == IPC_TEMPO
		if valType(__aParams[anTypeRec]) == "A"
			axP1 := isNull(axP1, __aParams[anTypeRec, 1])
			axP2 := isNull(axP2, __aParams[anTypeRec, 2])
			axP3 := isNull(axP3, __aParams[anTypeRec, 3])
		else
			__aParams[anTypeRec] := array(3)
		endif
		__aParams[anTypeRec, 1] := isNull(axP1, __aParams[anTypeRec, 1])
		__aParams[anTypeRec, 2] := isNull(axP2, __aParams[anTypeRec, 2])
		__aParams[anTypeRec, 3] := isNull(axP3, __aParams[anTypeRec, 3])
	endif
	
	sendIpcMsg(cIPCId, anTypeRec, axP1, axP2, axP3)

return

static function atzInfo(aaInfo, abLogFile)

	ShowMsg(IPC_INFO, aaInfo)
	
	if valType(abLogFile) == "B"
		eval(abLogFile, "</blockquote>"+buildSubTitle(STR0123)+"<blockquote>")  //"Informações"
		aEval(aaInfo, { |x| eval(abLogFile, x)})
	endif

return

/**
Function para "limpar" a expressão AdvPL de filtros para fonte de dados. Limpar nesse caso significa, retirar os labels
contendo os nomes das dimensões e do lable "FATO" para quando se utilizar atributos das dimensões e indicadores
do cubo, respectivamente.
Exemplo: FATO->QUANT > 500 .AND. CLIENTES->ESTADO == 'SP', será transformado em QUANT > 500 .AND. ESTADO == 'SP'
Param: acCond, string, contém a expressão
		anObjId, numérico, id do objeto em questão, podendo ser de dimensão ou cubo
		acObjType, string, dimensão ou cubo
		acCondReplace, string, string de substituição. Padrão: VAZIO
*/
function prepZapFilter(acCond, anObjId, acObjType, acCondReplace)
	
	Local oObj
	Local aObjItera := {}
	Local nInd
	
	default acCondReplace := ""
	
	If (acObjType == OBJ_DIMENSION)
		oObj := InitTable(TAB_DIMENSAO)
		If oObj:Seek(1, { anObjId })
			aAdd(aObjItera, oObj:value("nome"))
		EndIf
	Else
		aAdd(aObjItera, "FATO")
		oObj := InitTable(TAB_FACTFIELDS)
		If oObj:Seek(2, { anObjId })
			While !oObj:EoF() .and. oObj:value("id") == anObjId
				aAdd(aObjItera, oObj:value("nome"))
				oObj:_Next()
			EndDo
		EndIf
		
		oObj := InitTable(TAB_FACTVIRTUAL)
		If oObj:Seek(2, { anObjId })
			While !oObj:EoF() .and. oObj:value("id") == anObjId
				aAdd(aObjItera, oObj:value("nome"))
				oObj:_Next()
			EndDo
		EndIf
		
		oObj := InitTable(TAB_DIM_CUBES)
		If oObj:Seek(2, { anObjId })
			While !oObj:EoF() .and. oObj:value("id_cube") == anObjId
				acCond := prepZapFilter(acCond, oObj:value("id_dim"), "D")
				oObj:_Next()
			EndDo
		EndIf
	EndIf
	
	for nInd := 1 to len(aObjITera)
		acCond := strTran(acCond, aObjItera[nInd]+"->", acCondReplace)
	next

return acCond
