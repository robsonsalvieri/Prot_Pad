#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE TAMMAXXML 075000  //Tamanho Maximo do XML
#DEFINE TAMMSIGN  004000  //Tamanho médio da assinatura

//--------------------------------------------------------------------------- -
/*/{Protheus.doc} TAFProc5
Chama rotina responsavel por verificar os registros que devem ser
Consultados
@return Nil

@author Evandro dos Santos Oliveira
@since 07/11/2013 - Alterado 18/05/2015
@version 1.0
@obs - Rotina separada do fonte TAFAINTEG e realizado tratamentos especificos
		para a utilização do Job5 realizando a chamada individualmente e utilizando
		o schedDef para a execução no schedule.
/*/
//----------------------------------------------------------------------------
Function TAFProc5(lPrepare, cEmp, cFil)

	Local lJob := .F.
	Local lEnd := .F.

	If lPrepare
		RpcSetType(3)
		RpcSetEnv(cEmp, cFil,,,"TAF","TAFPROC5")
	EndIf

	lJob := IsBlind()
	If TAFAtualizado(!lJob)
		TafConOut('Rotina de Transmissão de eventos e-Social - Empresa: ' + cEmpAnt + ' Filial: ' + cFilAnt)

		If lJob
			TAFProc5TSS(lJob,,,,,@lEnd)
		Else
			Processa( {||TAFProc5TSS(lJob,,,,,@lEnd)}, "Aguarde...", "Executando rotina de Transmissão",  )
		EndIf

		If lEnd .And. !lJob
			MsgInfo("Processo finalizado.")
		EndIf
	EndIf

	If lPrepare
		RpcClearEnv()
	EndIf

Return Nil

//---------------------------------------------------------------------------
/*/{Protheus.doc} TAFProc5Tss
Processo responsavel por verificar os registros que devem ser consultados no
TSS.

Alteração: Evandro dos Santos
Data: 05/04/2016
Descrição: - Alterado a forma de geração dos registros, para a rotina possibilitar
a geração de XMLs em disco, foram incluidos uma série de parâmetros que permitem
a geração de layouts especificos e filtros por status, recno e Id.
- Alterado a Origem do array dos layouts, antes os mesmos eram baseados no array
aTafSocial deste fonte, agora os layouts considerados são os especificados no
fonte TAFROTINAS.

@param	lJob - Flag para Identificação da chamada de Função por Job
@param 	aEvtsESoc 	- Array com os Eventos a serem considerados, quando vazio são considerados
		todos os eventos contidos no TAFROTINAS.
		Obs: Quando informados os eventos devem seguir a mesma estrutura dos eventos e-Social
		contidos no TAFROTINAS.
@param 	cStatus - Status dos eventos que devem ser transmitidos, quando vazio  o sistema usa o 0
        para tranmissão e o 2 para consulta; o parâmetro pode conter mais de 1 status par isso
        passar os status separados por virgula ex: "1,3,4"
@param aIdTrab - Array com o Id dos trabalhadores (para filtro dos eventos que tem relação com o
	    trabalhador)
@param cRecNos - Filtra os registro pelo RecNo do Evento, pode ser utilizado um range de recnos
		ex;"1,5,40,60"
@param lEnd - Verifica o fim do processamento(variável referenciada)
@param cMsgRet - Mensagem de retorno do WS (referência)
@param aFiliais - Array de Filiais
@param dDataIni	-> Data Inicial dos eventos
@param dDataFim	-> Data Fim dos dos eventos
@param lEvtInicial -> Informa se o parâmetro de evento inicial foi marcado. (** Descontinuado)
@param lCommit -> Indica se será comitado na tabela
@param cIdEnt -> Id da Entidade
@param oProcess -> Objeto FWNewProcess
@param lForceRetorno -> Força o Retorno da consulta, mesmo quando há gravação no tempTable
@param lMV -> Utilização de Multiplos vinculos
@return Nil

@author Evandro dos Santos Oliveira
@since 07/11/2013
@version 1.0
/*/
//---------------------------------------------------------------------------
Function TAFProc5Tss( lJob as logical, aEvtsESoc as array, cStatus as character, aIdTrab as array, cRecNos as character,;
					lEnd as logical, cMsgRet as character, aFiliais as array, dDataIni as date, dDataFim as date,;
					lEvtInicial as logical, lCommit as logical, cIdEnt as character, oProcess as object,;
					lForceRetorno as logical, oTabFilSel as object, lMV as logical, lReavPen as logical,;
					oMsgRun as object, cPeriod as character, lRetResponse as logical, lCallApi as logical )

	Local aRetConsulta as array
	Local aRetorno     as array
	Local aXmls        as array
	Local cAliasRegs   as character
	Local cAlsEvt      as character
	Local cAmbte       as character
	Local cBancoDB     as character
	Local cCheckURL    as character
	Local cFuncP5      as character
	Local cFunction    as character
	Local cId          as character
	Local cIdThread    as character
	Local cJobName     as character
	Local cLog         as character
	Local cMsgProc     as character
	Local cQry         as character
	Local cTabOpen     as character
	Local cTimeProc    as character
	Local cUrl         as character
	Local cUUIDJob5	   as character
	Local cKeyProc	   as character
	Local lAllEventos  as logicaL
	Local lGravaErrTab as logical
	Local lMThread     as logical
	Local lNewProcess  as logical
	Local lTabTmpExt   as logical
	Local lTransFil    as logical
	Local lEnabLock    as logical 
	Local nCont        as numeric
	Local nItem        as numeric
	Local nLote        as numeric
	Local nMaxTry      as numeric
	Local nMThread     as numeric
	Local nQtdLote     as numeric
	Local nQtdPorLote  as numeric
	Local nQtdRegs     as numeric
	Local nQtLoteMT    as numeric
	Local nTopSlct     as numeric
	Local nTry         as numeric
	Local nTryConsult  as numeric
	Local nQtdLastProc as numeric

	Default aEvtsESoc     := {}
	Default aIdTrab       := {}
	Default cIdEnt        := ""
	Default cMsgRet       := ""
	Default cPeriod       := ""
	Default cRecNos       := ""
	Default cStatus       := "'2'"
	Default dDataFim      := SToD("")
	Default dDataIni      := SToD("")
	Default lCallApi      := .F.
	Default lCommit       := .T.
	Default lEnd          := .T.
	Default lForceRetorno := .F.
	Default lMV           := .F.
	Default lReavPen      := .F.
	Default lRetResponse  := .F.
	Default oMsgRun       := Nil
	Default oProcess      := Nil
	Default oTabFilSel    := Nil

	aRetConsulta := {}
	aRetorno     := {}
	aXmls        := {}
	cAliasRegs   := GetNextAlias()
	cAlsEvt      := ""
	cAmbte       := SuperGetMv("MV_TAFAMBE", .F., "2")
	cBancoDB     := Upper(AllTrim(TcGetDB()))
	cCheckURL    := ""
	cFuncP5      := "TAFPROC5MT"
	cFunction    := ""
	cId          := ""
	cIdThread    := StrZero(ThreadID(), 10)
	cJobName     := "TAFPROC5MT_" + AllTrim(cEmpAnt) + "_" + AllTrim(cFilAnt)
	cLog         := ""
	cMsgProc     := ""
	cQry         := ""
	cTabOpen     := ""
	cTimeProc    := Time()
	cUrl         := ""
	cUUIDJob5	 := "uid_" + AllTrim(cEmpAnt) + "_" + AllTrim(cFilAnt)
	cKeyProc	 := "proc5"
	lAllEventos  := .F.
	lGravaErrTab := FindFunction("FTableTSSErr") .And. Substr(GetRpoRelease(), 1, 2) == "12" .And. IsInCallStack("TAFMONTES")
	lMThread     := .F.
	lNewProcess  := .F.
	lTabTmpExt   := oTabFilSel <> Nil
	lTransFil    := .F.
	lEnabLock    := SuperGetMv("MV_TAFCLOC", .F.,.T.)
	nCont        := 0
	nItem        := 0
	nLote        := 0
	nMaxTry      := 150
	nMThread     := SuperGetMv("MV_TAFQTMT", .F., 0)
	nQtdLote     := 0
	nQtdPorLote  := 50
	nQtdRegs     := 0
	nQtLoteMT    := SuperGetMv("MV_TAFLTMT", .F., 0)
	nTopSlct     := 999999
	nTry         := 0
	nTryConsult  := 0

	If FindFunction("TafGetUrlTSS")
		cURL := PadR(TafGetUrlTSS(),250)
	Else
		cURL := PadR(GetNewPar("MV_TAFSURL","http://"),250)
	EndIf

	cURL := AllTrim(cURL)

	If !("TSSWSSOCIAL.APW" $ Upper(cUrl))

		cCheckURL := cUrl

		If RAT("/",cUrl) != Len(cUrl)
			cUrl += "/"
		EndIf 

		cUrl += "TSSWSSOCIAL.apw"

	Else

		cCheckURL := Substr(cUrl,1,Rat("/",cUrl)-1)

	EndIf

	If ValType(oProcess) == "O"
		lNewProcess := .T. // Informa que a barra de processamento é um MsNewProcess
		oProcess:IncRegua1("Consultando registros no Servidor TSS ... ")
	EndIf

	If ValType(oMsgRun) == "O" .AND. !lJob
		IncMessagens(oMsgRun,"Consultando registros no Servidor TSS ... ")
	EndIf

	If Empty(AllTrim(cUrl))

		If lJob 
			TafConOut("O parâmetro MV_TAFSURL não está preenchido")
		Else
			cMsgRet := "O parâmetro MV_TAFSURL não está preenchido"
		EndIf

	Else

		If FindFunction("TAFTransFil")
			lTransFil := TAFTransFil(lJob) 
		EndIf
		
		If Empty(cIdEnt)

			If TAFCTSpd(cCheckURL,,, @cMsgRet,, lTransFil)

				cIdEnt := TAFRIdEnt(lTransFil,,,,, .T.) 

			Else

				If lJob

					TafConOut("Não foi possivel conectar com o servidor TSS")
					TafConOut(cMsgRet)

				Else

					If Empty(AllTrim(cMsgRet))
						cMsgRet := "Não foi possivel conectar com o servidor TSS"
					EndIf 

				EndIf

			EndIf

		EndIf
		
		If !Empty(cIdEnt)

			If TAFAlsInDic("V2H")
				dbSelectArea("V2H")
				dbSetOrder(2)
			EndIf 

			If TAFAlsInDic("V2J")
				dbSelectArea("V2J")
				dbSetOrder(1)
			EndIf 

			dbSelectArea("T0X")
			T0X->(dbSetOrder(3))

			If lJob

				cLog := "* Inicio Consulta TAFProc5 TheadId: " + cIdThread + " - Data de Inicio: " + DTOC(dDataBase) + " - " + cTimeProc
				TAFConOut(cLog)	

			EndIf

			lAllEventos	:= Empty(aEvtsESoc) //Quando não vem eventos selecionados devo considerar todos por que não houve marcação no browse

			cMsgProc := "Verificando itens transmitidos para o RET. "

			If lJob
				cQry := TAFQryXMLeSocial( cBancoDB, nTopSlct,, cStatus, aEvtsESoc, aIdTrab, cRecNos, cMsgProc,, aFiliais,, lJob,, lCommit,, @oTabFilSel,,;
										cPeriod,,,,,,, dDataIni, dDataFim )
			Else
				cQry := TAFQryMonTSS( cBancoDB, nTopSlct,, cStatus, aEvtsESoc, aIdTrab, cRecNos, cMsgProc,, aFiliais, lAllEventos, dDataIni, dDataFim,,;
									@oTabFilSel, lMV, lReavPen )
			EndIf
			
			cQry := ChangeQuery(cQry)
		
			TcQuery cQry New Alias (cAliasRegs)
			Count To nQtdRegs

			nQtdLote := Ceiling(nQtdRegs/nQtdPorLote)

			//-- Verifica se deve habilitar o processamento multithread de acordo com a quantidade de registros / lotes
			If IPcCount(cFuncP5) > 0

				lMThread := .T.

			ElseIf nQtdLote >= nQtLoteMT

				//-- Cria as threads de acordo com o parametro definido
				//-- Se for multithread
				lMThread := IIF(nMThread > 1, .T., .F.)

				If lMThread

					cJobName := StrTran(cJobName, " ", "")

					ManualJob( cFuncP5,;
								GetEnvServer(),;
								"IPC"/*Type*/,;
								"TAF_START"/*OnStart*/,;
								"TAF_CONJ5M"/*OnConnect*/,;
								""/*OnExit*/,;
								cEmpAnt,;
								60,;
								nMThread,;
								nMThread,;
								1,;
								1)

				EndIf

			EndIf		

			If lJob			
				TAFConOut("Quantidade de Lotes a serem consultados: " + AllTrim(Str(nQtdLote)))
			EndIf

			If lNewProcess
				oProcess:SetRegua2(nQtdLote)
			EndIf

			If nQtdRegs > 0

				If !lMThread .And. lEnabLock

					TafConOut("Criando/Verificando Secao de variaveis globais para TAFProc5Tss")
					If VarSetUID(cUUIDJob5,.T.) 
						TafConOut("Secao de variaveis globais criada ou ja existente: " + cUUIDJob5)

						If !lockProcess(cUUIDJob5,cKeyProc,nQtdRegs,@nQtdLastProc,@nTryConsult) //Se o lock nao for obtido, a thread é finalizada(retornada) e a proxima tenta novamente.
							TafConOut("Aguardando a finalização de outra thread para realizar a execução.")
							Return aRetConsulta 
						EndIf 
						
					EndIf 

				EndIf 

				(cAliasRegs)->(dbGoTop())	
				While (cAliasRegs)->(!Eof())
				
					cAlsEvt := Alltrim( ( cAliasRegs )->ALIASEVT )
				
					If TAFAlsInDic( cAlsEvt )
					
						cFunction := AllTrim( (cAliasRegs)->FUNCXML )
						
						If !(cAlsEvt $ cTabOpen)
							dbSelectArea(cAlsEvt)
							cTabOpen += "|" + cAlsEvt
						EndIf
						
						( cAlsEvt )->( dbGoTo( ( cAliasRegs )->RECTAB ) )
						
						cId := AllTrim ( STRTRAN( ( cAliasRegs )->LAYOUT , "-" , "" ) ) + AllTrim( ( cAliasRegs )->ID ) + AllTrim( ( cAliasRegs )->VERSAO )
						aAdd( aXmls , { "" , cId , ( cAliasRegs )->RECTAB , AllTrim( ( cAliasRegs )->LAYOUT ) , cAlsEvt, ( cAliasRegs )->FILIAL,(cAliasRegs )->ID } )
						nItem++
		
						If nItem == nQtdPorLote

							If lMThread

								While !IPCGo(cFuncP5, aXmls,cAmbte,,cUrl,lJob,cIdEnt,lNewProcess,oProcess,nQtdLote,@nLote,lGravaErrTab )

									If nTry <= nMaxTry

										Sleep(nTry * 1000)
										TafConOut("["+cFuncP5+"]["+ProcName()+"] Aguardando thread disponivel - Tentativa " + cValToChar(nTry))
										nTry++

									Else

										Exit 

									EndIf

								Enddo

								If nTry > nMaxTry 

									MsgAlert("Execução abortada por falta de Threads Disponíveis. ")
									Exit

								Else

									nTry := 0

								EndIf
								
							Else

								aRetorno := TAFConRg(aXmls, cAmbte,, cUrl, lJob, cIdEnt, lNewProcess, oProcess, nQtdLote, @nLote, lGravaErrTab, oMsgRun, lTransFil, @cMsgRet, lRetResponse, lCallApi)
							
							EndIf

							If !lGravaErrTab .And. !lForceRetorno
								Aadd( aRetConsulta, aClone(aRetorno))
							EndIf

							aSize(aRetorno,0)
							aSize(aXmls,0)
							nItem := 0

						EndIf
		
					EndIf

					nCont := nCont + 1

					If ValType(oMsgRun) == "O" .AND. !lJob
						SetIncPerc( oMsgRun, "Consultando", nQtdRegs , nCont )
					EndIf

					(cAliasRegs)->(dbSkip())

				EndDo

				//Se houver, adiciono o residuo no array de lote
				If Len(aXmls) > 0

					aRetorno := TAFConRg(aXmls, cAmbte,, cUrl, lJob, cIdEnt, lNewProcess, oProcess, nQtdLote, @nLote, lGravaErrTab, oMsgRun, lTransFil, @cMsgRet, lRetResponse, lCallApi)
					
					If !lGravaErrTab .Or. lForceRetorno
						Aadd( aRetConsulta, aClone(aRetorno))
					EndIf

					aSize(aRetorno,0)
					aSize(aXmls,0)

				EndIf

				If !lMThread .And. lEnabLock
					unLockProcess(cUUIDJob5,cKeyProc)
				EndIf 

			Else

				cMsgProc := "0 documento(s)  consultado(s)."			
				TafConOut(cMsgProc)

			EndIf

			If lNewProcess
				oProcess:IncRegua1("Finalizado.")
			EndIf

			If ValType(oMsgRun) == "O" .AND. !lJob
				IncMessagens(oMsgRun,"Finalizado.")
			EndIf

			cLog := "* Fim Consulta TAFProc5 TheadId: " + cIdThread + " - Data de Inicio: " + DTOC(dDataBase) + " - " + Time() + " - Tempo de processamento: " + ElapTime(cTimeProc,Time())  + " - Quantidade de Registros: " + AllTrim(Str(nQtdRegs))
			TafConOut(cLog)
			
		EndIf

	EndIf

	//--------------------------------------------------------------------
	// Deleta a tabela temporaria desde que não seja chamada da TAFMontES
	//--------------------------------------------------------------------
	If !lTabTmpExt .And. oTabFilSel <> NIL .And. Substr(GetRpoRelease(),1,2) == '12'
		oTabFilSel:Delete()
	EndIf


	

