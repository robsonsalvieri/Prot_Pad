#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'CTBAATF.CH'
#INCLUDE "FWLIBVERSION.CH"

STATIC __lSN4Excl	:= FWModeAccess("SN4",1) == 'E' .AND. FWModeAccess("SN4",2) == 'E' .AND. FWModeAccess("SN4",3) == 'E'
STATIC __lFilorig   := Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} CTBAATF
Rotina de contabilização dos processos que foram executados com a
configuração da contabilização como Off-Line, com processamento
Multi-Thread.

@author marylly.araujo
@since 13/01/2014
@version MP12
/*/
//-------------------------------------------------------------------

Function CTBAATF()
Local bProcess	:= {|oProcesso| Iif(CtbValiDt(,dDataBase  ,,,,{"ATF001"},),CTATFMTR(oProcesso),.F.) }    
Local cPerg		:= "CTBAATF"
Local aInfo		:= {}
Local oProcesso	:= Nil
Local cLibLabel 	:= "20240520"
Local lLibSchedule	:= FwLibVersion() >= cLibLabel
Local lSchedule 	:= FWGetRunSchedule()

Private lAutomato := IsBlind()

/*
 * Botão para visualização do log de processamento da Contabilização Off-Line
 */
Aadd(aInfo,{STR0001, { || ProcLogView(,FunName()) },"WATCH" }) //"Visualizar"

If !lAutomato .Or. (lSchedule .And. lLibSchedule)

	oProcesso := tNewProcess():New("CTBAATF",;
										STR0026,; //"Contabilização Off-Line do Ativo Fixo"
										bProcess,;
										STR0027,; //"Rotina para contabilização dos registros do ambiente Ativo Fixo que foram contabilizados de forma off-line."
										cPerg,;
										aInfo,;
										.T.,;
										5,;
										STR0028,; //"Descrição do painel Auxiliar"
										.T., /*lViewExecute*/;
										.F., /*lOneMeter*/;
										.T.	 /*lSchedAuto*/)
Else
	CTATFMTR()
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CTATFMTR
Função de controle e execução das tarefas de cada Thread, de acordo com
quantidade de threads definidas pelo usuário.

@author marylly.araujo
@since 13/01/2014
@version MP12
/*/
//-------------------------------------------------------------------
Function CTATFMTR(oProcesso)
Local lRet			:= .T.
Local nQtdProc		:= GetMv("MV_ATFCTHR", .F., 1 )
Local oIPC			:= Nil
Local nContProc		:= 0
Local cRotThread	:= FunName()
Local cChave		:= cRotThread + "_" + AllTrim(SM0->M0_CODIGO) + "_" + StrTran(AllTrim(xFilial("SN4")), " ", "_")
Local cMostraLanc	:= MV_PAR01
Local cAglutLanc	:= MV_PAR02
Local dDtInicial	:= MV_PAR03
Local dDtFinal		:= MV_PAR04
Local cRotATF		:= Iif(Len(Alltrim(MV_PAR05)) == 1, "0"+Alltrim(MV_PAR05), MV_PAR05)
Local cQuebraPrc	:= MV_PAR06
Local cConsidFil	:= MV_PAR07
Local nAtvJaClas	:= MV_PAR08
Local cAlsTabReg	:= cRotThread + "_" + AllTrim(SM0->M0_CODIGO) + "_" + StrTran(AllTrim(xFilial("SN4")), " ", "_")
Local nQtdTotal		:= 0
Local nQtdLote		:= 0
Local nIniLote		:= 0
Local nFinLote		:= 0
Local bProcCTB		:= { || }
Local lUsaFlag		:= GETMV("MV_CTBFLAG",.F.,.F.)
Local cIdCV8		:= ''
Local aSelFil		:= {}
Local aTmpFil		:= {}
Local lCtbInTran	:= .F.
Local aParam 		:= {}
Local lCheckObj 	:= ValType(oProcesso) == "O"
Local cLibLabel 	:= "20240520"
Local lSchedule 	:= FWGetRunSchedule()
Local lLibSchedule	:= FwLibVersion() >= cLibLabel

Private cTipoGer    := SuperGetMv( "MV_ATFTIOA", .F., "12" )
Private lExSeqNJ    := .F.

If !(AllTrim(cTipoGer) $ '10|12')
	cTipoGer := "12"
EndIf

Default oProcesso := Nil

dbSelectArea("SN4")
dbSetOrder(1) //Garantir que indice 1 da SN4 esteja aberto 

//Validacao para o bloqueio do processo
If !CtbValiDt(,dDataBase  ,,,,{"ATF001"},)
	lRet := .F.
EndIf

If lRet .And. nQtdProc > 30
	If !lAutomato
		Help(" ",1,"CTBATFTRD",,STR0029,1,0) //"Quantidade de Thread não permitida. São permitidas até 30 thread para o processamento da contabilização off-line."
		lRet := .F.
	ElseIf lCheckObj
		oProcesso:SaveLog(STR0029)
		lRet := .F.
	EndIf
EndIf

If lRet .AND. nQtdProc > 1
	lCtbInTran := CTBINTRAN(1,cMostraLanc == 1)
	
	If !lCtbInTran
		If !lAutomato
			lRet := MsgYesNo(STR0030,STR0031)//"O processamento será feito sem multithread. Concorda com operação?" ##"Atenção"
			nQtdProc := 1 // Definido para não processar com multiplas threads.
		ElseIf lCheckObj
			oProcesso:SaveLog(STR0030)
			nQtdProc := 1 // Definido para não processar com multiplas threads.
		EndIf
	EndIf
EndIf

If lRet .AND. cConsidFil == 1
	aSelFil := AdmGetFil(.T.,.F.,"SN4")
	If Empty(aSelFil)
		Help(" ",1,"CTBATFIL",,STR0032, 1, 0 ) //"Selecione uma filial para busca de dados." 
		lRet := .F.
	EndIf
EndIf

/*
 * Definição de Quais Processos do Ativo Fixo serão contabilizados na Execução desta Rotina
 * 01 = Aquisição
 * 02 = Depreciação
 * 03 = Outros Movimentos
 * 04 = Todas as Rotinas
 */
If lRet
	CTATFDADOS(cRotATF,@cAlsTabReg,dDtInicial,dDtFinal,cConsidFil,aSelFil,aTmpFil,nAtvJaClas)
EndIf

bProcCTB := { || CTATFCTB( cRotATF, cAlsTabReg ,nIniLote, nFinLote, cQuebraPrc, cAglutLanc, cMostraLanc, lUsaFlag, cConsidFil, aParam, , oProcesso) }

ProcLogIni( {},FunName(),,@cIdCV8 )
ProcLogAtu( "INICIO" , STR0033 ,,,.T. ) // "Contabilização Off-Line dos Processos do Ambiente Ativo Fixo"

If lCheckObj
	oProcesso:SaveLog("INICIO - "+STR0033)
EndIf

/*
 * Verifica se o processamento será Multi-Thread
 */
