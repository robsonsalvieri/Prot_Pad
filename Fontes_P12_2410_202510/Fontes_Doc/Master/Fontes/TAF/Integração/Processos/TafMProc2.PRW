#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOPCONN.CH"

#DEFINE STATUS_NAO_INICIADO  00
#DEFINE STATUS_EM_PROCESSO 	 01
#DEFINE STATUS_TERMINO 		 02

STATIC __ThreadsCreate := .F.
STATIC __lJobIni := .F. 
STATIC __cJobName := "TAF_ACCEPT"

//---------------------------------------------------------------------
/*/{Protheus.doc} TafST2Manager
Realiza a Integração para o TAF utilizando multiThreads
Obs: Somente XMLs e-Scocial

@param aLisFil - Array com as filias para a importação
@param nContFil - Contador de Filiais processadas
@param nNFiliais - Numero de filias selecionadas no array 
@param cTimeStart - horario de inicio do processamento (função Time:)

@return - Nil

@Author		Evandro dos Santos Oliveira
@Since		31/05/2018
@Version	1.0
/*/
//---------------------------------------------------------------------
Function TafST2Manager(aLisFil,nContFil,nNFiliais,cTimeStart)

	Local cTimeTotal	:=	""
	Local lOk			:=	.F.

	Default cTimeStart := Time()

	FWMsgRun(,{|oMsgRun| lOk := TafMMProc2(oMsgRun,nContFil,nNFiliais)},"Execução Multi Thread","Realizando Processamento ...")

	cTimeTotal := ElapTime(cTimeStart,Time())

	If nContFil == nNFiliais
		If lOk
			MsgInfo( "Processo finalizado. Tempo Total: " + cTimeTotal, "Integração" )
		Else
			MsgAlert( "O processo foi finalizado mas não foi possível submeter todos os registros para processamento. Favor executar procedimento de integração novamente. Tempo Total: " + cTimeTotal, "Integração" )
		EndIf
	EndIf

Return Nil 