Return aRetConsulta

//---------------------------------------------------------------------------
/*/{Protheus.doc} TAFConRg  
Realiza consulta dos registros transmitidos.

@param	aXmlsLote  	- Array com os dados do Xml    
		cAmbiente	- Ambiente de Transmissão/Consulta 		  
					  [x][1] - Xml do Evento
					  [x][2] - Id(chave para transmissão)
					  [x][3] - RecNo do Evento na sua respectiva tabela
					  [x][4] - Layout que correspondente ao evento
					  [x][5] - Alias correspondente ao Evento
		lGrvRet		- Determina se deve ocorrer a gravação dos status    
		cUrl		- Url - Url do servidor TSS para o Ambiente e-Social
		lJob		- Identifica se a rotina está sendo executada por Job ou tela
		cIdEnt 		- Id da Entidade

@author Evandro dos Santos Oliveira
@since 19/11/2013
@version 1.0
/*/
//---------------------------------------------------------------------------
Static Function TAFConRg( aXmlsLote as array, cAmbiente as character, lGrvRet as logical, cUrl as character,;
						lJob as logical, cIdEnt as character, lNewProcess as logical, oProcess as object,;
						nQtdLote as numeric, nLote as numeric, lGravaErrTab as logical, oMsgRun as object,;
						lTransFil as logical, cMsgRet as character, lRetResponse as logical,;
						lCallApi as logical )

	Local aAreaTab      as array
	Local aEvtEsocial   as array
	Local aRetorno      as array
	Local cAliasTb      as character
	Local cAuxSts       as character
	Local cCodErroRet   as character
	Local cEmpEnv       as character
	Local cError        as character
	Local cEvtRetXml    as character
	Local cEvtTab       as character
	Local cFilErp       as character
	Local cFilEvt       as character
	Local cIdAux        as character
	Local cLayOut       as character
	Local cRecibo       as character
	Local cStatus       as character
	Local cTabOpen      as character
	Local cWarning      as character
	Local lGrvTotFilial as logical
	Local lMvTotExdt    as logical
	Local lRet          as logical
	Local lTotaliz      as logical
	Local lVersion12    as logical
	Local nJ            as numeric
	Local nSizeFil      as numeric
	Local nY            as numeric
	Local oErroRet      as object
	Local oHashXML      as object

	Local xRetXML        := Nil

	Default aXmlsLote    := {}
	Default cAmbiente    := ""
	Default lGrvRet      := .T.
	Default cIdEnt       := ""
	Default nLote        := 0
	Default lGravaErrTab := .F.
	Default oMsgRun      := Nil
	Default cMsgRet      := ""
	Default lTransFil    := .F.
	Default lRetResponse := .F.
	Default lCallApi     := .F.

	aAreaTab      := {}
	aEvtEsocial   := TAFRotinas(,,.T.,2)
	aRetorno      := {}
	cAliasTb      := ""
	cAuxSts       := ""
	cCodErroRet   := ""
	cEmpEnv       := ""
	cError        := ""
	cEvtRetXml    := ""
	cEvtTab       := ""
	cFilErp       := ""
	cFilEvt       := ""
	cIdAux        := ""
	cLayOut       := ""
	cRecibo       := ""
	cStatus       := ""
	cTabOpen      := ""
	cWarning      := ""
	lGrvTotFilial := .F.
	lMvTotExdt    := .F.
	lRet          := .F.
	lTotaliz      := .F.
	lVersion12    := Substr(GetRpoRelease(),1,2) == '12'
	nJ            := 0
	nSizeFil      := 0
	nY            := 0
	oErroRet      := Nil
	oHashXML      := Nil

	If lCallApi .And. lRetResponse

		cEvtRetXml := "S-1299|S-2210"

	ElseIf !lCallApi .AND. !lRetResponse

		cEvtRetXml := "S-1200|S-1210|S-1295|S-1299|S-2299|S-2399|S-2501|"

		If TAFColumnPos("T8I_GRVTOT")
			cEvtRetXml += "S-2555|"
		EndIf

		If TAFColumnPos("V9U_GRVTOT")
			cEvtRetXml += "S-2500|"
		EndIf 

	EndIf

	For nJ := 1 to Len(aEvtEsocial)

		If aEvtEsocial[nJ,12] == 'C'
			cEvtTab +=  aEvtEsocial[nJ,3] + "|"
		EndIf

	Next nJ

	If (dDataBase >= GetNewPar("MV_TOTEXDT", SToD("20991231")))
		lMvTotExdt := .T. 
	EndIf 

	nLote++

	If lNewProcess
		oProcess:IncRegua2("Consultando Eventos no TSS - Lote " + AllTrim(Str(nLote)) + "/" + AllTrim(Str(nQtdLote)) + ". " )
	Else
		ProcRegua(Len(aXmlsLote))
	EndIf

	If ValType(oMsgRun) == "O" .AND. !lJob
		IncMessagens(oMsgRun,"Consultando Eventos no TSS - Lote " + AllTrim(Str(nLote)) + "/" + AllTrim(Str(nQtdLote)) + ". ")
	EndIf

	aRetorno := GetXmlRetTss( aXmlsLote, cUrl, cIdEnt, cAmbiente, cEvtRetXml, @lRet,, lTransFil, @cMsgRet )
																															
	If ValType(lRet) == "L"   
	
		If lRet

			If lVersion12
				oHashXML	:=	AToHM(aXmlsLote, 2, 3 )
			Else
				oHashXML	:=	TafXAToHM(aXmlsLote, 2, 3 )	
			EndIf 

			If (lGrvRet)	

				For nY := 1 To Len(aRetorno)

					cIdAux := AllTrim(aRetorno[nY]:CID)

					If lVersion12
						HMGet( oHashXML , cIdAux ,@xRetXML )
					Else
						TafXHMGet( oHashXML , cIdAux ,@xRetXML )
					EndIf 

					If ValType(xRetXML[1][3]) == "N"

						cAliasTb := xRetXML[1][5]
						
						If !(cAliasTb $ cTabOpen)
							cTabOpen += "|" + cAliasTb
							dbSelectArea(cAliasTb)
						EndIf

						(cAliasTb)->(dbGoTo(xRetXML[1][3]))
						cLayOut := xRetXML[1][4]

						dbSelectArea("C1E")
						C1E->(dbSetOrder(3))
						
						If lMvTotExdt .And. (AllTrim(FwCodFil()) != AllTrim((cAliasTb)->&(cAliasTb + "_FILIAL"))) 

							If ( cLayOut $ cEvtRetXml ) .and. !Empty( ( cAliasTb )->&( cAliasTb + "_FILIAL" ) )
								C1E->(MsSeek(xFilial("C1E")+(cAliasTb)->&(cAliasTb + "_FILIAL")+"1"))
								lGrvTotFilial := .T.
							Else
								C1E->(MsSeek(xFilial("C1E")+cFilAnt+"1"))
							EndIf

						Else

							C1E->(MsSeek(xFilial("C1E")+cFilAnt+"1"))

						Endif

						cFilErp := AllTrim( C1E->C1E_CODFIL )

						If aRetorno[nY]:LSUCESSO

							// |Status de Retorno dos Documentos
							// |
							//1 – Recebido
							//2 – Assinado
							//3 – Erro de schema
							//4 – Aguardando transmissão
							//5 – Rejeição
							//6 – Autorizado
					   
							cStatus  := aRetorno[nY]:CSTATUS
							cChave   := aRetorno[nY]:CCHAVE
							//Retorno do Número do Recibo de Transmissão do TSS.
							cRecibo  := AllTrim(aRetorno[nY]:CRECIBO)

							(cAliasTb)->(dbGoTo(xRetXML[1][3]))
							cFilEvt  := xRetXML[1][6]
							nSizeFil := FWSizeFilial()
							cFilEvt  := PADR(cFilEvt,nSizeFil)
							cEmpEnv  := FWGrpCompany()
	
							//Retirado de dentro do transaction por que quando ocorre erro na gravacao de 1 totalizador a exception faz rollback
							//do totalizador ja gravado - Issue DSERTAF1-21025	
							If cStatus == "6"

								lTotaliz := .F.

								If cLayout $ cEvtRetXml .And. ( ValType(aRetorno[nY]:CXMLEVENTO) <> "U" .OR. ValType(aRetorno[nY]:CXMLBASE64) <> "U" )

									aAreaTab	:= (cAliasTb)->(GetArea())
									cFilBkp 	:= cFilAnt

									If lGrvTotFilial

										//Posiciona na filial para a correta gravacao do totalizador mediante ao parametro MV_TOTEXDT
										If SM0->(MsSeek(cEmpEnv + PADR(cFilEvt,nSizeFil)))										
											cFilAnt := SM0->M0_CODFIL
										Else
											TafConOut("Parametro MV_TOTEXDT preenchido e Filial não encontrada no arquivo de empresas.",2)	
										Endif

									EndIf 

									cMsgRet += GeraEvtTot(IIf(ValType(aRetorno[nY]:CXMLBASE64) <> "U", aRetorno[nY]:CXMLBASE64, aRetorno[nY]:CXMLEVENTO), cLayout, cAliasTb, cFilErp, @lTotaliz, cIdAux, cFilEvt, @cRecibo, xRetXML[1][3])
									cFilAnt := cFilBkp
									SM0->(MsSeek(cEmpEnv + PADR(cFilBkp,nSizeFil)))
														
									If TAFAlsInDic("V2J") 
										limpaTotV2J(cIdAux,cFilEvt)
									EndIf 

									RestArea(aAreaTab)

								EndIf

							EndIf 							

							BEGIN TRANSACTION

								If cLayOut $ "S-3000|S-3500"

									cMsgRet += gravaStsExclusao(cStatus,cFilEvt,cLayOut)[2]

								EndIf

								If cStatus == "6" .AND. !lRetResponse

									limpaRegT0X(cIdAux)

									If TAFAlsInDic("V2H")
										limpaRegV2H(cIdAux,cFilEvt)
									EndIf 

									If  AllTrim(aRetorno[nY]:CCODRECEITA) == "202"

										aAreaTab := (cAliasTb)->(GetArea())

										If lGravaErrTab .Or. TAFAlsInDic("V2H")
											gravaErr(aRetorno[nY],cFilEvt,AllTrim(xRetXML[1][7]),AllTrim(xRetXML[1][4]),lJob,cMsgRet)
										EndIf

										RestArea(aAreaTab)

									EndIf 

								ElseIf cStatus == "5"

									cError := ""

									// É necessário   se realmente foi retornado o XML do erro pelo RET.
									If ValType(aRetorno[nY]:CXMLERRORET) <> "U"

										oErroRet  := XmlParser( EncodeUTF8(aRetorno[nY]:CXMLERRORET), "_", @cError, @cWarning )

										If Empty(cError) .And. ValType(oErroRet) == "O" 

											If Valtype(XmlChildEx(oErroRet,"_OCORRENCIAS")) == "O" 		

												If Valtype(XmlChildEx(oErroRet:_OCORRENCIAS,"_OCORRENCIA")) == "O" .And. Valtype(XmlChildEx(oErroRet:_OCORRENCIAS:_OCORRENCIA,"_CODIGO")) == "O"
											
													cCodErroRet := oErroRet:_OCORRENCIAS:_OCORRENCIA:_CODIGO:Text

												ElseIf  Valtype(XmlChildEx(oErroRet:_OCORRENCIAS,"_OCORRENCIA")) == "A"

													cCodErroRet := oErroRet:_OCORRENCIAS:_OCORRENCIA[1]:_CODIGO:Text

												EndIf 	

											ElseIf Valtype(XmlChildEx(oErroRet,"_RETORNOPROCESSAMENTOLOTEEVENTOS")) == "O"

												cCodErroRet := oErroRet:_RETORNOPROCESSAMENTOLOTEEVENTOS:_STATUS:_CDRESPOSTA:Text

											EndIf	

										EndIf

									EndIf
									
									limpaRegT0X(cIdAux)
									
									//Os codigos de erro 402, 543 ou 609 são apresentados quando há duplicidade no XMLID ou mesmo esta gerado de forma incorreta, por isso ele é apagado para ser regerado.
									If TAFColumnPos( cAliasTb+"_XMLID" )

										If AllTrim(cCodErroRet) $ "402|543|609"

											RecLock((cAliasTb),.F.)
											(cAliasTb)->&(cAliasTb+"_XMLID") := ""
											(cAliasTb)->(MsUnlock())

										// Todos os outros codigos de erros são tratados e realizada a gravação do XMLID.										
										ElseIf !Empty(cChave) .AND. Empty( (cAliasTb)->&(cAliasTb+"_XMLID") )

											RecLock((cAliasTb),.F.)
											(cAliasTb)->&(cAliasTb+"_XMLID")	:=	cChave
											(cAliasTb)->(MsUnlock())

										EndIf

									Endif

									aAreaTab := (cAliasTb)->(GetArea())

									If lGravaErrTab .Or. TAFAlsInDic("V2H")

										cFilEvt := xRetXML[1][6]
										nSizeFil := FWSizeFilial()
										cFilEvt := PADR(cFilEvt,nSizeFil)

										If !gravaErr(aRetorno[nY],cFilEvt,AllTrim(xRetXML[1][7]),AllTrim(xRetXML[1][4]),lJob,cMsgRet)

											//Refaço o request deste item para tentar obter o erro buscando o XML completo de retorno 
											aRetAux := GetXmlRetTss( xRetXML, cUrl, cIdEnt, cAmbiente, cEvtRetXml, @lRet, .T., lTransFil, @cMsgRet )	

											If Len(aRetAux) > 0
												gravaErr(aRetAux[1],cFilEvt,AllTrim(xRetXML[1][7]),AllTrim(xRetXML[1][4]),lJob,cMsgRet)		
											EndIf 

										EndIf 

									EndIf

									RestArea(aAreaTab)
								
								EndIf
								
								cAuxSts := TAFStsXTSS(cStatus) 
		
								//Gravo o status do registro de retorno
								If !Empty(cAuxSts)

									DbSelectArea(cAliasTb)
									(cAliasTb)->(DbGoTo(xRetXML[1][3]))

									If (cAliasTb)->(RecLock(cAliasTb, .F.))

										If TAFColumnPos(cAliasTb + "_STATUS")

											If (cAliasTb)->&(cAliasTb+"_STATUS") <> "4"
												(cAliasTb)->&(cAliasTb+"_STATUS") := cAuxSts 
											EndIf

										EndIf
										
										If cLayout $ cEvtRetXml

											If TAFColumnPos(cAliasTb+"_GRVTOT")
												(cAliasTb)->&(cAliasTb+"_GRVTOT") := lTotaliz
											EndIf 

										EndIf 
			
										//Gravo o numero do protocolo de transmissão do TSS.
										If !Empty(cRecibo)

											If TAFColumnPos(cAliasTb + "_PROTUL")
												(cAliasTb)->&(cAliasTb+"_PROTUL") := cRecibo 
											EndIf

											//Verificar se é um evento de tabela e de exclusão
											//Caso seja, inativo a exclusão transmitida corretamente para que um novo registro igual possa ser incluido
											If cAliasTb $(cEvtTab) .And. (cAliasTb)->&(cAliasTb+"_EVENTO") == 'E'
												(cAliasTb)->&(cAliasTb+"_ATIVO") := '2'
											EndIf

											If TafColumnPos(cAliasTb + "_DTRECP")
												(cAliasTb)->&(cAliasTb + "_DTRECP") := DATE()
												(cAliasTb)->&(cAliasTb + "_HRRECP") := TIME()
											EndIf

										EndIf
		
										(cAliasTb)->(MsUnlock())

									EndIf	

								EndIf

				   			END TRANSACTION

						Else

							BEGIN TRANSACTION
							If TAFColumnPos(cAliasTb + "_STATUS")

								If (cAliasTb)->&(cAliasTb+"_STATUS") <> '4'

									cMsgRet := "Layout " + cLayOut + " - Id " + cIdAux  + " Problemas no Arquivo: "
									cMsgRet += aRetorno[nY]:CDETSTATUS
								
									RecLock((cAliasTb),.F.)
										(cAliasTb)->&(cAliasTb+"_STATUS") := '3'
									(cAliasTb)->(MsUnlock())
									
									aAreaTab := (cAliasTb)->(GetArea())
									If lGravaErrTab .Or. TAFAlsInDic("V2H")

										cFilEvt := xRetXML[1][6]
										nSizeFil := FWSizeFilial()
										cFilEvt := PADR(cFilEvt,nSizeFil)
										gravaErr(aRetorno[nY],cFilEvt,AllTrim(xRetXML[1][7]),AllTrim(xRetXML[1][4]),lJob,cMsgRet)

									EndIf

									RestArea(aAreaTab)

								EndIf

							EndIf

							END TRANSACTION

						EndIf
						
					Else

						cMsgRet := "Id " + cIdAux +" não encontrado no lote de envio. "

					EndIf

					If (lGravaErrTab .Or. TAFAlsInDic("V2H") .And. IsInCallStack("TAFMONDET")) .And. !IsInCallStack("mostraXMLErro")

						If ValType(aRetorno[nY]) == "O"
							FreeObj(aRetorno[nY])
							aRetorno[nY] := Nil 
						EndIf 

					EndIf 

				Next nY

			EndIf

		Else
			cMsgRet := IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)) //SOAPFAULT
		EndIf

	Else

		cMsgRet := "Retorno do WS não é do tipo lógico. "
		cMsgRet += CRLF + IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))

	EndIf
	
	If ValType("oHashXML") == "O"
		FreeObj(oHashXML)
		oHashXML := Nil
	EndIf

	aSize(aXmlsLote,0)

	DelClassIntF()

	If !Empty(cMsgRet)
		TafConOut(cMsgRet)
	EndIf

