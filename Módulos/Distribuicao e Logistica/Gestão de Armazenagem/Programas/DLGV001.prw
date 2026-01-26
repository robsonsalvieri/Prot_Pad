#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'DLGV001.CH'
#INCLUDE 'FIVEWIN.CH'
#INCLUDE 'APVT100.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ DLGV001  ³ Autor ³ Alex Egydio           ³ Data ³ 18.09.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Identifica as funcoes do operador logado na radio frequencia³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ADVPL16                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Geverico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function DLGV001()
Local aTelaAnt  := {}
Local cSeekDCI  := ''
Local nX        := 0
Local nKey      := 0
Local cHelice   := ''
Local cHora     := ''
Local cAmPm     := STR0001  //'am'
Local cClock    := ''
Local lRadioF   := (SuperGetMV('MV_RADIOF', .F., 'N')=='S')
Local lSleep    := (SuperGetMV('MV_RFSLEEP', .F., 0)>0)
Local lSleeping := .F.
Local nTimeIni  := 0
Local nIdle     := 0
Local nTimeSleep:= (SuperGetMV('MV_RFSLEEP', .F., 0)*60) //-- Tempo em MINUTOS para que o terminal comece a hibernar (Default=0)
Local nIndSDB   := 0
Local nOrdemFunc:= 0
Local cUsuArma  := CriaVar('BE_LOCAL',.F.)
Local cUsuZona  := CriaVar('BE_CODZON',.F.)
Local cDescFunc := ''
Local cMsgSem   := ''
Local dDataFec  := DToS(WmsData())
Local lRetPE    := .F.
Local nTipoConv := SuperGetMV('MV_TPCONVO', .F., 1) //-- 1=Por Atividade/2=Por Tarefa
Local cInternet := ''
Local lWMSCONV  := ExistBlock("WMSCONV")