If lRet .AND. nQtdProc > 1
	
	/*
	 * Trava a rotina para não ter acesso concorrente
	 */
	If !LockByName( cChave, .F. , .F. )
		Help( " " ,1, cChave ,, STR0034 ,1, 0 ) //"Outro usuário está usando a rotina. Tente novamente mais tarde."
	Else

		aParam := {dDataBase,cUsuario, cUsername}
		TcRefresh(cAlsTabReg)
	
		nQtdTotal	:= (cAlsTabReg)->(RecCount())
		nQtdLote	:= ROUND(ABS(nQtdTotal / nQtdProc),0)
		
 		//Defino uma quantidade mínima por thread 
		//Pois o sistema estava travando ao abrir 
		//Muitas threads para poucos registros
		If nQtdLote < 30
			nQtdProc := ROUND(ABS(nQtdTotal / 30),0)		
			If nQtdProc < 1
				nQtdProc := 1
			EndIf	
			nQtdLote := ROUND(ABS(nQtdTotal / nQtdProc),0)
		EndIf 
		
		/*
		 * Objeto do Controlador de Threads (Instancia para Execução das Threads)
		 */
		oIPC := FWIPCWait():New( cRotThread + "_" + AllTrim(STR(SM0->(RECNO()))) , 10000 )
		
		/*
		 * Inicia as Threads
		 */
		oIPC:SetThreads( nQtdProc )
		
		/*
		 * Informa o Ambiente Para Execução da Thread
		 */
		oIPC:SetEnvironment( cEmpAnt , cFilAnt )
		
		/*
		 * Função para ser executada na Thread
		 */
		oIPC:Start( "CTATFCTB" )
		
		Sleep( 600 )
		ProcRegua( nQtdTotal )
		
		/*
		 * Abertura de Threads
		 */
		For nContProc := 1 To nQtdProc

			If !lAutomato .And. (!lSchedule .And. !lLibSchedule)
				oProcesso:IncRegua1(STR0035) //"Iniciando contabilização dos registros off-line..."
				
				IncProc()
			EndIf
				
			/*
			 * Definição do ínicio do intervalo de registros que será processado em cada Thread
			 */
			If nContProc == 1
				nIniLote := 1
			Else
				nIniLote += nQtdLote
			EndIf
			
			/*
			 * Definição do final do intervalo de registros que será processado em cada Thread
			 */
			If nContProc == nQtdProc
				nFinLote := nQtdTotal
			Else
				nFinLote += nQtdLote
			EndIf
			
			/*
			 * Inicia a execução da função na Threads
			 */				
			oIPC:Go( cRotATF, cAlsTabReg ,nIniLote, nFinLote, cQuebraPrc, cAglutLanc, cMostraLanc, lUsaFlag, cConsidFil, aParam,,oProcesso)
		Next nContProc
				
		/*
		 * Fechamento das Threads Iniciadas (O método aguarda o encerramentos de todas as Threads antes de retornar ao controle.
		 */
		oIPC:Stop()
		
		FreeObj(oIPC)
		oIPC := Nil
		
		/*
		 * Destrava rotina após finalizar a execução das Threads
		 */
		UnLockByName( cChave, .F. , .F. )
		
		If !lAutomato	
			ProcLogAtu( "MENSAGEM",  STR0036 ,,,.T. )	//"Processo concluido sem ocorrências"
		ElseIf lCheckObj
			oProcesso:SaveLog("MENSAGEM - "+STR0036)			
		EndIf

	EndIf
ElseIf lRet .AND. nQtdProc == 1
	Eval(bProcCTB)
	
	If !lAutomato
		ProcLogAtu( "MENSAGEM",  STR0036 ,,,.T. )	//"Processo concluido sem ocorrências"
	ElseIf lCheckObj
		oProcesso:SaveLog("MENSAGEM - "+STR0036)
	EndIf
Else
	If !lAutomato
		ProcLogAtu( "MENSAGEM",  STR0037 ,,,.T. )	//"Processo de contabilização cancelado."
	ElseIf lCheckObj
		oProcesso:SaveLog("MENSAGEM - "+STR0037)
	EndIf
EndIf

If Select(cAlsTabReg) > 0
	/*
	 * Fecha área de trabalho
	 */
	(cAlsTabReg)->(DbCloseArea())
	
	/*
	 * Verifica se a tabela existe no banco de dados e exclui
	 */
	If TcCanOpen(cAlsTabReg)
		TcDelFile(cAlsTabReg)
	EndIf
EndIf

If !lAutomato
	ProcLogView(cFilAnt,FunName(),,cIdCV8)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CTATFQSN4
Função de busca dos dados da tabela SN4 das movimentações feita no
ambiente do Ativo Fixo (Aquisição/Baixa/Depreciação).