Return aRetorno

//---------------------------------------------------------------------
/*/{Protheus.doc} gravaErr

Grava os Erros da transmissão.

@param aRetorno - Array com o Retorno do TSS
@param cFil - Filial do Registro
@param cId - Id do Registro
@param cEvento - Evento relacionado ao Registro
@parma lJob - Informa se a rotina está sendo executada por um Job
@parm cMsgRet - Mensagem de retorno

@Author		Evandro dos Santos O. Teixeira
@Since		29/05/2018
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function gravaErr(aRetorno,cFil,cId,cEvento,lJob,cMsgRet)

	Local cSql 			:= ""
	Local cBanco		:= AllTrim(TCGetDB())
	Local cXml			:= ""
	Local nItem			:= 1
	Local cTipoErr  	:= ""
	Local cCodErr		:= ""
	Local cDescErr  	:= ""
	Local cDescResp 	:= ""
	Local nTamChv		:= 0
	Local lVersion12 	:= Substr(GetRpoRelease(),1,2) == '12'
	Local lCommitV2H 	:= .F.  
	Local lNoOcorr   	:= .F. 
	Local lRet202    	:= .F.
	Local cLocalErr  	:= ""
	Local cSequencia	:= "" 
	
	Private oXml  := Nil

	Default lJob := IsBlind()

	If TAFAlsInDic("V2H")

		nTamChv := GetSx3Cache("V2H_IDCHVE","X3_TAMANHO")

		//Se retornar Nil é por que não está com EncodeUTF8
		//o Servidor TSS as vezes retorna o XML sem Encode
		//ocasionando erro no Parser.

		If ValType(DecodeUTF8(aRetorno:CXMLERRORET)) == "U"
			cXml := EncodeUTF8(aRetorno:CXMLERRORET)
		Else
			cXml := aRetorno:CXMLERRORET
		EndIf 

		If AllTrim(cEvento) == "S-1000"
			cFil := xFilial("C1E")							
		EndIf
		
		oXml := tXmlManager():New()		

		If !Empty(cXml) .And. oXML:Parse( cXml )
			
			oXml:bDecodeUtf8 := .T.
			
			If oXml:XPathHasNode("/ocorrencias/ocorrencia[" + cValToChar(nItem)+ "]")

				While oXml:XPathHasNode("/ocorrencias/ocorrencia[" + cValToChar(nItem)+ "]")

					If nItem >= 1

						If oXml:xPathHasNode( "/ocorrencias/ocorrencia[" + cValToChar(nItem)+ "]/tipo" )
							cTipoErr := oXml:xPathGetNodeValue( "/ocorrencias/ocorrencia[" + cValToChar(nItem)+ "]/tipo" )
						EndIf

						If oXml:xPathHasNode( "/ocorrencias/ocorrencia[" + cValToChar(nItem)+ "]/codigo" )
							cCodErr := oXml:xPathGetNodeValue( "/ocorrencias/ocorrencia[" + cValToChar(nItem)+ "]/codigo" )
						EndIf

						If oXml:xPathHasNode( "/ocorrencias/ocorrencia[" + cValToChar(nItem)+ "]/descricao" )
							cDescErr := oXml:xPathGetNodeValue( "/ocorrencias/ocorrencia[" + cValToChar(nItem)+ "]/descricao" )
						EndIf

						If oXml:xPathHasNode( "/ocorrencias/ocorrencia[" + cValToChar(nItem)+ "]/localizacao" )
							cLocalErr := oXml:xPathGetNodeValue( "/ocorrencias/ocorrencia[" + cValToChar(nItem)+ "]/localizacao" )
						EndIf

						cSequencia := StrZero(nItem, GetSX3Cache("V2H_SEQERR", "X3_TAMANHO"))
						
						If V2H->(MsSeek(cFil + PADR(fixNull(aRetorno:CID), nTamChv) + cSequencia))
							limpaRegV2H(PADR(fixNull(aRetorno:CID),nTamChv),cFil)
						EndIf

						lCommitV2H := recV2H(aRetorno, cFil, cEvento, cTipoErr, cDescErr, cUserName, cCodErr, cDescResp, cSequencia, lJob, cLocalErr)

					EndIf

					nItem++

				EndDo	

			Else

				lNoOcorr := .T.

				If oXml:XPathHasNode("/retornoProcessamentoLoteEventos/status")

					cTipoErr	:= "001" 	// Tipo Advertência
					cCodErr 	:= oXml:xPathGetNodeValue( "/retornoProcessamentoLoteEventos/status/cdResposta" )		// Código do Erro
					cDescErr	:= oXml:xPathGetNodeValue( "/retornoProcessamentoLoteEventos/status/descResposta" )	// Descrição do Erro	
					cSequencia	:= StrZero(nItem, GetSX3Cache("V2H_SEQERR", "X3_TAMANHO"))

					If V2H->(MsSeek(cFil + PADR(fixNull(aRetorno:CID), nTamChv) + cSequencia))
						limpaRegV2H(PADR(fixNull(aRetorno:CID),nTamChv),cFil)
					EndIf
	
					If RecLock( "V2H", .T. )
	
						V2H->V2H_FILIAL := cFil
						V2H->V2H_ID 	:= TafGeraID("TAF")
						V2H->V2H_IDCHVE := fixNull(aRetorno:CID)
						V2H->V2H_EVENTO := cEvento
						V2H->V2H_DETAIL := fixNull(aRetorno:CDETSTATUS)
						V2H->V2H_TPERRO := cTipoErr
						V2H->V2H_DSCREC := fixNull(aRetorno:CDSCRECEITA)
						V2H->V2H_PROTUL := fixNull(aRetorno:CPROTOCOLO)
						V2H->V2H_DCERRO := cDescErr
						V2H->V2H_CODREC := fixNull(aRetorno:CCODRECEITA,3)
						V2H->V2H_DATA   := dDataBase
						V2H->V2H_HORA   := Time()
						V2H->V2H_SEQERR := cSequencia
						V2H->V2H_CODERR	:= cCodErr
	
						If lJob
							V2H->V2H_USER := "__Schedule"
						Else
							V2H->V2H_USER := cUserName
						Endif
						V2H ->(MsUnlock())
	
					EndIf
	
				EndIf
			EndIf
		Else
			 lNoOcorr := .T. 
		EndIf 

		If lNoOcorr

			If !ValType(aRetorno:CXMLEVENTO) == "U" .And. ValType(DecodeUTF8(aRetorno:CXMLEVENTO)) == "U" 
				cXml := EncodeUTF8(aRetorno:CXMLEVENTO)
			Else
				If !ValType(aRetorno:CXMLBASE64) == "U" .AND. ValType(DecodeUTF8(aRetorno:CXMLBASE64)) == "U"
					cXml := aRetorno:CXMLEVENTO
				Else
					cXml := aRetorno:CXMLBASE64
				EndIf
			EndIf 

			If !Empty(cXml) .And. oXML:Parse( cXml )

				//Tratativa para recuperar as mensagens de inconssitência quando o RET nao retorna as ocorrências
				oXml:XPathRegisterNS( "ns1", "http://www.esocial.gov.br/schema/evt/retornoEvento/v1_2_0" )
				oXml:XPathRegisterNS( "ns2", "http://www.esocial.gov.br/schema/evt/retornoEvento/v1_2_1" )

				cDescResp := getDescResposta(oXml,"/")
				If Empty(AllTrim(cDescResp))
					getDescResposta(oXml)
				EndIf 

				If aRetorno:CCODRECEITA = "202"

					lRet202 := gravaOcorr202(oXml,"/","ns2",cFil,cEvento,nTamChv,aRetorno,cDescResp,cUserName,lJob)
					If !lRet202

						lRet202 := gravaOcorr202(oXml,"/","ns1",cFil,cEvento,nTamChv,aRetorno,cDescResp,cUserName,lJob)
					
						If !lRet202 

							lRet202 := gravaOcorr202(oXml,"","ns2",cFil,cEvento,nTamChv,aRetorno,cDescResp,cUserName,lJob)
							
							If !lRet202
								gravaOcorr202(oXml,"","ns1",cFil,cEvento,nTamChv,aRetorno,cDescResp,cUserName,lJob)
							EndIf 
						EndIf 
					EndIf 
					
				Else

					cSequencia := StrZero(nItem, GetSX3Cache("V2H_SEQERR", "X3_TAMANHO")) 
				
					If  V2H->(MsSeek(cFil + PADR(fixNull(aRetorno:CID), nTamChv) + cSequencia))
						limpaRegV2H(PADR(fixNull(aRetorno:CID),nTamChv),cFil)
					EndIf

					lCommitV2H := recV2H(aRetorno, cFil, cEvento, cTipoErr, cDescErr, cUserName, cCodErr, cDescResp, cSequencia, lJob, cLocalErr)
				
				EndIf 
			EndIf 	
		EndIf

		If ValType(oXml) == "O"
			FreeObj(oXml)
			oXml := Nil 
		EndIf

	ElseIf lVersion12

		cSql := " INSERT INTO " + cArqREtTss:GetRealName()
		cSql += " (FILIAL,ID,EVENTO,DETSTATUS,DSCRECEITA,RECIBO,XMLERRORET,CODRECEITA,STATUS)
		cSql += " VALUES ("
		cSql +=  "'" + cFil +"'"
		cSql +=  ",'" + cId +"'"
		cSql +=  ",'" + cEvento +"'"
		cSql +=  ",'" + fixNull(aRetorno:CDETSTATUS,250)  	+"'"
		cSql +=  ",'" + fixNull(aRetorno:CDSCRECEITA,250) 	+"'"
		cSql +=  ",'" + fixNull(aRetorno:CRECIBO,44) 		+"'"
	//	cSql +=  ",'" + fixNull(aRetorno:CHISTPROC) 	+"'"
		cSql +=  ",'" + fixNull(aRetorno:CXMLERRORET, Iif( cBanco == "INFORMIX" .Or. cBanco == "POSTGRES", 250, 2000 )) + "'"
		cSql +=  ",'" + fixNull(aRetorno:CCODRECEITA,3) 	+"'"
		cSql +=  ",'" + fixNull(aRetorno:CSTATUS,1)			+"'"
		cSql += " )"


		If TCSQLExec (cSql) < 0
			If lJob
				TafConOut(TCSQLError())
			Else
				cMsgRet += TCSQLError()
			EndIf
		EndIf
	EndIf 

Return lCommitV2H

//---------------------------------------------------------------------
/*/{Protheus.doc} getDescResposta