Private cStatExec   := SuperGetMV('MV_RFSTEXE', .F., '1') //-- DB_STATUS indincando Atividade Executada
Private cStatProb   := SuperGetMV('MV_RFSTPRO', .F., '2') //-- DB_STATUS indincando Atividade com Problemas
Private cStatInte   := SuperGetMV('MV_RFSTINT', .F., '3') //-- DB_STATUS indincando Atividade Interrompida
Private cStatAExe   := SuperGetMV('MV_RFSTAEX', .F., '4') //-- DB_STATUS indincando Atividade A Executar
Private cStatAuto   := SuperGetMV('MV_RFSTAUT', .F., 'A') //-- DB_STATUS indincando Atividade Automatica
Private cStatManu   := SuperGetMV('MV_RFSTMAN', .F., 'M') //-- DB_STATUS indincando Atividade Manual
Private cReinAuto   := Iif(GetVersao(.F.) >= '11' .AND. GetRpoRelease('R7'),SuperGetMV('MV_REINAUT', .F., 'N'),'N') //-- Indica se permite convocar atividade com problemas/ Interrompida
Private lReinAuto   := (cReinAuto=='S')
Private aFuncoesWMS := {}
Private aColetor    := {}
Private aConfEnd    := {}
Private cFunExe     := ''
Private nWmsMTea    := SuperGetMv('MV_WMSMTEA',.F.,0) //Permite selecionar multiplas tarefas: 0=Nenhum;1=Apanhe;2=Enderecar;3=Ambos
Private nIdleWake   := SuperGetMV('MV_RFIDLEW', .F., 1000) //-- Intervalo de tempo em MILISEGUNDOS em que o sistema ficara em PAUSA no modo ACORDADO (Default=1000)
Private nIdleSleep  := SuperGetMV('MV_RFIDLES', .F., 5000) //-- Intervalo de tempo em MILISEGUNDOS em que o sistema ficara em PAUSA no modo HIBERNANDO (Default=5000)

	If SuperGetMv("MV_WMSNEW",.F.,.F.)
		Return WMSV001()
	EndIf

	If MVUlmes() >= dDataBase
		WmsMessage(STR0053,"MV_ULMES") // "A data base informada no acesso ao sistema e anterior ao ultimo fechamento de estoque! Nao e permitido efetuar movimentacoes desta forma."
		Return
	EndIf

	If Type("__cInterNet") <> "U"
		cInternet := __cInterNet
	EndIf
	__cInterNet := "AUTOMATICO"

	//-- Pesquisa quais funcoes o usuario exerce
	DCD->(DbSetOrder(1)) //-- DCD_FILIAL+DCD_CODFUN
	If DCD->(MsSeek(xFilial('DCD')+__cUserID, .F.))
		If DCD->DCD_STATUS == '3' //-- Recusro humano ausente
			VtAlert(STR0002 + AllTrim(CUSERNAME) + STR0046, STR0004, .T.)  //'Usuario '###' informado como recurso humano ausente.'###'Atencao'
			Return Nil
		EndIf
	Else
		VtAlert(STR0002 + AllTrim(CUSERNAME) + STR0047, STR0004, .T.)  //'Usuario '###' não cadastrado como recurso humano.'###'Atencao'
		Return Nil
	EndIf

	//-- Pesquisa quais funcoes o usuario exerce
	DCI->(DbSetOrder(1)) //-- DCI_FILIAL+DCI_CODFUN+STR(DCI_ORDFUN,2)+DCI_FUNCAO
	If DCI->(MsSeek(cSeekDCI:=xFilial('DCI')+__cUserID, .F.))
		Do While !DCI->(Eof()) .And. DCI->DCI_FILIAL+DCI->DCI_CODFUN==cSeekDCI .And. !Empty(DCI->DCI_FUNCAO)
			nOrdemFunc++
			cDescFunc := Posicione("SRJ",1,xFilial("SRJ")+DCI->DCI_FUNCAO,"RJ_DESC")
			AAdd(aFuncoesWMS, {nOrdemFunc, DCI->DCI_FUNCAO, cDescFunc})
			DCI->(DbSkip())
		EndDo
	EndIf

	If Len(aFuncoesWMS) == 0
		VtAlert(STR0002 + AllTrim(CUSERNAME) + STR0003, STR0004, .T.)  //'Usuario '###' sem Funcoes Cadastradas...'###'Atencao'
		Return Nil
	EndIf

	If SuperGetMV('MV_RFINFAZ', .F., 'S')=='S'
		//-- Solicita que o usuario informe sua localizacao
		DLVTCabec(STR0005, .F., .F., .T.)   //'Sua Localizacao?'
		@ 02, 00 VTSay PadR(STR0006, VTMaxCol())  //'Armazem'
		@ 03, 00 VTGet cUsuArma Valid DlgVldArm(cUsuArma)
		@ 05, 00 VTSay PadR(STR0007, VTMaxCol())  //'Zona de Armazenagem'
		@ 06, 00 VTGet cUsuZona Valid DlgVldZon(cUsuZona) F3 'DC4'
		VTRead
		If VTLastKey() == 27
			Return Nil
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza a coluna "Rotina" do VTMONITOR ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cMsgSem := STR0040+' '+If(Empty(cUsuArma), '??', Alltrim(cUsuArma))+' ' //'A'
	cMsgSem += STR0041+' '+If(Empty(cUsuZona), '??????', Alltrim(cUsuZona))+' ' //'Z'
	cMsgSem += STR0042 //'AGUARDANDO...'
	VTAtuSem('SIGAACD', cMsgSem)

	If !DlgV001Six(@nIndSDB)
	  Return Nil
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa variaveis utiliadas no While ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cClock   := 'SIGAWMS'
	cHelice  := ' '
	nTimeIni := Seconds() + nTimeSleep
	nIdle    := nIdleWake

	//-- Atribui a Funcao de Funcoes a Combinacao de Teclas <CTRL> + <U>
	VTSetKey(21,{||DispFuncWMS(aFuncoesWMS)},STR0008)  //'Funcoes Atrib.      '
	//-- Atribui a Funcao de DATA & HORA a Combinacao de Teclas <CTRL> + <D>
	VTSetKey(4, {||DLVTClock()}  ,STR0009) //'Data/Hora'
	//-- Atribui a Funcao de HELP DE TECLAS a Combinacao de Teclas <CTRL> + <O>
	VTSetKey(15,{||DLVDOcorre()},STR0010)  //'Ocorrencias'

	DLVTCabec(AllTrim(CUSERNAME), .F., .F., .T.)
	@ Int(VTMaxRow()/2)  , 00 VtSay STR0011   //'Aguarde Convocacao'
	If !Empty(cUsuArma) .Or. !Empty(cUsuZona)
	  @ Int(VTMaxRow()/2)+1, 00 VtSay PadC('('+If(!Empty(cUsuArma), STR0040+' '+AllTrim(cUsuArma), '')+If(!Empty(cUsuArma).And.!Empty(cUsuZona), ' ', '')+If(!Empty(cUsuZona), STR0041+' '+AllTrim(cUsuZona), '')+')', VTMaxCol(), ' ')//'A'#'Z'
	Else
	  @ Int(VTMaxRow()/2)+1, 00 VtSay Space(VTMaxCol()) //-- Precisa desta linha a mais para correta montagem da tela
	EndIf
	DLVTRodaPe(cClock, .F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ >> Looping para Aguarde de Convocacao << ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Do While .T.
	  Sleep(nIdle)
	  VTLoadMsgMonit()
	  //-- PE para exibir mensagens no coletor/RF
	  If lWMSCONV
		 lRetPE := ExecBlock("WMSCONV",.F.,.F.,{__cUserID})
		 lRetPE := (If(ValType(lRetPE)=='L',lRetPE,.F.))
		 If lRetPE
			Exit //-- Finaliza convocacao
		 EndIf
	  EndIf
	  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  //³ Verifica se existe Convocacao para as funcoes do Usuario ³
	  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	  For nX := 1 To Len(aFuncoesWMS)
		 If DLVConvoca(aFuncoesWMS[nX, 2], lRadioF, __cUserID, nIndSDB, cUsuArma, cUsuZona, nTipoConv, dDataFec)
			If __nOpcESC == 1 //Abandono
			   Exit
			EndIf
			nTimeIni := Seconds() + nTimeSleep
			nKey     := VTInkey()
			If lSleeping //-- Sai do modo de hibernacao
			   nIdle     := nIdleWake
			   lSleeping := .F.
			   VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
			EndIf
			//-- Somente processar a proxima funcao RH nao encontrado atividades.
			//-- caso contrario reinicia primeira funcao RH.
			nX := 0
		 EndIf
		 If (nKey:=VTInkey()) == 27
			Exit
		 EndIf
	  Next nX

	  // Limpa o último movimento que pulou, pois se
	  // ele for o único restante nunca será convocado
	  __nRecPula := 0

	  If __nOpcESC == 1 //Abandono
		 Exit
	  EndIf

	  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  //³ Tratamento da Hibernacao ³
	  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	  If lSleep
		 If !(nKey==0) //-- Reinicializa o contador se alguma tecla for pressionada
			nTimeIni := Seconds() + nTimeSleep
		 EndIf
		 If !lSleeping .And. (Seconds() > nTimeIni)
			VTAlert(,STR0012, .T., 1000, 3)  //'Hibernando...'
			nIdle     := nIdleSleep
			lSleeping := .T.
			aTelaAnt  := VTSave(00, 00, VTMaxRow(), VTMaxCol())
			VTClear()
		 ElseIf lSleeping .And. (nTimeIni >= Seconds())
			VTAlert(, STR0013, .T., 1000, 3) //'Acordando...'
			nIdle     := nIdleWake
			lSleeping := .F.
			VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
		 EndIf
	  EndIf

	  If !lSleeping
		 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		 //³ Monta a String para a visualizacao do Relogio no rodape' ³
		 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		 cHora  := If(Val(Left(Time(), 2))>12.And.Val(Left(Time(), 2))<=23,StrZero(Val(Left(Time(), 2))-12, 2),Left(Time(), 2))
		 cAmPm  := If(Val(Left(Time(), 2))>12.And.Val(Left(Time(), 2))<= 23,STR0014,STR0001) //'pm'###'am'
		 cClock := cHora + ':' + Subs(Time(), 4, 2) + ' ' + cAmPm

		 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		 //³ Monta o String da "helice" ³
		 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		 cHelice  := If(cHelice=='|','/',If(cHelice=='/','-',If(cHelice=='-','\',If(cHelice=='\','|','|'))))

		 @ Int(VTMaxRow()/2), 18 VTSay cHelice
		 DLVTRodaPe(cClock, .F.)
	  EndIf

	  If (nKey==27)
		 If DLVTAviso('DLGV00101',STR0015, {STR0016,STR0017}) == 1   //'Finaliza Aguarde de Convocacao?'###'Sim'###'Nao'
			Exit
		 EndIf
		 nTimeIni := Seconds() + nTimeSleep
	  EndIf
	EndDo
	__cInterNet := cInternet
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³DLVConvoca³ Autor ³ Alex Egydio           ³ Data ³ 18.09.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Convoca o operador logado na radio frequencia para executar³±±
±±³          ³ o Servico x Tarefa x Atividade.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DLVConvoca( ExpC1, ExpL1, ExpC2,ExpN1, ExpC3,ExpC4 )       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Funcao exercida pelo operador                      ³±±
±±³          ³ ExpL1 = Utilizacao da radio frequencia                     ³±±
±±³          ³ ExpC2 = Codigo do Recurso Humano                           ³±±
±±³          ³ ExpN1 = Indice utilizado na filtragem                      ³±±
±±³          ³ ExpC3 = Codigo do Armazem                                  ³±±
±±³          ³ ExpC4 = Codigo da Zona de Armazenagem                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ DLGV001                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static __lDestino := .F. //-- Determina se o produto foi enviado para o destino
Static __lConvoca := .F. //-- Determina se o SDB deve ser convocado
Static __nRecSDB  := 0   //-- Determina qual o Recno() do SDB a ser convocado
Static aRetRegra  := {}
Static Function DLVConvoca(cFuncao, lRadioF, cRecHum, nIndSDB, cUsuArma, cUsuZona, nTipoConv, dDataFec)
Local aAreaAnt    := GetArea()
Local aAreaSDB    := {}
Local aTelaAnt    := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local lRet        := .F.
Local cAliasCnv   := GetNextAlias()
Local cQuery      := ""
Local cStatusSDB  := ""
Local cRadioF     := ""
Local cDscTar     := ""
Local cDscAtv     := ""
Local cMsgSem     := ""
Local lRetPE      := .T.
Local lDLGV001G   := ExistBlock('DLGV001G')
Local cNumero     := ""
Local cAntRecHum  := "" //Para salvar o recurso humano anterior, caso o usuário abandone a tarefa
Local nCol        := 0
Local aRetPE      := {}
//-- Variaveis para solicitar dispositivo de movimentacao
Default cUsuArma  := ""
Default cUsuZona  := ""
Default nIndSDB   := 8

Private aParam150 := {}
Private cErro     := ""
Private lExec150  := .F.
Private lOcorre   := .F.
Private lRetAtiv  := .F.
Private lWMSDRMake:= .F. //-- Indica se a funcao executada eh RDMake
Private lWMSRDStat:= (SuperGetMV('MV_WMSRDST', .F., 'S')=='S') //-- Indica se o STATUS sera alterado pelo WMS quando forem executadas funcoes RDMake
Private aParConv  := {cFuncao, lRadioF, cRecHum, nIndSDB, cUsuArma, cUsuZona, nTipoConv, dDataFec}

//-- Deve verificar se existe alguma atividade para o usuário que ficou em andamento
If __nRecSDB == 0
   __nRecSDB := DCD->DCD_ULTATV
EndIf

//Verifica a versao e o paramentro que permite reabrir tarefa paralizadas
cStatusSDB := Iif((lReinAuto .And. cReinAuto == 'S')," AND SDB.DB_STATUS IN ('"+cStatProb+"','"+cStatInte+"','"+cStatAExe+"')", " AND SDB.DB_STATUS IN ('"+cStatInte+"','"+cStatAExe+"')" )
cQuery := QryValAtCv(cRecHum,cFuncao,cUsuArma,0,nIndSDB,cStatusSDB,.F.,.F.)
DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasCnv,.F.,.T.)

While (cAliasCnv)->(!Eof())
   //-- Abandona a Verificacao da Convocacao
   If VTLastKey() == 27
	  __nOpcESC := 1 //FLAG de Abandono
	  Exit
   EndIf
   cFunExe := ""
   cRadioF := ""

   If Empty((cAliasCnv)->RECDC5)
	  (cAliasCnv)->(DbSkip())
	  Loop
   EndIf
   //-- Verifica se o registro do SDB ja foi executado pelo processo de multi-tarefas
   nReg := aScan(aColetor,{|x|x[1] == (cAliasCnv)->RECSDB })
   If nReg > 0
	  (cAliasCnv)->(DbSkip())
	  Loop
   EndIf
   //-- Se o movimento a ser convocado é o mesmo do último que ele "pulou", não convoca
   If __nRecPula == (cAliasCnv)->RECSDB
	  (cAliasCnv)->(DbSkip())
	  Loop
   EndIf

   If !DLVAvalSDB((cAliasCnv)->RECSDB,(cAliasCnv)->RECDC5,(cAliasCnv)->RECDC6,cRecHum,cFuncao,cUsuArma,cUsuZona,nTipoConv,dDataFec,@cFunExe,@cRadioF,nIndSDB)
	  (cAliasCnv)->(DbSkip())
	  Loop
   EndIf

   __lConvoca := .T.
   __nRecSDB := SDB->(Recno())
   While __lConvoca //-- Para permitir multi-tarefa
	  __lConvoca := .F. //-- Para forçar sair caso não use multi-tarefa
	  __lDestino := .F.
	  //-- Neste ponto o SDB a ser excutado deve estar posicionado corretamente
	  //-- Não precisa recarregar a função a executar e nem se é RF
	  //-- Pois deve sempre executar uma mesma atividade
	  //-- Posiciona o registro de movimentação
	  SDB->(DbGoTo(__nRecSDB))
	  If SDB->(SimpleLock()) .And. Iif(cReinAuto == 'N',(SDB->DB_STATUS==cStatInte .Or. SDB->DB_STATUS==cStatAExe) .And. (Empty(SDB->DB_RECHUM) .Or. SDB->DB_RECHUM==cRecHum),(SDB->DB_STATUS==cStatProb .OR. SDB->DB_STATUS==cStatInte .OR. SDB->DB_STATUS==cStatAExe) .And. (Empty(SDB->DB_RECHUM) .Or. SDB->DB_RECHUM==cRecHum)) // Verifica se conseguiu travar registro
		 // -- Verifica se data do Protheus esta diferente da data do sistema.
		 DLDataAtu()
		 //-- Salva o recurso humano anterior, caso ousuário abandone a tarefa
		 cAntRecHum := SDB->DB_RECHUM
		 //-- Indica se a funcao executada eh RDMake
		 lWMSDRMake := Upper(SubStr(cFunExe, 1, 2)) == 'U_'
		 //-- Soh altera o Status se NAO for RDMake ou se for RDMake e a alteracao do Status (MV_WMSRDST) ficar a cargo o WMS
		 DLVAltSts(!lWMSDRMake .Or. (lWMSDRMake.And.lWMSRDStat))
		 //-- Limpa a FLAG da tecla ESC
		 DLVOpcESC(0)
		 //-- Carrega parâmetro para "Pular Atividade"
		 DLVPulaAti()
		 //-- Limpa o último movimento que pulou, pois convocou um outro movimento
		 __nRecPula := 0
		 //-- Verifica se execucao e Automatica ou via Manual
		 If !(cRadioF=='1')
			//-- Seta DB_STATUS para Servico Automatico em Execucao
			If DLVAltSts()
			   RecLock('SDB', .F.) // Trava para gravacao
			   SDB->DB_RECHUM := cRecHum
			   SDB->DB_STATUS := cStatAuto
			   SDB->DB_DATA   := dDataBase
			   SDB->DB_HRINI  := Time()
			   MsUnlock() //-- Libera o registro do arquivo SDB
			EndIf
		 Else
			//-- Avisa sobre a Convocacao
			//-- Seta DB_STATUS para Servico em Execucao
			If DLVAltSts()
			   RecLock('SDB', .F.)  // Trava para gravacao
			   SDB->DB_RECHUM := cRecHum
			   SDB->DB_STATUS := cStatInte
			   SDB->DB_DATA   := dDataBase
			   SDB->DB_HRINI  := Time()
			   MsUnlock() //-- Libera o registro do arquivo SDB
			EndIf
			//-- Pesquisa descricao da Tarefa e Atividade
			SX5->(DbSetOrder(1))
			SX5->(MsSeek(xFilial('SX5')+'L2'+SDB->DB_TAREFA))
			cDscTar := AllTrim(SX5->(X5Descri()))
			SX5->(MsSeek(xFilial('SX5')+'L3'+SDB->DB_ATIVID))
			cDscAtv := AllTrim(SX5->(X5Descri()))
			//--            1
			//--  01234567890123456789
			//--0 ___Administrador___
			//--1 Executar Apanhe de
			//--2 produtos -
			//--3 Movimento Vertical
			//--4
			//--5
			//--6 ___________________
			//--7  Pressione <ENTER>
			While .T.
			   VTBeep(3)
			   DLVTAviso(AllTrim(CUSERNAME),STR0018+cDscTar+" - "+cDscAtv) //"Executar "
			   Exit
			EndDo
			//-- Abandona a Verificacao da Convocacao, se não possui nada para descarregar
			If VTLastKey() == 27
			   RecLock('SDB', .F.)  // Trava para gravacao
			   SDB->DB_RECHUM := cAntRecHum
			   If !(SDB->DB_STATUS==cStatAuto) .And. SDB->DB_QTDLID <= 0
				  SDB->DB_STATUS := cStatAExe
			   EndIf
			   MsUnlock() //-- Libera o registro do arquivo SDB
			   DLVAltSts(.F.)
			   If Len(aColetor) == 0 .And. Len(aConfEnd) == 0
				  __nOpcESC := 1 //FLAG de Abandono
				  Exit
			   Else
				  __lDestino := .T.
			   EndIf
			EndIf
		 EndIf
		 lRet     := (SDB->DB_STATUS==cStatInte .Or. SDB->DB_STATUS==cStatAuto)
		 aAreaSDB := SDB->(GetArea())
		 //-- Ponto de Entrada na Gravacao do Status de Servico Automatico
		 If lDLGV001G
			ExecBlock('DLGV001G', .F., .F.,{cFunExe})
		 EndIf
		 //-- Dispara a funcao associada ao servico
		 If (SDB->DB_STATUS==cStatInte .Or. SDB->DB_STATUS==cStatAExe)
			//-- Atualiza a convocação do usuário para a ultima atividade
			//-- Somente se não cancelou a atividade atual e está levando para o destino
			If !__lDestino
			   RecLock("DCD",.F.)
			   DCD->DCD_DTULAL := dDataBase
			   DCD->DCD_HRULAL := Time()
			   DCD->DCD_ULTATV := __nRecSDB
			   DCD->DCD_STATUS := '2'
			   DCD->(MsUnlock())
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza a coluna "Rotina" do VTMONITOR ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cMsgSem := STR0040+' '+If(Empty(cUsuArma), '??', Alltrim(cUsuArma))+' ' //'A'
			cMsgSem += STR0041+' '+If(Empty(cUsuZona), '??????', Alltrim(cUsuZona))+' ' //'Z'
			cMsgSem += Upper(Alltrim(cFunExe))
			VTAtuSem('SIGAACD', cMsgSem)

			If 'DLCONFEREN' $ Upper(cFunExe) //-- Conferencia de mercadorias
			   lRetAtiv := WmsV070()
			ElseIf 'DLCONFENT' $ Upper(cFunExe) //-- Conferencia de recebimento
			   lRetAtiv := WmsV073()
			ElseIf 'DLCONFSAI' $ Upper(cFunExe) //-- Conferencia de expedição
			   lRetAtiv := WmsV075()
			ElseIf 'DLENDERECA' $ Upper(cFunExe) ;
			  .Or. 'DLTRANSFER' $ Upper(cFunExe) ;
			  .Or. 'DLDESFRAG'  $ Upper(cFunExe) ;
			  .Or. 'DLCROSSDOC' $ Upper(cFunExe) //-- Recebimento de mercadorias
			   lRetAtiv := DlgV080()
			ElseIf 'DLAPANHE'  $ Upper(cFunExe) ;
			  .Or. 'DLGXABAST' $ Upper(cFunExe) //-- Apanhe ou (Re)Abastecimento
			   lRetAtiv := DlgV030()
			ElseIf !Empty(cFunExe)
			   cFunExe  += If(!('('$cFunExe),'()','')
			   cFunExe  := StrTran(cFunExe,'"',"'")
			   lRetAtiv := &(cFunExe)
			   lRetAtiv := If(!(lRetAtiv==NIL).And.ValType(lRetAtiv)=='L', lRetAtiv, .T.)
			ElseIf Empty(cFunExe)
			   lRetAtiv := .T.
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza a coluna "Rotina" do VTMONITOR ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cMsgSem := STR0040+' '+If(Empty(cUsuArma), '??', Alltrim(cUsuArma))+' ' //'A'
			cMsgSem += STR0041+' '+If(Empty(cUsuZona), '??????', Alltrim(cUsuZona))+' ' //'Z'
			cMsgSem += STR0042 //'AGUARDANDO...'
			VTAtuSem("SIGAACD", cMsgSem)
		 ElseIf SDB->DB_STATUS==cStatAuto
			VTAlert(STR0019+cDscTar+' - '+cDscAtv, AllTrim(CUSERNAME), .T., 3000, 3)   //'Execucao Automatica '
			If DLUltiAtiv(SDB->DB_DOC,SDB->DB_SERIE,SDB->DB_CLIFOR,SDB->DB_LOJA,SDB->DB_SERVIC,SDB->DB_TAREFA,SDB->DB_IDMOVTO,SDB->DB_ORDATIV) //-- So executa atividades que atualizem estoque
			   lExec150      := .F.
			   aParam150     := Array(34)
			   aParam150[01] := SDB->DB_PRODUTO //-- Produto
			   aParam150[02] := SDB->DB_LOCAL      //-- Almoxarifado
			   aParam150[03] := SDB->DB_DOC     //-- Documento
			   aParam150[04] := SDB->DB_SERIE      //-- Serie
			   aParam150[05] := SDB->DB_NUMSEQ     //-- Sequencial
			   aParam150[06] := SDB->DB_QUANT      //-- Saldo do produto em estoque
			   aParam150[07] := SDB->DB_DATA    //-- Data da Movimentacao
			   aParam150[08] := Time()          //-- Hora da Movimentacao
			   aParam150[09] := SDB->DB_SERVIC     //-- Servico
			   aParam150[10] := SDB->DB_TAREFA     //-- Tarefa
			   aParam150[11] := SDB->DB_ATIVID     //-- Atividade
			   aParam150[12] := SDB->DB_CLIFOR     //-- Cliente/Fornecedor
			   aParam150[13] := SDB->DB_LOJA    //-- Loja
			   aParam150[14] := ''              //-- Tipo da Nota Fiscal
			   aParam150[15] := SDB->DB_ITEM    //-- Item da Nota Fiscal
			   aParam150[16] := SDB->DB_TM         //-- Tipo de Movimentacao
			   aParam150[17] := SDB->DB_ORIGEM     //-- Origem de Movimentacao
			   aParam150[18] := SDB->DB_LOTECTL //-- Lote
			   aParam150[19] := SDB->DB_NUMLOTE //-- Sub-Lote
			   aParam150[20] := SDB->DB_LOCALIZ //-- Endereco
			   aParam150[21] := SDB->DB_ESTFIS     //-- Estrutura Fisica
			   aParam150[22] := 1               //-- Regra de Apanhe (1=LOTE/2=NUMERO DE SERIE/3=DATA)
			   aParam150[23] := SDB->DB_CARGA      //-- Carga
			   aParam150[24] := SDB->DB_UNITIZ     //-- Nr. do Pallet
			   aParam150[25] := SDB->DB_LOCAL      //-- Centro de Distribuicao Destino
			   aParam150[26] := SDB->DB_ENDDES     //-- Endereco Destino
			   aParam150[27] := SDB->DB_ESTDES     //-- Estrutura Fisica Destino
			   aParam150[28] := SDB->DB_ORDTARE //-- Ordem da Tarefa
			   aParam150[29] := SDB->DB_ORDATIV //-- Ordem da Atividade
			   aParam150[30] := SDB->DB_RHFUNC     //-- Funcao do Recurso Humano
			   aParam150[31] := SDB->DB_RECFIS     //-- Recurso Fisico
			   aParam150[32] := SDB->DB_IDDCF   //-- Identificador do DCF
			   aParam150[34] := SDB->DB_IDMOVTO   //-- Identificador exclusivo do Movimento no SDB
			   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			   //³ Executa as Tarefas (SX5 - Tab L6) Referentes ao Servico  (DC5)  ou    ³
			   //³ Executa as Atividades referentes a Tarefa (DC6)                       ³
			   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			   aAreaDC5a := DC5->(GetArea())
			   If '()' $cFunExe
				  cFunExe := StrTran(cFunExe,'()','')
				  cFunExe += "(.T.,'2')"
			   EndIf
			   cFunExe  := StrTran(cFunExe,'"',"'")
			   lRetAtiv := &(cFunExe)

			   lRetAtiv := If(!(lRetAtiv==NIL).And.ValType(lRetAtiv)=='L', lRetAtiv, .T.)
			   If lRetAtiv
				  lRetAtiv := lExec150
			   EndIf
			EndIf
		 EndIf
		 // -- Verifica se data do Protheus esta diferente da data do sistema.
		 DLDataAtu()
		 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		 //³ Seta DB_STATUS para "Servico Executado" ³
		 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		 RestArea(aAreaSDB)
		 If DLVAltSts()
			Begin Transaction
			Reclock('SDB', .F.)  // Trava para gravacao
			If !(SDB->DB_STATUS==cStatAuto)
			   SDB->DB_STATUS := If(lRetAtiv, cStatExec, cStatProb)
			EndIf
			SDB->DB_RECHUM  := cRecHum
			SDB->DB_DATAFIM := dDataBase
			SDB->DB_HRFIM   := Time()
			If !Empty(cErro) .Or. !lRetAtiv
			   cErro := ''
			   SDB->DB_ANOMAL := 'S'
			EndIf
			MsUnlock() // Destrava apos gravacao
			End Transaction
		 EndIf
		 //-- Ponto de Entrada na Gravacao do Status de Servico Executado
		 If lDLGV001G
			ExecBlock('DLGV001G', .F., .F.,{cFunExe})
		 EndIf
		 //-- Marca o usuário como livre
		 RecLock("DCD",.F.)
		 DCD->DCD_STATUS := '1'
		 DCD->(MsUnlock())

		 MsUnlockAll() // Tira o lock da softlock
	  Else
		 SDB->(MsUnLock())
	  EndIf
   EndDo
   Exit //-- Se ocorreu convocação, sair do WHILE e processar a próxima função
EndDo
(cAliasCnv)->(DbCloseArea())

If __nOpcESC == 1 .And. Len(aColetor) > 0
   For nCol:= 1 To Len(aColetor)
	  SDB->(DbGoTo(aColetor[nCol][1]))
	  Begin Transaction
		 RecLock('SDB', .F.)
		 If !(SDB->DB_STATUS==cStatAuto)
			SDB->DB_STATUS := cStatProb
		 EndIf
		 SDB->DB_DATAFIM := dDataBase
		 SDB->DB_HRFIM   := Time()
		 MsUnlock()
	  End Transaction
   Next nCol
   __nOpcESC := 0
EndIf
aColetor := {}
aConfEnd := {}

If !Empty(aRetRegra) .And. aRetRegra[9]=='1'
   WmsRegra('4',,cRecHum,,,,,,,,aRetRegra,cFuncao,,lRetAtiv)
EndIf
VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)

RestArea(aAreaAnt)
Return lRet

/*--------------------------------------------------------------
Avalia se o SDB passado pode ser convocvado para execução

Jackson Patrick Werka
--------------------------------------------------------------*/
Static Function DLVAvalSDB(nRecnoSDB,nRecnoDC5,nRecnoDC6,cRecHum,cFuncao,cUsuArma,cUsuZona,nTipoConv,dDataFec,cFunExe,cRadioF,nIndSDB)
Local aAreaAnt   := GetArea()
Local lRet       := .T.
Local lConvoca   := .F.
Local lNaoConv   := SuperGetMV("MV_WMSNREG", .F., .F.)
Local aRetPE     := {}
Local cNumero    := ""
Local cArmSBE    := ""
Local cTipoServ  := "3"
Local lPertenceZ := .F.
Local cFunExeAnt := ""
Local lWMSCOMP   := SuperGetMV("MV_WMSCOMP",.F.,.T.) // Se realiza a separação completa da carga ou pedido antes de permitir a convocacao de atividade reiniciada de outra carga.
Local lPrimAtiv  := .T.
Local lUltiAtiv  := .T.
Local cDscAtv    := ""
Local cEndereco  := ""

Default nRecnoDC5 := 0
Default nRecnoDC6 := 0
Default cRecHum   := __cUserID
Default cFuncao   := ""
Default cUsuArma  := ""
Default cUsuZona  := ""
Default nTipoConv := SuperGetMV("MV_TPCONVO", .F., 1) //-- 1=Por Atividade/2=Por Tarefa
Default dDataFec  := DtoS(WmsData())
Default nIndSDB   := 8

   //-- Posiciona o registro de movimentação
   SDB->(DbGoTo(nRecnoSDB))
   //-- Posiciona cadastro de Servicos x Tarefas
   DbSelectArea('DC5')
   If nRecnoDC5 != 0
	  DC5->(DbGoTo(nRecnoDC5))
   Else
	  DC5->(DbSetOrder(1)) //-- DC5_FILIAL+DC5_SERVIC+DC5_ORDEM
	  DC5->(MsSeek(xFilial('DC5')+SDB->DB_SERVIC+SDB->DB_ORDTARE))
	  nRecnoDC5 := DC5->(Recno())
   EndIf
   SX5->(DbSetOrder(1))
   SX5->(MsSeek(xFilial('SX5')+'L6'+DC5->DC5_FUNEXE))
   cFunExe := AllTrim(Upper(SX5->(X5Descri())))
   //-- Posiciona cadastro de Tarefas x Atividades
   DbSelectArea('DC6')
   If nRecnoDC6 != 0
	  DC6->(DbGoTo(nRecnoDC6))
   Else
	  DC6->(DbSetOrder(1)) //-- DC6_FILIAL+DC6_TAREFA+DC6_ORDEM
	  DC6->(MsSeek(xFilial('DC6')+SDB->DB_TAREFA+SDB->DB_ORDATIV))
	  nRecnoDC6 := DC6->(Recno())
   EndIf
   cRadioF := DC6->DC6_RADIOF

   //-- Não deve convocar as atividades geradas a partir de um mapa de separação de quantidade fracionada,
   //-- pois se trata de um processo manual. Elas serão consideradas pelo programa WMSA360.
   If SDB->DB_TIPO == 'B'
	  SB5->(DbSetOrder(1))
	  If SB5->(MsSeek(xFilial('SB5')+SDB->DB_PRODUTO))
		 If SB5->B5_WMSEMB == '1'
			lRet := .F.
		 EndIf
	  EndIf
   EndIf
   //-- Ignora servicos jah atribuidos a outros usuarios
   If lRet .And. !Empty(SDB->DB_RECHUM) .And. SDB->DB_RECHUM<>cRecHum
	  lRet := .F.
   EndIf
   //-- Se atividade já está atribuída ao usuário e a quantidade lida está igual a solicitada
   //-- e a situação da atividade está em andamento e possuiu outras atividades em andamento
   If lRet .And. ;
	  SDB->DB_RECHUM == cRecHum .And. ;
	  SDB->DB_STATUS == cStatInte .And. ;
	  QtdComp(SDB->DB_QUANT) <= QtdComp(SDB->DB_QTDLID) .And. ;
	  DlUsrMorAtv(cRecHum,cFuncao,cUsuArma)
	  //-- Adiciona o registro atual no aColetor sem processar novamente
	  If SX5->(MsSeek(xFilial('SX5')+'L3'+SDB->DB_ATIVID))
		 cDscAtv := Upper(AllTrim(SX5->(X5Descri())))
	  EndIf
	  lPrimAtiv := DLPrimAtiv(SDB->DB_DOC,SDB->DB_SERIE,SDB->DB_CLIFOR,SDB->DB_LOJA,SDB->DB_SERVIC,SDB->DB_TAREFA,SDB->DB_IDMOVTO,SDB->DB_ORDATIV)
	  lUltiAtiv := DLUltiAtiv(SDB->DB_DOC,SDB->DB_SERIE,SDB->DB_CLIFOR,SDB->DB_LOJA,SDB->DB_SERVIC,SDB->DB_TAREFA,SDB->DB_IDMOVTO,SDB->DB_ORDATIV)
	  //-- Solicita endereco destino
	  cEndereco := SDB->DB_ENDDES
	  If lPrimAtiv .And. !lUltiAtiv .And. cDscAtv == 'MOVIMENTO VERTICAL'
		 //-- Usa endereco ORIGEM se eh primeira atividade.
		 //-- Solicita mesmo endereco, pois trata-se do 1o movto.
		 cEndereco := SDB->DB_LOCALIZ
	  EndIf
	  AAdd(aColetor,{SDB->(Recno()),DtoS(dDataBase)+Time(),SDB->DB_LOCAL,SDB->DB_LOCALIZ,cEndereco,SDB->DB_PRODUTO,SDB->DB_LOTECTL,SDB->DB_NUMLOTE,SDB->DB_QUANT,SDB->DB_CARGA,SDB->DB_DOC,SDB->DB_CLIFOR,SDB->DB_LOJA,lPrimAtiv,lUltiAtiv})
	  //-- Independente se é multiplo apanhe ou não, deve colocar o endereço no Array
		If AScan(aConfEnd,{|x|x[1]+x[2]==SDB->DB_LOCAL+cEndereco})==0
			AAdd(aConfEnd,{SDB->DB_LOCAL,cEndereco})
		EndIf
	  lRet := .F.
   EndIf

   // Verifica se há pendencias da ultima tarefa lida para permitir ser realizada uma atividade anterior reiniciada
   If lRet .And. SDB->DB_RECHUM == cRecHum .And. !Empty(__nRecSDB)
	  cFunExeAnt := DLUltFnExe(__nRecSDB)
	  If 'DLAPANHE' $ Upper(cFunExeAnt)
		 If DLPenDocAnt(cRecHum,cFuncao,cUsuZona,nIndSDB,SDB->(RecNo()),__nRecSDB)
			If !__lDestino .Or. (__lDestino .AND. lWMSCOMP)
			   lRet := .F.
			EndIf
		 EndIf
	  EndIf
   EndIf
   //-- Verifica se for conferência de expedição, se foi separado alguma quantidade para permitir conferir
   If lRet .And. 'DLCONFSAI' $ cFunExe  //-- Conferencia de expedição
	  lRet := HasPrdSep(SDB->DB_SERVIC,SDB->DB_ORDTARE,SDB->DB_CARGA,SDB->DB_DOC)
   EndIf

   //-- Verifica se permite reiniciar tarefas, e questiona uma unica vez na secao se deseja reiniciar
   If lRet
	  If lReinAuto .And. cReinAuto == 'S' .And. SDB->DB_STATUS == cStatProb .And. SDB->DB_OCORRE != '9999'
		 If !DLVTAviso('DLGV00111',STR0045, {STR0016,STR0017}) == 1  //'Existe tarefa anterior pendente. Reiniciar?'###'Sim'###'Nao'
			lReinAuto := .F. //-- Para não perguntar novamente quando solicionado que não quer reiniciar
			lRet := .F.
		 EndIf
	  Else
		 //-- Ignora atividades atribuidas a Outros Usuarios
		 If SDB->DB_STATUS<>cStatAExe .And. SDB->DB_STATUS<>cStatInte
			lRet := .F.
		 EndIf
	  EndIf
   EndIf

   If lRet
	  If ExistBlock('DLVACONV')
		 ExecBlock('DLVACONV', .F., .F., {cRecHum, cFuncao, SDB->(Recno())})
	  EndIf
	  //-- Regra para a convocacao dos Servicos x Tarefas x Atividades
	  If ExistBlock('DLGV001A')
		 lConvoca := ExecBlock('DLGV001A', .F., .F.,{cRecHum,cFuncao,SDB->DB_SERVIC,SDB->DB_TAREFA,SDB->DB_ATIVID,SDB->DB_ORDATIV,SDB->DB_DOC,lConvoca})
	  Else
		 If AllTrim(SDB->DB_RHFUNC)==AllTrim(cFuncao)
			If !Empty(SDB->DB_TAREFA) .And. !Empty(SDB->DB_ATIVID)
			   lConvoca := DLVExecAnt(nTipoConv,dDataFec,cRecHum)
			EndIf
		 EndIf
	  EndIf
	  //-- Ponto de Entrada Antes da Confirmacao da Convocacao para verificar saldo endereco origem.
	  If ExistBlock('DLGV001B')
		 aRetPE := ExecBlock('DLGV001B', .F., .F.,{cRecHum,cFuncao,SDB->DB_SERVIC,SDB->DB_TAREFA,SDB->DB_ATIVID,SDB->DB_ORDATIV,SDB->DB_DOC,lConvoca,cFunExe})
		 If ValType(aRetPE) == 'A' .And. !Empty(aRetPE) .And. ValType(aRetPE[1])=='L'
			lConvoca := aRetPE[1]
   //         If Len(aRetPE)>1
   //            lWmsSaldo := aRetPE[2]
   //         EndIf
		 EndIf
	  EndIf
   EndIf
   If lRet .And. lConvoca
	  aRetRegra := {}
	  If Empty(SDB->DB_RECHUM)
		 cNumero := Left(SDB->DB_DOC,Len(SD7->D7_NUMERO))
		 //-- Movimentacoes de CQ
		 SD7->(DbSetOrder(3))
		 If SD7->(MsSeek(xFilial('SD7')+SDB->DB_PRODUTO+SDB->DB_NUMSEQ+cNumero))
			cArmSBE := SD7->D7_LOCAL
		 Else
			cArmSBE := SDB->DB_LOCAL
		 EndIf
		 //-- Verifica se ha regras para convocacao
		 If WmsRegra('1',cArmSBE,cRecHum,SDB->DB_SERVIC,SDB->DB_TAREFA,SDB->DB_ATIVID,SDB->DB_LOCALIZ,SDB->DB_ESTFIS,SDB->DB_ENDDES,SDB->DB_ESTDES,aRetRegra)
			//-- Analisa se convocao ou nao
			If !WmsRegra('2',,cRecHum,SDB->DB_SERVIC,SDB->DB_TAREFA,SDB->DB_ATIVID,,,,,aRetRegra,,SDB->DB_CARGA)
			   lRet := .F.
			EndIf
		 Else
			//-- Convocar para esta atividade somente se encontrar regra definida para o operador.
			If lNaoConv
			   lRet := .F.
			EndIf
			//-- Apesar de o operador(A) nao ter regra definida, preciso analisar se outro operador(B) reservou a rua,
			//-- se o operador(B) ja reservou a rua o operador(A) nao sera convocado ate que a rua seja liberada.
			If lRet .And. !WmsRegra('3',cArmSBE,cRecHum,SDB->DB_SERVIC,SDB->DB_TAREFA,SDB->DB_ATIVID,SDB->DB_LOCALIZ,SDB->DB_ESTFIS,SDB->DB_ENDDES,SDB->DB_ESTDES)
			   lRet := .F.
			EndIf
			//-- Ignora a Zona de Armazenagem diferente da escolhida na convocacao
			If lRet .And. !Empty(cUsuZona)
			   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			   //³ Verifica o Tipo de Servico (1-Entrada/2-Saida/3-Mov.Interno)          ³
			   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			   cTipoServ := DC5->DC5_TIPO
			   SBE->(DbSetOrder(1)) //-- BE_FILIAL+BE_LOCAL+BE_LOCALIZ+BE_ESTFIS
			   lPertenceZ := .F.
			   If cTipoServ $'2ú3' //-- Saidas ou Mov. Internos: Considera a Zona referente ao Endereco/Zona de ORIGEM
				  If SBE->(MSSeek(xFilial('SBE')+cArmSBE+SDB->DB_LOCALIZ+SDB->DB_ESTFIS, .F.))
					 lPertenceZ := (SBE->BE_CODZON==cUsuZona)
				  EndIf
			   EndIf
			   If !lPertenceZ
				  If cTipoServ $'1ú3' //-- Entradas ou Mov. Internos: Considera a Zona referente ao Endereco/Zona de DESTINO
					 If SBE->(MSSeek(xFilial('SBE')+cArmSBE+SDB->DB_ENDDES+SDB->DB_ESTDES, .F.))
						lPertenceZ := (SBE->BE_CODZON==cUsuZona)
					 EndIf
				  EndIf
			   EndIf
			   If !lPertenceZ
				  lRet := .F.
			   EndIf
			EndIf
		 EndIf
	  EndIf
   Else
	  lRet := .F.
   EndIf

RestArea(aAreaAnt)
Return lRet

//-----------------------------------------------------------------------------
//Verifica quantidade do produto que está empenhada (já separada)
//Somente permite iniciar a conferência caso alguma atividade de separação
//tenha sido executada, disponiblizando assim itens para conferência
//-----------------------------------------------------------------------------
Static Function HasPrdSep(cServico,cOrdTar,cCarga,cPedido)
Local aAreaAnt   := GetArea()
Local aAreaDC5   := DC5->(GetArea())
Local lRet       := .F.
Local cAliasQry  := GetNextAlias()
Local cOrdSep    := "01"
Local cWhereDcf  := ""

   DC5->(DbSetOrder(1))
   If DC5->(MsSeek(xFilial("DC5")+cServico+cOrdTar))
	  DC5->(DbSkip(-1))
	  If DC5->DC5_SERVIC == cServico
		 cOrdSep := DC5->DC5_ORDEM
	  EndIf
   EndIf
   
    cWhereDcf :="%"
	If WmsCarga(cCarga)
		cWhereDcf += " AND DCF.DCF_CARGA = '"+cCarga+"'"
	Else
		cWhereDcf += " AND DCF.DCF_DOCTO = '"+cPedido+"'"
	EndIf
	cWhereDcf += "%"
	
   cAliasQry := GetNextAlias()											  
   BeginSql Alias cAliasQry
   		SELECT DISTINCT 1 
   		FROM %Table:DCF% DCF
		INNER JOIN %Table:DCR% DCR
		ON DCR.DCR_FILIAL = %xFilial:DCR%
		AND DCR.DCR_IDDCF = DCF.DCF_ID
		AND DCR.DCR_SEQUEN = DCF.DCF_SEQUEN
		AND DCR.%NotDel%
		INNER JOIN %Table:SDB% SDB
		ON SDB.DB_FILIAL = %xFilial:SDB%
		AND SDB.DB_SERVIC = DCF.DCF_SERVIC 
        AND SDB.DB_IDDCF = DCR.DCR_IDORI
        AND SDB.DB_IDMOVTO = DCR.DCR_IDMOV
        AND SDB.DB_IDOPERA = DCR.DCR_IDOPER
        AND SDB.DB_ESTORNO = ' ' 
        AND SDB.DB_ATUEST = 'N' 
        AND SDB.DB_ORDTARE = %Exp:cOrdSep%  //Assume a tarefa exatamante anterior 
        AND SDB.%NotDel%
		AND SDB.DB_STATUS IN (%Exp:cStatExec%, %Exp:cStatManu%)
        AND SDB.DB_ORDATIV = (SELECT MAX(DB_ORDATIV) 
                         		FROM %Table:SDB% SDBM 
                         		WHERE SDBM.DB_FILIAL = SDB.DB_FILIAL 
                         		AND SDBM.DB_PRODUTO  = SDB.DB_PRODUTO 
                         		AND SDBM.DB_DOC      = SDB.DB_DOC 
                         		AND SDBM.DB_SERIE    = SDB.DB_SERIE 
                         		AND SDBM.DB_CLIFOR   = SDB.DB_CLIFOR 
                         		AND SDBM.DB_LOJA     = SDB.DB_LOJA 
                         		AND SDBM.DB_SERVIC   = SDB.DB_SERVIC 
                         		AND SDBM.DB_TAREFA   = SDB.DB_TAREFA 
                         		AND SDBM.DB_IDMOVTO  = SDB.DB_IDMOVTO 
                         		AND SDBM.DB_ESTORNO  = ' ' 
                         		AND SDBM.DB_ATUEST   = 'N' 
                         		AND SDBM.%NotDel%)
        WHERE DCF.DCF_FILIAL = %xFilial:DCF%
	    AND DCF.DCF_SERVIC = %Exp:cServico%
		AND DCF.%NotDel%
		%Exp:cWhereDCF%
   EndSql
   lRet := (cAliasQry)->(!Eof())
   (cAliasQry)->(DbCloseArea())

RestArea(aAreaDC5)
RestArea(aAreaAnt)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³DLVEnderec³ Autor ³ Alex Egydio           ³ Data ³ 18.09.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Apresenta o codigo do endereco na tela do coletor de dados ³±±
±±³          ³ respeitando a configuracao do codigo do endereco.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DLVEndereco( ExpN1, ExpN2, ExpC1, ExpC2 )                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Numero da Linha                                    ³±±
±±³          ³ ExpN2 = Numero da Coluna                                   ³±±
±±³          ³ ExpC1 = Endereco                                           ³±±
±±³          ³ ExpC2 = Armazem                                            ³±±
±±³          ³ ExpN2 = Nivel Inicial a ser Visualizado                    ³±±
±±³          ³ ExpN3 = Nivel Final a ser Visualizado                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ DLGV001                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function DLVEndereco(nLin, nCol, cEndereco, cArmazem, nNivIni, nNivFim, cCabec)
Local aTelaAnt   := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local aCab       := {''}
Local aSize      := {VTMaxCol()}
Local aAreaAnt   := GetArea()
Local aAreaSBE   := SBE->(GetArea())
Local aAreaDC7   := DC7->(GetArea())
Local aEndereco  := {}
Local aNiveis    := {}
Local nX         := 1
Local nNivAtu    := 1
Local nParNivIni := SuperGetMV('MV_ENDINRF', .F., 0)
Local nParNivFim := SuperGetMV('MV_ENDFIRF', .F., 0)
Local nLenDesc   := 0
Local nLenEnd    := 0
Local cSeekDC7   := ''
Local lCfgEnd    := .F.

Default nLin       := 0
Default nCol       := 0
Default cEndereco  := SDB->DB_LOCALIZ
Default cArmazem   := SDB->DB_LOCAL
Default nNivIni    := 0
Default nNivFim    := 0
Default cCabec     := STR0020 //'Endereco'

If ExistBlock('DVDISPEN')
   cEndereco := ExecBlock('DVDISPEN', .F., .F., {cEndereco})
EndIf

//-- Considera o Parametro MV_ENDINRF
nNivIni := If(nParNivIni>0, nParNivIni, nParNivIni)

//-- Considera o Parametro MV_ENDINRF
nNivFim := If(nParNivFim>0, nParNivFim, nNivFim)

DbSelectArea('DC7')
DbSetOrder(1)

DbSelectArea('SBE')
DbSetOrder(1)
If (lCfgEnd:=(MsSeek(xFilial('SBE')+cArmazem+cEndereco, .F.) .And. !Empty(BE_CODCFG) .And. DC7->(MsSeek(cSeekDC7:=xFilial('DC7')+SBE->BE_CODCFG, .F.))))
   nX      := 1
   nNivAtu := 1
   DbSelectArea('DC7')
   Do While !Eof() .And. cSeekDC7==DC7_FILIAL+DC7_CODCFG
	  If ((nNivIni+nNivFim)==0) .Or. ((nNivIni>0.And.nNivFim>0) .And. (nNivAtu>=nNivIni.And.nNivAtu<=nNivFim))
		 aAdd(aNiveis, {AllTrim(DC7_DESEND), AllTrim(SubStr(cEndereco, nX, DC7_POSIC))})
	  EndIf
	  nX      += DC7_POSIC
	  nNivAtu ++
	  DbSkip()
   EndDo
   nLenDesc := 0
   nLenEnd  := 0
   For nX := 1 to Len(aNiveis)
	  nLenEnd := If(Len(aNiveis[nX, 2])>nLenEnd, Len(aNiveis[nX, 2]), nLenEnd)
   Next nX
   nLenDesc := VTMaxCol()-1-nLenEnd
   For nX := 1 to Len(aNiveis)
	  aAdd(aEndereco, {PadR(aNiveis[nX, 1], nLenDesc) + ' ' + PadR(aNiveis[nX, 2], nLenEnd)})
   Next nX
EndIf

VTClear()
If lCfgEnd
   aCab := {PadC(cCabec, VTMaxCol(), '_')}
   DLVTRodaPe(, .F.)
   VTaBrowse(nLin, nCol, (VTMaxRow()-2), VTMaxCol(), aCab, aEndereco, aSize)
Else
   @ nLin  , nCol VTSay PadC(cCabec, VTMaxCol(), '_')
   @ nLin+2, nCol VTSay AllTrim(cEndereco)
   DLVTRodaPe()
EndIf

RestArea(aAreaDC7)
RestArea(aAreaSBE)
RestArea(aAreaAnt)
VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)

Return NIL
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³DLVStAuto ³ Autor ³ Alex Egydio           ³ Data ³ 18.09.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava status de execucao 'A'utomatica                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DLVStAuto( ExpC1, ExpC2, ExpC3 )                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Servico                                  ³±±
±±³          ³ ExpC2 = Ordem da Tarefa registrado no SDB                  ³±±
±±³          ³ ExpC3 = Codigo da Tarefa                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ DLGV001                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function DLVStAuto(cServic,cOrdTare,cTarefa)
Local aAreaAnt  := GetArea()
Local aAreaSDB  := SDB->(GetArea())
Local cAliasNew := GetNextAlias()
Local cQuery    := ''
Local dDataFec  := DToS(WmsData())

//-- Os registros que originaram movimentacao de estoque terao o status de execucao automatica.
cQuery := " SELECT DB_FILIAL,DB_STATUS,DB_SERVIC,DB_ORDTARE,DB_TAREFA,DB_ORDATIV,R_E_C_N_O_ RECSDB "
cQuery += " FROM "+RetSqlName('SDB')+" SDB"
cQuery += " WHERE DB_FILIAL = '"+xFilial("SDB")+"'"
cQuery += " AND DB_STATUS   = '"+cStatAExe+"'"
cQuery += " AND DB_SERVIC   = '"+cServic+"'"
cQuery += " AND DB_ORDTARE  = '"+cOrdTare+"'"
cQuery += " AND DB_TAREFA   = '"+cTarefa+"'"
cQuery += " AND DB_ORDATIV  = 'ZZ' "
cQuery += " AND DB_ESTORNO  = ' ' "
cQuery += " AND DB_DATA    > '"+dDataFec+"'"
cQuery += " AND D_E_L_E_T_  = ' ' "
cQuery += " ORDER BY DB_FILIAL,DB_STATUS,DB_SERVIC,DB_ORDTARE,DB_TAREFA,DB_ORDATIV"
cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.F.,.T.)
(cAliasNew)->(DbGoTop())
// -- Verifica se data do Protheus esta diferente da data do sistema.
DLDataAtu()
DbSelectArea('SDB')
SDB->( DbSetOrder(8) )
While (cAliasNew)->(!Eof())
   SDB->(DbGoTo((cAliasNew)->RECSDB))
   If SDB->(SimpleLock())
	  SDB->DB_STATUS    := cStatAuto
	  SDB->DB_RECHUM    := __cUserID
	  If Empty(SDB->DB_DATA)
		 SDB->DB_DATA   := dDataBase
		 SDB->DB_HRINI  := Time()
	  Else
		 SDB->DB_DATAFIM:= dDataBase
		 SDB->DB_HRFIM  := Time()
	  EndIf
	  SDB->(MsUnlock())
   EndIf
   (cAliasNew)->(DbSkip())