@author marylly.araujo
@since 13/01/2014
@version MP12
/*/
//-------------------------------------------------------------------
Function CTATFQSN4(cAlsTabReg,aCampos,dDtInicial,dDtFinal,cConsidFil,aSelFil,aTmpFil,nAtvJaClas, cIdMov)
	local oExecSN4 	as object
	Local nQryParam as Numeric
	Local cQrySN4		:= ''
	Local aArea		:= GetArea()
	Local aSN4Area	:= {}
	Local cTmpSN4Fil	:= ''

	Default nAtvJaClas := 1 
	Default cIdMov     := ""

	oExecSN4 := FWPreparedStatement():New()
	nQryParam := 1

	DbSelectArea('SN4')
	aSN4Area := SN4->(GetArea())

	cQrySN4 := 'INSERT INTO ' + cAlsTabReg + CRLF

	//Via procedure sempre grava o idmov unica diferenca e que quando cIdMov vir preenchido faz filtro no where
	cQrySN4 += "(FILIAL,ORIGEM,RECNO,LP,TABELA,CPOFLAG, CPODTCTB ,IDMOV "+ IIF(__lFilorig, " , FILORIG", "") +" , R_E_C_N_O_ ) " + CRLF

	cQrySN4 += 'SELECT ' + CRLF
	
	cQrySN4 += 'SN4.N4_FILIAL ' + CRLF
	cQrySN4 += ',SN4.N4_ORIGEM ' + CRLF
	cQrySN4 += ',SN4.R_E_C_N_O_  SN4RECNO ' + CRLF
	cQrySN4 += ',SN4.N4_LP ' + CRLF
	cQrySN4 += ", 'SN4' " + CRLF
	cQrySN4 += ", 'N4_LA' " + CRLF
	cQrySN4 += ", 'N4_DCONTAB' " + CRLF
	//Via procedure sempre grava o idmov unica diferenca e que quando cIdMov vir preenchido faz filtro no where
	cQrySN4 += ',SN4.N4_IDMOV  IDMOV' + CRLF
	If __lFilorig
		cQrySN4 += ',SN3.N3_FILORIG FILORIG' + CRLF
	EndIf	
	cQrySN4 += ', ROW_NUMBER() OVER (ORDER BY SN4.R_E_C_N_O_ ) ' + CRLF

	cQrySN4 += ' FROM ' + RetSqlName('SN4') + ' SN4 ' + CRLF

	If nAtvJaClas == 2 
		cQrySN4 += " , "+RetSqlName("SN1")+" SN1 "+ CRLF
	Endif

	If __lFilorig
		cQrySN4 += " , "+RetSqlName("SN3")+" SN3 "+ CRLF
	EndIf	

	cQrySN4 += ' WHERE ' + CRLF
	cQrySN4 += " SN4.N4_LA IN  (?) "
	cQrySN4 += " AND SN4.N4_DATA BETWEEN ? AND ? ""
	cQrySN4 += " AND SN4.D_E_L_E_T_ = ? "

	If nAtvJaClas == 2 
		cQrySN4 += "       and SN1.N1_STATUS   <>  ? "+ CRLF
		cQrySN4 += "       and SN1.D_E_L_E_T_  =   ? "+ CRLF
		cQrySN4 += "       and SN1.N1_FILIAL   = SN4.N4_FILIAL "
		cQrySN4 += "       and SN1.N1_CBASE    = SN4.N4_CBASE "
		cQrySN4 += "       and SN1.N1_ITEM     = SN4.N4_ITEM "
	Endif

	If cConsidFil == 2
		cQrySN4 += " AND SN4.N4_FILIAL = ? "+CRLF
	ElseIf cConsidFil == 1
		cQrySN4 += " AND SN4.N4_FILIAL ? "+CRLF
		If __lFilorig
			cQrySN4 += " AND SN3.N3_FILIAL = SN4.N4_FILIAL "+CRLF
			cQrySN4 += " AND SN3.N3_CBASE = SN4.N4_CBASE "+CRLF 
			cQrySN4 += " AND SN3.N3_ITEM = SN4.N4_ITEM "+CRLF 
			cQrySN4 += " AND SN3.N3_TIPO = SN4.N4_TIPO "+CRLF
			cQrySN4 += " AND SN3.N3_SEQ = SN4.N4_SEQ "+CRLF
			cQrySN4 += " AND SN3.N3_TPSALDO =  SN4.N4_TPSALDO " + CRLF
			cQrySN4 += " AND SN3.D_E_L_E_T_  = ? "+ CRLF
		EndIf
		aAdd(aTmpFil, cTmpSN4Fil)
	EndIf

	If !Empty(cIdMov)
		cQrySN4 += " AND SN4.N4_IDMOV = ?"
	Endif

	oExecSN4:SetQuery(cQrySN4)
	oExecSN4:SetIn(nQryParam++ ,{ Space(1), 'N'})//N4_LA
	oExecSN4:SetString(nQryParam++ ,DTOS(dDtInicial))//N4_DATA
	oExecSN4:SetString(nQryParam++ ,DTOS(dDtFinal))//N4_DATA
	oExecSN4:SetString(nQryParam++ ,Space(1)) //D_E_L_E_T_

	If nAtvJaClas == 2 
		oExecSN4:SetString(nQryParam++ ,'0') //N1_STATUS
		oExecSN4:SetString(nQryParam++ ,Space(1)) //D_E_L_E_T_
	Endif

	If cConsidFil == 2
		oExecSN4:SetString(nQryParam++ , xFilial("SN4",cFilAnt)) //N4_FILIAL
	ElseIf cConsidFil == 1
		oExecSN4:SetUnsafe(nQryParam++ , GetRngFil( aSelFil, "SN4", .T., @cTmpSN4Fil )) //N4_FILIAL
		If __lFilorig
			oExecSN4:SetString(nQryParam++ ,Space(1)) //SN3.D_E_L_E_T_
		EndIf
		aAdd(aTmpFil, cTmpSN4Fil)
	EndIf

	If !Empty(cIdMov)
		oExecSN4:SetString(nQryParam++ ,cIdMov)//N4_IDMOV
	Endif

	TcSqlExec( oExecSN4:GetFixQuery() )
	
	RestArea(aSN4Area)

	RestArea(aArea)

	oExecSN4:Destroy()
	oExecSN4:= Nil
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CTATFQSNX
Função de busca dos dados da tabela SNX das movimentações de rateio de 
despesa de depreciação feita no ambiente do Ativo Fixo (Depreciação).

@author marylly.araujo
@since 26/02/2014
@version MP12
//-------------------------------------------------------------------
Alterado por Jeferson Couto em 20/10/2021
Incluído o parâmetro cIdMov para registrar no array aValores caso seja passado
/*/
//-------------------------------------------------------------------
Function CTATFQSNX(cAlsTabReg,aCampos,dDtInicial,dDtFinal,cConsidFil,aSelFil,aTmpFil, cIdMov)
Local oExecSNX 	as object
Local nQryParam as Numeric
Local lRet			:= .T.
Local cAlsSNX		:= GetNextAlias()
Local cQrySNX		:= ''
Local aArea		:= GetArea()
Local aSNXArea	:= {}
Local aValores	:= {}
Local cTmpSNXFil	:= ''

Default cIdMov     := ""

oExecSNX  := Nil
nQryParam := 1

DbSelectArea('SNX')
aSNXArea := SNX->(GetArea())

cQrySNX := 'SELECT ' + CRLF
cQrySNX += 'SNX.R_E_C_N_O_  SNXRECNO ' + CRLF
cQrySNX += ',SNX.NX_FILIAL ' + CRLF
cQrySNX += ',SNX.NX_ORIGEM ' + CRLF
cQrySNX += ',SNX.NX_DCONTAB ' + CRLF
cQrySNX += ',SNX.NX_LP ' + CRLF
If !Empty(cIdMov)
	cQrySNX += ',SNX.NX_IDMOV  IDMOV' + CRLF
Endif
If __lFilorig
	cQrySNX += " , SN3.N3_FILORIG FILORIG"
Endif	
cQrySNX += ' FROM ' + RetSqlName('SNX') + ' SNX ' + CRLF
If __lFilorig
	cQrySNX += " INNER JOIN "+ RetSqlName('SN3') +" SN3 ON SN3.N3_FILIAL = SNX.NX_FILIAL AND SN3.N3_CODRAT = SNX.NX_CODRAT AND SN3.D_E_L_E_T_ = ? " + CRLF
Endif
cQrySNX += ' WHERE ' + CRLF
cQrySNX += " SNX.D_E_L_E_T_ = ? "+ CRLF
If cConsidFil == 2
	cQrySNX += " AND SNX.NX_FILIAL = ? "+ CRLF
ElseIf cConsidFil == 1
	cQrySNX += " AND SNX.NX_FILIAL ? "+ CRLF
EndIf
cQrySNX += " AND SNX.NX_LA <> ? "
cQrySNX += " AND SNX.NX_DTMOV BETWEEN ? AND ? "
If !Empty(cIdMov)
	cQrySNX += " AND SNX.NX_IDMOV = ? "