@Author		
@Since		
@Version	
/*/
//---------------------------------------------------------------------
Static Function getDescResposta(oXml,cTagRaiz)

	Local cDescResp  := ""
	
	Default cTagRaiz := ""

	If oXml:xPathHasNode(cTagRaiz + "evento/retornoEvento/ns1:eSocial/ns1:retornoEvento/ns1:processamento/ns1:descResposta" ) 
		cDescResp := oXml:xPathGetNodeValue(cTagRaiz +"evento/retornoEvento/ns1:eSocial/ns1:retornoEvento/ns1:processamento/ns1:descResposta" )
	ElseIf oXml:xPathHasNode(cTagRaiz + "evento/retornoEvento/ns2:eSocial/ns2:retornoEvento/ns2:processamento/ns2:descResposta" )
		cDescResp := oXml:xPathGetNodeValue(cTagRaiz + "evento/retornoEvento/ns2:eSocial/ns2:retornoEvento/ns2:processamento/ns2:descResposta" )
	EndIf

Return cDescResp 

//---------------------------------------------------------------------
/*/{Protheus.doc} gravaOcorr202

@Author		
@Since		
@Version	
/*/
//---------------------------------------------------------------------
Static Function gravaOcorr202(oXml,cTagRaiz,ns,cFil,cEvento,nTamChv,aRetorno,cDescResp,cUserName,lJob)

	Local cNodeNs    := ""
	Local nItem      := 1
	Local cTipoErr   := ""
	Local cCodErr    := ""
	Local cDescErr   := ""
	Local lCommitV2H := .F.
	Local cSequencia := ""
	
	Default cTagRaiz := ""

	cNodeNs := cTagRaiz + "evento/retornoEvento/" + ns + ":eSocial/" + ns + ":retornoEvento/" + ns + ":processamento/" + ns + ":ocorrencias" 

	If oXml:xPathHasNode(cNodeNs) 

		While oXml:XPathHasNode(cNodeNs + "/" + ns + ":ocorrencia[" + cValToChar(nItem)+ "]")
			
			If nItem >= 1

				If oXml:xPathHasNode(cNodeNs + "/" + ns + ":ocorrencia[" + cValToChar(nItem)+ "]/" + ns + ":tipo" )
					cTipoErr := oXml:xPathGetNodeValue(cNodeNs + "/" + ns + ":ocorrencia["+ cValToChar(nItem)+ "]/" + ns + ":tipo" )
				EndIf

				If oXml:xPathHasNode(cNodeNs + "/" + ns + ":ocorrencia[" + cValToChar(nItem)+ "]/" + ns + ":codigo" )
					cCodErr := oXml:xPathGetNodeValue(cNodeNs + "/" + ns + ":ocorrencia[" + cValToChar(nItem)+ "]/" + ns + ":codigo" )
				EndIf

				If oXml:xPathHasNode(cNodeNs + "/" + ns + ":ocorrencia[" + cValToChar(nItem) + "]/" + ns + ":descricao" )
					cDescErr := oXml:xPathGetNodeValue(cNodeNs + "/" + ns + ":ocorrencia[" + cValToChar(nItem)+ "]/" + ns + ":descricao" )
				EndIf

				If oXml:xPathHasNode(cNodeNs + "/" + ns + ":ocorrencia[" + cValToChar(nItem) + "]/" + ns + ":localizacao" )
					cLocalErr := oXml:xPathGetNodeValue(cNodeNs + "/" + ns + ":ocorrencia[" + cValToChar(nItem)+ "]/" + ns + ":localizacao" )
				EndIf

				cSequencia := StrZero(nItem, GetSX3Cache("V2H_SEQERR", "X3_TAMANHO"))

				If  V2H->(MsSeek(cFil + PADR(fixNull(aRetorno:CID), nTamChv) + cSequencia))
					limpaRegV2H(PADR(fixNull(aRetorno:CID),nTamChv),cFil)
				EndIf

				lCommitV2H := recV2H(aRetorno, cFil, cEvento, cTipoErr, cDescErr, cUserName, cCodErr, cDescResp, cSequencia, lJob, cLocalErr)

				nItem++

			EndIf

		EndDo 

	EndIf

Return lCommitV2H

//---------------------------------------------------------------------
/*/{Protheus.doc} recV2H

