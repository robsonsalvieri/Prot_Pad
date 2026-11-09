#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'OFIA514.CH'

/*/{Protheus.doc} OFIA514
	Scheduler COMBO geracao de arquivos DPE por conta
	Roda em loop verificando geracoes via DMS_DPMSched por conta
	e dispara jobs de geracao DPE.

	@author Vinicius Gati
	@since  30/04/2026
/*/
Function OFIA514(aParam)
	Local nStat
	if valtype(aParam) != "U"
		Prepare Environment Empresa aParam[1] Filial aParam[2] Modulo "PEC"
	endif
	Private oUtil           := DMS_Util():New()
	Private oSqlHlp         := DMS_SqlHelper():New()
	Private oArHlp          := DMS_ArrayHelper():New()
	Private oLogger         := DMS_Logger():New("OFIA514.LOG")
	Private oDpm            := OFJDRpmConfig():New()
	Private lIsDebug        := "OFIA514" $ GetNewPar("MV_MILDBG", "NAO") .OR. "*DPM*" $ GetNewPar("MV_MILDBG", "NAO")
	Private lForcSch        := "OFIA514SCH" $ GetNewPar("MV_MILDBG", "NAO")
	Private lProcForce      := lIsDebug .AND. "FORCE" $ GetNewPar("MV_MILDBG", "NAO")
	Private cTblLogCod
	Private cHora1, cHora2
	Private lNovoCombo      := GetNewPar("MV_MIL0210", .F.)
	Private lDebug := .T.

	conout("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
	conout("~~~~~~~~ INICIANDO OFIA514 ~~~~~~~~~~~~~")
	conout("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")

	if ! lNovoCombo
		UserException(STR0001) /* "Somente clientes combo podem executar esta rotina." */
	endif

	if ! oDpm:Ready(.F.)
		if ! isBlind()
			MsgInfo(oDpm:cLastError, STR0002) /* "Informacao" */
		endif
		Return .F.
	endif

	cTblLogCod := oLogger:LogToTable({;
		{'VQL_AGROUP'     , 'OFIA514'                                      },;
		{'VQL_TIPO'       , 'LOG_EXECUCAO'                                 },;
		{'VQL_DADOS'      , 'MODO:' + IIF(isBlind(), STR0005 /*Agendado*/, STR0006 /*Normal*/) } ; 
	})

	If FM_SQL(" SELECT COUNT(VQL_DADOS) FROM " + RetSqlName('VQL') + " WHERE D_E_L_E_T_ = ' ' AND (VQL_AGROUP LIKE '%DPMC%' OR VQL_AGROUP = 'SCHEDULER') AND VQL_TIPO = 'PATH_DPMSCHED_F' ") > 0
		TcLink()

		nStat := TcSqlExec(" UPDATE " + RetSqlName("VQL") + " SET VQL_TIPO = 'PATH' WHERE D_E_L_E_T_ = ' ' AND (VQL_AGROUP LIKE '%DPMC%' OR VQL_AGROUP = 'SCHEDULER') AND VQL_TIPO = 'PATH_DPMSCHED_F' ")
		If nStat >= 0
			ConOut(STR0004) //"Compatibilizador.... Os dados da tabela VQL onde VQL_TIPO era 'PATH_PMSCHED_F' foram alterados para 'PATH'."
		Endif

		TCUnlink()
	Endif

	If ! isBlind()
		Processa( {|lAbort| OA5140014_SchedulerLoop() } )
	Else
		OA5140014_SchedulerLoop()
	EndIf

	oLogger:CloseOpened(cTblLogCod)
Return

/*/{Protheus.doc} OA5140014_SchedulerLoop
	Loop infinito de processamento por conta

	Percorre todas as contas RPM, verifica geracoes pendentes
	no DMS_DPMSched e dispara jobs de geracao DPE.

	@author Vinicius Gati
	@since  30/04/2026
/*/
Static Function OA5140014_SchedulerLoop()
	Local aContas  := {}
	Local nIdx     := 1
	Local nIdx2    := 1
	Local nRecVQL  := 0
	Local oAuth2   := OFOAUTH2():New()

	cHora1 := TIME()

	Do While .T. .AND. FM_SQL('SELECT count(*) FROM ' + RetSqlName('VQL') + " WHERE VQL_AGROUP = 'OFIA514' AND VQL_TIPO = 'SCH_STOP' AND D_E_L_E_T_ = ' ' ") == 0
		if dDatabase != DATE()
			dDatabase := DATE()
		endif

		sleep(60000)
		If Empty(cHora2)
			cHora2 := TIME()
		Else
			cHora1 := STRTRAN( ALLTRIM(TRANSFORM(SOMAHORAS(LEFT(cHora2,5), "00:01"), '@E 9999999.99')), ',', ':' ) + ":00"
			cHora1 := IIF( LEN(chora1) == 7, "0" + cHora1, cHora1 )
			cHora2 := TIME()
		EndIf

		conout("DPMSCHED - " + STR0007 + ": " + cHora1 + " e " + cHora2)

		aContas := OA5120074_BuscaContasRPM()
		for nIdx := 1 to len(aContas)
			cConta := aContas[nIdx]

			oSched  := DMS_DPMSched():New(cConta)
			aGerar  := oSched:WhatToGen( cHora1, cHora2 )
			nRecVQL := oSched:GetRegHoraExec()

			conout( "DPMSCHED - "+STR0011+": " + cConta + " - "+STR0012+": " + ALLTRIM(STR(LEN(aGerar))) ) //Conta: | Geracoes:

			for nIdx2 := 1 to LEN(aGerar)
				cTipo := aGerar[nIdx2]:cTipo
				conout(STR0008+" - Emp: " + cEmpAnt + " Filial: " + xFilial('VS1') + " Conta: " + cConta) //"Executando thread"
				conout("Environment: " + GetEnvServer())
				StartJob("OA5140034_DPEGeneration", GetEnvServer(), .F., { cEmpAnt, xFilial('VS1'), cConta, cTipo, nRecVQL, cConta })
			Next
		next

		oAuth2:RenewTokens()
	End

	TcSqlExec('UPDATE ' + RetSqlName('VQL') + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE VQL_AGROUP = 'OFIA514' AND VQL_TIPO = 'SCH_STOP' AND D_E_L_E_T_ = ' ' ")
	if ! isBlind()
		MSGINFO(STR0003, STR0002)
	EndIf
	conout("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
	conout("~~~~~~~~ FINALIZANDO OFIA514 ~~~~~~~~~~")
	conout("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
Return

/*/{Protheus.doc} SchedDef
	Funo padro scheduler

	@author Vinicius Gati
	@since 05/05/2025
	@type function
/*/
Static Function SchedDef()
	Local aParam := {;
		"P",;
		"",;
		"",;
		"",;
		"" ;
	}
Return aParam

/*/{Protheus.doc} OA5140034_DPEGeneration
	Job de geracao DPE por conta (chamado via StartJob)

	Recebe parametros do scheduler e dispara a geracao de Parts Data
	para uma conta especifica ou para todas as contas.

	@author Vinicius Gati
	@since  30/04/2026
/*/
Function OA5140034_DPEGeneration(aParams)
	Local cConta := ""
	Local nX := 1

	Prepare Environment Empresa aParams[1] Filial aParams[2] Modulo "PEC"

	if len(aParams) >= 6 .and. !empty(aParams[6])
		cConta := aParams[6]
	endif

	if empty(cConta)
		aContas := OA5120074_BuscaContasRPM()
		for nX := 1 to len(aContas)
			oJdConfig := OFJDConfig():New(, aContas[nX])
			jFil := oJdConfig:GetFiliais()[1]
			cFilAnt := jFil["FILIAL"] // só pra setar uma filial da conta qualquer pois pode ser que pega grupo diferente dependendo da config

			OFIA504(aParams, .t., "", aContas[nX])
		next
	else
		conout(STR0009 + " :" + aParams[4] + STR0011 +": " + cConta) //"Iniciando Geracao de Parts Data via JDPrism tipo" "Conta"
		OFIA504(aParams, .t., "", cConta)
	endif

	OA5140044_MarcaFlag(aParams)
Return .T.

/*/{Protheus.doc} OA5140044_MarcaFlag
	Marca flags de processamento no VQL apos geracao

	Atualiza o campo VQL_DADOS da linha de agendamento
	e remove linhas de inicializacao (SCHED_I) concluidas.

	@author Vinicius Gati
	@since  30/04/2026
/*/
Static Function OA5140044_MarcaFlag(aParams)
	if Empty(aParams[4])
		cTipo := "I"
	Else
		cTipo := aParams[4]
	EndIf
	conout(STR0010 + " :" + aParams[4]) //Geracao de Parts Data via JDPrism tipo

	If !Empty(aParams[4]) .and. aParams[4] <> "D"
		DbSelectArea("VQL")
		VQL->(DbGoTo(aParams[5]))
		cDados := StrTran(VQL->VQL_DADOS,Subs(VQL->VQL_DADOS,1,1),"D")
		RecLock("VQL",.f.)
		VQL->VQL_DADOS := cDados
		MsUnLock()
	EndIf

	if TCSQLEXEC(" SELECT COUNT(*) FROM "+RetSqlName('VQL')+" WHERE VQL_AGROUP = '"+IIF(EMPTY(aParams[3]), "", aParams[3])+"' AND VQL_TIPO = 'SCHED_I' AND VQL_DATAF = ' ' AND D_E_L_E_T_ = ' ' ") >= 0
		cTipo := "I"
		TCSQLEXEC(" UPDATE "+RetSqlName('VQL')+" SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE VQL_AGROUP = '"+IIF(EMPTY(aParams[3]), "", aParams[3])+"' AND VQL_TIPO = 'SCHED_I' AND VQL_DATAF = ' ' AND D_E_L_E_T_ = ' ' ")
	endif
Return