EndDo
(cAliasNew)->( dbCloseArea() )

RestArea(aAreaSDB)
RestArea(aAreaAnt)
Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DlgVldArm ºAutor  ³ Manutencao/N3-DL   º Data ³  19/03/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validacao do Armazem digitado no coletor de dados           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³PROGRAMA DE COLETOR DE DADOS APDL                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function DlgVldArm(cUsuArma)
Local lRet   :=.T.
Local lRetPE :=.T.

//-- Permite efetuar validacoes especificas na digitacao do armazem
If ExistBlock("WMSVLARM")
   lRetPE := ExecBlock("WMSVLARM",.F.,.F.,{cUsuArma})
   If Valtype(lRetPE) == "L"
	  lRet := lRetPE
   EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DlgVldZon ºAutor  ³Rodrigo A Sartorio  º Data ³  09/10/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida a zona digitada no coletor de dados                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³PROGRAMA DE COLETOR DE DADOS APDL                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function DlgVldZon(cUsuZona)
Local lRet :=.T.
If !Empty(cUsuZona) .And. !ExistCpo('DC4', cUsuZona)
   lRet:=.F.
EndIf
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³DLVDOcorreºAutor  ³Fernando J. Siquini º Data ³  04/12/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Permite a digitacao de ocorrencias via VT100                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function DLVDOcorre()
Local aTelaAnt := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local cOcorre  :=  CriaVar('DCM_OCORRE', .F.)
Local cNumOcor := ""
Local nAviso   := 0