@Author		
@Since		
@Version	
/*/
//---------------------------------------------------------------------
Static Function recV2H(aXmlsRetorno,cFil,cEvento,cTipoErr,cDescErr,cUserName,cCodErr,cDescResp,cSequencia,lJob,cLocalErr)

	Local lRecOk := .F. 

	Default cSequencia := "000001"

	lRecOk := RecLock( "V2H", .T. )

	If lRecOk

		V2H->V2H_FILIAL := cFil
		V2H->V2H_ID 	:= TafGeraID("TAF")
		V2H->V2H_IDCHVE := fixNull(aXmlsRetorno:CID)
		V2H->V2H_EVENTO := cEvento
		V2H->V2H_DETAIL := fixNull(aXmlsRetorno:CDETSTATUS)
		V2H->V2H_TPERRO := cTipoErr
		V2H->V2H_DSCREC := fixNull(aXmlsRetorno:CDSCRECEITA)
		V2H->V2H_PROTUL := fixNull(aXmlsRetorno:CPROTOCOLO)
		V2H->V2H_DCERRO := cDescErr
		V2H->V2H_CODREC := fixNull(aXmlsRetorno:CCODRECEITA,3)
		V2H->V2H_DATA   := dDataBase
		V2H->V2H_HORA   := TIme()
		V2H->V2H_SEQERR := cSequencia
		V2H->V2H_CODERR	:= cCodErr

		If TafColumnPos("V2H_LOCERR")
			V2H->V2H_LOCERR := cLocalErr
		EndIf 

		If TafColumnPos("V2H_DCRESP")
			V2H->V2H_DCRESP := cDescResp
		EndIf 

		If lJob
			V2H->V2H_USER := "__Schedule"
		Else
			V2H->V2H_USER := cUserName
		EndIf

		V2H ->(MsUnlock())

	EndIf 

Return lRecOk 

//---------------------------------------------------------------------
/*/{Protheus.doc} ajustaNull

Verifica se o valor da String é '', nesses casos é necessário inserir
1 espaço por que o Banco Oracle considera este valor Null e retorna
o erro ORA-01400

@Param  cField - Campo a ser avaliado.
@param  nTamanho - Tamanho maximo do campo

@Author		Evandro dos Santos O. Teixeira
@Since		29/05/2018
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function fixNull(cField,nTamanho)

	Local cValueRet  := ""
	
	Default nTamanho := 0

	If nTamanho == 0
		cValueRet := IIf(Empty(cField),' ',cField)
	Else
		cValueRet := IIf(Empty(cField),' ',Substr(cField,1,nTamanho))
	EndIf

Return  (cValueRet)

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFStsXTSS

De/Para dos Códigos de Retorno do TSS x TAF

@Param  cStatus - Status de retorno do TSS
@return cStatusTAF - Status de retorno do TAF

@Author		Evandro dos Santos O. Teixeira
@Since		13/08/2017
@Version	1.0
/*/
//---------------------------------------------------------------------
Function TAFStsXTSS( cStatus as Character )

	Local cStatusTAF as Character

	cStatusTAF := "9"

	//Aguardando retorno
	If cStatus $ "124"
		cStatusTAF :=  '2'
	EndIf

	//Documento recusado
	If cStatus $ "35"
		cStatusTAF := '3'
	EndIf

	//Documento autorizado
	If cStatus == "6"
		cStatusTAF := '4'
	EndIf
	
Return cStatusTAF

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFStsEXTSS

De/Para dos Códigos de Retorno do TSS x TAF (Eventos Excluidos)
Obs. Quando é enviado um registro S-3000 o evento que está sendo
vinculado na exclusão é identificado com os status 6 - Aguardando
Exclusão e 7 - Registro excluido com sucesso.

@Param  cStatus - Status de retorno do TSS
@return cStatusTAF - Status de retorno do TAF

@Author		Evandro dos Santos O. Teixeira
@Since		13/08/2017
@Version	1.0
/*/
//---------------------------------------------------------------------
Function TAFStsEXTSS(cStatus)

	Local cRetorno := ""

	//Documento autorizado (exclusão)
	If cStatus == "6"
		//Registro Excluido
		cRetorno := '7'
	Else
		//Aguardando retorno da Exclusao
		cRetorno :=  '6'
	Endif
		
Return cRetorno