Endif

cQrySNX := ChangeQuery(cQrySNX)
oExecSNX := FwExecStatement():New(cQrySNX)

If __lFilorig
	oExecSNX:SetString(nQryParam++ ,Space(1)) //SN3.D_E_L_E_T_
Endif
oExecSNX:SetString(nQryParam++ ,Space(1)) //SNX.D_E_L_E_T_
If cConsidFil == 2
	oExecSNX:SetString(nQryParam++ , xFilial("SNX",cFilAnt)) //NX_FILIAL
ElseIf cConsidFil == 1
	oExecSNX:SetUnsafe(nQryParam++ , GetRngFil( aSelFil, "SNX", .T., @cTmpSNXFil )) //NX_FILIAL
	aAdd(aTmpFil, cTmpSNXFil)
EndIf
oExecSNX:SetString(nQryParam++ , 'S') //NX_LA
oExecSNX:SetString(nQryParam++ , DTOS(dDtInicial)) //NX_DTMOV
oExecSNX:SetString(nQryParam++ , DTOS(dDtFinal)) //NX_DTMOV
If !Empty(cIdMov)
	oExecSNX:SetString(nQryParam++ , cIdMov) //NX_IDMOV
Endif

oExecSNX:OpenAlias(cAlsSNX)

While !(cAlsSNX)->(Eof())
	aAdd(aValores,{(cAlsSNX)->NX_FILIAL,;
					 (cAlsSNX)->NX_ORIGEM,;
					 (cAlsSNX)->SNXRECNO,;
					 (cAlsSNX)->NX_LP,;
					 'SNX',;
					 'NX_LA',;
					 'NX_DCONTAB',;
					 iF(!Empty(cIdMov), (cAlsSNX)->IDMOV, " "),;
					 iF(__lFilorig, (cAlsSNX)->FILORIG, " ")  })
	(cAlsSNX)->(DbSkip())
EndDo

CTAFGRVTMP(@cAlsTabReg,aCampos,aValores)

(cAlsSNX)->(DbCloseArea())

RestArea(aSNXArea)
RestArea(aArea)
oExecSNX:Destroy()
oExecSNX := Nil
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CTATFDADOS
Definição de Quais Processos do Ativo Fixo serão contabilizados na Execução desta Rotina
01 = Aquisição
02 = Depreciação
03 = Outros Movimentos
04 = Todas as Rotinas

@author marylly.araujo
@since 13/01/2014
@version MP12
/*/
//-------------------------------------------------------------------

Function CTATFDADOS(cRotATF,cAlsTabReg,dDtInicial,dDtFinal,cConsidFil,aSelFil,aTmpFil,nAtvJaClas, cIdMov)

Local aCampos := {}

Default cRotATF := '04'
Default nAtvJaClas := 1
Default cIdMov     :="" 

If __lFilorig == Nil
	__lFilorig  := cConsidFil == 1 .AND. !__lSN4Excl .AND. cPaisLoc <> 'RUS'
EndIf

/*
 * Verifica se a tabela existe no banco de dados e exclui
 */
If TcCanOpen(cAlsTabReg)
	TcDelFile(cAlsTabReg)
EndIf

/*
 * Criação da Tabela de Dados de Registros que serão contabilizados
 */
aAdd(aCampos, {"FILIAL"	,"C",FWSizeFilial()			,0})
aAdd(aCampos, {"ORIGEM"	,"C",TamSX3("N4_ORIGEM")[1]	,0})
aAdd(aCampos, {"RECNO"	,"N",14						,0})
aAdd(aCampos, {"LP"		,"C",TamSX3("N4_LP")[1]	    ,0})
aAdd(aCampos, {"TABELA"	,"C",3						,0})
aAdd(aCampos, {"CPOFLAG","C",10		     	 		,0})
aAdd(aCampos, {"CPODTCTB","C",10					,0})
aAdd(aCampos, {"IDMOV","C",TamSX3("N4_IDMOV")[1]    ,0})  // Id da movimentação recebe pelo ATFA050 , MOVIEMNTO DE CÁCULO DE DEPRECIAÇÃO

If __lFilorig
	aAdd(aCampos, {"FILORIG","C",FWSizeFilial()	    ,0})//Filial de Origem para ser usada em caso de tabela compartilhada com mais de uma filial para contabilizar
EndIf	

/*
 * Cria tabela temporária no banco de dados
 */
DbCreate( cAlsTabReg ,aCampos,"TOPCONN") // criar 2 indices um por idmov

/*
 * Abertura da tabela no área de trabalho para utilização
 */
DbUseArea(.T.,"TOPCONN", cAlsTabReg, cAlsTabReg,.T.,.F.)

If cRotATF == '01' .OR. cRotATF == '02' 
	CTATFQSN4(@cAlsTabReg,aCampos,dDtInicial,dDtFinal,cConsidFil,aSelFil,aTmpFil,nAtvJaClas, cIdMov)
	CTATFQSNX(@cAlsTabReg,aCampos,dDtInicial,dDtFinal,cConsidFil,aSelFil,aTmpFil, cIdMov)
	CTATFQSNJ(@cAlsTabReg,aCampos,dDtInicial,dDtFinal,cConsidFil,aSelFil,aTmpFil)
ElseIf cRotATF == '03' .OR. cRotATF == '04'
	/*
	 * Movimentos do Ativo Fixo (Depreciação,Transferência, Ampliação)
	 */
	CTATFQSN4(@cAlsTabReg,aCampos,dDtInicial,dDtFinal,cConsidFil,aSelFil,aTmpFil)
	/*
	 * Movimentos de Rateio de Despesa de Depreciação
	 */
	CTATFQSNX(@cAlsTabReg,aCampos,dDtInicial,dDtFinal,cConsidFil,aSelFil,aTmpFil)
	/*
	 * Movimentos de Putting Into Operation
	 */
	If cPaisLoc == "RUS"
		CTATFQF43(@cAlsTabReg,aCampos,dDtInicial,dDtFinal,cConsidFil,aSelFil,aTmpFil)
	EndIf
	/*
	 * Movimentos de Impairment
	 */
	CTATFQSNJ(@cAlsTabReg,aCampos,dDtInicial,dDtFinal,cConsidFil,aSelFil,aTmpFil)
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CTATFCTB
Função de contabilização dos registros pendentes de contabilização do
ambiente Ativo Fixo.