//---------------------------------------------------------------------
/*/{Protheus.doc} TafMMProc2
Realiza o gerenciamento do processo verificando se existem registros
a serem processados assim como a abertura,processamento e encerrramento
das threads.

@param oMsgRun - Objeto FWMsgRun
@param nContFil - Contador de Filiais processadas
@param nNFiliais - Numero de filias selecionadas no array 

@return - Nil

@Author		Evandro dos Santos Oliveira
@Since		31/05/2018
@Version	1.0
/*/
//---------------------------------------------------------------------
Function TafMMProc2(oMsgRun,nContFil,nNFiliais)

	Local nMaxRecNo := 0
	Local cFuncInteg := "TafSlcProc2"

	Local lRet		:=	.T.

	Local cModo := ""
	Local nCont := 0
	Local nQtdPend := 0
	Local nQtdTotal := 0
	Local cContFil := '0'
	Local cUltValor := '0'
	
	Local cFilsErp := ""
	Local cJobName := ""
	Local cJobsIni := ""

	Local cIDThread		:=	""
	Local aIDThreads	:=	{}

	cJobName   := __cJobName

	cModo := 'menu'

	dbSelectArea("C1E")

	C1E->(dbSetOrder(3)) 
	
	If C1E->(dbSeek( xFilial("C1E") + PadR(cFilAnt, TamSX3("C1E_FILTAF")[1] ) + "1" ) )
		
		cFilsErp := getCodFilsERP()

		nMaxRecNo := getMaxRecNo(cFilsErp)
		cJobName := cJobName + "_" + cEmpAnt

		If !__ThreadsCreate .Or. IPCCount(cJobName) == 0

			cJobsIni :=  getPvProfString("ONSTART",'JOBS','',getAdv97())
			__lJobIni := "TAF_CFGJOB" $ AllTrim(cJobsIni)

			If !__lJobIni

				TafConOut("TAF_CFGJOB não iniciado na seção Jobs do arquivo appserver.ini. Criando WorkThreads para o processamento.")
								
				ManualJob(cJobName,;
					GetEnvServer(),;
					"IPC"/*Type*/,;
					"TAF_START"/*OnStart*/,;
					"TAF_MTESOCIAL"/*OnConnect*/,;
					""/*OnExit*/,;
					cEmpAnt,;
					60,;
					2,;
					6,;
					2,;
					1)

			EndIf 

			__ThreadsCreate := .T.

			//Garanto que exista pelo menos 1 Thread criada para a execução da rotina.
			While IPCCount(cJobName) < 1
				TafConOut("Aguardando Criação das Threads de Trabalho.") 
				Sleep(1500)
			EndDo

		EndIf 

		cContFil  := cValToChar(nContFil)
		cNFiliais := cValtoChar(nNFiliais)

		//Faço a chamada da função para obter a quantidade total pendente antes de iniciar o processamento
		hasRecords(nMaxRecNo,cFilsErp,@nQtdPend)
		nQtdTotal := nQtdPend

		If nQtdTotal > 0
			oMsgRun:cCaption := "Quantidade de Filiais: " + cContFil + "/" + cNFiliais + " - Codigo: "  + cFilAnt 
			ProcessMessages()
		EndIf 

		While hasRecords(nMaxRecNo,cFilsErp,@nQtdPend)
			nCont ++
			cIDThread := PadL( StrTran( Time(), ":", "" ) + AllTrim( Str( nCont ) ), 10, "0" )
			aAdd( aIDThreads, cIDThread )
			TAFSPCALLIPC( cJobName, cFuncInteg, cFilsErp, cFilAnt, cIDThread, cFilEvent )
			setIncProgress(oMsgRun,nQtdPend,nQtdTotal,@cUltValor,cContFil,cNFiliais)
		EndDo

	Else
		MsgStop("Não Existe Complemento de Empresa Valido para esta Filial.")
	EndIf

	//Garanto que não há registros pendentes 
	//Se a variavel chegar neste ponto com 0, é por que não houve processamento.
	While cUltValor != '100' .And. (cUltValor != '0')
		Sleep(2000)
		hasRecords(nMaxRecNo,cFilsErp,@nQtdPend)
		setIncProgress(oMsgRun,nQtdPend,nQtdTotal,@cUltValor,cContFil,cNFiliais)
	EndDo 

	If !__lJobIni .And. __ThreadsCreate .And. nContFil == nNFiliais
		killMThread(cJobName)

		If !Empty( aIDThreads ) .and. PendRegs( aIDThreads )
			lRet := .F.
			RollbackThrd( aIDThreads )
		EndIf
	EndIf

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} PendRegs
@type			function
@description	Função de verificação de registros pendentes na TAFST2 após processamento.
@author			Felipe C. Seolin
@since			01/08/2018
@version		1.0
@param			aIDThreads	-	Identificador das threads processadas na integração
@return			lRet		-	Indica se existem registros pendentes
/*/
//---------------------------------------------------------------------
Static Function PendRegs( aIDThreads )

Local cQuery	:=	""
Local nI		:=	0
Local nRegs	:=	0
Local lRet		:=	.F.

For nI := 1 to Len( aIDThreads )
	cQuery := "SELECT COUNT(*) NREGS "
	cQuery += "FROM TAFST2 "
	cQuery += "WHERE TAFIDTHRD IN ( '" + aIDThreads[nI] + "' ) "
	cQuery += "  AND TAFSTATUS = '2' "

	cQuery := ChangeQuery( cQuery )
	TCQuery cQuery New Alias "ALIASPEND"

	nRegs += ALIASPEND->NREGS

	ALIASPEND->( DBCloseArea() )
Next nI

lRet := nRegs > 0

TAFConOut( 'PendRegs: ' + AllTrim( Str( nRegs ) ) )

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} RollbackThrd
@type			function
@description	Realiza rollback dos registros represados como pendentes durante o processamento da integração.
@author			Felipe C. Seolin
@since			01/08/2018
@version		1.0
@param			aIDThreads	-	Identificador das threads processadas na integração
/*/
//---------------------------------------------------------------------
Static Function RollbackThrd( aIDThreads )

Local cUpdate	as character
Local cQuery 	as character
Local cErro		as character
Local cXAls		as character
Local nI		as numeric

cUpdate		:=	""
cQuery 		:=  ""
cErro		:=	""
nI			:=	0
cXAls		:= GetNextAlias()