Do While .T.
   DLVTCabec(AllTrim(CUSERNAME), .F., .F., .T.)
	@ 02, 00 VTSay 'Prod.: ' + SDB->DB_PRODUTO
	@ 03, 00 VTSay 'Doc..: ' + SDB->DB_DOC+' '+SerieNfId("SDB",2,"DB_SERIE")
	@ 04, 00 VTSay 'S/T/A: ' + SDB->DB_SERVIC+'/'+SDB->DB_TAREFA+'/'+SDB->DB_ATIVID
	@ 05, 00 VTSay PadR(STR0030, VTMaxCol())  //'Ocorrencia'
	@ 06, 00 VTGet cOcorre Valid DLVValOcor(@cOcorre) F3 'DCM'
   VTRead
   If Empty(cOcorre) .Or. VTLastKey() == 27
	  nAviso := DLVTAviso('DLGV00105', STR0031, {STR0032, STR0033, STR0034})  //'Deseja:'###'Redigitar'###'Continuar'###'Abandonar'
	  If nAviso == 1 .Or. (nAviso == 2 .And. Empty(cOcorre))
		 Loop
	  ElseIf nAviso == 3
		 Exit
	  EndIf
   EndIf
   cNumOcor := GetSX8Num('DCN', 'DCN_NUMERO')
   If __lSX8
	  ConfirmSX8()
   EndIf
   RecLock('SDB', .F.)
   SDB->DB_OCORRE:=cOcorre
   SDB->DB_STATUS:=cStatProb
   MsUnlock()
   RecLock('DCN', .T.)
   DCN->DCN_FILIAL   := xFilial('DCN')
   DCN->DCN_NUMERO   := cNumOcor
   DCN->DCN_OCORR    := cOcorre
   DCN->DCN_STATUS   := '1'
   DCN->DCN_DTINI    := dDataBase
   DCN->DCN_HRINI    := Time()
   DCN->DCN_PROD     := SDB->DB_PRODUTO
   DCN->DCN_LOCAL    := SDB->DB_LOCAL
   DCN->DCN_QUANT    := SDB->DB_QUANT
   DCN->DCN_DOC      := SDB->DB_DOC
   DCN->DCN_SERIE    := SDB->DB_SERIE
   SerieNfId("DCN",1,"DCN_SERIE",nil,nil,SDB->DB_SERIE,SDB->DB_SERIE)
   DCN->DCN_CLIFOR   := SDB->DB_CLIFOR
   DCN->DCN_LOJA     := SDB->DB_LOJA
   DCN->DCN_ITEM     := SDB->DB_SERIE
   DCN->DCN_LOTECTL  := SDB->DB_LOTECTL
   DCN->DCN_NUMLOT   := SDB->DB_NUMLOTE
   DCN->DCN_ENDER    := SDB->DB_LOCALIZ
   DCN->DCN_NUMSER   := SDB->DB_NUMSERI
   DCN->DCN_NUMSEQ   := ProxNum()
   MsUnlock()
   DLVTAviso('DLGV00106',STR0035, {})  //'Ocorrencia Registrada! Pressione qualquer tecla.'
   lOcorre := .T.
   Exit
EndDo

VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DLGV001   ºAutor  ³Microsiga           º Data ³  12/04/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function DLVValOcor(cOcorre)
Local lRet := .T.
If !Empty(cOcorre) .And. !ExistCpo('DCM',cOcorre)
   lRet := .F.
EndIf
If VTLastKey() == 27
   cOcorre := CriaVar('DCM_OCORRE', .F.)
