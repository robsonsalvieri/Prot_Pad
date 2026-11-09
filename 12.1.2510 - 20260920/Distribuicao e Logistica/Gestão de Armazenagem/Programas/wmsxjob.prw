#INCLUDE 'Protheus.ch'
#INCLUDE 'TBICONN.CH'
#DEFINE LIMITE 80
#DEFINE ARQ_CPRJOB 'WMSXJOB.CFG'

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³WMSXJOB   ³ Autor ³ Nilton A. Rodrigues   ³ Data ³ 16.09.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Biblioteca dos jobs das APIs do WMS                          ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Materiais                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function JobWMS()

Local aRotina    := {}
Local cAuxiliar  := ''
Local nX         := 0
Local nY         := 0
Local nZ         := 0
Local nIntervalo := 0
Local nJobs      := 0
Local nSleepJob  := 0
Local cHoraIni   := ''
Local cHoraFim   := ''
Local cAtivo     := ''
Local lContinua  := .T.
Local cPath      := Iif(IsSrvUnix(),'/BIN/APPSERVER/','\BIN\APPSERVER\')
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica os parametros da rotina                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
WmsLogMsg(Repl('=',LIMITE))
WmsLogMsg(PadC('STARTING JOBS - Warehouse Management System',LIMITE))
WmsLogMsg('INIT TIME: ' + Time() + ' - ' + DtoC(Date()))
WmsLogMsg(Repl('=',LIMITE))
WmsLogMsg('')
If !File(cPath+ARQ_CPRJOB)
	WmsLogMsg('WARNING: '+'Configuration File not found'+': '+cPath+ARQ_CPRJOB)
	lContinua := .F.
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verificando as Empresas e Rotinas Habilitadas                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lContinua
	//-- Executa Servicos de Entrada
	If !Empty(GetPvProfString('JOBS','WMSJOBSENT','',ARQ_CPRJOB))
			cAuxiliar := GetPvProfString('JOBS','WMSJOBSENT','',ARQ_CPRJOB)
			Do While !Empty(cAuxiliar)
				aadd(aRotina,{'WMSJOBSENT',SubStr(cAuxiliar,1,2),SubStr(cAuxiliar,3,2),'01:00:00','23:59:59',0,'ON',Time()})
				nX := At(cAuxiliar,';')
				If nX == 0
					cAuxiliar := ''
				Else
					cAuxiliar := SubStr(cAuxiliar,nX+1)
				EndIf
			EndDo
	EndIf
	//-- Executa Servicos de Saida
	If !Empty(GetPvProfString('JOBS','WMSJOBSSAI','',ARQ_CPRJOB))
		cAuxiliar := GetPvProfString('JOBS','WMSJOBSSAI','',ARQ_CPRJOB)
		Do While !Empty(cAuxiliar)
			aadd(aRotina,{'WMSJOBSSAI',SubStr(cAuxiliar,1,2),SubStr(cAuxiliar,3,2),'01:00:00','23:59:59',0,'ON',Time()})
			nX := At(cAuxiliar,';')
			If nX == 0
				cAuxiliar := ''
			Else
				cAuxiliar := SubStr(cAuxiliar,nX+1)
			EndIf
		EndDo
	EndIf
	//-- Executa Servicos de Ordens de Servico Manuais
	If !Empty(GetPvProfString('JOBS','WMSJOBSOSM','',ARQ_CPRJOB))
		cAuxiliar := GetPvProfString('JOBS','WMSJOBSOSM','',ARQ_CPRJOB)
		Do While !Empty(cAuxiliar)
			aadd(aRotina,{'WMSJOBSOSM',SubStr(cAuxiliar,1,2),SubStr(cAuxiliar,3,2),'01:00:00','23:59:59',0,'ON',Time()})
			nX := At(cAuxiliar,';')
			If nX == 0
				cAuxiliar := ''
			Else
				cAuxiliar := SubStr(cAuxiliar,nX+1)
			EndIf
		EndDo
	EndIf
	If Empty(aRotina)
		WmsLogMsg(Repl('=',LIMITE))
		WmsLogMsg('WARNING: '+'Routine not found')
		WmsLogMsg(Repl('=',LIMITE))
		WmsLogMsg('Section: JOBS ')
		WmsLogMsg('{Process Name}: {Company/Branch[;...]}')
		WmsLogMsg('Example: [JOBS])')
		WmsLogMsg('         WMSJOBSENT  =9901;9902;9903;...')
		WmsLogMsg('')
		WmsLogMsg(Repl('-',LIMITE))
		lContinua := .F.
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verificando os Parametros de cada Rotina                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lContinua
	For nX := 1 To Len(aRotina)
		cHoraIni   := GetPvProfString(aRotina[nX][1]+'_'+aRotina[nX][2]+aRotina[nX][3],'START_TIME','01:00:00',ARQ_CPRJOB)
		cHoraFim   := GetPvProfString(aRotina[nX][1]+'_'+aRotina[nX][2]+aRotina[nX][3],'FINISH_TIME','23:59:59',ARQ_CPRJOB)
		nIntervalo := GetPvProfString(aRotina[nX][1]+'_'+aRotina[nX][2]+aRotina[nX][3],'INTERVAL','5',ARQ_CPRJOB)
		cAtivo     := GetPvProfString(aRotina[nX][1]+'_'+aRotina[nX][2]+aRotina[nX][3],'ACTIVATE','ON',ARQ_CPRJOB)
		nJobs      := Val(GetPvProfString(aRotina[nX][1]+'_'+aRotina[nX][2]+aRotina[nX][3],'JOBS','1',ARQ_CPRJOB))
		nSleepJob  := Max(Val(GetPvProfString(aRotina[nX][1]+'_'+aRotina[nX][2]+aRotina[nX][3],'SLEEPJOB','1',ARQ_CPRJOB)),10)

		aRotina[nX][4] := cHoraIni
		aRotina[nX][5] := cHoraFim
		aRotina[nX][6] := nIntervalo
		aRotina[nX][7] := cAtivo
		aRotina[nX][8] := cHoraIni

		WmsLogMsg('Processing in: ')
		WmsLogMsg('          COMPANY    ='+aRotina[nX][2])
		WmsLogMsg('          BRANCH     ='+aRotina[nX][3])
		WmsLogMsg('')
		WmsLogMsg('['+aRotina[nX][1]+'_'+aRotina[nX][2]+aRotina[nX][3]+']')
		WmsLogMsg('          START_TIME ='+aRotina[nX][4])
		WmsLogMsg('          FINISH_TIME='+aRotina[nX][5])
		WmsLogMsg('          INTERVAL   ='+aRotina[nX][6])
		WmsLogMsg('          ACTIVATE   ='+aRotina[nX][7])
		WmsLogMsg('          JOBS       ='+StrZero(nJobs,2))
		WmsLogMsg('          SLEEPJOB   ='+StrZero(nSleepJob,3))
		WmsLogMsg('')
	Next nX
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processamento das Rotinas                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Do While !KillApp()
		For nX := 1 To Len(aRotina)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se a Rotina deve ser executada                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			cHoraIni   := GetPvProfString(aRotina[nX][1]+'_'+aRotina[nX][2]+aRotina[nX][3],'START_TIME','01:00:00',ARQ_CPRJOB)
			cHoraFim   := GetPvProfString(aRotina[nX][1]+'_'+aRotina[nX][2]+aRotina[nX][3],'FINISH_TIME','23:59:59',ARQ_CPRJOB)
			nIntervalo := Val(GetPvProfString(aRotina[nX][1]+'_'+aRotina[nX][2]+aRotina[nX][3],'INTERVAL','5',ARQ_CPRJOB))
			cAtivo     := GetPvProfString(aRotina[nX][1]+'_'+aRotina[nX][2]+aRotina[nX][3],'ACTIVATE','OFF',ARQ_CPRJOB)
			nJobs      := Val(GetPvProfString(aRotina[nX][1]+'_'+aRotina[nX][2]+aRotina[nX][3],'JOBS','1',ARQ_CPRJOB))
			nSleepJob  := Max(Val(GetPvProfString(aRotina[nX][1]+'_'+aRotina[nX][2]+aRotina[nX][3],'SLEEPJOB','1',ARQ_CPRJOB)),10)
			If cAtivo == 'ON'
				For nY := 1 To nJobs
					StartJob(aRotina[nX][1],GetEnvServer(),.F.,aRotina[nX][2],aRotina[nX][3],nY)
					For nZ := 0 To nSleepJob
						Sleep(1000)
						If KillApp()
							Exit
						EndIf
					Next nZ
					If KillApp()
						Exit
					EndIf
				Next nY
			EndIf
		Next nX
		Sleep(1000)
	EndDo
EndIf

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³WMSJOBSENTºAutor  ³Microsiga           º Data ³  09/20/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que executa Servicos de Entrada via JOB              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Advanced Protheus                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function WMSJOBSENT(cCodEmp, cCodFil, nIDJob)

WMSJOBSERV(cCodEmp, cCodFil, nIDJob, 'WMSJOBSENT', 1) //-- Servicos de Entrada

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³WMSJOBSSAIºAutor  ³Microsiga           º Data ³  09/20/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que executa Servicos de Saida via JOB                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Advanced Protheus                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function WMSJOBSSAI(cCodEmp, cCodFil, nIDJob)

WMSJOBSERV(cCodEmp, cCodFil, nIDJob, 'WMSJOBSSAI', 2) //-- Servicos de Saida  

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³WMSJOBSOSMºAutor  ³Microsiga           º Data ³  09/20/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que executa Servicos de Ordem de Servicos Manuais viaº±±
±±º          ³JOB                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Advanced Protheus                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function WMSJOBSOSM(cCodEmp, cCodFil, nIDJob)

WMSJOBSERV(cCodEmp, cCodFil, nIDJob, 'WMSJOBSOSM', 4) //-- Servicos de Ordem de Servicos Manuais

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³WMSJOBSERV³ Autor ³Nilton A. Rodrigues    ³ Data ³16.09.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Job de processamento                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Codigo da Empresa                                    ³±±
±±³          ³ExpC2: Codigo da Filial                                     ³±±
±±³          ³ExpN3: Codigo do Job, utilizado no controle de execucao     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function WMSJOBSERV(cCodEmp, cCodFil, nIDJob, cJobName, nTipoJob)
Local lContinua  := .T.
Local lExecuta   := .F.
Local cHoraUlt   := '01:00:00'
Local cHora      := cHoraUlt
Local cHoraIni   := GetPvProfString(cJobName+'_'+cCodEmp+cCodFil,'START_TIME','01:00:00',ARQ_CPRJOB)
Local cHoraFim   := GetPvProfString(cJobName+'_'+cCodEmp+cCodFil,'FINISH_TIME','23:59:59',ARQ_CPRJOB)
Local cAtivo     := GetPvProfString(cJobName+'_'+cCodEmp+cCodFil,'ACTIVATE','OFF',ARQ_CPRJOB)
Local nIntervalo := Val(GetPvProfString(cJobName+'_'+cCodEmp+cCodFil,'INTERVAL','5',ARQ_CPRJOB))
Local nJobs      := Val(GetPvProfString(cJobName+'_'+cCodEmp+cCodFil,'JOBS','1',ARQ_CPRJOB))
Local nLenVar    := SetVarNameLen(255)
Local cTipoJob   := If(nTipoJob==1,'Entradas',If(nTipoJob==2,'Saidas',If(nTipoJob==3,'Cargas','Ordens de Servico Manuais')))
Local nC         := 0

	PREPARE ENVIRONMENT EMPRESA cCodEmp FILIAL cCodFil ;
	TABLES 'SD1', 'SD2', 'SD3', 'SD4', 'SDA', 'SC1', 'SC2', 'SC4', 'SC6', 'SC7', 'DC1', 'DC2', 'DC3', 'DC4', ;
	'DC5', 'DC7', 'DC8', 'DCD', 'DCF', 'DCI', 'SAH', 'SB1', 'SB2', 'SB3', 'SB4', 'SB5', 'SB6', 'SB8', ;
	'SBE', 'SBF', 'SBJ' MODULO 'WMS'
   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Controle de execucao. Nao permite que o mesmo JOB seja inicializado mais³
//³de uma vez                                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While !LockByName("WMSJOBSERV", .T., .F.)
	Sleep(50)
	nC++
	If nC == 60
		lContinua := .F.
		Exit
	EndIf
EndDo

If lContinua
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Preparando o ambiente para execucao                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	WmsLogMsg(Repl('-',LIMITE))
	WmsLogMsg(cJobName+'('+StrZero(nIDJob,2)+'): '+'Starting environment')
	WmsLogMsg(Repl('-',LIMITE))
    
	Do While cAtivo == 'ON' .And. nJobs >= nIDJob .And. !Killapp()
		lExecuta := .F.
		cAtivo   := GetPvProfString(cJobName+'_'+cCodEmp+cCodFil,'ACTIVATE','OFF',ARQ_CPRJOB)
		If cHoraIni > cHoraFim
			If !(Time() >= cHoraFim .And. Time() <= cHoraIni)
				cHora := cHoraUlt
				SomaDiaHor(Date(),@cHora,nIntervalo/60)
				If Time() >= cHora .Or. nIntervalo == 0
					cHoraUlt := Time()
					lExecuta := .T.
				EndIf
			Else
				cAtivo := 'OFF'
			EndIf
		Else
			If Time() >= cHoraIni .And. Time() <= cHoraFim
				cHora := cHoraUlt
				SomaDiaHor(Date(),@cHora,nIntervalo/60)
				If Time() >= cHora .Or. nIntervalo == 0
					cHoraUlt := Time()
					lExecuta := .T.
				EndIf
			Else
				cAtivo := 'OFF'
			EndIf
		EndIf

		If lExecuta
			DLA150Job(nTipoJob, cTipoJob)
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verificando o ambiente novamente para assumir novos parametros          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cHoraIni   := GetPvProfString(cJobName+'_'+cCodEmp+cCodFil,'START_TIME','01:00:00',ARQ_CPRJOB)
		cHoraFim   := GetPvProfString(cJobName+'_'+cCodEmp+cCodFil,'FINISH_TIME','23:59:59',ARQ_CPRJOB)
		nIntervalo := Val(GetPvProfString(cJobName+'_'+cCodEmp+cCodFil,'INTERVAL','5',ARQ_CPRJOB))
		nJobs      := Val(GetPvProfString(cJobName+'_'+cCodEmp+cCodFil,'JOBS','1',ARQ_CPRJOB))
		cAtivo     := GetPvProfString(cJobName+'_'+cCodEmp+cCodFil,'ACTIVATE','OFF',ARQ_CPRJOB)
		WmsLogMsg('Searching Service... ('+Time()+' - '+DtoC(Date())+')')
		Sleep(5000)
	EndDo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Finalisando o ambiente para execucao                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	WmsLogMsg(Repl('=',LIMITE))
	WmsLogMsg(PadC('FINISHING JOB - Warehouse Management System',LIMITE))
	WmsLogMsg(PadC(cTipoJob,LIMITE))
	WmsLogMsg('END TIME: ' + Time() + ' - ' + DtoC(Date()))
	WmsLogMsg(cJobName+'('+StrZero(nIDJob,2)+'): '+'Environment reseted')
	WmsLogMsg(Repl('=',LIMITE))
	WmsLogMsg('')
	RESET ENVIRONMENT
	UnLockByName("WMSJOBSERV", .T., .F.)
EndIf
SetVarNameLen(nLenVar)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³DLA150Job ³ Autor ³ Fernando Joly Siquini ³ Data ³16.09.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Executa os Servicos via Job                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DLA150Job()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function DLA150Job(nTipoJob, cTipoJob)

Local aRecnos  := {}
Local aJaExec  := {}
Local aAExec   := {}
Local cSeekDCF := ''
Local cCompara := ''
Local cQryDCF  := ''
Local nExec    := 0
Local nY       := 0
Local nX       := 0
Local lRetPE   := .T.
Local lWMSJBDCF:= ExistBlock("WMSJBDCF")

Private cMarca  := '+J'

Static cTitProd := ''
Static cTitQtd  := ''
Static cTitEnd  := ''

cTitProd := FWX3Titulo("DCF_CODPRO")
cTitQtd  := FWX3Titulo("DCF_QUANT")
cTitEnd  := FWX3Titulo("DCF_ENDER")

//-- Seleciona os Servicos a Executar e Interrompidos no DCF
dbSelectArea('DCF')
cQryDCF := "SELECT DCF_FILIAL, DCF_STSERV , R_E_C_N_O_ DCFRECNO "
cQryDCF += "FROM " + RetSqlName('DCF') + " DCF "
cQryDCF += "WHERE DCF_FILIAL='"+xFilial('DCF')+"'"
cQryDCF += " AND DCF_STSERV<>'3'"
cQryDCF += " AND DCF_OK='  '"
cQryDCF += " AND D_E_L_E_T_=' '"

If	nTipoJob == 1
	//-- Entradas
	cQryDCF  += "AND (DCF_ORIGEM = 'SD1' OR DCF_ORIGEM = 'SD2' OR DCF_ORIGEM = 'SDA' OR DCF_ORIGEM = 'SCM')"
ElseIf nTipoJob == 2
	//-- Saidas
	cQryDCF  += "AND (DCF_ORIGEM = 'SC9' OR DCF_ORIGEM = 'SCN')"
ElseIf nTipoJob == 4
	//-- Ordem de Servico Manual
	cQryDCF  += "AND (DCF_ORIGEM = 'DCF' OR DCF_ORIGEM = 'SD3')"
EndIf
cQryDCF := ChangeQuery(cQryDCF)
dbUseArea(.T., 'TOPCONN', TcGenQry(,,cQryDCF), 'SELECTDCF')
dbSelectArea('SELECTDCF')
Do While !SELECTDCF->(Eof()) .And. !KillApp()
	//-- Ponto de entrada para definir servicos (DCF) que serao executados.
	If	lWMSJBDCF
		lRetPE := ExecBlock("WMSJBDCF",.F.,.F.,{SELECTDCF->DCFRECNO})
		lRetPE := If(ValType(lRetPE)=="L",lRetPE,.T.)
		If	!lRetPE
			SELECTDCF->(dbSkip())
			Loop
		EndIf
	EndIf
	aAdd(aRecnos, SELECTDCF->DCFRECNO)
	SELECTDCF->(dbSkip())
EndDo
SELECTDCF->(dbCloseArea())

dbSelectArea('DCF')
For nX := 1 to Len(aRecnos)

	If KillApp()
		Exit
	EndIf

	//-- Ignora Registros Jah Executados
	If aScan(aJaExec, aRecnos[nX]) > 0
		Loop
	EndIf

	Begin Transaction

		//-- Marca o Servico A Executar
		dbGoto(aRecnos[nX])
		Reclock('DCF', .F.)
		Replace DCF_OK With cMarca
		MsUnlock()
		aAdd(aAExec, Recno())

		//-- Marca Servicos que possuam mesma Carga ou Documento
		IF !Empty(DCF_CARGA)
			dbSetOrder(4) //-- DCF_FILIAL+DCF_SERVIC+DCF_CARGA+DCF_UNITIZ
			cSeekDCF := xFilial('DCF')+DCF_SERVIC+DCF_CARGA
			cCompara := 'DCF_FILIAL+DCF_SERVIC+DCF_CARGA'
		Else
			dbSetOrder(2) //-- DCF_FILIAL+DCF_SERVIC+DCF_DOCTO+DCF_SERIE+DCF_CLIFOR+DCF_LOJA+DCF_CODPRO
			cSeekDCF := xFilial('DCF')+DCF_SERVIC+DCF_DOCTO
			cCompara := 'DCF_FILIAL+DCF_SERVIC+DCF_DOCTO'
		EndIf
		If MsSeek(cSeekDCF, .F.)
			Do While !Eof() .And. cSeekDCF == &(cCompara) .And. !KillApp()
				If !(DCF_STSERV) == '3' .And. !(aRecnos[nX]==Recno()) //-- Somente para servicos "1-Nao Executados" ou "2-Interrompidos"
					Reclock('DCF', .F.)
					Replace DCF_OK With cMarca
					MsUnlock()
					aAdd(aAExec, Recno())
				EndIf
				dbSkip()
			Enddo
		EndIf

		//-- Executa os Servicos
		If !KillApp()
			For nY := 1 to Len(aAExec)
			If KillApp()
				Exit
			EndIf
			DCF->(dbGoTo(aAExec[nY]))
				WmsLogMsg(Repl('-', LIMITE))
				WmsLogMsg(PadC('JOB MESSAGE - Warehouse Management System',LIMITE))
				WmsLogMsg(PadC(cTipoJob,LIMITE))
				WmsLogMsg('EXECUTING WMS SERVICE...')
				WmsLogMsg('DCF RECNO...: ' +AllTrim(Str(aAExec[nY])))
				WmsLogMsg('DCF Service : ' +DCF->DCF_SERVIC)
				WmsLogMsg(Padr(cTitProd,12)+'.: ' + DCF->DCF_CODPRO)
				WmsLogMsg(Padr(cTitQtd,12)+'.: ' + TransForm(DCF->DCF_QUANT,PesqPict('DCF','DCF_QUANT')))
				WmsLogMsg(Padr(cTitEnd,12)+'.: ' + DCF->DCF_ENDER)
				WmsLogMsg('INIT TIME....: ' + Time() + ' - ' + DtoC(Date()))
				DLA150SerJ(aAExec[nY])
				WmsLogMsg('END TIME.....: ' + Time() + ' - ' + DtoC(Date()))
				WmsLogMsg(Repl('-', LIMITE))
				WmsLogMsg('')
				nExec ++
				aAdd(aJaExec, aAExec[nY])
			Next nY
			aAExec := {}
		EndIf

	End Transaction	
Next nX
MsUnlockAll()
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³DLA150SerJ³ Autor ³ Alex Egydio           ³ Data ³17.01.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Executa o Servico via JOB                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DLA150SerJ(ExpL1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 = Recno do Servico a ser Executado                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ DLGA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function DLA150SerJ(nRecno)

Local aAreaAnt   := GetArea()
Local aAreaDC5   := DC5->(GetArea())
//-- Variaveis utilizadas pela funcao wmsexedcf
Local lRet       := Nil
Private aLibSDB  := {}
Private aWmsAviso:= {}
//--
Private lExec150:= .T.
Private lRadioF	:= (GetMV('MV_RADIOF', .F., 'N')=='S') //-- Como Default o parametro MV_RADIOF e verificado

dbSelectArea('SD1')
dbSetOrder(1)

dbSelectArea('SD2')
dbSetOrder(3)

dbSelectArea('SD3')
dbSetOrder(2)

dbSelectArea('SC9')
dbSetOrder(1)

dbSelectArea('DC6')
dbSetOrder(1)

If !(cPaisLoc=='BRA')
	dbSelectArea('SCM')
	dbSetOrder(9)

	dbSelectArea('SCN')
	dbSetOrder(6)
Endif

dbSelectArea('DCF')
dbGoto(nRecno)

dbSelectArea('DC5')
dbSetOrder(1)
If	DCF->DCF_OK==cMarca
	WmsExeDCF('1',.T.)
	WmsExeDCF('2')
	If	lRet == Nil
		lRet := lExec150
	EndIf
EndIf

If lRet == Nil
	lRet := .F.
EndIf

RestArea(aAreaDC5)
RestArea(aAreaAnt)

Return lRet

Static Function WmsLogMsg(cMsg)

	FWLogMsg("INFO", "", "BusinessObject", "WMSXJOB", "", "", cMsg, 0, 0)

Return