For nI := 1 to Len( aIDThreads )

	//UPDATE PARA REGISTROS COM TAFXERP STATUS 2
	//TAFST2 SEM TAFXERP
	TAFConOut("UPDATE PARA REGISTROS COM TAFXERP STATUS 2")

	cUpdate := "UPDATE TAFXERP SET D_E_L_E_T_ = '*' "
	cUpdate += "                 , R_E_C_D_E_L_ = R_E_C_N_O_ "
	cUpdate += "                 , TAFCODERR = 'ERROMT' "
	cUpdate += "                 , TAFERR = 'Erro no processamento multithread' "
	cUpdate += " WHERE EXISTS ( "
	cUpdate += " SELECT 1 "
	cUpdate += " FROM TAFST2 "
	cUpdate += " WHERE TAFST2.TAFTICKET = TAFXERP.TAFTICKET "
	cUpdate += " AND TAFST2.TAFKEY = TAFXERP.TAFKEY "
	cUpdate += "  AND TAFXERP.D_E_L_E_T_ = '' "
	cUpdate += "  AND TAFST2.TAFIDTHRD IN ( '" + aIDThreads[nI] + "' ) "
	cUpdate += "  AND TAFST2.TAFSTATUS = '2' "
	cUpdate += "  AND TAFXERP.TAFALIAS = '' "
	cUpdate += "  AND TAFXERP.TAFRECNO = 0 "
	cUpdate += "  AND TAFST2.D_E_L_E_T_ = '' )"

	If TCSQLExec( cUpdate ) < 0
		cErro := TCSQLError()	
		TafConOut( cErro, 3 )
	EndIf

	//TAFST2 SEM TAFXERP
	TAFConOut("TAFST2 SEM TAFXERP")

	cQuery := "SELECT ST2.R_E_C_N_O_ RECST2 FROM TAFST2 ST2 "
	cQuery += "LEFT JOIN TAFXERP XERP "
	cQuery += "       ON XERP.TAFKEY = ST2.TAFKEY "
	cQuery += "	  AND XERP.D_E_L_E_T_ = ' ' "
	cQuery += "	  AND XERP.TAFKEY = NULL "
	cQuery += " WHERE ST2.TAFSTATUS = '3' "
	cQuery += "  AND ST2.TAFIDTHRD IN ( '" + aIDThreads[nI] + "' ) "
	cQuery += "  AND ST2.D_E_L_E_T_ = ' ' "

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cXAls, .F., .T. )

	(cXAls)->(DBGotop())
	While !(cXAls)->(Eof())
		TAFRecSt2((cXAls)->RECST2)
		(cXAls)->(dbSkip())
	EndDo

	(cXAls)->(dbCloseArea())

	//VOLTO PARA STATUS 1
	TAFConOut("VOLTO PARA STATUS 1")

	cUpdate := "UPDATE TAFST2 SET TAFSTATUS = '1' "
	cUpdate += " , TAFIDTHRD = '' "
	cUpdate += "WHERE TAFIDTHRD IN ( '" + aIDThreads[nI] + "' ) "
	cUpdate += "  AND TAFSTATUS = '2' "

	If TCSQLExec( cUpdate ) < 0
		cErro := TCSQLError()
		TafConOut( cErro, 3 )
	EndIf

Next nI

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFArrFils
Retorna Array com os codigos de Filiais do ERP considerando a 
empresa Logada
@author Evandro dos Santos
@since   2018-07-07
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFArrErpFils()
Return getCodFilsERP()

//-------------------------------------------------------------------
/*/{Protheus.doc} getCodFilsERP
Retorna Codigo de Filiais ERP do Grupo
@author Evandro dos Santos
@since   2018-07-07
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function getCodFilsERP()

	Local cSql := ""
	Local cCodFils:= ""
	
	cSql := " SELECT C1E_CODFIL , CR9_CODFIL "
	cSql += " FROM " + RetSqlName("C1E") +  " C1E "
	cSql += " LEFT JOIN " + RetSqlName("CR9") + " CR9 " 
	cSql += " ON C1E_FILIAL = CR9_FILIAL "
	cSql += " AND C1E_ID = CR9_ID "
	cSql += " AND C1E_VERSAO = CR9_VERSAO " 
    cSql += " AND CR9.CR9_ATIVO = '1' "
	cSql += " AND CR9.D_E_L_E_T_ = ' ' "
	cSql += " WHERE C1E.D_E_L_E_T_ = ' ' "
	cSql += " AND C1E_ATIVO = '1' "	
	cSql += " AND C1E_FILTAF = '" + cFilAnt + "'"

	TCQuery cSql New Alias 'aliasEmp'

	cCodFils := "'" + AllTrim(aliasEmp->C1E_CODFIL) + "'"

	While aliasEmp->(!Eof()) 

		If !Empty(AllTrim(aliasEmp->CR9_CODFIL))
			cCodFils += ",'" + AllTrim(aliasEmp->CR9_CODFIL) + "'"
		EndIf 
		aliasEmp->(dbSkip())
	EndDo

	aliasEmp->(dbCloseArea())

Return cCodFils 


//---------------------------------------------------------------------
/*/{Protheus.doc} setIncProgress
Calcula o % de registros processados e incrementa o Label utilizado 
no objeto FWMsgRun.

@param oMsgRun - Objeto FWMsgRun
@pram nQtdPend - Quantidade de Registro Pendentes 
@param nQtdTotal -Quantidade total de registros a serem processados
na filial.
@param cUltValor - Ultimo valor % calculado, quando esse valor muda
o label é incrementado.
@param nContFil - Contador de Filiais processadas
@param nNFiliais - Numero de filias selecionadas no array 