EndIf
Return lRet
//--------------------------------------------------------------
/*{Protheus.doc}
Verifica se a atividade anterior já foi executada para liberar
a atividade atual para convocação.

@param  nTipoConv, numérico, Tipo de convocação. Valor do parâmetro MV_TPCONVO
@param  dDataFec, data, Data do último fechamento de estoque
@param  cRecHum, caracter, Recurso humano que irá executar a tarefa. Usuário atual
@return boolean, Indicador .T. ou .F. se a atividade pode ser convocada
@author Jackson Patrick Werka
@since  08/10/2013
@obs    A atividade atual é considerada para o registro posicionado no SDB.
		O tipo de convocação tem influência direta sobre a análise feita por esta função.
		O retorno para a atividade atual vai depender se permite reinício automático.
*/
//--------------------------------------------------------------
Function DLVExecAnt(nTipoConv,dDataFec,cRecHum)
Local aAreaAnt  := GetArea()
Local lCarga    := WmsCarga(SDB->DB_CARGA)
Local lRet      := .F.
Local lAchou    := .F.
Local lRetPE    := .F.
Local nRecOri   := SDB->(Recno())
Local cQuery    := ""
Local cAliasNew := GetNextAlias()
Local lOrdMov   := SuperGetMV('MV_WMSVLMV', .F., .T.) // Valida ordem de execução dos movimentos de recebimento com conferencia
Local lConfEnd  := FwIsInCallStack("WMSA331") .And. lOrdMov .And. WMSHasConf(SDB->DB_SERVIC) //Executado via WMSA331, possui conferencia e enderecamento no mesmo servico com parametro habilitado

Default cRecHum := ""

If nTipoConv == 1 //-- Convocacao por ATIVIDADE (Default)
   //Verifica se a atividade atual é a primeira atividade
   If DLPrimAtiv(SDB->DB_DOC,SDB->DB_SERIE,SDB->DB_CLIFOR,SDB->DB_LOJA,SDB->DB_SERVIC,SDB->DB_TAREFA,SDB->DB_IDMOVTO,SDB->DB_ORDATIV,SDB->DB_ORDTARE,lConfEnd)
	  lAchou := .F.
	  lRet   := Iif(cReinAuto == 'N',(SDB->DB_STATUS==cStatAExe .OR. SDB->DB_STATUS==cStatInte),(SDB->DB_STATUS==cStatProb .OR. SDB->DB_STATUS==cStatInte .OR. SDB->DB_STATUS==cStatAExe)) //-- Convoca se a atividade ainda nao foi executada
   Else
	  //-- Não pode permitir convocar a atividade atual se alguma atividade
	  //-- do movimento atual que seja anterior a mesma não foi executada
	  cQuery := "SELECT DB_STATUS"
	  cQuery +=  " FROM "+RetSqlName('SDB')+" SDB"
	  cQuery += " WHERE DB_FILIAL  = '"+xFilial("SDB")+"'"
	  cQuery +=   " AND DB_DOC     = '"+SDB->DB_DOC+"'"
	  cQuery +=   " AND DB_SERIE   = '"+SDB->DB_SERIE+"'"
	  cQuery +=   " AND DB_CLIFOR  = '"+SDB->DB_CLIFOR+"'"
	  cQuery +=   " AND DB_LOJA    = '"+SDB->DB_LOJA+"'"
	  cQuery +=   " AND DB_PRODUTO = '"+SDB->DB_PRODUTO+"'"
	  cQuery +=   " AND DB_SERVIC  = '"+SDB->DB_SERVIC+"'"
      If lConfEnd
	      cQuery +=   " AND ((DB_TAREFA  = '"+SDB->DB_TAREFA+"'"
	      cQuery +=   " AND DB_ORDTARE = '"+SDB->DB_ORDTARE+"'"
	      cQuery +=   " AND DB_IDMOVTO = '"+SDB->DB_IDMOVTO+"')"
          cQuery +=   " OR (SDB.DB_TAREFA  <> '"+SDB->DB_TAREFA+"'"
          cQuery +=   " AND DB_ORDTARE < '"+SDB->DB_ORDTARE+"'))"
      Else
	      cQuery +=   " AND DB_TAREFA  = '"+SDB->DB_TAREFA+"'"
	      cQuery +=   " AND DB_ORDTARE = '"+SDB->DB_ORDTARE+"'"
	      cQuery +=   " AND DB_IDMOVTO = '"+SDB->DB_IDMOVTO+"'"	  
      EndIf
	  cQuery +=   " AND DB_IDOPERA < '"+SDB->DB_IDOPERA+"'"
	  cQuery +=   " AND DB_STATUS  IN ('"+cStatProb+"','"+cStatInte+"','"+cStatAExe+"')"
	  cQuery +=   " AND DB_ATUEST  = 'N'"
	  cQuery +=   " AND DB_ESTORNO = ' '"
	  cQuery +=   " AND SDB.D_E_L_E_T_ = ' ' "
	  cQuery := ChangeQuery(cQuery)
	  DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasNew,.F.,.T.)
	  If (cAliasNew)->(!Eof())
		 lRet   := .F. //-- Encontrou uma atividade anterior ainda não executada
		 lAchou := .T.
	  Else
		 lAchou := .F.
		 lRet   := Iif(cReinAuto == 'N',(SDB->DB_STATUS==cStatAExe .OR. SDB->DB_STATUS==cStatInte),(SDB->DB_STATUS==cStatProb .OR. SDB->DB_STATUS==cStatInte .OR. SDB->DB_STATUS==cStatAExe)) //-- Convoca se a atividade ainda nao foi executada
	  EndIf
	  (cAliasNew)->(DbCloseArea())
   EndIf
ElseIf nTipoConv == 2 //-- Convocacao por TAREFA/PRODUTO
   //-- Não pode permitir convocar a atividade atual se alguma atividade
   //-- da tarefa atual, para o mesmo produto, que seja anterior a mesma não foi executada
   //-- ou se alguma atividade do movimento atual que seja anterior a mesma não foi executada
   cQuery := "SELECT DB_STATUS"
   cQuery +=  " FROM "+RetSqlName('SDB')+" SDB"
   cQuery += " WHERE DB_FILIAL  = '"+xFilial("SDB")+"'"
   If lCarga
	  cQuery += " AND DB_CARGA  = '"+SDB->DB_CARGA+"'"
   Else
	  cQuery += " AND DB_DOC    = '"+SDB->DB_DOC+"'"
	  cQuery += " AND DB_SERIE  = '"+SDB->DB_SERIE+"'"
	  cQuery += " AND DB_CLIFOR = '"+SDB->DB_CLIFOR+"'"
	  cQuery += " AND DB_LOJA   = '"+SDB->DB_LOJA+"'"
   EndIf
   cQuery +=   " AND DB_PRODUTO   = '"+SDB->DB_PRODUTO+"'"
   cQuery +=   " AND DB_SERVIC  	 = '"+SDB->DB_SERVIC+"'"
   cQuery +=   " AND ((DB_ORDTARE < '"+SDB->DB_ORDTARE+"')"
   cQuery +=   " OR (DB_ORDTARE   = '"+SDB->DB_ORDTARE+"'"
   cQuery +=   " AND DB_IDMOVTO   = '"+SDB->DB_IDMOVTO+"'"
   cQuery +=   " AND DB_IDOPERA   < '"+SDB->DB_IDOPERA+"'))"
   cQuery +=   " AND DB_STATUS  IN ('"+cStatProb+"','"+cStatInte+"','"+cStatAExe+"')"
   cQuery +=   " AND DB_ATUEST    = 'N'"
   cQuery +=   " AND DB_ESTORNO   = ' '"
   cQuery +=   " AND SDB.D_E_L_E_T_ = ' ' "
   cQuery := ChangeQuery(cQuery)
   DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasNew,.F.,.T.)
   If (cAliasNew)->(!Eof())
	  lRet   := .F. //-- Encontrou uma atividade anterior ainda não executada
	  lAchou := .T.
   Else
	  lAchou := .F.
	  lRet   := Iif(cReinAuto == 'N',(SDB->DB_STATUS==cStatAExe .OR. SDB->DB_STATUS==cStatInte),(SDB->DB_STATUS==cStatProb .OR. SDB->DB_STATUS==cStatInte .OR. SDB->DB_STATUS==cStatAExe)) //-- Convoca se a atividade ainda nao foi executada
   EndIf
   (cAliasNew)->(DbCloseArea())
Else //-- Convocacao por TAREFA COMPLETA
   //-- Não pode permitir convocar a atividade atual se alguma atividade da tarefa anterior
   //-- não foi executada, ou seja, se a tarefa anterior não foi completamente finalizada
   //-- ou se alguma atividade do movimento atual que seja anterior a mesma não foi executada
   cQuery := "SELECT DB_STATUS"
   cQuery +=  " FROM "+RetSqlName('SDB')+" SDB"
   cQuery += " WHERE DB_FILIAL  = '"+xFilial("SDB")+"'"
   If lCarga
	  cQuery += " AND DB_CARGA  = '"+SDB->DB_CARGA+"'"
   Else
	  cQuery += " AND DB_DOC    = '"+SDB->DB_DOC+"'"
	  If SDB->DB_ORIGEM <> "SC9"
		 cQuery += " AND DB_SERIE = '"+SDB->DB_SERIE+"'"
	  EndIf
	  cQuery += " AND DB_CLIFOR = '"+SDB->DB_CLIFOR+"'"
	  cQuery += " AND DB_LOJA   = '"+SDB->DB_LOJA+"'"
   EndIf
   cQuery +=   " AND DB_SERVIC  = '"+SDB->DB_SERVIC+"'"
   cQuery +=   " AND ((DB_ORDTARE < '"+SDB->DB_ORDTARE+"')"
   cQuery +=   " OR (DB_ORDTARE   = '"+SDB->DB_ORDTARE+"'"
   cQuery +=   " AND DB_IDMOVTO   = '"+SDB->DB_IDMOVTO+"'"
   cQuery +=   " AND DB_IDOPERA   < '"+SDB->DB_IDOPERA+"'))"
   cQuery +=   " AND DB_STATUS  IN ('"+cStatProb+"','"+cStatInte+"','"+cStatAExe+"')"
   cQuery +=   " AND DB_ATUEST  = 'N'"
   cQuery +=   " AND DB_ESTORNO = ' '"
   cQuery +=   " AND SDB.D_E_L_E_T_ = ' ' "
   cQuery := ChangeQuery(cQuery)
   DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasNew,.F.,.T.)
   If (cAliasNew)->(!Eof())
	  lRet   := .F. //-- Encontrou uma atividade anterior ainda não executada
	  lAchou := .T.
   Else
	  lAchou := .F.
	  lRet   := Iif(cReinAuto == 'N',(SDB->DB_STATUS==cStatAExe .OR. SDB->DB_STATUS==cStatInte),(SDB->DB_STATUS==cStatProb .OR. SDB->DB_STATUS==cStatInte .OR. SDB->DB_STATUS==cStatAExe)) //-- Convoca se a atividade ainda nao foi executada
   EndIf
   (cAliasNew)->(DbCloseArea())
EndIf
If ExistBlock('DLGVEXAN')
   lRetPE := ExecBlock('DLGVEXAN', .F., .F., {lRet, nRecOri, lAchou, cRecHum})
   If Valtype(lRetPE) == "L"
	  lRet := lRetPE
   EndIf
EndIf
RestArea(aAreaAnt)
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CHGCONF   ºAutor  ³Fernando J. Siquini º Data ³  01/07/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relogio com Data e Hora do Sistema                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function DLVTClock(lAllwaysOn)
Local aTelaAnt   := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local aSemana    := {'Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab'}
Local aMeses     := {'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'}
Local cAmPm      := STR0001   //'am'
Local cDiaSem    := ''
Local cDia       := ''
Local cMes       := ''
Local cAno       := ''
Local cHora      := ''
Local cMin       := ''
Local cSeg       := ''
Local cString1   := ''
Local cString2   := ''
Local nTimeIni   := Seconds()

Default lAllwaysOn := .F.

DLVTCabec(STR0036, .F., .F., .T.)   //'Data/Hora'
Do While .T.
   cDiaSem := aSemana[Dow(Date())]
   cDia    := StrZero(Day(Date()), 2)
   cMes    := aMeses[Month(Date())]
   cAno    := StrZero(Year(Date()),4)
   cHora   := Left(Time(),2)
   cMin    := Subs(Time(),4,2)
   cSeg    := Right(Time(),2)
   cAmPm   := STR0001   //'am'
   If Val(cHora) > 12 .And. Val(cHora) <= 23
	  cHora := StrZero(Val(cHora) - 12,2)
	  cAmPm := STR0014  //'pm'
   EndIf
   cString1 := cDiaSem + ' ' + cDia + '/' + cMes + '/' + cAno
   cString2 := cHora + ':' + cMin + ':' + cSeg + ' ' + cAmPm
   @ Int(VTMaxRow()/2)  , 00 VTSay PadC(cString1, VTMaxCol())
   @ Int(VTMaxRow()/2)+1, 00 VTSay PadC(cString2, VTMaxCol())
   DLVTRodaPe(Nil, .F.)
   If VTInkey() == 13 .Or. If(!lAllwaysOn, (Seconds()-nTimeIni)>300, .T.)
	  Exit
   EndIf
   Sleep(1000)