@author marylly.araujo
@since 13/01/2014
@version MP12
/*/
//-------------------------------------------------------------------
Function CTATFCTB(cRotATF, cAlsTabReg ,nIniLote, nFinLote, cQuebraPrc, cAglutLanc, cMostraLanc, lUsaFlag, cConsidFil, aParam, cIdMov, oProcesso)   //passar cIdMov
Local oExecFil 	as object
Local nQryParam as Numeric
Local lRet 		:= .T.
Local cQryRegs	:= ''
Local cAlsRegs	:= GetNextAlias()
Local aSN1Area	:= {}
Local aSN3Area	:= {}
Local aSN4Area	:= {}
Local nHdlPrv	:= 0
Local cArquivo	:= ''
Local cLoteATF	:= LoteCont("ATF")
Local cRotCont	:= FunName()
Local cUserCont	:= ""
Local nTotal		:= 0
Local aFlagCTB	:= {}
Local cWhere	:= ''
Local cLPAtual	:= ''
Local cFilAtua	:= ''
Local cFilAux	:= cFilAnt
Local aRegCTB   := {}
Local nValReg	:= 0		
Local aLPadrao  := {}
Local lProcessa := .F.
Local cPadrao   := ""
Local lCheckObj 	:= ValType(oProcesso) == "O"
Local cLibLabel 	:= "20240520"
Local lSchedule 	:= FWGetRunSchedule()
Local lLibSchedule	:= FwLibVersion() >= cLibLabel
Local nCountReg		:= 0

DEFAULT aParam  := {}
Default cIdMov  := ""

oExecFil  := Nil
nQryParam := 1

If __lFilorig == Nil
	__lFilorig  := cConsidFil == 1 .AND. !__lSN4Excl .AND. cPaisLoc <> 'RUS'
EndIf

If Len(aParam) > 0	
	dDataBase := aParam[1]

	If Type("cUsuario") <> "U" .And. Empty(cUsuario)
		cUsuario := aParam[2]
	EndIf

	If Type("cUsername") <> "U" .And. Empty(cUsername)
		cUsername := aParam[3]
	EndIf
EndIf

cUserCont := Substr(cUsername,1,6)

//Utilizado para contabilizar na data correta - MultiThread

DbSelectArea('SN1')
aSN1Area := SN1->(GetArea())
SN1->(dbSetOrder(1)) //N1_FILIAL+N1_CBASE+N1_ITEM

DbSelectArea('SN3')
aSN3Area := SN3->(GetArea())
SN3->(dbSetOrder(11)) //N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_TPSALDO+N3_SEQ+N3_SEQREAV

DbSelectArea('SN4')
aSN4Area := SN4->(GetArea())
//Begin Transaction

cQryRegs := "SELECT FILIAL, ORIGEM, RECNO, LP, TABELA, CPOFLAG, CPODTCTB "+ IIF( __lFilorig, " ,FILORIG", "") +" ,D_E_L_E_T_, R_E_C_N_O_ FROM " + cAlsTabReg + " "

If nIniLote != 0 .AND. nFinLote != 0
	cWhere += "WHERE R_E_C_N_O_ BETWEEN ? AND ? "
EndIf

If cRotATF == '01'
	cWhere += Iif(!EMPTY(cWhere)," AND "," WHERE ") + " ( ORIGEM IN (?) ) " 			
ElseIf cRotATF == '02'// quado vem pela ATFA050
	cWhere += Iif(!EMPTY(cWhere)," AND "," WHERE ") + " ( ORIGEM IN (?) AND LP IN (?) ) "
	If !Empty(cIdMov) 
		cWhere += " AND IDMOV = ? "
	EndIf
ElseIf cRotATF == '03'
	cWhere += Iif(!EMPTY(cWhere)," AND "," WHERE ") + " ORIGEM NOT IN (?) "
EndIf

cQryRegs += cWhere

/*
 * Tratamento na query da quebra por filial e por processo.
 */
If cQuebraPrc == 1
	cQryRegs += "ORDER BY FILIAL,LP "
/*
 * Tratamento na query da quebra por filial e por processo.
 */
ElseIf cConsidFil == 1
	cQryRegs += "ORDER BY FILIAL "
	If __lFilorig
		cQryRegs += ", FILORIG "
	EndIf
EndIf

cQryRegs := ChangeQuery(cQryRegs)
oExecFil := FwExecStatement():New(cQryRegs)

If nIniLote != 0 .AND. nFinLote != 0
	oExecFil:SetString(nQryParam++, CVALTOCHAR(nIniLote))
	oExecFil:SetString(nQryParam++, CVALTOCHAR(nFinLote))
EndIf

If cRotATF == '01'
	oExecFil:SetIn(nQryParam++, {'ATFA010 ', 'ATFA012 '})
ElseIf cRotATF == '02'// quado vem pela ATFA050
	oExecFil:SetIn(nQryParam++, {'ATFA050 ', 'ATFA036 '})
	oExecFil:SetIn(nQryParam++, {'820','823'})
	If !Empty(cIdMov) 
		oExecFil:SetString(nQryParam++, cIdMov)
	EndIf	
ElseIf cRotATF == '03'
	oExecFil:SetIn(nQryParam++, {'ATFA050 ', 'ATFA010 ' ,'ATFA012 '})
EndIf

oExecFil:OpenAlias(cAlsRegs)

//Tratativa apenas via job em segundo plano.
If lLibSchedule .and. lSchedule .And. lCheckObj
	Count to nCountReg
	(cAlsRegs)->(DbGoTop())
EndIf

If nIniLote > 0  
	(cAlsRegs)->(DbGoTo(nIniLote)) // só quando tiver mais de uma thread 
Endif

nHdlPrv := HeadProva(cLoteAtf,cRotCont,cUserCont,@cArquivo)  

If lLibSchedule .and. lSchedule .And. lCheckObj
	oProcesso:SetRegua1(nCountReg)
Endif