@return - Nil

@Author		Evandro dos Santos Oliveira
@Since		31/05/2018
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function setIncProgress(oMsgRun,nQtdPend,nQtdTotal,cUltValor,cContFil,cNFiliais)

	Local cPercent := ""
	Local nQtdProc := 0

	Default cNFiliais := '1'
	Default cContFil := '1'

	nQtdProc := nQtdTotal - nQtdPend
	cPercent := cValToChar(Int((nQtdProc/nQtdTotal) * 100))

	//Só faço atualização do label se o perce
	If cPercent != cUltValor
    	oMsgRun:cCaption := "Quantidade de Filiais: " + cContFil + "/" + cNFiliais + " - Codigo: "  + cFilAnt +  " - Concluido: " + cPercent + " %"
		cUltValor := cPercent
		ProcessMessages()
	EndIf 

	TafConOut("Percentual de Registros Integrados: " + cPercent)
	
Return Nil 

//---------------------------------------------------------------------
/*/{Protheus.doc} getMaxRecNo
Retorna o numero Max do RecNo a ser processado pela Filial.

@param cFilsERP - Codigo das Filias do ERP

@return nRecno - Numero do RecNo do ultimo registro a ser processado

@Author		Evandro dos Santos Oliveira
@Since		31/05/2018
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function getMaxRecNo(cFilsErp)

	Local cQry := ""
	Local nRecno := 0

	cQry := "SELECT MAX(R_E_C_N_O_) MAXRECNO FROM TAFST2 WHERE TAFFIL IN (" + cFilsErp +") AND TAFSTATUS = '1' AND TAFIDTHRD = ' ' AND D_E_L_E_T_ = ' ' "
	cQry := ChangeQuery(cQry)
	
	TCQuery cQry New Alias 'AliasMax'

	nRecno := AliasMax->MAXRECNO
	
	AliasMax->(dbCloseArea())

Return nRecno 

//---------------------------------------------------------------------
/*/{Protheus.doc} hasRecords
Verifica se há registros pendentes para processamento na Filial

@param nMaxRecNo - Numero Maximo do RecNo a ser processado
@param cFilsERP - Codigo das Filias do ERP
@param nQtdRegs - Quantidade de registros pendententes (referencia)

@return lVar - Informa se ainda existes registros para o processamento

@Author		Evandro dos Santos Oliveira
@Since		31/05/2018
@Version	1.0,
/*/
//---------------------------------------------------------------------
Static Function hasRecords(nMaxRecNo,cFilsERP,nQtdRegs)

	Local cQry := ""

	cQry := "SELECT COUNT(*) NREGS FROM TAFST2 WHERE R_E_C_N_O_ <= " + AllTrim(Str(nMaxRecNo)) 
	
	//por tela por entquanto vou respeitar a filial
	cQry += " AND TAFFIL  IN (" + cFilsERP + ")"
	cQry += " AND TAFSTATUS = '1' AND TAFIDTHRD = ' '  AND D_E_L_E_T_ = ' '"

	If !isBlind( ) .And. Len(cFilEvent) > 0
		cQry +=  " AND TAFTPREG IN (" + cFilEvent + ") "
	EndIf
	
	cQry := ChangeQuery(cQry)

	TCQuery cQry New Alias 'AliasCount'

	nQtdRegs := AliasCount->NREGS

	TafConOut("Quantidade de registros : " + AllTrim(Str(nQtdRegs)))

	AliasCount->(dbCloseArea())

Return nQtdRegs > 0

//---------------------------------------------------------------------
/*/{Protheus.doc} TafSlcProc2
Gerencia a partição e processamento da thread.

@param cFilsErp - Codigo das Filiais do ERP
@param cFilTAF - Codigo de Filial do TAF
@param cIDThread - Identificador da Thread (customizado)

@return Nil 