EndDo
VTInkey()
VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³DLVTCabec   ³ Autor ³Fernando Joly Siquini³ Data ³29.04.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Exibe um Cabecalho Padrao de 20 caracteres na Linha ZERO   ³±±
±±³          ³ para a Tarefa a ser executada.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DLVTCabec(ExpC1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Titulo do cabecalho (se NIL considera o cCadastro) ³±±
±±³          ³ ExpL1 = Rola a tela anterior para Cima                     ³±±
±±³          ³ ExpL2 = Rola a tela anterior para Baixo                    ³±±
±±³          ³ ExpL3 = Limpa a tela antrerior                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ DLGV???                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function DLVTCabec(cCabec, lRolaUP, lRolaDW, lClear)
Local cCabecDef  := If(!(Type('cCadastro')=='C'),STR0037,cCadastro)  //'Tarefa'

Default cCabec     := cCabecDef
Default lRolaUP    := .T.
Default lRolaDW    := .F.
Default lClear     := .F.

If lClear
   VTclear() //-- Limpa a tela Anterior
ElseIf lRolaDW
   DLVTRolaDW() //-- Rola a tela Anterior p/Baixo
Else
   DLVTRolaUP() //-- Rola a tela Anterior p/Baixo
EndIf

@ 0,0 VTSay PadC(cCabec, VTMaxCol(), '_')

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³DLVTRodaPe  ³ Autor ³Fernando Joly Siquini³ Data ³29.04.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Exibe um Rodape Padrao de 20 caracteres nas Linhas CINCO   ³±±
±±³          ³ e SEIS com informacoes ao usuario                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DLVTRodaPe(ExpC1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Conteudo Rodape (NIL considera "Pressione <ENTER>")³±±
±±³          ³ ExpL1 = Espera a digitacao de alguma tecla?                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ DLGV???                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function DLVTRodaPe(cRodaPe, lWait)

Default cRodaPe    := STR0038 //'Pressione <ENTER>'
Default lWait      := .T.

If VTRow() < (VTMaxRow()-1)
   @ (VTMaxRow()-1), 00 VTSay Replicate('_', VTMaxCol())
EndIf
If VTRow() < VTMaxRow()
   @ VTMaxRow(), 00 VTSay PadC(cRodaPe, VTMaxCol())
EndIf
If lWait
   VTInkey(0)
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³DLVTRolaUP  ³ Autor ³Fernando Joly Siquini³ Data ³29.04.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Rola a tela atual para cima                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DLVTRolaUP()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ DLGV???                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function DLVTRolaUP()
Local nX := 0

For nX := 1 to VTMaxRow()
   VTScroll(00, 00, VTMaxRow(), VTMaxCol(), 1)
Next nX

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³DLVTRolaDW  ³ Autor ³Fernando Joly Siquini³ Data ³29.04.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Rola a tela atual para Baixo                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DLVTRolaDW()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ DLGV???                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function DLVTRolaDW()
Local nX := 0

For nX := 1 to VTMaxRow()
   VTScroll(00, 00, VTMaxRow(), VTMaxCol(), -1)
Next nX

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³DLVTAviso   ³ Autor ³Fernando Joly Siquini³ Data ³29.04.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Exibe um Aviso na Tela                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DLVTAviso(ExpC1, ExpC2, ExpA1)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Cabecalho do Aviso (Default = "Atencao")           ³±±
±±³          ³ ExpC2 = Conteudo do Aviso                                  ³±±
±±³          ³ ExpA1 = Array com as Opcoes para Retorno do Aviso - Max 3  ³±±
±±³          ³         (Default = "Pressione <Enter>")                    ³±±
±±³          ³ ExpL1 = Espera a Selecao ou Sai da Rotina                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ A Opcao do Array Escolhida                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ DLGV???                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function DLVTAviso(cCabec, cMsg, aOpcoes, lWait)
Local aTelaAnt  := VTSave(00, 00, VTMaxRow(),  VTMaxCol())
Local nOpcao    := 1
Local nX        := 0
Local nLines    := 0
Local aMsg      := {}
Local lTerminal := (VTMaxRow()==1)
Default cCabec  := STR0004 //'Atencao'
Default cMsg    := ''
Default aOpcoes := {}
Default lWait   := .T.

//-- Permite SOMENTE TRES opcoes
If Len(aOpcoes) > 1
   If Len(aOpcoes)>3
	  aSize(aOpcoes, 3)
   EndIf
EndIf

VTBeep(2)
If ! lTerminal
   DLVTCabec(cCabec, .F., .F., .T.)
   //Determina o múmero de linhas da mensagem
   nLines := MlCount(cMsg, VTMaxCol())
   //Se não é multipla escolha e a mensagem ultrapassa a tela
   //Força a quebra da mensagem para gerar rolagem da tela
   If (Len(aOpcoes) <= 0 .And. nLines >= VTMaxRow())
	  For nX := 1 To nLines
		 AAdd(aMsg, MemoLine(cMsg, VTMaxCol(), nX))
	  Next nX
	  VTAchoice(01,00,VTMaxRow(),VtMaxCol(),aMsg,,,VTMaxRow(),.T.)
	  VTInkey()
   //Se as opções mais a mensagem ultrapassam a tela
   ElseIf ((Len(aOpcoes)+nLines) > VTMaxRow())
	  //Exibe a mensagem de forma cortada, forçando rolagem de tela
	  For nX := 1 To nLines
		 AAdd(aMsg, MemoLine(cMsg, VTMaxCol(), nX))
	  Next nX
	  //Força uma impressão das respostas na tela
	  For nX := 1 To Len(aOpcoes)
		 @ nX+(VTMaxRow()-Len(aOpcoes)), 00 VTSay aOpcoes[nX]
	  Next nX
	  //Mostra a mensagem para o usuário com rolagem de tela
	  VTAchoice(01,00,(VTMaxRow()-Len(aOpcoes)),VtMaxCol(),aMsg,,,(VTMaxRow()-Len(aOpcoes)),.T.)
	  VTInkey()
	  //Mostra as opções, agora com a opção de escolha do usuário
	  nOpcao := VTachoice(((VTMaxRow()+1)-Len(aOpcoes)),0,VTMaxRow(),VtMaxCol(),aOpcoes,,,1,.T.)
	  VTInkey()
   Else
	  For nX := 1 To nLines
		 @ nX, 00 VTSay MemoLine(cMsg, VTMaxCol(), nX)
	  Next nX
	  If Len(aOpcoes) > 0
		 nOpcao := VTachoice(((VTMaxRow()+1)-Len(aOpcoes)),0,VTMaxRow(),VtMaxCol(),aOpcoes,,,1,.T.)
		 VTInkey()
	  Else
		 DLVTRodaPe(, lWait)
	  EndIf
   EndIf
   If lWait
	  VTRestore(00, 00, VTMaxRow(),  VTMaxCol(), aTelaAnt)
   EndIf
Else
   VtClear()
   @ 00,00 VTSay cMsg
   If Len(aOpcoes) > 0
	  nOpcao := VTAchoice(01, 00, VTMaxRow(),  VTMaxCol(), aOpcoes)
	  VTInkey()
   Else
	  nOpcao := 1
	  VTInkey(0)
   EndIf
   If lWait
	  VTRestore(00, 00, VTMaxRow(),  VTMaxCol(), aTelaAnt)
   EndIf
EndIf
Return nOpcao

//--------------------------------------------------------------
/*{Protheus.doc}
Verifica se a atividade a ser executada é a última da movimentação

@author  Jackson Patrick Werka
@Since   21/08/2013

@param cServico,   caracter, (Obrigatório) Serviço atual sendo executado
@param cTarefa,    caracter, (Obrigatório) Tarefa atual sendo executada
@param cIdMovto,   caracter, (Obrigatório) Identificador do movimento atual sendo executado
@param cOrdAtiv,   caracter, (Obrigatório) Ordem da atividade atual sendo executada

@return boolean, Indicador de última atividade .T. ou .F.
*/
//--------------------------------------------------------------
Function DLUltiAtiv(cDocumento,cSerie,cCliFor,cLoja,cServico,cTarefa,cIdMovto,cOrdAtiv)
Local aAreaAnt  := GetArea()
Local cQuery    := ""
Local cAliasQry := GetNextAlias()
Local lUltAtiv  := .T.

   //-- Query utiliza o documento e cliente/fornecedor para melhora no indice de pesquisa
   cQuery := "SELECT SDB.R_E_C_N_O_ RECSDB"
   cQuery +=  " FROM "+RetSqlName('SDB')+" SDB "
   cQuery += " WHERE SDB.DB_FILIAL  = '"+xFilial("SDB")+"'"
   cQuery +=   " AND SDB.DB_DOC     = '"+cDocumento+"'"
   cQuery +=   " AND SDB.DB_SERIE   = '"+cSerie+"'"
   cQuery +=   " AND SDB.DB_CLIFOR  = '"+cCliFor+"'"
   cQuery +=   " AND SDB.DB_LOJA    = '"+cLoja+"'"
   cQuery +=   " AND SDB.DB_SERVIC  = '"+cServico+"'"
   cQuery +=   " AND SDB.DB_TAREFA  = '"+cTarefa+"'"
   cQuery +=   " AND SDB.DB_IDMOVTO = '"+cIdMovto+"'"
   cQuery +=   " AND SDB.DB_ORDATIV > '"+cOrdAtiv+"'"
   cQuery +=   " AND SDB.DB_ATUEST  = 'N'"
   cQuery +=   " AND SDB.DB_ESTORNO = ' '"
   cQuery +=   " AND SDB.D_E_L_E_T_ = ' ' "

   DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
   Do While (cAliasQry)->(!Eof()) .And. lUltAtiv
	  lUltAtiv := .F.
	  (cAliasQry)->(DbSkip())
   EndDo
   (cAliasQry)->(DbCloseArea())
RestArea(aAreaAnt)
Return lUltAtiv

//--------------------------------------------------------------
/*/{Protheus.doc}
Verifica se a atividade a ser executada é a primeira da movimentação

@author  Jackson Patrick Werka
@Since   21/08/2013

@param cServico,   caracter, (Obrigatório) Serviço atual sendo executado
@param cTarefa,    caracter, (Obrigatório) Tarefa atual sendo executada
@param cIdMovto,   caracter, (Obrigatório) Identificador do movimento atual sendo executado
@param cOrdAtiv,   caracter, (Obrigatório) Ordem da atividade atual sendo executada

@return boolean, Indicador de primeira atividade .T. ou .F.
/*/
//--------------------------------------------------------------
Function DLPrimAtiv(cDocumento,cSerie,cCliFor,cLoja,cServico,cTarefa,cIdMovto,cOrdAtiv,cOrdTarefa,lConfEnd)
Local aAreaAnt  := GetArea()
Local cQuery    := ""
Local cAliasQry := GetNextAlias()
Local lPrimAtiv := .T.
Default cOrdTarefa := "01"
Default lConfEnd := .F.

   //Se for a primeira, nem verifica o SELECT, pois já indica isso
   If cOrdAtiv == "01" .And. IIF(lConfEnd, cOrdTarefa == "01", .T.)
	  Return lPrimAtiv
   EndIf

   //-- Query utiliza o documento e cliente/fornecedor para melhora no indice de pesquisa
   cQuery := "SELECT SDB.R_E_C_N_O_ RECSDB"
   cQuery +=  " FROM "+RetSqlName('SDB')+" SDB "
   cQuery += " WHERE SDB.DB_FILIAL  = '"+xFilial("SDB")+"'"
   cQuery +=   " AND SDB.DB_DOC     = '"+cDocumento+"'"
   cQuery +=   " AND SDB.DB_SERIE   = '"+cSerie+"'"
   cQuery +=   " AND SDB.DB_CLIFOR  = '"+cCliFor+"'"
   cQuery +=   " AND SDB.DB_LOJA    = '"+cLoja+"'"
   cQuery +=   " AND SDB.DB_SERVIC  = '"+cServico+"'"
   If lConfEnd
       cQuery +=   " AND ((SDB.DB_TAREFA  = '"+cTarefa+"'"
       cQuery +=   " AND SDB.DB_IDMOVTO = '"+cIdMovto+"'"
       cQuery +=   " AND SDB.DB_ORDATIV < '"+cOrdAtiv+"')"
       cQuery +=   " OR (SDB.DB_TAREFA  <> '"+cTarefa+"'"
       cQuery +=   " AND DB_IDOPERA < '"+SDB->DB_IDOPERA+"'"
       cQuery +=   " AND DB_ORDTARE < '"+cOrdTarefa+"'))"
       cQuery +=   " AND DB_STATUS IN ('"+cStatProb+"','"+cStatInte+"','"+cStatAExe+"')"
   Else
       cQuery +=   " AND SDB.DB_TAREFA  = '"+cTarefa+"'"
       cQuery +=   " AND SDB.DB_IDMOVTO = '"+cIdMovto+"'"
       cQuery +=   " AND SDB.DB_ORDATIV < '"+cOrdAtiv+"'"
   EndIf
   cQuery +=   " AND SDB.DB_ATUEST  = 'N'"
   cQuery +=   " AND SDB.DB_ESTORNO = ' '"
   cQuery +=   " AND SDB.D_E_L_E_T_ = ' '"

   DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
   Do While (cAliasQry)->(!Eof()) .And. lPrimAtiv
	  lPrimAtiv := .F.
	  (cAliasQry)->(DbSkip())
   EndDo
   (cAliasQry)->(DbCloseArea())
RestArea(aAreaAnt)
Return lPrimAtiv

//--------------------------------------------------------------
/*/{Protheus.doc}
Verifica se a atividade a ser executada está aglutinada,
ou seja, se a mesma possui mais de um IDDCF na tabela DCR
@author  Jackson Patrick Werka
@Since   31/01/2014

@param cIdMovto,   caracter, (Obrigatório) Identificador do movimento atual sendo executado
@return boolean, Indicador de atividade aglutinada .T. ou .F.
/*/
//--------------------------------------------------------------
Function DLAtivAglt(cIdDCF,cIdMovto,cIdOpera)
Local aAreaAnt  := GetArea()
Local cQuery    := ""
Local cAliasQry := GetNextAlias()
Local lRet      := .F.

   cQuery := "SELECT DCR_IDDCF"
   cQuery += "  FROM " +RetSqlName("DCR")+" DCR "
   cQuery += " WHERE DCR_FILIAL  = '"+xFilial("DCR")+"'"
   cQuery += "   AND DCR_IDORI   = '"+cIdDCF+"'"
   cQuery += "   AND DCR_IDMOV   = '"+cIdMovto+"'"
   cQuery += "   AND DCR_IDOPER  = '"+cIdOpera+"'"
   cQuery += "   AND DCR_IDDCF <> '"+cIdDCF+"'"
   cQuery += "   AND DCR.D_E_L_E_T_ = ' '"

   DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
   lRet := (cAliasQry)->(!Eof())
   (cAliasQry)->(DbCloseArea())
RestArea(aAreaAnt)
Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³DlgV001Six| Autor ³ Alex Egydio              ³Data³15.03.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se o indice foi criado no SDB                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function DlgV001Six(nIndSDB1)
Local aAreaAnt   := GetArea()
Local aAreaSIX   := SIX->(GetArea())
Local lRet       := .F.
Local cNewOrd    := ""
Local cIndSDB    := "DB_FILIAL+DB_STATUS+DB_PRIORI+DB_CARGA+DB_DOC+DB_SERIE+DB_CLIFOR+DB_LOJA+DB_ITEM+DB_SERVIC+DB_ORDTARE+DB_ORDATIV"

SIX->(DbSetOrder(1))
If SIX->(DbSeek("SDB"))
   While SIX->(!Eof() .And. SIX->INDICE == "SDB")
	  If AllTrim(Upper(SIX->CHAVE)) == cIndSDB
		 cNewOrd := SIX->ORDEM
		 lRet    := .T.
		 Exit
	  EndIf
	  SIX->(DbSkip())
   EndDo
EndIf

If lRet
   If IsAlpha(cNewOrd)
	  nIndSDB1 := (Asc(cNewOrd)-55)
   Else
	  nIndSDB1 := Val(cNewOrd)
   EndIf
   DbSelectArea('SDB')
   DbSetOrder(nIndSDB1)

   lRet := AllTrim(Upper(IndexKey()))==cIndSDB
EndIf

If !lRet
   DLVTAviso('DLGV00107', STR0029+'"'+cIndSDB+'"'+STR0050, {'Ok'})   //'Criar a chave de indice '##' no SDB.'
EndIf

RestArea(aAreaSIX)
RestArea(aAreaAnt)
Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DispFuncWMºAutor  ³Microsiga           º Data ³  05/31/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function DispFuncWMS(aFuncoesWMS)
Local aCab       := {'N.',STR0008}  //'Funcoes Atrib.      '
Local aSize      := {Len(aCab[1]), Len(aCab[2])}
Local aTelaAnt   := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local aFuncoes   := {}
Local nX         := 0

For nX := 1 to Len(aFuncoesWMS)
   aAdd(aFuncoes, {StrZero(aFuncoesWMS[nX, 1], 2), aFuncoesWMS[nX, 3]})
Next nX

If Len(aFuncoes) > 0
   VTClear()
   For nX := 1 to VTMaxRow()-1
	  @ nX, 00 VTSay PadR('  |', VTMaxCol())
   Next nX
   DLVTRodaPe(, .F.)
   VTaBrowse(00, 00, Min(VTMaxRow()-1,Len(aFuncoes)+1), VTMaxCol(), aCab, aFuncoes, aSize)
Else
   DLVTAviso('DLGV00108', STR0039) //'Nenhuma Funcao Cadastrada...'
EndIf

VTRestore(00, 00, VTMaxRow()  , VTMaxCol(), aTelaAnt)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DLDataAtu ºAutor  ³Microsiga           º Data ³  14/01/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³MV_WMSAtDt = Atualiza data do Protheus com data atual para  º±±
±±º          ³             gravacao da data no SDB para RF                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function DLDataAtu()
Local lWMSAtDt := (SuperGetMV('MV_WMSATDT', .F., 'S')=='S') //-- Indica se a data do Protheus deve ser atualizada se diferente da data do sistema
If dDataBase # Date() .And. lWMSAtDt
   dDataBase := Date()
EndIf
Return NIL

/*--------------------------------------------------------------
Monta a Query que valida as atividades para convocação
Jackson Patrick Werka
--------------------------------------------------------------*/
Static Function QryValAtCv(cRecHum,cFuncao,cUsuArma,nRecnoSDB,nIndSDB,cStatusSDB,lFiltraSer,lFiltraDoc)
Local cRecHumVz := Space(Len(SDB->DB_RECHUM))
Local cQuery    := ""

   cQuery := "SELECT CASE"
   cQuery +=           " WHEN SDB.DB_STATUS = '"+cStatInte+"' THEN 0"
   cQuery +=           " WHEN SDB.DB_STATUS = '"+cStatProb+"' THEN 1"
   cQuery +=           " WHEN (SDB.DB_STATUS NOT IN ('"+cStatProb+"','"+cStatInte+"') AND SDB.DB_RECHUM = '"+cRecHum+"') THEN 2"
   cQuery +=           " WHEN (SDB.DB_STATUS NOT IN ('"+cStatProb+"','"+cStatInte+"') AND SDB.DB_RECHUM = '"+cRecHumVz+"') THEN 3"
   cQuery +=        " ELSE 99 "
   cQuery +=        " END AS ORDWMS,"
   cQuery +=        " SDB.R_E_C_N_O_ RECSDB"
   If !lFiltraSer
	  cQuery +=",(SELECT DC5.R_E_C_N_O_ FROM " + RetSqlName('DC5') + " DC5"
	  cQuery +=  " WHERE DC5.DC5_FILIAL = '"+xFilial("DC5")+"'"
	  cQuery +=    " AND DC5.DC5_SERVIC = SDB.DB_SERVIC "
	  cQuery +=    " AND DC5.DC5_TAREFA = SDB.DB_TAREFA "
	  cQuery +=    " AND DC5.DC5_ORDEM = SDB.DB_ORDTARE "
	  cQuery +=    " AND DC5.D_E_L_E_T_ = ' ') RECDC5 "
	  cQuery +=",(SELECT DC6.R_E_C_N_O_ FROM " + RetSqlName('DC6')+" DC6"
	  cQuery +=  " WHERE DC6.DC6_FILIAL = '"+xFilial("DC6")+"'"
	  cQuery +=    " AND DC6.DC6_TAREFA = SDB.DB_TAREFA "
	  cQuery +=    " AND DC6.DC6_ATIVID = SDB.DB_ATIVID "
	  cQuery +=    " AND DC6.DC6_ORDEM = SDB.DB_ORDATIV "
	  cQuery +=    " AND DC6.D_E_L_E_T_ = ' ') RECDC6 "
   EndIf
   cQuery +=   " FROM " + RetSqlName('SDB')+" SDB "
   cQuery +=  " WHERE SDB.DB_FILIAL = '"+xFilial("SDB")+"'"
   //Verifica a versao e o paramentro que permite reabrir tarefa paralizadas
   cQuery += cStatusSDB
   cQuery += " AND SDB.DB_ATUEST = 'N'"
   cQuery += " AND SDB.DB_ESTORNO = ' '"
   If lFiltraSer
	  cQuery += " AND SDB.DB_SERVIC  = '"+SDB->DB_SERVIC+"'"
	  cQuery += " AND SDB.DB_TAREFA  = '"+SDB->DB_TAREFA+"'"
	  cQuery += " AND SDB.DB_ATIVID  = '"+SDB->DB_ATIVID+"'"
	  cQuery += " AND SDB.DB_ORDTARE = '"+SDB->DB_ORDTARE+"'"
	  cQuery += " AND SDB.DB_ORDATIV = '"+SDB->DB_ORDATIV+"'"
   EndIf
   cQuery += " AND SDB.DB_RHFUNC  = '"+cFuncao+"'"
   If !Empty(cUsuArma)
	  cQuery += " AND SDB.DB_LOCAL = '"+cUsuArma+"'"
   EndIf
   If lFiltraDoc
	  If WmsCarga(SDB->DB_CARGA)
		 cQuery +=  " AND SDB.DB_CARGA = '"+SDB->DB_CARGA+"'"
	  Else
		 cQuery +=  " AND SDB.DB_DOC    = '"+SDB->DB_DOC+"'"
		 cQuery +=  " AND SDB.DB_CLIFOR = '"+SDB->DB_CLIFOR+"'"
		 cQuery +=  " AND SDB.DB_LOJA   = '"+SDB->DB_LOJA+"'"
	  EndIf
   EndIf
   If ExistBlock('DLV001WH')
	  cQuery += ExecBlock('DLV001WH',.F.,.F.,{cRecHum,cFuncao})
   EndIf
   cQuery += " AND SDB.D_E_L_E_T_ = ' ' "
   If nRecnoSDB <> 0
	  cQuery += " AND SDB.R_E_C_N_O_ <> " + AllTrim(Str(nRecnoSDB))
   EndIf
   cQuery += " ORDER BY ORDWMS, "

   If ExistBlock('DLV001ORD')
	  cQuery += ExecBlock('DLV001ORD', .F., .F., {nIndSDB})
   Else
	  cQuery += SqlOrder(SDB->(IndexKey(nIndSDB))) //DB_FILIAL+DB_STATUS+DB_PRIORI+DB_CARGA+DB_DOC+DB_SERIE+DB_CLIFOR+DB_LOJA+DB_ITEM+DB_SERVIC+DB_ORDTARE+DB_ORDATIV
   EndIf
   cQuery := ChangeQuery(cQuery)

Return cQuery
/*--------------------------------------------------------------
Verifica se existe mais alguma atividade a ser executada no modo
multi-tarefa possibilitando ao usuário executar diversas
atividades sem ter a necessidade de finalizar a anterior.

Jackson Patrick Werka
--------------------------------------------------------------*/
Function DLVMultAtv(nRecnoSDB)
Local aAreaAnt  := GetArea()
Local cAliasAtv := GetNextAlias()
Local cFuncao   := aParConv[1]
Local cRecHum   := aParConv[3]
Local nIndSDB   := aParConv[4]
Local cUsuArma  := aParConv[5]
Local cUsuZona  := aParConv[6]
Local nTipoConv := aParConv[7]
Local dDataFec  := aParConv[8]
Local cCabecDef := If(!(Type('cCadastro')=='C'),STR0037,cCadastro)  //'Tarefa'
Local cQuery    := ""
Local lConvoca  := .F.
//Verifica a versao e o paramentro que permite reabrir tarefa paralizadas
Local cStatusSDB:= Iif((lReinAuto .And. cReinAuto == 'S')," AND SDB.DB_STATUS IN ('"+cStatInte+"','"+cStatProb+"','"+cStatAExe+"')", " AND SDB.DB_STATUS IN ('"+cStatInte+"','"+cStatAExe+"')")

   cQuery := QryValAtCv(cRecHum,cFuncao,cUsuArma,nRecnoSDB,nIndSDB,cStatusSDB,.T.,.F.)
   DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasAtv,.F.,.T.)
   While (cAliasAtv)->(!Eof())
	  //verifica se o registro do SDB ja foi executado pelo processo de multi-tarefas
	  If AScan(aColetor,{|x|x[1] == (cAliasAtv)->RECSDB }) > 0
		 (cAliasAtv)->(DbSkip())
		 Loop
	  EndIf

	  //Não precisa avaliar as tabelas DC5 e DC6, pois deve ser a mesma atividade
	  If !DLVAvalSDB((cAliasAtv)->RECSDB,/*nRecnoDC5*/,/*nRecnoDC6*/,cRecHum,cFuncao,cUsuArma,cUsuZona,nTipoConv,dDataFec,@cFunExe,/*cRadioF*/,nIndSDB)
		 (cAliasAtv)->(DbSkip())
		 Loop
	  EndIf

	  If DLVTAviso(cCabecDef,STR0052,{STR0016,STR0017}) == 1 //"Tarefa"###"Selecionar outra tarefa?"###"Sim"###"Nao"
		 DLVConvSDB(SDB->(Recno()))
		 lConvoca := .T.
	  EndIf
	  Exit
   EndDo
   (cAliasAtv)->(DbCloseArea())

RestArea(aAreaAnt)
Return lConvoca

/*--------------------------------------------------------------
Verifica se existe mais alguma atividade a ser executada quando
o apanhe permite selecionar vários movimentos desde que não sejam
maior que a norma do produto, possibilitando ao usuário executar
diversas atividades sem ter a necessidade de finalizar a anterior.

Jackson Patrick Werka
--------------------------------------------------------------*/
Function DLVMultApn(nRecnoSDB)
Local aAreaAnt  := GetArea()
Local cAliasAtv := GetNextAlias()
Local cFuncao   := aParConv[1]
Local cRecHum   := aParConv[3]
Local nIndSDB   := aParConv[4]
Local cUsuArma  := aParConv[5]
Local cUsuZona  := aParConv[6]
Local nTipoConv := aParConv[7]
Local dDataFec  := aParConv[8]
Local cQuery    := ""
Local lConvoca  := .F.
//Verifica a versao e o paramentro que permite reabrir tarefa paralizadas
Local cStatusSDB:= Iif((lReinAuto .And. cReinAuto == 'S')," AND SDB.DB_STATUS IN ('"+cStatInte+"','"+cStatProb+"','"+cStatAExe+"')", " AND SDB.DB_STATUS IN ('"+cStatInte+"','"+cStatAExe+"')")

   cQuery := QryValAtCv(cRecHum,cFuncao,cUsuArma,nRecnoSDB,nIndSDB,cStatusSDB,.T.,.T.)
   DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasAtv,.F.,.T.)
   While (cAliasAtv)->(!Eof())
	  //verifica se o registro do SDB ja foi executado pelo processo de multi-tarefas
	  If AScan(aColetor,{|x|x[1] == (cAliasAtv)->RECSDB }) > 0
		 (cAliasAtv)->(DbSkip())
		 Loop
	  EndIf

	  //Não precisa avaliar as tabelas DC5 e DC6, pois deve ser a mesma atividade
	  If !DLVAvalSDB((cAliasAtv)->RECSDB,/*nRecnoDC5*/,/*nRecnoDC6*/,cRecHum,cFuncao,cUsuArma,cUsuZona,nTipoConv,dDataFec,@cFunExe,/*cRadioF*/,nIndSDB)
		 (cAliasAtv)->(DbSkip())
		 Loop
	  EndIf
	  //Verifica se o SDB a ser convocado não é uma norma, neste caso força a descarga dos anteriores
	  If QtdComp(SDB->DB_QUANT) < QtdComp(DLQtdNorma(SDB->DB_PRODUTO,SDB->DB_LOCAL,SDB->DB_ESTFIS,,.F.))
		 DLVConvSDB(SDB->(Recno()))
		 lConvoca := .T.
	  EndIf
	  Exit
   EndDo
   (cAliasAtv)->(DbCloseArea())