//---------------------------------------------------------------------
/*/{Protheus.doc} gravaStsExclusao

Atualiza registros excluidos de acordo com o retorno do S-3000
Obs. O registro S-3000 deve estar posicionado.

@Param  cStatus - Status de retorno do TSS
@Param  cFilEvt - Filial do Evento de acordo com o Browse
@return x - [1] - Status da gravação (logico)
		    [2] - Descrição efetividade da gravação

@Author		Evandro dos Santos O. Teixeira
@Since		13/08/2017
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function gravaStsExclusao( cStatus as character, cFilEvt as character, cLayOut as character)

	Local cAlias       as character
	Local cEvtExcluido as character
	Local cAliasExclu  as character
	Local cMsgRet      as character
	Local cStatusEx    as character
	Local cIdCM6       as character
	Local cAliasCM6    as character
	Local cAliasTot    as character
	Local cNrRecTot    as character
	Local nOrdRecibo   as numeric
	Local nRecNo       as numeric
	Local lGravaOk     as logical
	Local aEvtExcluido as array
	Local aChaveV3N    as array
	Local oReport      as object

	Default cStatus := ""
	Default cFilEvt := ""
	Default cLayOut := ""

	cAlias          := IIF(cLayOut=="S-3500", "V7J", "CMJ")
	cEvtExcluido    := Posicione( 'C8E' ,1,xFilial("C8E")+(cAlias)->&(cAlias + "_TPEVEN"),"C8E_CODIGO")
	cAliasExclu     := ""
	cMsgRet         := ""
	cStatusEx       := ""
	cIdCM6          := ""
	cAliasCM6       := ""
	cAliasTot       := ""
	cNrRecTot       := ""
	nOrdRecibo      := 0
	nRecNo          := 0
	lGravaOk        := .T.
	aEvtExcluido    := TAFRotinas(cEvtExcluido,4,.F.,2)
	aChaveV3N       := {}
	oReport         := Nil
	
	If Len(aEvtExcluido) > 1

		cAliasExclu  := aEvtExcluido[3]
		nOrdRecibo	 := aEvtExcluido[13]

		dbSelectArea(cAliasExclu)
		dbSetOrder(nOrdRecibo)
		
		If ( cAliasExclu )->( MsSeek( cFilEvt + PADR( AllTrim((cAlias)->&(cAlias + "_NRRECI")), GetSx3Cache( cAlias + "_NRRECI", "X3_TAMANHO" ) ) ) )

			//Posiciono primeiro para achar o Id, deixando assim a consulta + performatica pois não tenho um indice
			//para o campo PROTPN
			nRecNo := foundPendExclusao( cAliasExclu, cFilEvt, (cAliasExclu)->&(cAliasExclu + "_ID"), AllTrim( (cAlias)->&(cAlias + "_NRRECI") ) )

			If nRecNo > 0

				(cAliasExclu)->(dbGoTo(nRecNo))
				
				cStatusEx := TAFStsEXTSS(cStatus)
				
				RecLock((cAliasExclu),.F.)
					(cAliasExclu)->&(cAliasExclu+"_STATUS") := cStatusEx
					(cAliasExclu)->&(cAliasExclu+"_ATIVO")  := IIF(cStatusEx == '6','1','2')
				(cAliasExclu)->(MsUnlock())

				cMsgRet := "Atualização do Status de exclusão do evento " + cEvtExcluido + " realizado com sucesso."

				//Operação para casos em que foi transmitido um S-3000 de um Evento que possui relação com o Totalizador S-5001 e/ou S-5003

				If cAliasExclu == "CMD" .or. cAliasExclu == "T92" .or. cAliasExclu == "C91"
					cNrRecTot := ( cAliasExclu )->&( cAliasExclu + "_PROTPN" )

					//Realiza a limpeza da tabela de Movimentação de Remunerações
					If TAFAlsInDic( "V3N" )

						aChaveV3N := GetV3NChv( cAliasExclu )

						oReport := TAFSocialReport():New()
						oReport:Delete(aChaveV3N[1],aChaveV3N[2],aChaveV3N[3],aChaveV3N[4],aChaveV3N[5],'','',.T. )
						FreeObj( oReport )

					EndIf

					//S-5001
					cAliasTot := GetNextAlias()

					BeginSql Alias cAliasTot
						SELECT T2M.R_E_C_N_O_ RECNOT2M
						FROM %table:T2M% T2M
						WHERE T2M.T2M_NRRECI = %exp:cNrRecTot%
						  AND T2M.T2M_ATIVO = '1'
						  AND T2M.%notDel%
					EndSql

					( cAliasTot )->( DBGoTop() )
					If ( cAliasTot )->( !Eof() )

						T2M->( DBGoTo( ( cAliasTot )->RECNOT2M ) )

						RecLock( "T2M", .F. )
						T2M->T2M_ATIVO := "2"
						T2M->( MsUnlock() )

					EndIf

					( cAliasTot )->( DBCloseArea() )

					//S-5003

					//-- Proteção para não causar erro no layout 2.4
					If TAFAlsInDic("V2P")

						cAliasTot := GetNextAlias()

						BeginSql Alias cAliasTot
							SELECT V2P.R_E_C_N_O_ RECNOV2P
							FROM %table:V2P% V2P
							WHERE V2P.V2P_NRRECI = %exp:cNrRecTot%
							AND V2P.V2P_ATIVO = '1'
							AND V2P.%notDel%
						EndSql

						( cAliasTot )->( DBGoTop() )
						If ( cAliasTot )->( !Eof() )

							V2P->( DBGoTo( ( cAliasTot )->RECNOV2P ) )

							RecLock( "V2P", .F. )
							V2P->V2P_ATIVO := "2"
							V2P->( MsUnlock() )

						EndIf

						( cAliasTot )->( DBCloseArea() )

					EndIf

				EndIf

				// Ao excluir o término de um afastamento já transmitido, será necessário buscar o registro de início para reativá-lo, possibilitando assim o envio de um novo término.
				If cAliasExclu == "CM6" .And. cStatusEx == '7' .And. CM6->CM6_XMLREC == 'TERM'
				
					cIdCM6     := CM6->CM6_ID
					cAliasCM6  := GetNextAlias()
				
					BeginSql Alias cAliasCM6
						SELECT MAX(CM6.R_E_C_N_O_) RECNOCM6
						FROM %table:CM6% CM6
						WHERE CM6.CM6_FILIAL = %xfilial:CM6% 
						AND	CM6.CM6_ID       = %exp:cIdCM6%
						AND CM6.CM6_XMLREC   = 'INIC'
						AND	CM6.%notDel%
					EndSql
					
					(cAliasCM6)->(DbGoTop())
					
					If (cAliasCM6)->(!Eof()) .And. (cAliasCM6)->RECNOCM6 > 0

						CM6->( DBGoTo( (cAliasCM6)->RECNOCM6 ) )
						Reclock('CM6', .F.)
						CM6->CM6_ATIVO := '1'
						CM6->(MsUnlock())

					EndIf
					
					(cAliasCM6)->(DbCloseArea())
				EndIf

			Else
				lGravaOk := .F.
			EndIf

		Else
			lGravaOk := .F.
		EndIf

	Else
		lGravaOk := .F.
	EndIf

	If !lGravaOk
		MsgRet := "Evento não encontrado para atualização do Status de exclusão."
	EndIf

Return { lGravaOk, cMsgRet }

//---------------------------------------------------------------------
/*/{Protheus.doc} foundPendExclusao

Retorna o RecNo do registro que está pendente de Exclusão

@Param  cAliasEvt  - Alias do Evento pendente de Exclusão
@Param  cFilEvt    - Filial do Evento pendente de Exclusão
@Param  cIdEvt     - Id do Evento pendente de Exclusão
@Param  cReciboEvt - Numero do recibo que se encontra no campo _PROTPN

@Author		Evandro dos Santos O. Teixeira
@Since		18/03/2018
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function foundPendExclusao(cAliasEvt,cFilEvt,cIdEvt,cReciboEvt)

	Local nRecNo := 0
	Local cQuery := ""
	Local cAlias := GetNextAlias()

	cQuery := " SELECT R_E_C_N_O_ RECNO "
	cQuery += " FROM " + RetSqlName(cAliasEvt)
	cQuery += " WHERE " + cAliasEvt + "_FILIAL = '" + cFilEvt + "'"
	cQuery += " AND " + cAliasEvt + "_ID = '" + cIdEvt + "'"
	cQuery += " AND " + cAliasEvt + "_PROTPN = '" + cReciboEvt + "'"    
	cQuery += " AND " + cAliasEvt + "_STATUS = '6'
	cQuery += " AND " + cAliasEvt + "_EVENTO = 'E'
	cQuery += " AND D_E_L_E_T_ = ' '

	cQuery := ChangeQuery(cQuery)

	TCQuery cQuery New Alias (cAlias)

	If !Empty((cAlias)->RECNO)
		nRecNo := (cAlias)->RECNO
	EndIf 

	(cAlias)->(dbCloseArea())

Return nRecNo

//-------------------------------------------------------------------
/*/{Protheus.doc} GeraEvtTot
Geração dos eventos totalizadores (5000|5001|5012) no retorno do 1200/1210/1290
@Return  Mensagem com status 
@author Victor Andrade
@since  17/05/2016
@version 1.0
/*///----------------------------------------------------------------
Static Function GeraEvtTot( cXmlTot as character, cLayout as character, cAliasTb as character, cFilErp as character,;
							lTotaliz as logical, cChvV2J as character, cFil as character, cRecibo as character, nRecEvtOri as numeric )

	Local aRetorno 			as array
	Local aEvtTotal			as array
	Local cErrorXML			as character
	Local cWarningXML		as character
	Local cMsgRetorno		as character
	Local lInsert			as logical
	Local nX				as numeric
	Local oXmlTot			as object
	Local xEvtTotalizador	as variant

	Default cXmlTot			:= ""
	Default cLayout			:= ""
	Default cFilErp			:= ""
	Default cRecibo 		:= ""
	Default cAliasTb		:= "C1E"
	Default lTotaliz		:= .F.
	Default nRecEvtOri		:= 0

	aRetorno		:= {}
	aEvtTotal		:= {}
	cErrorXML		:= ""
	cWarningXML		:= ""
	cMsgRetorno		:= ""
	lInsert			:= .T. 
	nX				:= 0
	oXmlTot			:= Nil
	xEvtTotalizador	:= Nil

	// --> Faz o "parse" do XML para pegar somente o bloco do eSocial, pois a tag possui o retorno do governo completo
	oXmlTot := XmlParser( cXmlTot,"", @cErrorXML, @cWarningXML )

	If Empty(cErrorXML)

		If ValType(oXmlTot) == "O"

			If XmlChildEx(oXmlTot, '_EVENTO' ) <> Nil

				If Empty(cRecibo)
					cRecibo := oXmlTot:_EVENTO:_RETORNOEVENTO:_ESOCIAL:_RETORNOEVENTO:_RECIBO:_NRRECIBO:TEXT
				EndIf 

				xEvtTotalizador := XmlChildEx(oXmlTot:_EVENTO, "_TOT")
				aEvtTotal		:= IIf(ValType(xEvtTotalizador) == "O", {xEvtTotalizador}, xEvtTotalizador)

				If !Empty(aEvtTotal)

					For nX := 1 To Len(aEvtTotal)

						aRetorno := gravaTotalizador(aEvtTotal[nX], cFilErp, cLayout, cAliasTb, nRecEvtOri)

						If !aRetorno[1] 
							cMsgRetorno += aRetorno[4] + CRLF
						EndIf 

						lTotaliz 	:= aRetorno[1] 
						nX 			:= IIf(!lTotaliz, Len(aEvtTotal) + 1, nX)

					Next nX

				Else
					cMsgRetorno := "Evento " + cLayout + " sem retorno de totalizador."
				EndIf

			Else
				cMsgRetorno := "Evento " + cLayout + " sem retorno de totalizador."
			EndIf

		Else

			cMsgRetorno := "--- Falha ao efetuar XmlParser - Tipo oXmlTot " + ValType(oXmlTot) + " ---"

			If valtype(cWarningXML) == 'C'
				cMsgRetorno += "--- Warning --- " + cWarningXML
			EndIf

		EndIf

	Else
		cMsgRetorno := cErrorXML
	EndIf

	If !lTotaliz
	
		If Valtype(cMsgRetorno) == 'C' 

			If Empty(cMsgRetorno) 
				cMsgRetorno := "Nao foi possivel obter o erro ocorrido na gravacao do totalizador. Chave: " + cChvV2J
			EndIf 

		Else
			cMsgRetorno := "Tipo de dado indefinido no retorno do Totalizador. Chave: " + cChvV2J
		EndIf 

		If TAFAlsInDic("V2J")

			lInsert := V2J->(MsSeek(cFil+PADR(AllTrim(cChvV2J),GetSx3Cache("V2J_CHVTAF","X3_TAMANHO"))))
			lInsert := !lInsert

			RecLock("V2J",lInsert)
				V2J->V2J_FILIAL := cFil
				V2J->V2J_CHVTAF := AllTrim(cChvV2J)
				V2J->V2J_DSCERR := AllTrim(cMsgRetorno)
				V2J->V2J_DTOCOR := dDataBase
				V2J->V2J_HROCOR := Time()
			V2J->(MsUnlock())

		EndIf 

		TafConOut(cMsgRetorno)
		
	EndIf
	
	If ValType(oXmlTot) == "O"
		FreeObj(oXmlTot)
	EndIf

	oXmlTot  := Nil
	aSize(aRetorno,0)

	FwFreeArray(aEvtTotal)

	If ValType(xEvtTotalizador) == "O"

		FreeObj(xEvtTotalizador)
		xEvtTotalizador := Nil 

	ElseIf ValType(xEvtTotalizador) == "A"

		For nX := 1 To Len(xEvtTotalizador)

			If ValType(xEvtTotalizador) == "O"
				FreeObj(xEvtTotalizador[nX])
				xEvtTotalizador[nX] := Nil 
			EndIf 

		Next nX

		aSize(xEvtTotalizador,0)

	EndIf 