@Author		Evandro dos Santos Oliveira
@Since		31/05/2018
@Version	1.0
/*/
//---------------------------------------------------------------------
Function TafSlcProc2(cFilsErp,cFilTAF,cIDThread, cFilEvent)

	Local aErrosQry := { } 
	Local aRetorno := {} 
	Local aErros := {}
	Local cCodGrpEmp := FWGrpCompany()
	Local aAreaSM0 := {} 
	Local cFilBkp := ""

	TafConOut("TafSlcProc2 - Filial: " + cFilTAF)

	aAreaSM0 := SM0->(GetArea())
	If SM0->(MsSeek(cCodGrpEmp+cFilTAF))
		cFilBkp := cFilAnt
		cFilAnt := cFilTAF

		aErrosQry := slice(,,cIDThread,cFilsErp)

		If aErrosQry[1]

			aRetorno := Array(2)

			If processaThread(,,cIDThread,aErros,cFilsErp)
				aRetorno[1] := .T.
				aRetorno[2] := "OK"
			Else
				aRetorno[1] := .F.
				aRetorno[2] := "ERRO"
				varInfo('aRetorno',aRetorno)
			EndIf 

		Else
			aRetorno := aClone(aErrosQry)
		EndIf 
	
		RestArea(aAreaSM0)
		cFilAnt := cFilBkp
		
		aSize(aErrosQry,0)
		aSize(aRetorno,0)
		aSize(aErros,0)
		delClassIntF()
	Else
		TAFConOut("** Nao Foi possivel posicionar na filial: " + cFilTAF + " Grupo de Empresa: " + cCodGrpEmp)
	EndIf 

Return Nil 

//---------------------------------------------------------------------
/*/{Protheus.doc} slice
Seleciona os registros que devem ser processados utilizando o recurso
de SELECT TOP/FETCH FIRST/LIMIT/ROWNUM dos bancos de dados.

@param cStatusWHERE - Status dos registros que devem ser considerados 
para o campo TAFSTATUS na Clausula WHERE do SQL.
@param cStatusSET - Status dos registros que devem ser considerados 
para o campo TAFSTATUS ma Clausula SET do SQL 
@param cIDThread - Identificador da Thread (customizado)
@param cFilsERP - Codigo das filias do ERP

@return Nil 

@Author		Evandro dos Santos Oliveira
@Since		31/05/2018
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function slice(cStatusWHERE,cStatusSET,cIDThread,cFilsErp) 

	Local cQuery := ""
    Local cErro  := ""
	Local aRetorno := {}

    Default cStatusSET := "2"
    Default cStatusWHERE := "1"

	aRetorno := Array(2)
	nTopSelect := 50
	cBanco := Upper(AllTrim(TcGetDB()))

	While !LockByName("TafSlcProc2",.F.,.F.)

		TafConOut("Esperando retirar o Lock - IdThread Server: " + StrZero(ThreadID(),10)) 

	EndDo
	
	TafConOut("Id Thread Server: " + StrZero(ThreadID(),10) )  
	TafConOut("Id Thread TafSlcProc2: " + cIDThread) 
	
    cTableName := "TAFST2"
	
	cQuery := " UPDATE " + cTableName
	cQuery += " SET TAFSTATUS = '" + cStatusSET + "'"
	cQuery += ", TAFIDTHRD = '" + cIDThread + "'"
	cQuery += " WHERE "
	cQuery += " TAFFIL IN (" + cFilsErp + ")"
	cQuery += " AND TAFSTATUS = '" + cStatusWHERE + "' "
	cQuery += " AND TAFIDTHRD = ' ' "
	cQuery += " AND D_E_L_E_T_ = ' ' "
	
	cQuery += " AND R_E_C_N_O_ IN "

	cQuery += " ( "
 	If (cBanco $ ("MSSQL|MSSQL7" )) 
		cQuery += " SELECT TOP " + AllTrim(Str(nTopSelect)) + " R_E_C_N_O_ REC
	Else
		cQuery += " SELECT R_E_C_N_O_ REC
	EndIf
	
	cQuery += " FROM TAFST2 " 
	cQuery += " WHERE " 
	cQuery += " TAFFIL IN (" + cFilsErp + ") "
	cQuery += " AND TAFSTATUS = '1' " 
	cQuery += " AND TAFIDTHRD = ' ' "
	If !isBlind( ) .And. Len(cFilEvent) > 0
		cQuery +=  " AND TAFTPREG IN (" + cFilEvent + ") "
	EndIf
	cQuery += " AND D_E_L_E_T_ = ' ' " 
	



	If cBanco == "ORACLE"
		cQuery += " AND ROWNUM <= " + AllTrim(Str(nTopSelect))
	ElseIf cBanco == "DB2"
		cQuery += "FETCH FIRST " + AllTrim(Str(nTopSelect)) + " ROWS ONLY "
	ElseIf cBanco $ "POSTGRES|MYSQL"
		cQuery += " LIMIT " + AllTrim(Str(nTopSelect)) + " "
	Endif  
	
	cQuery += " ) "

	If TCSQLExec (cQuery) < 0

		cErro := TCSQLError()		
		TafConOut(cErro,3)
		
		DisarmTransaction()

		aRetorno[1] := .F. 
		aRetorno[2] := cErro
	
	Else

		aRetorno[1] := .T. 
		aRetorno[2] := ""	

	EndIf	

	UnLockByName("TafSlcProc2",.F.,.F.)
	TafConOut("Retirou Lock - IdThread Server: " + StrZero(ThreadID(),10) )

