/*
// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : SigaDW
// Fonte  : DWStartSyncEmpFil - executa a sincronização da empresa/filial e o
//          dicionário de dados
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 30.01.07 | 0548-Alan Candido | Versão 3
// 18.11.08 | 0548-Alan Candido | FNC 00000005741/2008 (P10)
//          |                   | Ajuste em mensagens de log e na sua apresentação
// 15.12.08 | 0548-Alan Candido | FNC 09025/2008 (8.11) e 09034/2008 (10)
//          |                   | Adequação de geração de máscara em campos numéricos e datas, 
//          |                   | para respeitar o formato conforme idioma 
//          |                   | (chave RegionalLanguage na sessão do ambiente).
// --------------------------------------------------------------------------------------
*/
#include "dwincs.ch"
#include "dwIdProcs.ch"
#include "dwSyncEmpFil.ch"

function DWStartSyncEmpFil(acLogFile, alFalseStart)

	default alFalseStart := .f.
	
	acLogFile := "DWSYNC"+dwEncodeParm("", oSigaDW:DWCurr()[2]) + ".LOG"
	
	if !alFalseStart
		dwStartJob("DWSyncEmpFil", {oSigaDW:DWCurr()[2], acLogFile},,.t.)
	endif
	
return .t.
	
function DWSyncEmpFil(acDW, acLogFile)
	local oQuery := initQuery(SEL_DSN_EMPFIL)
	local cRet := "", lRet := .t.
	local cTo, oFile, lErro := .f.
	local cTitulo, aAux, lOk
	local cProcesso := STR0001 //###"SINCRONIZAÇÃO EMPRESA/FILIAL"
	local aAlias := {}, oConexao
	local aRet, aRet2, nInd, nInd2, nInd3
	local oTabSX2, oTabSX9, cMsg
	local nTotRegs, nRegsProc
	local dInic := date(), cInic := time()
	local cPrev := "", cDuracao := ""
	local oldEmpFil := "**/**",  nTotEmpFil, nEmpFil := 0
	
	if valtype(acDW) == "A"
		return dwSyncEmpFil(acDW[1], acDW[2])
	endif
	
	oFile := TDWFileIO():New(DwTempPath() + "\" + acLogFile)
	
	if oFile:Exists()
		lOk := oFile:Append(FO_EXCLUSIVE)
	else
		lOk := oFile:Create(FO_EXCLUSIVE + FO_WRITE)
	endif
	
	if lOk
		DWLog(cProcesso + " - " + STR0002, "DW:" + acDW, "Log:" + oFile:Filename()) //###"Iniciando processo"
		SigaDWStart(,.T.)
		if !(valType(oUserDW) == "O")
			oUserDW := TDWUser():New()
		endif
		if valType(oSigaDW) == "U"
			oFile:WriteLN(STR0003) //###"ERRO: Não foi possivel inicializar gerenciador do SigaDW"
		elseif valType(oUserDW) == "U"
			oFile:WriteLN(STR0004) //###"ERRO: Não foi possivel obter/inicializar informações sobre usuário"
		else
			oUserDW:foUsers:seek(2, { "DWADMIN" } )
			oUserDW:ChangeUser(oUserDW:foUsers:value("id"))
		endif
		
		oSigaDW:SelectDW(acDW)
		oFile:WriteLN("------------------------------")
		oFile:WriteLN(dwFormat(STR0005 + " [99/99/99] as [@X]", { dInic, cInic})) //###"Iniciado em"
		oFile:WriteLN(dwConcatWSep(CRLF, cProcesso + " - " + STR0002, "DW:" + acDW)) //###"Iniciando processo"
		
		begin sequence
			oConexao := oSigaDW:Connections()
			oTabSX2 := initTable(TAB_SX2)
			oTabSX9 := initTable(TAB_SX9)
			
			oTabSX2:zap()
			oTabSX9:zap()
			
			oFile:WriteLN(STR0006) //###"Preparando alias"
			oQuery := initQuery(SEL_DSN_ALIAS)
			oQuery:Open()
			while !oQuery:eof()
				aAdd(aAlias, { oQuery:value("alias"), {} } )
				oQuery:_next()
			enddo
			oQuery:Close()

			oQuery := initQuery(SEL_DSN_EMPFIL)
			nTotEmpFil := oQuery:recCount() + 1
			nRegsProc := 0
			
			sendIpcMsg(acLogFile, IPC_PROCESSO, SYNC_PRO_INICIO, 0)
			sendIpcMsg(acLogFile, IPC_TEMPO, dtoc(dInic) + " " + cInic)
			
			cMsg := STR0007 //###"Preparando processamento"
			oQuery:Open()
			nTotRegs := len(aAlias) * nTotEmpFil
			nRegsProc := 0
			while !oQuery:eof() .and. !dwKillApp()
				if oQuery:value("empfil") <> oldEmpFil
					nEmpFil++
					sendIpcMsg(acLogFile, IPC_PROCESSO, nEmpFil / nTotEmpFil)
				endif
				
				if !empty(oQuery:value("empfil"))
					oConexao:Seek(1, { oQuery:value("id_connect") } )
					aParams := {}
					aAdd(aParams, 1)
					aAdd(aParams, oConexao:value("server"))
					aAdd(aParams, oConexao:value("ambiente"))
					aAdd(aParams, dwEmpresa(oQuery:value("empfil")))
					aAdd(aParams, dwFilial(oQuery:value("empfil")))
					aAdd(aParams, nil)

					cMsg := dwFormat(STR0008 + " [@X] " + STR0009 + " [@X]", { dwEmpresa(oQuery:value("empfil")), dwFilial(oQuery:value("empfil")) }) //###"Empresa"###"Filial"
					sendIpcMsg(acLogFile, IPC_ETAPA, cMsg, nRegsProc / nTotRegs)
					
					aRet := DWWaitJob(JOB_BASESXS, aParams, , .t.)
					
					if valType(aRet) == "A" .and. valType(aRet[1]) == "A"
						// cada item de aRet -> (1)X2_CHAVE, (2)X2_ARQUIVO, (3)X2_NOME, (4)X2_PATH, (5)X2_MODO
						aAux := dwToken(oQuery:value("empfil"), "/", .F.)
						for nInd := 1 to len(aAlias)
							if dwKillApp()
								exit
							endif
							nPos := ascan(aRet, { |x| x[1] == aAlias[nInd, 1]})
							nRegsProc++
							if nPos <> 0
								cMsg := dwFormat(STR0010 + " [@X] ([@X]) [999]/[999] ([999.999%])", { alltrim(aRet[nPos, 3]), aRet[nPos, 1], nRegsProc, nTotRegs, nRegsProc / nTotRegs * 100 }) //###"Tabela"
								sendIpcMsg(acLogFile, IPC_BUFFER, .t.)
								sendIpcMsg(acLogFile, IPC_ETAPA, dwFormat(STR0008 + " [@X] " + STR0009 + " [@X]", aAux), nRegsProc / nTotRegs) //###"Empresa"###"Filial"
								sendIpcMsg(acLogFile, IPC_AVISO, cMsg)
								sendIpcMsg(acLogFile, IPC_BUFFER, .f.)
								
								aAdd(aAlias[nInd, 2], { aRet[nPos, 5], trim(aRet[nPos, 4]) + "\" + trim(aRet[nPos, 2]), oQuery:value("empfil") })
								aParams := {}
								aAdd(aParams, 11)
								aAdd(aParams, oConexao:value("server"))
								aAdd(aParams, oConexao:value("ambiente"))
								aAdd(aParams, dwEmpresa(oQuery:value("empfil")))
								aAdd(aParams, dwFilial(oQuery:value("empfil")))
								aAdd(aParams, aAlias[nInd, 1])
								oSigaDW:Log(STR0011, dwStr(aParams, .t.)) //###"Processando sincronização SX2/SX9"
								
								aRet2 := DWWaitJob(JOB_BASESXS, aParams, , .t.)
								if valType(aRet2) == "U"
									break
								endif
								
								// cada item de aRet2 -> (1)X9_DOM, (2)X9_CDOM, (3)X9_EXPDOM, (4)X9_EXPCDOM
								for nInd2 := 1 to len(aRet2)
									if ascan(aAlias, { |x| x[1] == aRet2[nInd2, 1]}) > 0
										aValues := {}
										aAdd(aValues, { "dom" , aRet2[nInd2, 1] } )
										aAdd(aValues, { "cdom", aRet2[nInd2, 2] } )
										aAdd(aValues, { "expdom", aRet2[nInd2, 3] } )
										aAdd(aValues, { "expcdom", aRet2[nInd2, 4] } )
										if !oTabSX9:Seek(2, { aRet2[nInd2, 2], aRet2[nInd2, 1] })
											oTabSX9:append(aValues)
										else
											oTabSX9:update(aValues)
										endif
									endif
								next
							endif
							
							dwPrevTime(dInic, cInic, nRegsProc*nEmpFil, nTotRegs*(nTotEmpFil-1), @cPrev, @cDuracao)
							sendIpcMsg(acLogFile, IPC_TEMPO, dtoc(dInic) + " " + cInic, cDuracao, cPrev)
						next
					endif
				endif
				sendIpcMsg(acLogFile, IPC_ETAPA, , SYNC_ETA_FIM)
				oQuery:_next()
			enddo
			oQuery:Close()
			
			if !dwKillApp()
				sendIpcMsg(acLogFile, IPC_ETAPA, , SYNC_ETA_INICIO)
				sendIpcMsg(acLogFile, IPC_AVISO, STR0012 + "..." ) //###"Gravando dados obtidos"
				for nInd := 1 to len(aAlias)
					for nInd2 := 1 to len(aAlias[nInd, 2])
						for nInd3 := 2 to len(aAlias[nInd, 2])
							aValues := {}
							aAdd(aValues, { "alias" , aAlias[nInd, 1] } )
							aAdd(aValues, { "empfil" , aAlias[nInd, 2, nInd2, 3] } )
							if aAlias[nInd, 2, nInd2, 1] == MODO_COMP_FILIAL .and. (aAlias[nInd, 2, nInd2] == aAlias[nInd, 2, nInd3]) .and.;
								!(left(aAlias[nInd, 2, nInd2, 3], 2) == left(aAlias[nInd, 2, nInd3, 3], 2))
								aAdd(aValues, { "modo" , MODO_COMP_EMPRESA } )
							else
								aAdd(aValues, { "modo" , aAlias[nInd, 2, nInd2, 1] } )
							endif
							if !oTabSX2:Seek(2, { aAlias[nInd, 1], aAlias[nInd, 2, nInd2, 3] })
								oTabSX2:append( aValues)
							else
								oTabSX2:update( aValues)
							endif
						next
						cMsg := dwFormat(STR0012 + " [@X] ([999]/[[999]] ([999.999%])", { aAlias[nInd, 1], nInd, len(aAlias), nInd / len(aAlias) * 100 })
						sendIpcMsg(acLogFile, IPC_AVISO, cMsg)
					next
				next
				sendIpcMsg(acLogFile, IPC_ETAPA, , SYNC_ETA_FIM)
				sendIpcMsg(acLogFile, IPC_PROCESSO, SYNC_PRO_FIM)
			else
				sendIpcMsg(acLogFile, IPC_AVISO, STR0013) //###"Processo cancelado por solicitação do servidor"
				oFile:WriteLN(STR0013) //###"Processo cancelado por solicitação do servidor"
				oFile:WriteLN(STR0014) //###"Favor verificar o log de console do servidor Protheus, para obter detalhes"
			endif
		recover
			lErro := .t.
			oFile:WriteLN(STR0015) //###"Ocorreu um erro durante o processamento."
			oFile:WriteLN(STR0014) //###"Favor verificar o log de console do servidor Protheus, para obter detalhes")
		end sequence

		oFile:WriteLN("------------------------------")
		oFile:WriteLN(dwFormat(STR0016 + " [99/99/99] [@X]", { date(), time()})) //###"Finalizado em"
		oFile:WriteLN(dwFormat(STR0017 + " [@X]", { DWElapTime(dInic, cInic, date(), time())})) //###"Tempo total de processamento"
		oFile:WriteLN("##############################")
		oFile:Close()

		if lErro
			DWLog(cProcesso + " - " + STR0018, "DW:" + acDW, "Log:" + oFile:Filename()) //###"Processo finalizado com ERRO"
			sendIpcMsg(acLogFile, IPC_ERRO, { oFile:Filename() })
		else
			DWLog(cProcesso + " - " + STR0019, "DW:" + acDW, "Log:" + oFile:Filename()) //###"Processo finalizado"
			sendIpcMsg(acLogFile, IPC_TERMINO, { oFile:Filename() })
		endif
	else
		DWLog(STR0020, "DW:" + acDW) //###"Processo já esta em execução"
	endif

return lRet