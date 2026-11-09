#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'OFIA627.CH'

/*/{Protheus.doc} OFIA627
	Scheduler geracao de arquivos DPE por conta
	Roda em loop verificando geracoes via DMS_DPMSched por conta
	e dispara jobs de geracao DPE.

	@author Vinicius Gati
	@since  30/04/2026
/*/
Function OFIA627(aParam)
	if valtype(aParam) != "U"
		Prepare Environment Empresa aParam[1] Filial aParam[2] Modulo "PEC"
	endif
	Private oUtil           := DMS_Util():New()
	Private oSqlHlp         := DMS_SqlHelper():New()
	Private oArHlp          := DMS_ArrayHelper():New()
	Private oLogger         := DMS_Logger():New("OFIA627.LOG")
	Private oDpm            := OFJDRpmConfig():New()
	Private lIsDebug        := "OFIA627" $ GetNewPar("MV_MILDBG", "NAO") .OR. "*DPM*" $ GetNewPar("MV_MILDBG", "NAO")
	Private lForcSch        := "OFIA627SCH" $ GetNewPar("MV_MILDBG", "NAO")
	Private lProcForce      := lIsDebug .AND. "FORCE" $ GetNewPar("MV_MILDBG", "NAO")
	Private cTblLogCod
	Private cHora1, cHora2
	Private lNovoCombo      := GetNewPar("MV_MIL0210", .F.)
	Private lDebug := .T.

	conout("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
	conout("~~~~~~~~ INICIANDO OFIA627 ~~~~~~~~~~~~~")
	conout("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")

	if lNovoCombo
		UserException(STR0009) // "Usuários combo brasil deve executar a rotina OFIA514"
	endif

	if ! oDpm:Ready(.F.)
		if ! isBlind()
			MsgInfo(oDpm:cLastError, STR0001) /* "Atenção" */
		endif
		Return .F.
	endif

	cTblLogCod := oLogger:LogToTable({;
		{'VQL_AGROUP'     , 'OFIA627'                                      },;
		{'VQL_TIPO'       , 'LOG_EXECUCAO'                                 },;
		{'VQL_DADOS'      , 'MODO:' + IIF(isBlind(), STR0002 /*Agendado*/, STR0003 /*Normal*/) } ; 
	})

	If isBlind()
		OA6270014_SchedulerLoop()
	Else
		Processa( {|lAbort| OA6270014_SchedulerLoop() } )
	EndIf

	oLogger:CloseOpened(cTblLogCod)

	conout("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
	conout("~~~~~~~~ FINALIZANDO OFIA627 ~~~~~~~~~~~")
	conout("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
Return

/*/{Protheus.doc} OA6270014_SchedulerLoop
	Loop infinito de processamento por conta

	Percorre todas as contas RPM, verifica geracoes pendentes
	no DMS_DPMSched e dispara jobs de geracao DPE.

	@author Vinicius Gati
	@since  30/04/2026
/*/
Static Function OA6270014_SchedulerLoop()
	Local nIdx     := 1
	Local nIdx2    := 1
	Local nRecVQL  := 0
	Local oAuth2   := OFOAUTH2():New()
	Local aConfs   := oDpm:GetConfigs()

	cHora1 := TIME()

	lUsaGrps := LEN( aConfs ) > 0

	If ! lUsaGrps // mais fácil primeiro
		aConfs := { DMS_DPMConfig():New("SCHEDULER") } // "SCHEDULER" é só o valor padrao sem grupos
	EndIf

	Do While .T. .AND. FM_SQL('SELECT count(*) FROM ' + RetSqlName('VQL') + " WHERE VQL_AGROUP = 'OFIA627' AND VQL_TIPO = 'SCH_STOP' AND D_E_L_E_T_ = ' ' ") == 0
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

		conout("DPMSCHED - " + STR0005 + ": " + cHora1 + " e " + cHora2) // verificando geracoes

		for nIdx := 1 to LEN(aConfs)
			oConf := aConfs[nIdx]
			// verificar proximas gerações e gera se estiver no horário
			// IMPORTANTE: mesmo que se use combo ou config sempre vai usar apenas 1 configuração de geração
			// não temos hoje como separar horarios de geração
			oSched  := DMS_DPMSched():New(oConf:cGrupo)
			aGerar  := oSched:WhatToGen( cHora1, cHora2 ) // pega o que precisa ser gerado
			nRecVQL := oSched:GetRegHoraExec()

			if lDebug
				conout( "DPMSCHED - " + STR0007 + " : " + ALLTRIM(STR(LEN(aGerar))) ) // numero de parts data a gerar
			EndIf
			
			for nIdx2 := 1 to LEN(aGerar)
				cTipo := aGerar[nIdx2]:cTipo
				
				StartJob("OA6270034_DPEGeneration", GetEnvServer(), .F., { cEmpAnt, xFilial('VS1'), oConf:cGrupo, cTipo, nRecVQL }) //  usa grupo
				conout("Executando thread - Emp: " + cEmpAnt + " Filial: " +  xFilial('VS1') )
				conout("Environment: " + GetEnvServer())
			
			Next

			oAuth2:RenewTokens()

		next

		oAuth2:RenewTokens()
	End

	TcSqlExec('UPDATE ' + RetSqlName('VQL') + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE VQL_AGROUP = 'OFIA627' AND VQL_TIPO = 'SCH_STOP' AND D_E_L_E_T_ = ' ' ")
	if ! isBlind()
		MSGINFO(STR0006, STR0001) //"Processo finalizado"
	EndIf
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

/*/{Protheus.doc} OA6270034_DPEGeneration
	Job de geracao DPE por conta (chamado via StartJob)

	Recebe parametros do scheduler e dispara a geracao de Parts Data
	para uma conta especifica ou para todas as contas.

	@author Vinicius Gati
	@since  30/04/2026
/*/
Function OA6270034_DPEGeneration(aParams)
	Prepare Environment Empresa aParams[1] Filial aParams[2] Modulo "PEC"

	conout("Gerando Parts Data via JDPrism para conta: " + cvaltochar(aParams[1]) + " e filial: " + cValTochAr(aParams[2]))
	oJdConfig := OFJDConfig():New()

	if oJDConfig:SendoUsada()
		OFIA504(aParams, .t.)
	else
		OFINJD31(aParams, .t.)
	endif

	OA6270044_MarcaFlag(aParams)
Return .T.

/*/{Protheus.doc} OA6270044_MarcaFlag
	Marca flags de processamento no VQL apos geracao

	Atualiza o campo VQ7L_DADOS da linha de agendamento
	e remove linhas de inicializacao (SCHED_I) concluidas. Isso é um marcador de REINIT.

	@author Vinicius Gati
	@since  30/04/2026
/*/
Static Function OA6270044_MarcaFlag(aParams)
	if Empty(aParams[4])
		cTipo := "I"
	Else
		cTipo := aParams[4]
	EndIf
	conout(STR0008 + " :" + aParams[4]) //Geracao de Parts Data via JDPrism tipo

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