Return aRetorno

//---------------------------------------------------------------------
/*/{Protheus.doc} processaThread
Seleciona os registros que devem ser processados utilizando o recurso
de SELECT TOP/FETCH FIRST/LIMIT/ROWNUM dos bancos de dados.

@param cStatus - Status dos registros que devem ser processados, campo
TAFSTATUS na TAFST2
@param cCodMsg - Codigo Status do campo TAFCODMSG na TAFST2
para o campo TAFSTATUS ma Clausula SET do SQL 
@param cIDThread - Identificador da Thread (customizado)
@param aErros - Erros na abertura da Tabela
@param cFilsErp - Codigo das filiais do ERP

@return lRet - Informa se houve erros no processo

@Author		Evandro dos Santos Oliveira
@Since		31/05/2018
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function processaThread(cStatus,cCodMsg,cIDThread,aErros,cFilsErp)

	Local cQuery 		:= ""
	Local cStatQueue 	:= ""
	Local cOwner 		:= ""
	Local cPredecs 		:= ""
	Local cFilTran 		:= ""
	Local cComplem		:= ""
	Local lRet 			:= .T.
	Local cXERPAlias 	:= GetNextAlias()
	Local cST2Alias 	:= GetNextAlias()
	Local cProcInteg 	:= GetNextAlias()
	Local aRecInt		:= {}
	Local aRecQueue		:= {} 
	Local lFldOwner 	:= .F.
	Local lFldPrdcs		:= .F. 
	Local lFldTrans		:= .F. 
	Local lFldComp		:= .F.

	Default cStatus 	:= '2'
	Default cCodMsg 	:= '2'
	Default aErros 		:= {}

	openTabInteg("TAFST2",cST2Alias,aErros)
	If Len(aErros) == 0 
		openTabInteg("TAFXERP",cXERPAlias,aErros)
	EndIf

	If Len(aErros) == 0 

		lFldOwner	:=	(cST2Alias)->(fieldPos('TAFOWNER')) > 0
		lFldPrdcs	:=	(cST2Alias)->(fieldPos('TAFREGPRED')) > 0
		lFldTrans 	:=	(cST2Alias)->(fieldPos('TAFFILTRAN')) > 0
		lFldComp	:=	(cST2Alias)->(fieldPos( 'TAFCOMP')) > 0

		cQuery := " SELECT TAFFIL " 
		cQuery += " ,TAFKEY " 
		cQuery += " ,TAFTPREG " 
		cQuery += " ,TAFTICKET " 
		cQuery += " ,TAFSTQUEUE "
		If lFldOwner
			cQuery += " ,TAFOWNER "
		EndIf 
		If lFldPrdcs
			cQuery += " ,TAFREGPRED "
		EndIf 
		If lFldTrans
			cQuery += " ,TAFFILTRAN "
		EndIf 
		If lFldComp
			cQuery += " ,TAFCOMP "
		EndIf
		cQuery += " ,R_E_C_N_O_ "
		cQuery += " FROM TAFST2 "
		cQuery += " WHERE "
		cQuery += " TAFFIL IN (" + cFilsErp + ")"
		cQuery += " AND TAFIDTHRD = '" + cIDThread + "'"
		cQuery += " AND TAFCODMSG = '" + cCodMsg  + "'"
		cQuery += " AND TAFSTATUS = '" + cStatus  + "'"
		cQuery += " AND D_E_L_E_T_ = ' '"

		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ),cProcInteg, .T., .F. )
		
		While (cProcInteg)->(!Eof())


			cStatQueue	:= (cST2Alias)->TAFSTQUEUE
			cOwner		:= Iif( lFldOwner , AllTrim((cProcInteg)->TAFOWNER) , '' )
			cPredecs	:= Iif( lFldPrdcs , (cProcInteg)->TAFREGPRED , '' )
			cFilTran	:= Iif( lFldTrans , (cProcInteg)->TAFFILTRAN , '' )
			cComplem	:= Iif( lFldComp  , ( cProcInteg )->TAFCOMP , '' )

			(cST2Alias)->(dbGoTo((cProcInteg)->R_E_C_N_O_))
			TAFConOut("TafPrepInt " + AllTrim((cProcInteg)->TAFKEY) + " - Thread: " + cIDThread + " - RecNo: " + cValToChar((cProcInteg)->R_E_C_N_O_))
		
			TafPrepInt(	'',;
				(cProcInteg)->TAFFIL,;
				(cST2Alias)->TAFMSG,;
				(cProcInteg)->TAFKEY,;
				'3',;
				(cProcInteg)->TAFTPREG,;
				cXERPAlias,;
				(cProcInteg)->TAFTICKET,;
				@cStatQueue,;
				,;
				,;
				cOwner,;
				cFilTran,;
				cPredecs,;
				cComplem )

				If Empty(cStatQueue) .Or. cStatQueue == 'R'
					TAFConOut("RecInt ST2 : " + ( cST2Alias )->TAFKEY )
					aAdd( aRecInt, { (cST2Alias)->( Recno() ), ( cST2Alias )->TAFKEY } )
				Else
					TAFConOut("aRecQueue ST2 : " + ( cST2Alias )->TAFKEY )
					aAdd( aRecQueue, { (cST2Alias)->( Recno() ), ( cST2Alias )->TAFKEY } )
				Endif
			
			(cProcInteg)->(dbSkip())

		EndDo

		//Atualiza o status para 3 na TAFST2 quando a integracao eh concretizada e o registro nao esta marcado para ficar em fila 
		//quando ocorre erros de integracao a nivel de cadastro. (status 9 na TAFXERP)
		commitThred(,,cIDThread,aRecInt,cFilsErp)
		//Atualiza o status para 1 na TAFST2 quando a integracao eh concretizada e o registro esta marcado para ficar em fila 
		//quando ocorre erros de integracao a nivel de cadastro. (status 9 na TAFXERP)
		commitThred(,"1",cIDThread,aRecQueue,cFilsErp)

	Else
		lRet := .F.
	EndIf

	aSize(aRecInt,0)
	aSize(aRecQueue,0)

	aRecQueue := Nil 
	aRecInt := Nil 
	aSize := Nil 
		
	(cProcInteg)->(dbCloseArea())
	(cST2Alias)->(dbCloseArea())
	(cXERPAlias)->(dbCloseArea())

Return lRet 

//---------------------------------------------------------------------
/*/{Protheus.doc} commitThred
Atualiza Registros processados na tabelas TAFST2.