While !(cAlsRegs)->(Eof())
	cPadrao := Alltrim((cAlsRegs)->LP)
	If Ascan(aLPadrao, cPadrao) == 0
		If VerPadrao(cPadrao)
			Aadd(aLPadrao, cPadrao)
			lProcessa := .T.
		Else
			lProcessa := .F.
		Endif
	Else
		lProcessa := .T.
	Endif
	If lProcessa

		If lLibSchedule .And. lSchedule .And. lCheckObj
			oProcesso:IncRegua1()
		Endif
		/*
 		 * Tratamento na contabilização da quebra por LP e por processo para geração de um novo documento
 		 */
		If cQuebraPrc == 1
			If EMPTY(cLPAtual)
				cLPAtual := cPadrao
			ElseIf cLPAtual <> cPadrao
				cLPAtual := cPadrao
				
				If nTotal > 0
					RodaProva(nHdlPrv,nTotal)
					cA100Incl(cArquivo,nHdlPrv,3,cLoteAtf,cMostraLanc == 1,cAglutLanc == 1,,,,@aFlagCTB)
				EndIf
				
				nTotal := 0
			EndIf
		EndIf
		
		/*
 		 * Tratamento na contabilização da quebra por filial para geração de um novo documento
 		 */
		If cConsidFil == 1
		
			If EMPTY(cFilAtua)
		
				If __lFilorig
					cFilAnt	:= (cAlsRegs)->FILORIG
					cFilAtua := (cAlsRegs)->FILORIG
				Else
					cFilAnt	:= (cAlsRegs)->FILIAL
					cFilAtua := (cAlsRegs)->FILIAL
				EndIf
				
			ElseIf cFilAtua <> IIF( __lFilorig, (cAlsRegs)->FILORIG, (cAlsRegs)->FILIAL)
							
				If nTotal > 0
					RodaProva(nHdlPrv,nTotal)
					cA100Incl(cArquivo,nHdlPrv,3,cLoteAtf,cMostraLanc == 1,cAglutLanc == 1,,,,@aFlagCTB)
				EndIf

				If __lFilorig
					cFilAnt	:= (cAlsRegs)->FILORIG
					cFilAtua := (cAlsRegs)->FILORIG
				Else
					cFilAnt	:= (cAlsRegs)->FILIAL
					cFilAtua := (cAlsRegs)->FILIAL	
				EndIf

				nTotal := 0
			EndIf
		EndIf
		
		/*
		 * Posiciona nas tabelas necessários para criar as linhas de detalhes da contabilização.
		 */
		CTATFPOS(@cAlsRegs,.F.) 
		
		AAdd( aRegCTB,(cAlsRegs)->TABELA)
		If (cAlsRegs)->TABELA <> "SNI"
			AAdd( aRegCTB,(cAlsRegs)->RECNO)
		Else
			AAdd( aRegCTB,SNI->(RECNO()))	
		EndIf	

		If lUsaFlag
			If (cAlsRegs)->TABELA <> "SNI"
				aAdd(aFlagCTB,{(cAlsRegs)->CPOFLAG,"S",(cAlsRegs)->TABELA,(cAlsRegs)->RECNO,0,0,0})
			Else
				aAdd(aFlagCTB,{(cAlsRegs)->CPOFLAG,"S",(cAlsRegs)->TABELA,SNI->(RECNO()),0,0,0})
			EndIf
		EndIf
		
		nValReg	:= 	DetProva(nHdlPrv,cPadrao,cRotCont ,cLoteAtf,,,,,,,,@aFlagCTB,aRegCTB) 
		
		nTotal		+=	nValReg 
		
		aRegCTB  := {} // Limpar para enviar novo posicionamento
		/*
		* Posiciona no registro que será contabilizado para atualizar a flag.
		*/
		If !lUsaFlag
			CTATFPOS(@cAlsRegs,nValReg > 0)
		EndIf
	EndIf
	(cAlsRegs)->(DbSkip())
EndDo

If nTotal > 0
	RodaProva(nHdlPrv,nTotal)
	cA100Incl(cArquivo,nHdlPrv,3,cLoteAtf,cMostraLanc == 1,cAglutLanc == 1,,,,@aFlagCTB)
EndIf

//End Transaction
(cAlsRegs)->(DbCloseArea())
aSize(aLPadrao, 0)
alPadrao := NIL
cFilAnt := cFilAux
RestArea(aSN4Area)
RestArea(aSN3Area)
RestArea(aSN1Area)
oExecFil:Destroy()
oExecFil := Nil

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CTAFGRVTMP
Função que grava as informações dos registros de origem da contabilização
numa tabela temporária para montagem da contra-prova.

@author marylly.araujo
@since 14/01/2014
@version MP12
/*/
//-------------------------------------------------------------------
Function CTAFGRVTMP(cAlsTabReg,aCampos,aValores)
Local nQtdCpo		:= Len(aCampos)
Local nContCpo	:= 0
Local nLinha		:= 0

For nLinha := 1 To Len(aValores)
	(cAlsTabReg)->(RecLock(cAlsTabReg,.T.))
	For nContCpo := 1 To nQtdCpo
		(cAlsTabReg)->&(aCampos[nContCpo][1]) := aValores[nLinha][nContCpo]
	Next nContCpo
	(cAlsTabReg)->(MsUnLock())
Next nLinha
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CTATFPOS
Função para posicionamento das tabelas necessários para montagem do
detalhe da contabilização e para atualização da flag dos registros
que foram contabilizados.

@author marylly.araujo
@since 13/01/2014
@version MP12
/*/
//-------------------------------------------------------------------
Function CTATFPOS(cAlsTabReg,lFlag)
Local lRet 		:= .T.
Local aSNWArea 	:= {}
Local aSNXArea 	:= {}
Local aSNYArea 	:= {}
Local aSNVArea 	:= {}
Local cTabOrig	:= (cAlsTabReg)->TABELA
Local cCpoFlag	:= (cAlsTabReg)->CPOFLAG
Local cCpoDtCtb	:= (cAlsTabReg)->CPODTCTB
Local aTabArea	:= (cAlsTabReg)->(GetArea())
Local aTabReg		:= {}
Local cChaveSN1	:= ""
Local cChaveSN3	:= ""
Local cFilSN3		:= xFILIAL("SN3")

Default lFlag := .F.

DbSelectArea(cTabOrig)
aTabReg := (cTabOrig)->(GetArea())
If cTabOrig <> 'SNI'
	(cTabOrig)->(DbGoTo((cAlsTabReg)->RECNO))
EndIf

If lFlag
	(cTabOrig)->(RecLock(cTabOrig,.F.))
	(cTabOrig)->&(cCpoFlag)	:= 'S'
	(cTabOrig)->&(cCpoDtCtb):= DDATABASE
	(cTabOrig)->(MsUnLock())