RestArea(aAreaAnt)
Return lConvoca

/*--------------------------------------------------------------
Seta a próxima atividade a ser convocada, sem ter a necessidade de remontar
o SQL da rotina de convocação automática. Utilizada no multi-tarefa e também
quando o SDB é desmembrado em várias movimentações para convocar o novo SDB.
Jackson Patrick Werka
--------------------------------------------------------------*/
Function DLVConvSDB(nRecnoSDB,lConvSDB)
Default lConvSDB := .T.
   __nRecSDB  := nRecnoSDB
   __lConvoca := lConvSDB
Return Nil

//----------------------------------------------------------
/*/{Protheus.doc}
Verifica a funcao da atividade
@param      nRecSDB        Recno SDB

@author  Alexsander Burigo Corrêa
@version P11
@Since    30/08/13
@obs  Verifica a funcao da atividade
/*/
//----------------------------------------------------------
Static Function DLUltFnExe(nRecSDB)
Local aAreaAnt   := GetArea()
Local aAreaSDB   := SDB->(GetArea())
Local cFunExeAux := ''

   SDB->(DbGoTo(nRecSDB))
   DbSelectArea('DC5')
   DC5->(DbSetOrder(1)) //-- DC5_FILIAL+DC5_SERVIC+DC5_ORDEM
   If DC5->(MsSeek(xFilial('DC5')+SDB->DB_SERVIC+SDB->DB_ORDTARE))
	  SX5->(DbSetOrder(1))
	  SX5->(MsSeek(xFilial('SX5')+'L6'+DC5->DC5_FUNEXE))
	  cFunExeAux := AllTrim(Upper(SX5->(X5Descri())))
   EndIf

RestArea(aAreaSDB)
RestArea(aAreaAnt)
Return cFunExeAux

//----------------------------------------------------------
/*/{Protheus.doc}
Verifica se há atividades pendentes que podem ser realizadas
pelo recurso

@param      cRecHum        Recurso Humano
@param      cFuncao        Função Usuario
@param      cUsuZona       Zona Usuário
@param      dDataFec       Data Fechamento
@param      nIndSDB        Indice SDB
@param      rRecSDB        Recno SDB posicionado

@author  Alexsander Burigo Corrêa
@version P11
@Since    22/08/13
@obs  Verifica se há atividades pendentes que podem ser realizadas
pelo recurso
/*/
//----------------------------------------------------------
Static Function DLPenDocAnt(cRecHum,cFuncao,cUsuZona,nIndSDB,nRecSDBAtu,nRecSDBAnt)
Local aAreaSDB  := SDB->(GetArea())
Local lRet      := .F.
Local cAliasDCQ := GetNextAlias()
Local cAliasDoc := GetNextAlias()
Local cArmazem  := ""
Local cNumero   := ""
Local lContinua := .F.
Local cQuery    := ""
Local cStatusSDB:= " AND SDB.DB_STATUS IN ('"+cStatInte+"','"+cStatAExe+"')"

   //SDB da atividade atual
   SDB->(DbGoTo(nRecSDBAtu))

   If WmsCarga(SDB->DB_CARGA)
	  cCargaPed := SDB->DB_CARGA
   Else
	  cCargaPed := SDB->DB_DOC+SDB->DB_CLIFOR+SDB->DB_LOJA
   EndIf

   //SDB da atividade anterior
   SDB->(DbGoTo(nRecSDBAnt))
   //Verifica se a documento/carga é diferente do atual
   If cCargaPed <> Iif(WmsCarga(SDB->DB_CARGA), SDB->DB_CARGA, SDB->DB_DOC+SDB->DB_CLIFOR+SDB->DB_LOJA)
	  cNumero := Left(SDB->DB_DOC,Len(SD7->D7_NUMERO))
	  SD7->(DbSetOrder(3))
	  If SD7->(MsSeek(xFilial('SD7')+SDB->DB_PRODUTO+SDB->DB_NUMSEQ+cNumero))
		 cArmazem := SD7->D7_LOCAL
	  Else
		 cArmazem := SDB->DB_LOCAL
	  EndIf
	  //Verifica se possui regra de convocação exclusiva por documento/carga
	  cQuery := " SELECT DCQ_FILIAL, DCQ_TPREGR, DCQ_DOCEXC "
	  cQuery += " FROM " + RetSqlName('DCQ')
	  cQuery += " WHERE DCQ_FILIAL = '"+xFilial("DCQ")+"'"
	  cQuery += " AND DCQ_DOCEXC <> '2' "
	  cQuery += " AND DCQ_LOCAL = '"+cArmazem+"' "
	  cQuery += " AND (DCQ_CODFUN = ' ' or DCQ_CODFUN = '"+cRecHum+"') "
	  cQuery += " AND (DCQ_CODZON = ' ' or DCQ_CODZON = '"+cUsuZona+"') "
	  cQuery += " AND (DCQ_SERVIC = ' ' or DCQ_SERVIC = '"+SDB->DB_SERVIC+"') "
	  cQuery += " AND D_E_L_E_T_ = ' ' "
	  cQuery := ChangeQuery(cQuery)
	  DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasDCQ,.F.,.T.)

	  If (cAliasDCQ)->(!Eof())
		 lContinua := .T.
	  EndIf
	  (cAliasDCQ)->(DbCloseArea())

	  If lContinua
		 //Se possui regra verifica se o documento anterior possui pendencias
		 cQuery := QryValAtCv(cRecHum,cFuncao,cArmazem,nRecSDBAnt,nIndSDB,cStatusSDB,.T.,.T.)
		 DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasDoc,.F.,.T.)

		 If (cAliasDoc)->(!Eof())
			lRet := .T.
		 EndIf
		 (cAliasDoc)->(DbCloseArea())
	  EndIf
   EndIf
   RestArea(aAreaSDB)