@param cStatusWHERE - Status dos registros que devem ser considerados 
para o campo TAFSTATUS na Clausula WHERE do SQL.
@param cStatusSET - Status dos registros que devem ser considerados 
para o campo TAFSTATUS ma Clausula SET do SQL 
@param cIDThread - Identificador da Thread (customizado)
@param aRecNos - Recnos dos Registros que devem ser atualizos
@param cFilsErp - Codigo das filiais do ERP

@return aRetorno - Array com os status do retorno do TCSqlExec

@Author		Evandro dos Santos Oliveira
@Since		31/05/2018
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function commitThred(cStatusWHERE,cStatusSET,cIDThread,aRecNos,cFilsErp) 

	Local cQuery := ""
    Local cErro  := ""
	Local cRecNos := ""
	Local aRetorno := {}

    Default cStatusSET := "3"
    Default cStatusWHERE := "2"
    
	aRetorno := Array(2)
	nTopSelect := 100
	cBanco := Upper(AllTrim(TcGetDB()))

	cRecNos := recNoToStr(aRecNos,",")

    cTableName := "TAFST2"
	
	cQuery := " UPDATE " + cTableName
	cQuery += " SET TAFSTATUS = '" + cStatusSET + "'"
	If cStatusSET == "1"
		cQuery += ", TAFIDTHRD = ' ' "
	Endif 
	cQuery += " WHERE "
	cQuery += " TAFFIL IN (" + cFilsErp + ") "
	cQuery += " AND TAFIDTHRD = '" + cIDThread + "'"
	cQuery += " AND TAFSTATUS = '" + cStatusWHERE + "' "
	
	If !Empty(cRecNos)
		cQuery += " AND R_E_C_N_O_ IN (" + cRecNos + ")"
	EndIf 
	
	cQuery += " AND D_E_L_E_T_ = ' ' "
	
	If TCSQLExec (cQuery) < 0
		cErro := TCSQLError()
		TafConOut(cErro)
		DisarmTransaction()

		aRetorno[1] := .F. 
		aRetorno[2] := cErro
	Else
		aRetorno[1] := .T. 
		aRetorno[2] := ""	
	EndIf	

Return aRetorno

//----------------------------------------------------------------------------
/*/{Protheus.doc} recNoToStr 
Converte o array de RecNos para String.

@param aRecNos  - Array de RecNos
@param cToken - Caracter de separação

@return cRecNos	- String com os RecNos

@author Evandro dos Santos Oliveira
@since 131/05/2018
@version 1.0
/*/
//--------------------------------------------------------------------------- 
Static Function recNoToStr(aRecNos,cToken)

	Local cRecNos := ''
	Local nX := 0

	For nX := 1 To Len(aRecNos)
		If nX > 1
			cRecNos += cToken	
		EndIf
		cRecNos += AllTrim(Str(aRecNos[nX][1]))
	Next nX