Return (cMsgRetorno)

//-------------------------------------------------------------------
/*/{Protheus.doc} gravaTotalizador
Grava evento totalizador utilizado a API de integraçao TafPrepInt
@Return  aRetInt - Retorno da gravação do totalizador
			[1] - logico - determina se a mensagem é de uma integração bem sucedida
			[2] - caracter - status do registro (codigo utilizado na TAFXERP)
				1 - Incluido
				2 - Alterado
				3 - Excluido
				4 - Aguardando na Fila
				8 - Filhos Duplicado
				9 - Erro
			[3] - Codigo do Erro
			[4] - Descrição da Mensagem de Integração
@author Evandro dos Santos Oliveira	
@since  19/08/2017
@version 1.0
/*///----------------------------------------------------------------
Static Function gravaTotalizador( xEvtTotalizador as Object, cFilErp as Character, cEvtOri as Character, cAliasTb as Character, nRecEvtOri as Numeric )

	Local aLayouts   as Array
	Local aRetInt    as Array
	Local cEvtTot    as Character
	Local cVersTot   as Character
	Local cXMLConv   as Character
	Local lLaySmpTot as Logical
	Local nPosIni    as Numeric
	
	Default cEvtOri 		:= ""
	Default cFilErp			:= ""
	Default cAliasTb		:= ""
	Default nRecEvtOri		:= 0
	Default xEvtTotalizador := Nil

	aLayouts   := StrTokArr2("S_01_00_00|S_01_01_00|S_01_02_00|S_01_03_00", "|")
	aRetInt    := {}
	cEvtTot    := ""
	cXMLConv   := XMLSaveStr(xEvtTotalizador)
	lLaySmpTot := .F.
	nPosIni    := (At("eSocial", cXMLConv) - 1)

	cXmlConv := SubStr( cXMLConv, nPosIni )
	cEvtTot  := xEvtTotalizador:_TIPO:TEXT
	cVersTot := TAFNameEspace(xEvtTotalizador:_ESOCIAL:_XMLNS:TEXT)
	
	If !Empty(cVersTot)

		If AScan(aLayouts, cVersTot) > 0
			lLaySmpTot := .T.
		EndIf

	EndIf	 
	
	TafPrepInt( cEmpAnt, cFilErp, cXmlConv,, "4", cEvtTot,,,, @aRetInt, .F.,,,,,,,, cEvtOri,,,, lLaySmpTot, cAliasTb, nRecEvtOri )
	
Return aRetInt

//-------------------------------------------------------------------
/*/{Protheus.doc} limpaRegT0X
Limpa inconsistênca da tabela T0X.

@Return cIdAux - Chave da inconsistência a ser excluida 

@author Evandro dos Santos Oliveira	
@since  15/01/2018
@version 1.0

/*///----------------------------------------------------------------
Static Function limpaRegT0X( cIdAux as Character)

	If TcSqlExec("DELETE FROM " + RetSqlName("T0X") + " WHERE T0X_IDCHVE = '" + cIdAux + "' AND (T0X_USER = '" + cUserName + "' OR T0X_USER = '__Schedule')") < 0
		
		If lJob
			TafConOut("Erro na limpeza das inconsistências: " + TCSQLError())
		Else
			MsgStop(TCSQLError(),"Erro na limpeza das inconsistências")
		EndIf

	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} limpaRegV2H
Limpa inconsistênca da tabela V2H.

@Return cIdAux - Chave da inconsistência a ser excluida 

@author Evandro dos Santos Oliveira	
@since  21/10/2018
@version 1.0

/*///----------------------------------------------------------------
Function limpaRegV2H( cIdAux as Character, cFil as Character)

	Local cSqlExec as Character
	Local nTamChv  as Numeric
	
	Default cFil  := ""

	nTamChv  := GetSx3Cache("V2H_IDCHVE","X3_TAMANHO")

	cSqlExec := "DELETE FROM " + RetSqlName("V2H") + " WHERE V2H_IDCHVE = '" + PADR( cIdAux, nTamChv ) + "'"
	
	If !Empty(cFil)
		cSqlExec += " AND V2H_FILIAL = '" + cFil + "'"
	EndIf

	If TcSqlExec( cSqlExec ) < 0

		If lJob
			TAFConOut("Erro na limpeza das inconsistências do RET: " + TCSQLError())
		Else
			MsgStop(TCSQLError(),"Erro na limpeza das inconsistências do RET")
		EndIf

	EndIf

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} limpaTotV2J
Limpa inconsistênca da tabela V2J.

@Return cIdAux - Chave da inconsistência a ser excluida 

@author Evandro dos Santos Oliveira	
@since  09/11/2018
@version 1.0

/*///----------------------------------------------------------------
Static Function limpaTotV2J( cIdAux as Character,  cFil as Character)

	Local nTamChv as Numeric

	nTamChv := GetSx3Cache("V2J_CHVTAF","X3_TAMANHO")

	If TcSqlExec("DELETE FROM " + RetSqlName("V2J") + " WHERE V2J_FILIAL = '" + cFil + "' AND  V2J_CHVTAF = '" + PADR(cIdAux,nTamChv) + "'" ) < 0
		
		If lJob
			TAFConOut("Erro na limpeza das inconsistências dos Totalizadores: " + TCSQLError())
		Else
			MsgStop(TCSQLError(),"Erro na limpeza das inconsistências dos Totalizadores")
		EndIf

	EndIf

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Informacoes de definicao dos parametros do schedule
@Return  Array com as informacoes de definicao dos parametros do schedule
		 Array[x,1] -> Caracter, Tipo: "P" - para Processo, "R" - para Relatorios
		 Array[x,2] -> Caracter, Nome do Pergunte
		 Array[x,3] -> Caracter, Alias(para Relatorio)
		 Array[x,4] -> Array, Ordem(para Relatorio)
		 Array[x,5] -> Caracter, Titulo(para Relatorio)

@author Evandro dos Santos Oliveira	
@since  17/05/2016
@version 1.0

/*///----------------------------------------------------------------
Static Function SchedDef()

	Local aParam := {}

	aParam := { "P",;			//Tipo R para relatorio P para processo
				"TAFESXTSS",;	//Pergunte do relatorio, caso nao use passar ParamDef
				,"SM0";			//Alias
				,;				//Array de ordens
				}				//Titulo

Return ( aParam )

//---------------------------------------------------------------------
/*/{Protheus.doc} GetXmlRetTss
@type			function
@description	Rotina que irá realizar a consulta dos eventos no TSS para retorno do recibo e do XML de envio.
@author			Eduardo Sukeda
@since			09/04/2019
/*/
//---------------------------------------------------------------------
Static Function GetXmlRetTss( aXmlsLote as Array, cUrl as Character, cEntidade as Character, cAmbiente as Character, cEvtRetXml as Character,;
							  lRequest as Logical, lRetXml as Logical, lTransFil as Logical, cMsgErro as Character )

	Local aArea        as Array
	Local aXmlsRetorno as Array
	Local cFilBack     as Character
	Local lCngFil      as Logical
	Local nItemLote    as Numeric
	Local oSocial      as Object

	Default lRequest 	:= .F. 
	Default lRetXml 	:= .F. 
	Default cEvtRetXml 	:= ""
	Default lTransFil	:= .F.
	Default cMsgErro	:= ""

	aArea        := SM0->(GetArea())
	aXmlsRetorno := {}
	cFilBack     := cFilAnt
	lCngFil      := .F.
	nItemLote    := 0
	oSocial      := Nil

	If lTransFil
		lCngFil := TAFChgFil(@cMsgErro)
	Else
		lCngFil := .T.
	EndIf

	If lCngFil

		oSocial	:= WSTSSWSSOCIAL():New()

		If oSocial <> Nil

			oSocial:_Url 						:= cUrl 
			oSocial:oWSENTCONSDADOS:cUSERTOKEN 	:= "TOTVS"
			oSocial:oWSENTCONSDADOS:cID_ENT    	:= cEntidade
			oSocial:oWSENTCONSDADOS:cAMBIENTE   := cAmbiente    

			oSocial:oWSENTCONSDADOS:oWSENTCONSDOCS := WsClassNew("TSSWSSOCIAL_ARRAYOFENTCONSDOC")  
			oSocial:oWSENTCONSDADOS:oWSENTCONSDOCS:oWSENTCONSDOC := {}

			For nItemLote := 1 To Len(aXmlsLote)

				aAdd(oSocial:oWSENTCONSDADOS:oWSENTCONSDOCS:oWSENTCONSDOC,WsClassNew("TSSWSSOCIAL_ENTCONSDOC"))
				Atail(oSocial:oWSENTCONSDADOS:oWSENTCONSDOCS:oWSENTCONSDOC):CCODIGO	:= aXmlsLote[nItemLote][4]
				Atail(oSocial:oWSENTCONSDADOS:oWSENTCONSDOCS:oWSENTCONSDOC):CID		:= aXmlsLote[nItemLote][2]

				If AllTrim(aXmlsLote[nItemLote][4]) $ cEvtRetXml .Or. lRetXml
					Atail(oSocial:oWSENTCONSDADOS:oWSENTCONSDOCS:oWSENTCONSDOC):lRETORNAXML	:= .T.
				Else
					Atail(oSocial:oWSENTCONSDADOS:oWSENTCONSDOCS:oWSENTCONSDOC):lRETORNAXML	:= .F.
				EndIf
				Atail(oSocial:oWSENTCONSDADOS:oWSENTCONSDOCS:oWSENTCONSDOC):lHISTPROC := .T.

			Next nItemLote 

			lRequest := oSocial:consultarDocumentos() 
			
			If oSocial:oWSCONSULTARDOCUMENTOSRESULT <> Nil

				If oSocial:oWSCONSULTARDOCUMENTOSRESULT:oWSSAIDACONSDOCS <> Nil 

					If oSocial:oWSCONSULTARDOCUMENTOSRESULT:oWSSAIDACONSDOCS:oWSSAIDACONSDOC <> Nil
						aXmlsRetorno := oSocial:oWSCONSULTARDOCUMENTOSRESULT:oWSSAIDACONSDOCS:oWSSAIDACONSDOC
					EndIf

				EndIf

			EndIf

			FreeObj(oSocial)
			oSocial := Nil

		EndIf

	EndIf

	RestArea(aArea)
	cFilAnt := cFilBack

Return aXmlsRetorno

//---------------------------------------------------------------------
/*/
{Protheus.doc} getUrlTSS
Rotina para retornar a URL do TSS
@type  Static Function
@author Diego Santos
@since 15-10-2018
@version 1.0
@return return, return_type, return_description
/*/
//---------------------------------------------------------------------
Static Function getUrlTSS()

	Local cUrl := ""

	If FindFunction("TafGetUrlTSS")
		cUrl := AllTrim((TafGetUrlTSS()))
	Else
		cUrl := AllTrim(GetNewPar("MV_TAFSURL","http://"))
	EndIf 

	If !("TSSWSSOCIAL.APW" $ Upper(cUrl)) 
		cUrl += "/TSSWSSOCIAL.apw"
	EndIf	

Return cUrl

//---------------------------------------------------------------------
/*/
{Protheus.doc} getUrlTSS
Rotina para retornar a URL do TSS.
@type  Static Function
@author Diego Santos
@since 15-10-2018
@version 1.0
@return return, return_type, return_description
/*/
//---------------------------------------------------------------------
Static Function getIdEntidade(cUrl,cIdEntidade,cMsgErro)

	Local lTransFil := .F.
	Local lJob      := IsBlind()
	Local cCheckURL := ""
	Local lRet      := .T.

	If FindFunction("TAFTransFil")
		lTransFil := TAFTransFil(lJob)
	EndIf

	If !("TSSWSSOCIAL.APW" $ Upper(cUrl))
		cCheckURL := cUrl
	Else
		cCheckURL := Substr(cUrl,1,Rat("/",cUrl)-1)
	EndIf

	If TAFCTSpd(cCheckURL,,,@cMsgErro)

		cIdEntidade := TAFRIdEnt(lTransFil)

	Else

		lRet := .F.

		If lJob
			TafConOut("Não foi possivel conectar com o servidor TSS")
			TafConOut(cMsgErro)
		EndIf

	EndIf
    
Return lRet

//--------------------------------------------------------------------------- -
/*/{Protheus.doc} TAF_CONJ5M
Recebe a conexão via IPCGO e passa os dados para a rotina processar o lote específico.