Else
	If cTabOrig == 'SN4'
		cChaveSN1 := cTabOrig + '->N4_CBASE + ' + cTabOrig + '->N4_ITEM '
		cChaveSN3 := cChaveSN1 + ' + ' + cTabOrig + "->N4_TIPO + " + cTabOrig + "->N4_SEQ "//+ '0' + " + cTabOrig + '->N4_TPSALDO "
		
		SN3->(dbSetOrder(12)) //N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_TPSALDO+N3_SEQ+N3_SEQREAV
		SN3->(DbSeek(cFilSN3	+  &(cChaveSN3) ))
		
	ElseIf cTabOrig == 'SNX'
		SN3->(DbSetOrder(10)) // Filial + Código de Rateio de Despesa de Depreciação
		SN3->(DbSeek( cFilSN3 + SNX->NX_CODRAT ) )
		SN4->(DbSetOrder(1))             //N4_FILIAL+N4_CBASE+N4_ITEM+N4_TIPO+DTOS(N4_DATA)+N4_OCORR+N4_SEQ                                                                                                
		SN4->(DbSeek(XFILIAL("SN4") + SN3->N3_CBASE + SN3->N3_ITEM + SN3->N3_TIPO + DTOS(SNX->NX_DTMOV) ) )
		
		cChaveSN1 := 'SN4->N4_CBASE + SN4->N4_ITEM '

	ElseIf cTabOrig == 'F43'
		SN3->(DbGoTo(F43->F43_SN3REC))
		
		cChaveSN1 := 'SN3->N3_CBASE + SN3->N3_ITEM '
	ElseIf  cTabOrig == 'SNI'
		SNJ->(DbGoTo((cAlsTabReg)->RECNO))
		SNI->(DbSetOrder(1)) 
		SNI->(DbSeek(SNJ->NJ_FILIAL + SNJ->NJ_PROC ) )
		If lExSeqNJ 
			SN3->(DbSetOrder(12))  //N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_SEQ
			SN3->(DbSeek( SNJ->NJ_FILIAL + SNJ->NJ_BEM+SNJ->NJ_ITBEM+AllTrim(cTipoGer)+SNJ->NJ_SEQSN3 ) )
		EndIf
		cChaveSN1 := 'SNJ->NJ_BEM + SNJ->NJ_ITBEM '
	EndIf
		
	SN1->(DbSeek(XFILIAL('SN1') + &(cChaveSN1) ))
	
	/*
	 * Posicionamento das tabelas envolvidas no Rateio de Despesas de Depreciação
	 */
	If SN3->N3_RATEIO == "1" .and. !Empty(SN3->N3_CODRAT)
		cRevAtu := Af011GetRev(SN3->N3_CODRAT)
		
		DbSelectArea("SNV") // Critério de Rateio de Despesa de Depreciação
		SNV->(DbSetOrder(1)) // Filial + Código de Rateio + Revisão + Sequência
		SNV->(DbSeek( XFILIAL("SNV") +  SNX->NX_CODRAT + cRevAtu + SNX->NX_SEQUEN ) )
		
		DbSelectArea("SNW") // Saldo Diário de Rateio por Despesa de Depreciação
		SNW->(DbSetOrder(2)) // Filial + Conta Contábil + Centro de Custo + Item Contábil + Classe de Valor + Data do Saldo + Tipo de Saldo + Moeda
		SNW->(DbSeek( XFILIAL("SNW") + SNX->NX_NIV01 + SNX->NX_NIV02 + SNX->NX_NIV03 + SNX->NX_NIV04 + DTOS(SNX->NX_DTMOV) + SNX->NX_TPSALDO + SNX->NX_MOEDA ) )
		
		DbSelectArea("SNY") // Saldo Mensal de Rateio por Despesa de Depreciação
		SNY->(DbSetOrder(2)) // Filial + Conta Contábil + Centro de Custo + Item Contábil + Classe de Valor + Data Último Dia Mês + Tipo de Saldo + Moeda
		SNY->(DbSeek( XFILIAL("SNY") + SNX->NX_NIV01 + SNX->NX_NIV02 + SNX->NX_NIV03 + SNX->NX_NIV04 + DTOS(LastDay(SNX->NX_DTMOV)) + SNX->NX_TPSALDO + SNX->NX_MOEDA ) )
	EndIf
EndIf

RestArea(aTabArea)

If cTabOrig == 'F43'
	DbSelectArea('F43')
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VlCpCtAtf
Função para validação dos parâmetros da tela de processamento da 
contabilização Off-Line do Ativo Fixo.

@author marylly.araujo
@since 13/02/2014
@version MP12
/*/
//-------------------------------------------------------------------
Function VlCpCtAtf()
Local lRet 		:= .T.
Local cCpo 		:= ReadVar()
Local nQtdProc := GetMv("MV_ATFCTHR", .F., 1 )


If UPPER(cCpo) == "MV_PAR01"	
	If MV_PAR01 == 1 .AND. nQtdProc > 1
		Help( " " ,1, "VLCPCTATF" ,, STR0038 ,1, 0 ) //"Os lançamentos não podem ser exibidos quando o processamento ocorrer em multiplas threads. Verifique o parâmetro MV_ATFCTHR."
		lRet := .F.
	EndIf
	
	If nQtdProc > 1 .AND. MV_PAR06 == 1
		Help( " " ,1, "QBPROCTATF" ,, STR0041,1, 0 ) //"Não é possível quebrar a contabilização off-line por processo na contabilização com múltiplas threads. Verifique os parâmetros de processamento."
	EndIf
ElseIf UPPER(cCpo) == "MV_PAR03" .OR. UPPER(cCpo) == "MV_PAR04"
	If !EMPTY(MV_PAR03) .AND. !EMPTY(MV_PAR04) .AND. MV_PAR03 > MV_PAR04
		Help( " " ,1, "DTCPCTATF" ,, STR0039 ,1, 0 ) //"A data final do período não pode ser maior que a data final para contabilização. Verifique a data inicial e data final informadas."
		lRet := .F.
	EndIf
ElseIf UPPER(cCpo) == "MV_PAR05"
	If EMPTY(MV_PAR05)
		Help( " " ,1, "PRCPCTATF" ,, STR0040 ,1, 0 ) //"Informar os processos que deseja efetuar a contabilização."
		lRet := .F.
	EndIf
ElseIf UPPER(cCpo) == "MV_PAR06"
	If nQtdProc > 1 .AND. MV_PAR06 == 1
		Help( " " ,1, "QBPROCTATF" ,, STR0041,1, 0 ) //"Não é possível quebrar a contabilização off-line por processo na contabilização com múltiplas threads. Verifique os parâmetros de processamento."
		lRet := .F.
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CTATFQF43
Função de busca dos dados da tabela F43 das movimentações de Putting 
Into Operation feita no ambiente do Ativo Fixo (Depreciação).

@author felipe.morais
@since 22/05/2017
@version P12.1.16
/*/
//-------------------------------------------------------------------
Function CTATFQF43(cAlsTabReg,aCampos,dDtInicial,dDtFinal,cConsidFil,aSelFil,aTmpFil)
Local lRet			:= .T.
Local cAlsF43		:= GetNextAlias()
Local cQryF43		:= ''
Local aArea		:= GetArea()
Local aF43Area	:= {}
Local aValores	:= {}
Local cTmpF43Fil	:= ''

DbSelectArea('F43')
aF43Area := F43->(GetArea())

cQryF43 := "SELECT T0.R_E_C_N_O_ AS F43_RECNO," + CRLF
cQryF43 += "	T0.F43_FILIAL," + CRLF
cQryF43 += "	'RU01T01' AS ORIGEM," + CRLF
cQryF43 += "	T0.F43_DATA," + CRLF
cQryF43 += "	T0.F43_OPER" + CRLF
cQryF43 += "FROM " + RetSQLName("F43") + " T0" + CRLF
cQryF43 += "WHERE T0.D_E_L_E_T_ = ' '" + CRLF
If cConsidFil == 2
	cQryF43 += " AND T0.F43_FILIAL = '" + xFilial("F43",cFilAnt) + "' "
ElseIf cConsidFil == 1
	cQryF43 += " AND T0.F43_FILIAL " + GetRngFil( aSelFil, "F43", .T., @cTmpF43Fil ) 
	aAdd(aTmpFil, cTmpF43Fil)
EndIf
cQryF43 += "	AND T0.F43_LA <> 'S'" + CRLF
cQryF43 += "	AND T0.F43_DATA BETWEEN '" + DTOS(dDtInicial) + "'" + CRLF
cQryF43 += "		AND '" + DTOS(dDtFinal) + "'"