Return cRecNos 

//----------------------------------------------------------------------------
/*/{Protheus.doc} openTabInteg 
Faz a abertura das tabelas auxiliares de integração (TAFST2,TAFXERP etc..)

@param cNomeTab  - Nome da Tabela 
@param cAliasTab - Alias da Tabela 


@return aErros	- Possiveis Erros na Criação/Abertura da Tabela.

@author Evandro dos Santos Oliveira
@since 18/09/2017
@version 1.0
/*/
//--------------------------------------------------------------------------- 
Static Function openTabInteg(cNomeTab,cAliasTab,aErros)

	Local nTry 	 as numeric
	Local lRet	 as logical
	
	Default cNomeTab  := ""
	Default cAliasTab := ""
	Default aErros    := {}
	
	nTry    := 5
	nCount	:= 1
	lRet 	:= .T.
	
	While nCount <= nTry
	
		//Tenho que zerar por que estara preenchido cada vez que falhar a abertura da tabela
		If !Empty(aErros)
			aSize(aErros,0)
		Endif
	
		xTAFCriaTB(,,cNomeTab,cAliasTab,,,,,,,, @aErros,)

		If Empty(aErros)
			Exit
		Else
			TafConOut("Tentativa de abertura da tabela " + cNomeTab +  " - "  + AllTrim(Str(nCount)) + "/" + AllTrim(Str(nTry)))
			
			//Espero meio segundo antes de uma nova tentativa
			Sleep(500)
			
			//Garanto que o Alias não está aberto
			If Select(cAliasTab) > 0
				(cAliasTab)->(dbCloseArea())
			EndIf
		EndIf
		nCount++
	EndDo
	
	If nCount >= nTry 
		TafConOut("Esgotadas as tentativas de abertura de tabela. Alias: " + cNomeTab)
		lRet := .F.
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} killMThread
Deleta as threads abertas para o processamento.

@param cJobName - Semaforo utilizado para controle das threads.

@return - Nil

@Author		Evandro dos Santos Oliveira
@Since		31/05/2018
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function killMThread(cJobName)

	Local aMonitor    := GetUserInfoArray()
	Local aDelThreads := {}
	Local nQtdThread  := 0
	Local lThreadsInUse := .T.
	Local nTimeOut 	  := 100
	Local nTryWait 	  := 0
	Local lTimeOut	  := .F.
	
	Sleep(10000)

	aEval( aMonitor,{|x| If(x[1] == cJobName, aAdd(aDelThreads,aClone(x)),)})
	nQtdThread := Len(aDelThreads)

	//Verifico se ainda existem threads em processamento
	While lThreadsInUse .And. !lTimeOut
		aMonitor    := GetUserInfoArray()
		nThreadsInUse := aScan(aMonitor,{|x|x[10] > 0 .And. x[1] == cJobName})
		lThreadsInUse := nThreadsInUse > 0
		nTryWait++
		Sleep(1000)
		lTimeOut := nTryWait == nTimeOut
	EndDo

	//Tenho que zerar o semaforo antes de deletar as threads para evitar que elas "ressucitem"	
	//por conta do RefresRate utilizado na criação do ManualJob.

	ManualJob(cJobName,;
		GetEnvServer(),;
		"IPC"/*Type*/,;
		"TAF_START"/*OnStart*/,;
		"TAF_MTESOCIAL"/*OnConnect*/,;
		""/*OnExit*/,;
		cEmpAnt,;
		60,;
		0,;
		0,;
		0,;
		0)

	DeleThread( aDelThreads )

	__ThreadsCreate := .F.

Return Nil 

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFMP2JobName
Retorna nome do semaforo utilizado pela função

@return - Nome do Semaforo

@Author		Evandro dos Santos Oliveira
@Since		12/10/2018
@Version	1.0
/*/
//---------------------------------------------------------------------
Function TAFMP2JobName()
Return __cJobName

//----------------------------------------------------------------------------
/*/{Protheus.doc} TAFRecSt2
Função executadar update TAFST2

@author Leonardo Kichitaro
@since 16/06/2018
@version 1.0
/*/
//--------------------------------------------------------------------------- 
Static Function TAFRecSt2(nRecnoST2)

Local cUpdt	as character

cUpdt	:= ""

cUpdt := "UPDATE TAFST2 "
cUpdt += "SET TAFSTATUS = '1' "
cUpdt += "  ,TAFIDTHRD = ' ' "
cUpdt += "WHERE R_E_C_N_O_ = " + AllTrim(Str(nRecnoST2))

if TCSQLExec( cUpdt ) < 0
	xTAFMsgJob( "Erro... " + TCSQLError() + " -> " + cUpdt )
endif

Return