@return Nil

@author Robson Santos
@since 07/05/2019
@version 1.0

/*/
//----------------------------------------------------------------------------
Function TAF_CONJ5M(aXmlsLote, cAmbiente, lGrvRet,cUrl,lJob,cIdEnt,lNewProcess,oProcess,nQtdLote,nLote,lGravaErrTab )

	Local oBlock	:=	Nil

	//-- ConOut( "[TAFPROC5MT] Started IPCGo [InitializeProcess]" )
	//-- ConOut( "[TAFPROC5MT] Thread ID: "+ cValtochar(ThreadID()) )

	oBlock := ErrorBlock( { |x| TAFConOut( "[TAFPROC5MT][ERROR] " + Chr( 10 ) + x:Description + Chr( 10 ) + x:ErrorStack ) } )

	BEGIN SEQUENCE
		TafConRG(aXmlsLote, cAmbiente, lGrvRet,cUrl,lJob,cIdEnt,lNewProcess,oProcess,nQtdLote,nLote,lGravaErrTab)
	END SEQUENCE

	ErrorBlock( oBlock )
	
Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} GetV3NChv
@type			function
@description	Retorna a chave para que seja possível posicionar na tabela V3N.
@author			Victor A. Barbosa
@since			18/11/2019
@version		1.0
@param			cAliasExclu	-	Alias do evento pendente de exclusão
@return			cChvRet		-	Chave de negócio para busca na tabela V3N
/*/
//---------------------------------------------------------------------
Static Function GetV3NChv( cAliasExclu )

	Local cCPF		:=	""
	Local cPeriodo	:=	""
	Local aChvRet	:=	""

	Do Case

		Case cAliasExclu == "C91"

			cCPF := C91->C91_CPF

			If Empty( cCPF )
				cCPF := GetAdvFVal( "C9V", "C9V_CPF", xFilial( "C9V" ) + C91->C91_TRABAL + "1", 2, "", .T. )
			EndIf

			aChvRet := {C91->C91_FILIAL,C91->C91_INDAPU,C91->C91_PERAPU,cCPF,"S-1200"}

		Case cAliasExclu == "CMD"
			cCPF		:= GetAdvFVal( "C9V", "C9V_CPF", xFilial( "C9V" ) + CMD->CMD_FUNC + "1", 2, "", .T. )
			cPeriodo	:= SubStr( DToS( CMD->CMD_DTDESL ), 1, 6 )
			aChvRet		:= {CMD->CMD_FILIAL,"1",cPeriodo,cCPF,"S-2299"}

		Case cAliasExclu == "T92"
			cCPF		:= GetAdvFVal( "C9V", "C9V_CPF", xFilial( "C9V" ) + T92->T92_TRABAL + "1", 2, "", .T. )
			cPeriodo	:= SubStr( DToS( T92->T92_DTERAV ), 1, 6 )
			aChvRet		:= {T92->T92_FILIAL,"1",cPeriodo,cCPF,"S-2399"}

	EndCase

Return( aChvRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} IncMessagens

Atualiza o label do objeto FWMSGRUN

@Author		Evandro dos Santos Oliveira
@Since		02/10/2018
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function IncMessagens( oMsgRun as Object, cMsg as Character)

    oMsgRun:cCaption := cMsg
    ProcessMessages()

Return Nil 

//---------------------------------------------------------------------
/*/{Protheus.doc} SetIncPerc
@type			function
@description	Incrementa o progresso realizado.
@author			Felipe C. Seolin
@since			03/12/2018
@version		1.0
@param			oMsgRun		-	Objeto do FWMsgRun
@param			cOper		-	Operação em curso de execução
@param			nQtdTotal	-	Quantidade total de registros a processar
@param			nQtdProc	-	Quantidade de registros processados
/*/
//---------------------------------------------------------------------
Static Function SetIncPerc( oMsgRun as Object, cOper as Character, nQtdTotal as Numeric, nQtdProc as Numeric )

	Local cMessage as Character
	Local cPercent as Character
	
	cPercent := cValToChar( Int( ( nQtdProc / nQtdTotal ) * 100 ) )
	cMessage := I18N( "#1 - Progresso: #2%", { cOper, cPercent } )

	oMsgRun:cCaption := cMessage
	ProcessMessages()

Return()

/*/{Protheus.doc} lockProcess
Implementa um controle de semáforo dinâmico, onde o sistema monitora a execução do processo de consulta. 
Se um processo de consulta estiver em andamento e o número de registros pendentes permanecer inalterado 
após várias execuções, o sistema libera o processo bloqueado e permite que outro processo (thread) seja 
executado.	

Para evitar erros não utilizei o bloqueio de variável, no futuro podemos realizar um controle 
mais robusto. 

@Param  cUUIDJob5 - Secao utilizada para fazer o controle das variáveis de processamento
@Param  cKeyProc  - Chave de controle do processo
@Param	nQtdRegs  - Quantidade de registros pendendes de processamento
@Param	nQtdLastProc - Quantidade de registros processados na ultima execução do processo 
@Param	nTryConsult - Quantidade de vezes que o processo foi executado e o mesmo estava 
estagnado (com a mesma quantidade de registros)

@author  Evandro Oliviera
@since   03/09/2024
@version 1.0
/*/
Static Function lockProcess(cUUIDJob5,cKeyProc,nQtdRegs,nQtdLastProc,nTryConsult)

	Local lLock   as Logical
	Local aProc5  as Array
	Local nMaxTry as Numeric

	Default cKeyProc     := ""
	Default cUUIDJob5    := ""
	Default nQtdLastProc := 0
	Default nTryConsult  := 0

	lLock  	:= .F. 
	aProc5 	:= {}
	nMaxTry := 5

	If VarGetAD(cUUIDJob5,cKeyProc, @aProc5) //Faz uma leitura suja para pegar a quantidade de vezes que o processo foi executado.

		nQtdLastProc := aProc5[1]
		nTryConsult  := aProc5[2] 

		aProc5[1] := nQtdRegs

		If nQtdRegs == nQtdLastProc
			nTryConsult++ //Se a quantidade de registros for igual a quantidade da ultima execução, incrementa a quantidade de tentativas.
			aProc5[2] := nTryConsult
			If VarSetAD(cUUIDJob5,cKeyProc,aProc5) //Faço a atualização suja por que a chave está bloqueada
				TafConOut("lock - Processo de consulta com 'lock' e estagnado: " + cUUIDJob5 + " - " + cKeyProc + " - Quantidade: " + cValToChar(nQtdLastProc) + " - Tentativa: " + cValToChar(nTryConsult))
			EndIf 
		Else 
			nTryConsult := 1
			aProc5[2] := nTryConsult
			// Reinicia a quantidade de tentativas, se a quantidade de registros for diferente da ultima execução indica que o processo está sendo executado normalmente.
			If VarSetAD(cUUIDJob5,cKeyProc,aProc5) //Faço a atualização suja por que a chave está bloqueada
				TafConOut("lock - Processo de consulta com 'lock' e fluindo: " + cUUIDJob5 + " - " + cKeyProc + " - Quantidade: " + cValToChar(nQtdLastProc))
			EndIf 
		EndIf 
	EndIf 

	If nTryConsult == nMaxTry .Or. Len(aProc5) == 0

		If nTryConsult == nMaxTry 
			unLockProcess(cUUIDJob5,cKeyProc)
		EndIf 

		nTryConsult  := 0
		nQtdLastProc := nQtdRegs
		aProc5 := {nQtdRegs,nTryConsult}	
		lLock := VarSetAD(cUUIDJob5,cKeyProc,aProc5) // Seta a quantidade inicial 
		TafConOut("lock - Processo de consulta 'free': " + cUUIDJob5 + " - " + cKeyProc + " - Quantidade: " + cValToChar(nQtdLastProc) + " - Tentativa: " + cValToChar(nTryConsult))
	EndIf 

Return lLock 

/*/{Protheus.doc} unLockProcess
Realiza a limpeza de todas as transacoes e valores vinculados a seção cUUIDJob5

@Param  cUUIDJob5 - Secao utilizada para fazer o controle das variáveis de processamento
@Param  cKeyProc  - Chave de controle do processo

@author  Evandro Oliviera
@since   03/09/2024
@version 1.0
/*/
Static Function unLockProcess(cUUIDJob5,cKeyProc)

	Local lUnlock as Logical

	Default cUUIDJob5 := ""
	Default cKeyProc  := ""

	lUnlock  := VarDel(cUUIDJob5,cKeyProc)

	If lUnlock
		TafConOut("unLock - remocao dos dados da secao : " + cUUIDJob5 + " realizada com sucesso")
	EndIf
	TafConOut("unLock - Encerrando o processo de desbloqueio para a secao: " + cUUIDJob5) 

Return Nil 