Return lRet

/*/------------------------------------------------------------
Verifica se possui algum registro em andamento no SDB
além dos que estão no array aColetor
------------------------------------------------------------/*/
Static Function DlUsrMorAtv(cRecHum,cFuncao,cUsuArma)
Local aAreaSDB  := SDB->(GetArea())
Local lRet      := .F.
Local cQuery    := ""
Local cAliasSDB := GetNextAlias()
Local cRecSDB   := AllTrim(Str(SDB->(Recno())))
Local nCnt      := 0

   For nCnt := 1 To Len(aColetor)
	  cRecSDB := cRecSDB+","+AllTrim(Str(aColetor[nCnt,1]))
   Next

   cQuery := "SELECT SDB.R_E_C_N_O_ RECSDB"
   cQuery +=  " FROM "+RetSqlName('SDB')+" SDB "
   cQuery += " WHERE SDB.DB_FILIAL = '"+xFilial("SDB")+"'"
   cQuery += " AND SDB.DB_STATUS   = '"+cStatInte+"'"
   cQuery += " AND SDB.DB_ATUEST   = 'N'"
   cQuery += " AND SDB.DB_ESTORNO  = ' '"
   cQuery += " AND SDB.DB_SERVIC  = '"+SDB->DB_SERVIC+"'"
   cQuery += " AND SDB.DB_TAREFA  = '"+SDB->DB_TAREFA+"'"
   cQuery += " AND SDB.DB_ATIVID  = '"+SDB->DB_ATIVID+"'"
   cQuery += " AND SDB.DB_ORDTARE = '"+SDB->DB_ORDTARE+"'"
   cQuery += " AND SDB.DB_ORDATIV = '"+SDB->DB_ORDATIV+"'"
   cQuery += " AND SDB.DB_RECHUM  = '"+cRecHum+"'"
   cQuery += " AND SDB.DB_RHFUNC  = '"+cFuncao+"'"
   If !Empty(cUsuArma)
	  cQuery += " AND SDB.DB_LOCAL = '"+cUsuArma+"'"
   EndIf
   cQuery += " AND SDB.D_E_L_E_T_ = ' ' "
   cQuery += " AND SDB.R_E_C_N_O_ NOT IN ("+cRecSDB+")"
   DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSDB,.F.,.T.)
   If (cAliasSDB)->(!Eof())
	  lRet := .T.
   EndIf
   (cAliasSDB)->(DbCloseArea())

RestArea(aAreaSDB)
Return lRet

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³DLGV110ORD | Autor ³ Evaldo Cevinscki Jr.     ³Data³10.01.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Ordena os registros conforme paramentro para descarga        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function DLGV001ORD(aColetor,nOriDest)
Local aAux := {}
Local i
Local nWmsMDes  := SuperGetMV('MV_WMSMDES',.F.,0)
Local aColetorX := aClone(aColetor)

Default nOriDest := 1

If nWmsMDes == 0
   //ordenação por endereço destino
   ASort(aColetorX,,,{|x,y| x[5]+x[6]+x[7]+x[8] < y[5]+y[6]+y[7]+y[8]})

   For i:= 1 to Len(aColetorX)

	  //para produtos+lote+sublote no mesmo endereco destino faz o agrupamento somando as quantidades.
	  If nOriDest == 1
		 nAux := aScan(aAux,{|x|x[5]+x[6]+x[7]+x[8] == aColetorX[i][5]+aColetorX[i][6]+aColetorX[i][7]+aColetorX[i][8] })
	  Else
		 nAux := aScan(aAux,{|x|x[4]+x[6]+x[7]+x[8] == aColetorX[i][4]+aColetorX[i][6]+aColetorX[i][7]+aColetorX[i][8] })
	  EndIf
	  If nAux == 0
		 aAdd(aAux,aColetorX[i])
	  Else
		 aAux[nAux][9] += aColetorX[i][9]
	  EndIf

	  aDel(aColetorX,i) //apaga do array o registro que ja foi gravado no array auxiliar
	  aSize(aColetorX,Len(aColetorX)-1)   //exclui fisicamente o registro, reordenando o array

	  If Len(aColetorX) > 0
		 i--   //como eh eliminado cada registro do array apanhe, decrementa o contador
	  Else
		 Exit //quando todos os registros ja estiverem reordenados no array auxiliar, sai fora do FOR
	  EndIf
   Next i

ElseIf nWmsMDes == 1 //ordenacao inversa do apanhe agrupando por endereco destino iguais
   aSort(aColetorX,,,{|x,y| x[2] > y[2]}) //1o ordena no inverso do apanhe
   //monta array auxiliar agrupando por endereco destino
   aAux := {}
   cEndDest := ''
   For i:= 1 To Len(aColetorX)

	  nReg := aScan(aColetorX,{|x|x[5] == cEndDest }) //verifica se tem algum registro com o mesmo endereco destino
	  If nReg > 0 .And. aScan(aAux,{|x| x[2] == aColetorX[nReg][2]}) == 0 //se achar com mesmo endereco verifica ainda se ja foi gravado no array auxiliar

		 //para produtos+lote+sublote no mesmo endereco destino faz o agrupamento somando as quantidades.
		 nAux := aScan(aAux,{|x|x[5]+x[6]+x[7]+x[8] == aColetorX[nReg][5]+aColetorX[nReg][6]+aColetorX[nReg][7]+aColetorX[nReg][8] })
		 If nAux == 0
			aAdd(aAux,aColetorX[nReg])
		 Else
			aAux[nAux][9] += aColetorX[nReg][9]
		 EndIf

		 aDel(aColetorX,nReg) //apaga do array o registro que ja foi gravado no array auxiliar
		 aSize(aColetorX,Len(aColetorX)-1)   //exclui fisicamente o registro, reordenando o array
	  Else
		 cEndDest := aColetorX[i][5] //armazena nessa variavel para agrupar por endereco destino

		 //para produtos+lote+sublote no mesmo endereco destino faz o agrupamento somando as quantidades.
		 nAux := aScan(aAux,{|x|x[5]+x[6]+x[7]+x[8] == aColetorX[i][5]+aColetorX[i][6]+aColetorX[i][7]+aColetorX[i][8] })
		 If nAux == 0
			aAdd(aAux,aColetorX[i])
		 Else
			aAux[nAux][9] += aColetorX[i][9]
		 EndIf

		 aDel(aColetorX,i)
		 aSize(aColetorX,Len(aColetorX)-1)
	  EndIf
	  If Len(aColetorX) > 0
		 i--   //como eh eliminado cada registro do array apanhe, decrementa o contador
	  Else
		 Exit //quando todos os registros ja estiverem reordenados no array auxiliar, sai fora do FOR
	  EndIf
   Next i

EndIf

Return aAux

//----------------------------------------------------------
/*/{Protheus.doc}
Atualiza o campo logico __lDestino para permitir o controle de convocacao
de serviços antes interrompidos que devido prioridade são executados
no meio de outra carga

@author  Alexsander Burigo Corrêa
@version P11
@Since    30/08/13
@obs  Atualiza o campo logico __lDestino para permitir o controle de convocacao
de serviços antes interrompidos que devido prioridade são executados
no meio de outra carga
/*/
//----------------------------------------------------------
Function DLV001EDT() // Endereco destino igual a true
   __lDestino := .T.
Return (Nil)

//----------------------------------------------------------
/*/{Protheus.doc}
Visualiza o valor da __lDestino
@author  Alexsander Burigo Corrêa
@version P11
@Since    30/08/13
@obs  Visualiza o valor da __lDestino
/*/
//----------------------------------------------------------
Function DLV001VD() // Endereco destino igual a true
Return __lDestino

Function DLVEndDes(lDestino)
   If ValType(lDestino) == "L"
	  __lDestino := lDestino
   EndIf
Return __lDestino

/*/----------------------------------------------------------
Responsável por atualizar a situação do SDB após a execução da atividade
Caso seja passado o valor ele vai "setar" o valor
Caso não seja passado vai retornar o último valor salvo
----------------------------------------------------------/*/
Static __lAltSts := .T.
Function DLVAltSts(lAltSts)
Local lOldAltSts := __lAltSts
   If ValType(lAltSts) == "L"
	  __lAltSts := lAltSts
   EndIf
Return lOldAltSts

/*/----------------------------------------------------------
Responsável por controlar a opção quando o usuário pressiona ESC
Caso seja passado o valor ele vai "setar" o valor
Caso não seja passado vai retornar o último valor salvo
0-Nenhum;1-Abandona Bloqueando Atividades;2-Bloqueia Atividade Atual;3-Pula Atividade Atual;
----------------------------------------------------------/*/
Static __nOpcESC := 0
Function DLVOpcESC(nOpcESC)
   If ValType(nOpcESC) == "N"
	  __nOpcESC := nOpcESC
   EndIf
Return __nOpcESC

/*/----------------------------------------------------------
Responsável por verificar as parametrizações, indicando ao usuário
se o sistema irá ativar a opção de "Pular Atividade" quando o usuário
pressionar ESC numa convocação.
----------------------------------------------------------/*/
Static __lPulaAtiv := Nil
Function DLVPulaAti()
   If ValType(__lPulaAtiv) != "L"
	  //-- Pega o valor do parâmetro
	  __lPulaAtiv := SuperGetMV("MV_WMSPARF",.F.,.F.)
	  //-- Verifica o parametro de ordem de sequencia
	  If __lPulaAtiv
		 If !("DB_SEQPRI" $ SuperGetMV("MV_WMSPRIO",.F.,""))
			DLVTAViso("SIGAWMS","Não é possível pular atividade. Parâmetro MV_WMSPRIO não contém campo DB_SEQPRI.")
			__lPulaAtiv := .F.
		 EndIf
	  EndIf
   EndIf
Return __lPulaAtiv

/*/----------------------------------------------------------
Altera a prioridade da atividade atual gerando uma nova sequencia
de execução para apenas esta atividade de forma que a mesma seja
alocada no final da fila das atividades atribuidas para o usuário
----------------------------------------------------------/*/
Static __nRecPula := 0
Function DLGVAltPri()
Local aRetRegra:= {}
Local cWmsPrio := SuperGetMV('MV_WMSPRIO', .F., '' ) //-- Prioridade de convocacao no WMS.
Local lRegDoc  := WmsRegra('1',SDB->DB_LOCAL,__cUserID,SDB->DB_SERVIC,SDB->DB_TAREFA,SDB->DB_ATIVID,SDB->DB_LOCALIZ,SDB->DB_ESTFIS,SDB->DB_ENDDES,SDB->DB_ESTDES,aRetRegra)
   SDB->DB_SEQPRI := WMSProxSeq('MV_WMSSQPR','DB_SEQPRI') //Proxima sequencia da execucao dos servicos
   SDB->DB_PRIORI := "ZZ"+Iif(Empty(cWmsPrio),'',&cWmsPrio)+"ZZ"
   //-- Se não possui regra por documento exclusivo, libera o recurso humano
   If !lRegDoc .Or. (lRegDoc .And. aRetRegra[17] == "2")
	  SDB->DB_RECHUM := Space(Len(SDB->DB_RECHUM))
   EndIf
   __nRecPula := SDB->(Recno())
Return Nil

/*/----------------------------------------------------------
 Validações genéricas relacionadas ao código do produto
----------------------------------------------------------/*/
Function DLVValProd(cProduto,cLoteCtl,cNumLote,nQtde)
Local aProduto := {}
	If Empty(cProduto)
		Return .F.
	EndIf
	aProduto := CBRetEtiEAN(cProduto)
	If Len(aProduto) > 0
		cProduto := aProduto[1]
		nQtde    := 0 // Se nQtde = 0, solicita digitacao
		cLoteCtl := Padr(aProduto[3],TamSx3("B8_LOTECTL")[1])
		If ExistBlock("CBRETEAN")
			nQtde := aProduto[2]
		EndIf
	Else
		aProduto := CBRetEti(cProduto,'01')
		If Len(aProduto) > 0
			cProduto := aProduto[1]
			nQtde    := aProduto[2]
			cLoteCtl := Padr(aProduto[16],TamSx3("B8_LOTECTL")[1])
			cNumLote := Padr(aProduto[17],TamSx3("B8_NUMLOTE")[1])
		Else
			WmsMessage(STR0054) // "Etiqueta inválida!"
			cProduto := Space(128)
			VTKeyBoard(Chr(20))
		EndIf
	EndIf
Return .T.

/*/{Protheus.doc} WMSHasConf
	(Valicao se o servico tem conferencia e recebimento. Validacao pontual)
	@type  Function
	@author equipe WMS
	@since 21/03/2024
	@param cServ, servico
	@see (DLOGWMSMSP-16063)
	/*/
Function WMSHasConf(cServ)
	Local lHasConf  := .F.
	Local lHasEnd   := .F.
	Local aAreaDC5  := DC5->(GetArea())
	Local cQuery    := ""
	Local cAliasDC5 := GetNextAlias()

	cQuery := "SELECT DC5.DC5_OPERAC "
	cQuery +=  " FROM "+RetSqlName('DC5')+" DC5 "
	cQuery += " WHERE DC5.DC5_FILIAL = '"+xFilial("DC5")+"'"
	cQuery += " AND DC5.DC5_SERVIC   = '"+cServ+"'"
	cQuery += " AND (DC5.DC5_OPERAC = '1' OR DC5.DC5_OPERAC = '6') " //Endereçamento/Conferência Entrada
	cQuery += " AND DC5.D_E_L_E_T_ = ' ' "

	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasDC5,.F.,.T.)
	Do While (cAliasDC5)->(!Eof())
		If (cAliasDC5)->DC5_OPERAC = '6'
			lHasConf := .T.
		EndIf
		If (cAliasDC5)->DC5_OPERAC = '1'
			lHasEnd := .T.
		EndIf
		(cAliasDC5)->(dbSkip())
	EndDo
	(cAliasDC5)->(DbCloseArea())

	RestArea(aAreaDC5)

Return (lHasConf .And. lHasEnd)