cQryF43 := ChangeQuery(cQryF43)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQryF43), cAlsF43 , .F., .T.)

While !(cAlsF43)->(Eof())
	aAdd(aValores,{(cAlsF43)->F43_FILIAL,;
					 (cAlsF43)->ORIGEM,;
					 (cAlsF43)->F43_RECNO,;
					 Iif((cAlsF43)->F43_OPER == "P", "8A2", "8A3"),;
					 'F43',;
					 'F43_LA',;
					 'F43_DATA', " "})	
	(cAlsF43)->(DbSkip())
EndDo

CTAFGRVTMP(@cAlsTabReg,aCampos,aValores)

(cAlsF43)->(DbCloseArea())

RestArea(aF43Area)
RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Retorna os parametros no schedule.

@return aReturn			Array com os parametros

@author  TOTVS
@since   24/06/2024
@version 12
/*/
//-------------------------------------------------------------------
Static Function SchedDef()

Local aParam  := {}

aParam := { "P",;			//Tipo R para relatorio P para processo
            "CTBAATF",;		//Pergunte do relatorio, caso nao use passar ParamDef
            ,;				//Alias
            ,;				//Array de ordens
            STR0026}		//Titulo - "Contabilização Off-line de movimentos do Ativo Fixo"

Return aParam


//-------------------------------------------------------------------
/*/{Protheus.doc} CTATFQSNJ
Função de busca dos dados da tabela SNJ e SNI referente movimentações de impairment 
feitas no ambiente do Ativo Fixo (ATFA380).

@author Ewerton Franklin
@since 27/06/2024
@version MP-23.1.10
//-------------------------------------------------------------------
/*/
//-------------------------------------------------------------------
Function CTATFQSNJ(cAlsTabReg as Character,aCampos as Array,dDtInicial as Date,dDtFinal as Date,cConsidFil as Numeric,aSelFil as Array,aTmpFil as Array) as Logical

Local lRet		:= .T. 				as Logical
Local cAlsSNJ	:= ""			    as Character
Local cQrySNJ	:= ""				as Character
Local aArea		:= GetArea()		as Array
Local aSNJArea	:= {}				as Array
Local aSNIArea	:= {}				as Array
Local aValores	:= {}				as Array
Local cTmpSNJFil:= ""				as Character
Local nParam  	:= 1   				as Numeric
Local oQryExec	     				as Object

DEFAULT cAlsTabReg  := ""			
DEFAULT aCampos 	:= {}
DEFAULT dDtInicial  := Ctod("")
DEFAULT dDtFinal    := Ctod("")
DEFAULT cConsidFil  := 1
DEFAULT aSelFil		:= {}
DEFAULT aTmpFil		:= {}

DbSelectArea('SNI')
aSNIArea := SNI->(GetArea())

DbSelectArea('SNJ')
aSNJArea := SNJ->(GetArea())

If SNI->(FieldPos("NI_DCONTAB")) > 0
	lExSeqNJ := SNJ->(FieldPos("NJ_SEQSN3")) > 0
	//Envia o Recno da SNJ, para posicionar corretamente nos itens
	cQrySNJ := "SELECT "                   + CRLF
	cQrySNJ += "SNJ.R_E_C_N_O_ SNJRECNO, " + CRLF
	cQrySNJ += "SNI.NI_FILIAL, "           + CRLF
	cQrySNJ += "'AF380NJ' AS ORIGEM, "            + CRLF
	cQrySNJ += "SNI.NI_DCONTAB, "          + CRLF
	cQrySNJ += "'894' AS LP "                 + CRLF
	If __lFilorig
		cQrySNJ += ',SN3.N3_FILORIG FILORIG' + CRLF
	EndIf	
	cQrySNJ += " FROM " + RetSqlName('SNI') + " SNI " + CRLF
	cQrySNJ += " INNER JOIN " + RetSqlName('SNJ') + " SNJ ON NI_FILIAL = NJ_FILIAL AND NI_PROC = NJ_PROC "+ CRLF
	If __lFilorig
		cQrySNJ += "INNER JOIN " + RetSqlName('SN3') + " SN3 ON SN3.N3_FILIAL = SNJ.NJ_FILIAL AND SN3.N3_CBASE = SNJ.NJ_BEM AND SN3.N3_ITEM = SNJ.NJ_ITBEM	AND SN3.N3_TIPO = SNJ.NJ_TIPO AND SN3.D_E_L_E_T_ = ? "+ CRLF
	EndIf	
	cQrySNJ += " WHERE "                   + CRLF
	cQrySNJ += " SNJ.D_E_L_E_T_ = ? AND SNI.D_E_L_E_T_ = ? " + CRLF
	If cConsidFil == 2
		cQrySNJ += " AND SNI.NI_FILIAL = ? "+ CRLF
	ElseIf cConsidFil == 1
		cQrySNJ += " AND SNI.NI_FILIAL ?"   + CRLF		
	EndIf
	cQrySNJ += " AND SNI.NI_LA <> ? "       + CRLF
	cQrySNJ += " AND SNI.NI_DTIOA BETWEEN ? AND ? " + CRLF

	cQrySNJ := ChangeQuery(cQrySNJ)

	oQryExec := FWExecStatement():New(cQrySNJ)
	If __lFilorig
		oQryExec:SetString(nParam++, Space(1))//SN3.D_E_L_E_T_
	EndIf
	oQryExec:SetString(nParam++, Space(1))//SNJ.D_E_L_E_T_
	oQryExec:SetString(nParam++, Space(1))//SNI.D_E_L_E_T_
	If cConsidFil == 2
		oQryExec:SetString(nParam++, xFilial("SNI",cFilAnt))
	ElseIf cConsidFil == 1
		oQryExec:SetUnsafe(nParam++, GetRngFil( aSelFil, "SNI", .T., @cTmpSNJFil ))		
		aAdd(aTmpFil, cTmpSNJFil)
	EndIf
	oQryExec:SetString(nParam++, 'S')
    oQryExec:SetDate(nParam++, dDtInicial)
	oQryExec:SetDate(nParam++, dDtFinal)
    
	cAlsSNJ := oQryExec:OpenAlias(GetNextAlias())

	While !(cAlsSNJ)->(Eof())
		aAdd(aValores,{(cAlsSNJ)->NI_FILIAL,;
						(cAlsSNJ)->ORIGEM,;
						(cAlsSNJ)->SNJRECNO,;
						(cAlsSNJ)->LP,;
						'SNI',;
						'NI_LA',;
						'NI_DCONTAB',;
						" ",;
						iF(__lFilorig, (cAlsSNJ)->FILORIG, " ")})
		(cAlsSNJ)->(DbSkip())
	EndDo

	CTAFGRVTMP(@cAlsTabReg,aCampos,aValores)

	(cAlsSNJ)->(DbCloseArea())

	oQryExec:Destroy()
	oQryExec:=Nil
EndIf

RestArea(aSNJArea)
RestArea(aSNIArea)
RestArea(aArea)

Return lRet
