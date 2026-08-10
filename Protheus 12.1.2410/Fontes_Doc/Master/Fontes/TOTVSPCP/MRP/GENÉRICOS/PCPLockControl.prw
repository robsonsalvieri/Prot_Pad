#INCLUDE "TOTVS.CH"
#INCLUDE 'FILEIO.CH'
#INCLUDE "PCPLockControl.CH"

#DEFINE PREF_LOCK         "PCP_Lock_"

#DEFINE AROTINAS_ROTINA   1
#DEFINE AROTINAS_IDROTINA 2
#DEFINE AROTINAS_USUARIO  3
#DEFINE AROTINAS_CONEXAO  4
#DEFINE AROTINAS_DATA     5 //DISPONIVEL PARA ANALISE e TRATAMENTOS DE ERROS - melhoria
#DEFINE AROTINAS_HORA     6
#DEFINE AROTINAS_FUNNAME  7 //DISPONIVEL PARA ANALISE e TRATAMENTOS DE ERROS - melhoria

#DEFINE DEFAULT_NESPERAMAX      300 //Segundos = 5 minutos
#DEFINE DEFAULT_NSLEEP_LOCK     500 //Milisegundos
#DEFINE DEFAULT_NSLEEP_UNLOCK    50 //Milisegundos
#DEFINE DEFAULT_NSLEEP_CHECK     50 //Milisegundos
#DEFINE DEFAULT_NSLEEP_TRANSFER  50 //Milisegundos

/*/{Protheus.doc} PCPLockControl
Controle de Locks PCP
@author  brunno.costa
@since   14/08/2020
@version P12.1.27
/*/
CLASS PCPLockControl FROM LongClassName

	DATA lHabilitado AS LOGICAL
	DATA cPrefLock   AS CHARACTER

	//Metodos publicos
	METHOD new() CONSTRUCTOR
	METHOD check(cProcesso, cRotina, cIDRotina, lExclusivo, cProblema, cSolucao, nSleepDef)
	METHOD lock(cProcesso, cRotina, cIDRotina, lExclusivo, aExcecao, nEspera, cError, nEsperaMax, nSleepDef)
	METHOD transfer(cProcesso, cAnterior, cPosterior, cIDRotina, nSleepDef)
	METHOD unlock(cProcesso, cRotina, cIDRotina, nSleepDef)
	METHOD waitCheck(cProcesso, cRotina, cIDRotina, lExclusivo, cProblema, cSolucao)

	STATIC METHOD semaforo(cOpcao, cChave, nTentativa, lEmpresa, lFilial)

	//Metodos internos
	METHOD getProcessName(cProcesso)
	METHOD getName(cCodRotina)
	METHOD memoWrite(cFileName, cConteudo)
	METHOD memoErase(cFileName)
	METHOD blocks(oJson, lResumido)
	METHOD showHelp(lTela, oJson, cFileName, cProcesso)
	METHOD showMsgRun(cProcesso, bBlock, cUsuario, cRotina)
	METHOD recovery(oJson)

ENDCLASS

/*/{Protheus.doc} New
Metodo construtor
@author  brunno.costa
@since   14/08/2020
@version P12.1.27
@return Self, objeto, instancia da classe
/*/
METHOD New() CLASS PCPLockControl
	Self:cPrefLock   := Iif(Self:cPrefLock == Nil, GetPathSemaforo() + FWGrpCompany() + FWCodEmp() + FWCodFil() + "_PCPLockControl_" , Self:cPrefLock)
	Self:lHabilitado := .F. //SuperGetMV("MV_PCPLMRP",.F.,.T.)
Return Self

/*/{Protheus.doc} lock
Efetua tentativa de lock para o processo com o controle cRotina
Retorna conteúdo lógico indicando se conseguiu fazer o lock
@type  Method
@author  brunno.costa
@since   14/08/2020
@version P12.1.27
@param 01 - cProcesso   , caracter , informe um código de controle para o processo de trava
@param 02 - cRotina     , caracter , informe a rotina ou processo chamador
@param 03 - cIDRotina   , caracter , identificador único de execucao das rotinas do processo - MRP -> ticket
@param 04 - lExclusivo  , numero   , indica se inibe a execução paralela com outras rotinas do processo
@param 05 - aExcecao    , array    , quando lExclusivo é falso: indica o nome do fonte de exceção para exclusividade, ou seja, aquele que impede o lock da rotina atual
                                     quando lExclusivo é true : indica o nome do fonte de exceção, ou seja, aquele que é permitido para o lock da rotina atual
@param 06 - nEspera     , numerico , indica o comportamento relacionado a espera e falha na tentativa de reserva:
                                     0 - Não aguarda lock e não exibe help
								     1 - Não aguarda lock e exibe Help de Falha
								     2 - Aguarda para fazer lock e não exibe tela de aguarde;
								     3 - Aguarda para fazer lock e exibe tela de aguarde;
								     4 - Aguarda para fazer lock e não exibe tela de aguarde - nEsperaMax fixo 10 segundos para atualização de nomenclatura na MsgRun ;
@param 07 - cError      , caracter, retorna por referencia mensagem de erro
@param 08 - nEsperaMax  , numerico, tempo maximo para espera - UNIDADE SEGUNDO
@param 09 - nSleepDef   , numerico, tempo default de sleep de espera - UNIDADE MILÉSSIMO DE SEGUNDO
@return lLock, logico, indica se conseguiu realizar o lock no processo
/*/
METHOD lock(cProcesso, cRotina, cIDRotina, lExclusivo, aExcecao, nEspera, cError, nEsperaMax, nSleepDef) CLASS PCPLockControl
	Local bBlock
	Local cFileName
	Local cJson     := ""
	Local lEspera
	Local lEspera10s
	Local lHelp
	Local lLock     := .F.
	Local lProcess
	Local lReturn   := .T.
	Local lWhile    := .T.
	Local nExcecoesOk := 0
	Local nInd
	Local nPos
	Local oJson
	Local nTempoIni    := Seconds()
	Local nTentSemaf   := 0
	Local nTentMaxSf   := 300

	Default cProcesso  := "MRP_MEMORIA"
	Default cRotina    := ProcName(1)
	Default cIDRotina  := ""
	Default lExclusivo := .T.
	Default aExcecao   := {}
	Default nEspera    := 0
	Default cError     := ""
	Default nEsperaMax := DEFAULT_NESPERAMAX   //300 segundos = 5 Minutos
	Default nSleepDef  := DEFAULT_NSLEEP_LOCK  //500 Milisegundos

	If Self:lHabilitado
		cFileName  := Lower(Self:cPrefLock + AllTrim(cProcesso))
		lHelp      := nEspera == 1
		lEspera    := nEspera == 2 .OR. nEspera == 3 .OR. nEspera == 4
		lEspera10s := nEspera == 4
		lProcess   := nEspera == 3
		cRotina    := Upper(ALlTrim(cRotina))
		cIDRotina  := Upper(cIDRotina)

		While lWhile
			lReturn := .T.

			//CONSEGUIU BLOQUEAR SEMAFORO - LockByName
			If LockByName(cFileName, .F., .F., .T.)
				oJson := JsonObject():New()
				lLock := .T.
				cJson := ""

				//Verifica existencia de arquivo e retorna conteudo
				If File(cFileName + ".tmp", 0 ,.T.)
					cJson := MemoRead( cFileName + ".tmp")
				EndIf

				//Execucao Exclusiva - Arquivo inexistente ou vazio
				If Empty(cJson)
					lWhile  := .F.
					lReturn := .T.
					oJson["aRotinas"] := {}
					aAdd(oJson["aRotinas"], {cRotina, cIDRotina, AllTrim(UsrRetName(RetCodUsr())) , " (" + GetServerIP() + ":" + GetPvProfString( "tcp", "port", "1234", "appserver.ini") + "-Thread:" + cValToChar(ThreadID()) + ")", DtoS(Date()), Time(), FunName()})

				//Analisa conteudo do arquivo de controle de lock
				Else
					oJson:fromJson(cJson)
					oJson := Self:recovery(oJson)
					If oJson["aRotinas"] == Nil
						oJson["aRotinas"] := {}
						nTotal            := 0
					Else
						nTotal := Len(oJson["aRotinas"])
					EndIf
					nPos := aScan(oJson["aRotinas"], {|x| x[AROTINAS_ROTINA] == cRotina} )

					//Avalia Excecao de Exclusividade
					nExcecoesOk := Iif(nPos == 0, 0, 1)
					If lExclusivo .AND. nTotal >= 1 .AND. !Empty(aExcecao)
						nTotal    := Len(aExcecao)
						For nInd := 1 to nTotal
							If aScan(oJson["aRotinas"], {|x| x[AROTINAS_ROTINA] == aExcecao[nInd]} ) != 0
								nExcecoesOk++
							EndIf
						Next
						nTotal := Len(oJson["aRotinas"])
					EndIf

					//Rotina Exclusiva - Ocasião não exclusiva
					If lExclusivo .AND. ((nTotal - nExcecoesOk) > 1;
					   .OR. ((nTotal - nExcecoesOk) == 1 .AND. nPos == 0))
						If lHelp
							lWhile  := .F.
							lReturn := .F.
							cError  := Self:showHelp(lHelp, oJson, cFileName, cProcesso)
						ElseIf lProcess
							bBlock := {|| lReturn := Self:Lock(cProcesso, cRotina, cIDRotina, lExclusivo, aExcecao, 4 /*nEspera*/, @cError, nEsperaMax, nSleepDef)}
							Self:showMsgRun(cProcesso, bBlock, oJson["aRotinas"][1][AROTINAS_USUARIO], oJson["aRotinas"][1][AROTINAS_ROTINA])
							lWhile := .F.
							If lReturn
								//Verifica existencia de arquivo e retorna conteudo
								If File(cFileName + ".tmp", 0 ,.T.)
									cJson := MemoRead( cFileName + ".tmp")
								Else
									cJson := ""
								EndIf
								oJson:fromJson(cJson)
							Else
								cError := Self:showHelp(.F., oJson, cFileName, cProcesso)
							EndIf

						ElseIf lEspera
							lReturn := .F.
						Else
							lWhile  := .F.
							lReturn := .F.
						EndIf

					//Execução com exclusividade
					ElseIf Empty(aExcecao);
					       .OR. nTotal == 0;
					       .OR. (lExclusivo .AND. !Empty(aExcecao) .AND. (nTotal - nExcecoesOk) == 0)

						lWhile  := .F.
						lReturn := .T.

						nPos := aScan(oJson["aRotinas"], {|x| x[AROTINAS_ROTINA] == cRotina} )
						If nPos == 0
							aAdd(oJson["aRotinas"], {cRotina, cIDRotina, AllTrim(UsrRetName(RetCodUsr())) , " (" + GetServerIP() + ":" + GetPvProfString( "tcp", "port", "1234", "appserver.ini") + "-Thread:" + cValToChar(ThreadID()) + ")", DtoS(Date()), Time(), FunName()})

						//Mesma Rotina e cIDRotina - Bloqueia
						ElseIf oJson["aRotinas"][nPos][AROTINAS_IDROTINA] = cIDRotina
							lReturn := .F.
							cError := Self:showHelp(lHelp, oJson, cFileName, cProcesso)

						//Outro cIDRotina
						Else
							aAdd(oJson["aRotinas"], {cRotina, cIDRotina, AllTrim(UsrRetName(RetCodUsr())) , " (" + GetServerIP() + ":" + GetPvProfString( "tcp", "port", "1234", "appserver.ini") + "-Thread:" + cValToChar(ThreadID()) + ")", DtoS(Date()), Time(), FunName()})

						EndIf

					//Rotina não exclusiva, analise regra de excecao de exclusividade
					ElseIf !lExclusivo
						For nInd := 1 to nTotal
							If aScan(aExcecao, {|x| AllTrim(x) == AllTrim(oJson["aRotinas"][nInd][AROTINAS_ROTINA]) } ) > 0
								UnLockByName(cFileName, .F., .F., .T.) //Libera SEMAFORO
								lLock   := .F.
								If lHelp
									cError := Self:showHelp(lHelp, oJson, cFileName, cProcesso)
									lWhile  := .F.

								ElseIf lProcess
									bBlock := {|| lReturn := Self:Lock(cProcesso, cRotina, cIDRotina, lExclusivo, aExcecao, 4 /*nEspera*/, @cError, nEsperaMax, nSleepDef)}
									Self:showMsgRun(cProcesso, bBlock, oJson["aRotinas"][nInd][AROTINAS_USUARIO], oJson["aRotinas"][nInd][AROTINAS_ROTINA])
									lWhile := .F.
									If lReturn
										//Verifica existencia de arquivo e retorna conteudo
										If File(cFileName + ".tmp", 0 ,.T.)
											cJson := MemoRead( cFileName + ".tmp")
										Else
											cJson := ""
										EndIf
										oJson:fromJson(cJson)
									Else
										cError := Self:showHelp(.F., oJson, cFileName, cProcesso)
									EndIf

								ElseIf lEspera
									lReturn := .F.

								Else
									lReturn := .F.
									lWhile  := .F.
								EndIf
								Exit
							Else
								lWhile  := .F.
							EndIf
						Next

					EndIf
				EndIf

				//Libera SEMAFORO
				If lLock
					If lReturn .AND. !lWhile
						cJson := oJson:toJson()
						Self:memoWrite( cFileName + ".tmp", cJson )
					EndIf
					UnLockByName(cFileName, .F., .F., .T.)
					lLock := .F.
				EndIf

			//NAO CONSEGUIU BLOQUEAR SEMAFORO - LockByName
			Else
				nTentSemaf++

				//Tenta realizar LockByName nTentMaxSf vezes antes de acusar falha
				If nTentSemaf < nTentMaxSf
					Sleep(50)

				Else
					cJson := MemoRead( cFileName + ".tmp")
					If !Empty(cJson)
						oJson := JsonObject():New()
						oJson:fromJson(cJson)
						oJson := Self:recovery(oJson)
					EndIf
					cError := Self:showHelp(lHelp, oJson, cFileName, cProcesso)
					lReturn := .F.
					lWhile  := .F.

				EndIf

			EndIf

			//Aguarda sem mensagem de progresso por nEsperaMax segundos
			If lEspera .AND. !lReturn
				If (Seconds() - nTempoIni) >= nEsperaMax
					lWhile  := .F.
					lReturn := .F.
				ElseIf lEspera10s .AND. (Seconds() - nTempoIni) >= 10
					lWhile  := .F.
					lReturn := .F.
				Else
					lWhile  := .T.
					Sleep(nSleepDef)
				EndIf
				If !lWhile .AND. !lReturn .AND. !lEspera10s
					cError := Self:showHelp(GetRemoteType() >= 0, oJson, cFileName, cProcesso)
				EndIf
			EndIf

			FreeObj(oJson)
			oJson := Nil
		EndDo
	EndIf

Return lReturn

/*/{Protheus.doc} unlock
Efetua tentativa de unlock para o processo com o controle cRotina.
@type  Method
@author  brunno.costa
@since   14/08/2020
@version P12.1.27
@param 01 - cProcesso   , caracter , informe um código de controle para o processo de trava
@param 02 - cRotina     , caracter , informe a rotina ou processo chamador
@param 03 - cIDRotina   , caracter , identificador único de execucao das rotinas do processo - MRP -> ticket
@param 04 - nSleepDef   , numerico, tempo default de sleep de espera - UNIDADE MILÉSSIMO DE SEGUNDO
/*/
METHOD unlock(cProcesso, cRotina, cIDRotina, nSleepDef) CLASS PCPLockControl
	Local cFileName
	Local lWhile     := .T.
	Local nPos       := 0
	Local oJson

	Default cIDRotina := ""
	Default nSleepDef := DEFAULT_NSLEEP_UNLOCK

	If Self:lHabilitado
		cFileName := Lower(Self:cPrefLock + AllTrim(cProcesso))
		cRotina   := Upper(ALlTrim(cRotina))
		cIDRotina := Upper(cIDRotina)

		While lWhile
			oJson := JsonObject():New()
			If LockByName(cFileName, .F., .F., .T.)
				lWhile := .F.
				If File(cFileName + ".tmp", 0 ,.T.)
					cJson := MemoRead( cFileName + ".tmp")

					If Empty(cJson)
						Self:memoErase(cFileName + ".tmp")

					Else
						oJson:fromJson(cJson)
						oJson := Self:recovery(oJson)

						While nPos := aScan(oJson["aRotinas"], {|x| x[AROTINAS_ROTINA] == cRotina .AND. (x[AROTINAS_IDROTINA] == cIDRotina .OR. cIDRotina == "*" .OR. Empty(x[AROTINAS_IDROTINA]))} )
							aDel(oJson["aRotinas"], nPos)
							aSize(oJson["aRotinas"], Len(oJson["aRotinas"]) - 1)
						EndDo

						If Len(oJson["aRotinas"]) == 0
							Self:memoErase(cFileName + ".tmp")
						Else
							cJson := oJson:toJson()
							Self:memoWrite( cFileName + ".tmp", cJson )
						EndIf

					EndIf

				Endif
				UnLockByName(cFileName, .F., .F., .T.)

			Else
				Sleep(nSleepDef)

			EndIf

			FreeObj(oJson)
			oJson := Nil
		EndDo
	EndIf

Return

/*/{Protheus.doc} recovery
Elimina bloqueios existentes a mais de 6 horas
@type  Method
@author  brunno.costa
@since   14/08/2020
@version P12.1.27
@param 01 - oJson, objeto, objeto json para analise dos locks a recuperar
@return oJson, objeto Json com os locks com mais de 6 horas removidos
/*/
METHOD recovery(oJson) CLASS PCPLockControl
	Local cTime := Time()
	//Local cUser := AllTrim(UsrRetName(RetCodUsr()))
	Local nPos
	Local nTempo := 60*6 //6 horas: minutos*horas
	While nPos := aScan(oJson["aRotinas"], {|x| (Hrs2Min(ElapTime(x[AROTINAS_HORA], cTime)) > nTempo)} ) // .AND. x[AROTINAS_USUARIO] == cUser
		aDel(oJson["aRotinas"], nPos)
		aSize(oJson["aRotinas"], Len(oJson["aRotinas"]) - 1)
	EndDo
Return oJson

/*/{Protheus.doc} check
Checa a existencia de lock no cProcesso para a cRotina e cIDRotina
@type  Method
@author  brunno.costa
@since   14/08/2020
@version P12.1.27
@param 01 - cProcesso   , caracter , informe um código de controle para o processo de trava
@param 02 - cRotina     , caracter , informe a rotina ou processo chamador
@param 03 - cIDRotina   , caracter , identificador único de execucao das rotinas do processo - MRP -> ticket
@param 04 - lExclusivo  , numero   , indica se inibe a execução paralela com outras rotinas do processo
@param 05 - cProblema   , caracter , retorna por referencia mensagem cProblema
@PARAM 06 - cSolucao    , caracter , retorna por referencia mensagem cSolucao
@return lLock, logico, indica se existe o lock no cProcesso para cRotina e cIDRotina
/*/
METHOD check(cProcesso, cRotina, cIDRotina, lExclusivo, cProblema, cSolucao) CLASS PCPLockControl

	Local cFileName
	Local lReturn    := .F.
	Local nPos       := 0
	Local nTotal
	Local oJson      := JsonObject():New()

	Default cIDRotina  := ""
	Default lExclusivo := .F.

	If Self:lHabilitado
		cFileName := Lower(Self:cPrefLock + AllTrim(cProcesso))
		cRotina   := Upper(ALlTrim(cRotina))
		cIDRotina := Upper(cIDRotina)

		If File(cFileName + ".tmp", 0 ,.T.)
			cJson := MemoRead( cFileName + ".tmp")

			If !Empty(cJson)
				oJson:fromJson(cJson)
				oJson := Self:recovery(oJson)

				nPos := aScan(oJson["aRotinas"], {|x| x[AROTINAS_ROTINA] == cRotina .AND. (x[AROTINAS_IDROTINA] == cIDRotina .OR. cIDRotina == "*") .OR.;
				                                                    ("*" == cRotina .AND.  x[AROTINAS_IDROTINA] == cIDRotina) } )
				If nPos > 0
					If lExclusivo
						lReturn := Len(oJson["aRotinas"]) == 1
					Else
						lReturn := .T.
					EndIf
				EndIf

				If !lReturn
					nTotal := Len(oJson["aRotinas"])
					cProblema := STR0001+Self:getProcessName(cProcesso)+STR0002+Self:blocks(oJson, .F.) + "." //"O processo '" + "' encontra-se bloqueado nas rotinas: "
					cSolucao  := STR0003+cFileName+".tmp'"
				EndIf

			EndIf

		Endif
	Else
		lReturn := .T.
	EndIf

Return lReturn

/*/{Protheus.doc} waitCheck
Checa a existencia de lock no cProcesso para a cRotina e cIDRotina - Até conseguir ou expirar DEFAULT_NESPERAMAX
@type  Method
@author  brunno.costa
@since   14/08/2020
@version P12.1.27
@param 01 - cProcesso   , caracter , informe um código de controle para o processo de trava
@param 02 - aRotina     , array    , informe a rotina ou processo chamador
@param 03 - cIDRotina   , caracter , identificador único de execucao das rotinas do processo - MRP -> ticket
@param 04 - lExclusivo  , numero   , indica se inibe a execução paralela com outras rotinas do processo
@param 05 - cProblema   , caracter , retorna por referencia mensagem cProblema
@PARAM 06 - cSolucao    , caracter , retorna por referencia mensagem cSolucao
@return lLock, logico, indica se existe o lock no cProcesso para cRotina e cIDRotina
/*/
METHOD waitCheck(cProcesso, aRotina, cIDRotina, lExclusivo, cProblema, cSolucao) CLASS PCPLockControl

	Local cRotina
	Local nInd
	Local lLock   := .F.
	Local nSecIni := Seconds()
	Local nTotal  := Len(aRotina)

	While !lLock
		Sleep(100)
		For nInd := 1 to nTotal
			cRotina := aRotina[nInd]
			lLock := Self:check(cProcesso, cRotina, cIDRotina, lExclusivo, @cProblema, @cSolucao)
			If lLock
				Exit
			EndIf
		Next
		If (Seconds() - nSecIni) > DEFAULT_NESPERAMAX
			Exit
		EndIf
	EndDo

Return lLock

/*/{Protheus.doc} transfer
Transfere propriedade do lock atual de cProcesso da rotina cAnterior para cPosterior
@type  Method
@author  brunno.costa
@since   14/08/2020
@version P12.1.27
@param 01 - cProcesso , caracter, codigo do processo relacionado
@param 02 - cAnterior , caracter, cRotina anterior
@param 03 - cPosterior, caracter, cRotina posterior
@param 04 - cIDRotina , caracter, codigo identificador de cRotina anterior
@param 05 - nSleepDef , numerico, tempo default de sleep de espera - UNIDADE MILÉSSIMO DE SEGUNDO
/*/
METHOD transfer(cProcesso, cAnterior, cPosterior, cIDRotina, nSleepDef) CLASS PCPLockControl

	Local cFileName
	Local lWhile     := .T.
	Local nPos       := 0
	Local oJson      := JsonObject():New()

	Default cIDRotina  := ""
	Default nSleepDef := DEFAULT_NSLEEP_TRANSFER

	cFileName  := Lower(Self:cPrefLock + AllTrim(cProcesso))
	cAnterio   := Upper(ALlTrim(cAnterior))
	cPosterior := Upper(ALlTrim(cPosterior))
	cIDRotina  := Upper(cIDRotina)

	While lWhile
		If LockByName(cFileName, .F., .F., .T.)
			lWhile := .F.
			If File(cFileName + ".tmp", 0 ,.T.)
				cJson := MemoRead( cFileName + ".tmp")

				If Empty(cJson)
					oJson["aRotinas"] := {}
					aAdd(oJson["aRotinas"], {cPosterior, cIDRotina, AllTrim(UsrRetName(RetCodUsr())), " ThreadID(" + cValToChar(ThreadID()) + ") (" + GetServerIP() + ":" + GetPvProfString( "tcp", "port", "1234", "appserver.ini") + ")", DtoS(Date()), Time(), FunName()})
					cJson := oJson:toJson()
					Self:memoWrite( cFileName + ".tmp", cJson )

				Else
					oJson:fromJson(cJson)
					oJson := Self:recovery(oJson)
					nPos := aScan(oJson["aRotinas"], {|x| x[AROTINAS_ROTINA] == cAnterior .AND.  x[AROTINAS_IDROTINA] == cIDRotina} )
					If nPos > 0
						oJson["aRotinas"][nPos][AROTINAS_ROTINA]  := cPosterior
						oJson["aRotinas"][nPos][AROTINAS_FUNNAME] := FunName()
						cJson := oJson:toJson()
						Self:memoWrite( cFileName + ".tmp", cJson )
					EndIf

				EndIf

			Endif
			UnLockByName(cFileName, .F., .F., .T.)

		Else
			Sleep(nSleepDef)

		EndIf
	EndDo

Return

/*/{Protheus.doc} getProcessName
Retorna o nome correspondente ao codigo de processo
@type  Method
@author  brunno.costa
@since   14/08/2020
@version P12.1.27
@return cProcName, caracter, nome do processo relacionado
/*/
METHOD getProcessName(cProcesso) CLASS PCPLockControl
	Local cProcName := cProcesso

	If cProcesso == "MRP_MEMORIA"
		cProcName := STR0017 //"MRP Memória"
	EndIf

Return cProcName

/*/{Protheus.doc} getName
Retorna o nome da rotina
@type  Method
@author  brunno.costa
@since   14/08/2020
@version P12.1.27
@PARAM 01 - cCodRotina, caracter, codigo da rotina relacionado
@return cRotina, caracter, nome da rotina relacionada
/*/
METHOD getName(cCodRotina) CLASS PCPLockControl
	Local cRotina := cCodRotina

	If cRotina == "PCPA712"
		cRotina := STR0008 //"MRP Memória"
	ElseIf cRotina $ "|PCPA144|PCPA145|"
		cRotina := STR0009 //"Geração Documentos do MRP"
	ElseIf cRotina == "PCPA141"
		cRotina := STR0010 //"Schedule do MRP"
	ElseIf cRotina == "PCPA145INT"
		cRotina := STR0011 //"Integrações de OP"
	ElseIf cRotina == "PCPA146"
		cRotina := STR0012 //"Exclusão de Documentos Previstos"
	ElseIf cRotina == "PCPA140"
		cRotina := STR0013 //"Sincronização do MRP"
	ElseIf cRotina == "PCPA151"
		cRotina := STR0018 //"Sugestão de Lote e Endereço nos Empenhos"
	EndIf

	If cRotina != cCodRotina
		cRotina += "-" + cCodRotina
	EndIf

Return cRotina

/*/{Protheus.doc} memoWrite
Efetua a gravação da string no arquivo memo de controle e trata exibição para ocorrência de erro
@type  Method
@author  brunno.costa
@since   14/08/2020
@version P12.1.27
@param 01 - cFileName, caracter, nome do arquivo de controle para gravacao
@param 02 - cConteudo, caracter, string para gravacao no arquivo
@return Ret, logico, indica se conseguiu realizar a gravação
/*/
METHOD memoWrite(cFileName, cConteudo) CLASS PCPLockControl
	Local lRet := MemoWrite( cFileName, cConteudo )
	If !lRet
		//"Falha na escrita do arquivo '\RootPath\Semaforo\"
		//"Contate o departamento de TI e verifique as configurações de acesso do AppServer ao diretório '\RootPath\SEMAFORO\.'"
		Help(,,"PCPLCl"+cValToChar(ProcLine())+ProcName(2)+"l"+cValToChar(ProcLine(2)),,STR0014+cFileName+"': "+Str(fError())+" ("+ProcName(1)+" - "+cValToChar(ProcLine(1))+")",1,0,,,,,,{STR0015})
	EndIf
Return lRet

/*/{Protheus.doc} memoErase
Efetua eliminacao do arquivo de controle e trata exibição para ocorrência de erro
@type  Method
@author  brunno.costa
@since   14/08/2020
@version P12.1.27
@param 01 - cFileName, caracter, nome do arquivo de controle para gravacao
@return Ret, logico, indica se conseguiu realizar a eliminação
/*/
METHOD memoErase(cFileName) CLASS PCPLockControl
	Local lRet := fErase(cFileName) != -1
	If !lRet
		//"Falha na exclusao do arquivo '"
		//"Contate o departamento de TI e verifique as configurações de acesso do AppServer ao diretório '\RootPath\SEMAFORO\.'"
		Help(,,"PCPLCl"+cValToChar(ProcLine())+ProcName(2)+"l"+cValToChar(ProcLine(2)),,STR0016+cFileName+"': "+Str(fError())+" ("+ProcName(1)+" - "+cValToChar(ProcLine(1))+")",1,0,,,,,,{STR0015})
	Endif
Return lRet

/*/{Protheus.doc} blocks
Retorna string com os bloqueios relacionados ao processo
@type  Method
@author  brunno.costa
@since   14/08/2020
@version P12.1.27
@param 01 - oJson    , JsonObject, objeto json da operacao
@param 02 - lResumido, retorna bloqueios sem o nome da rotina (.T.) ou com o nome da rotina (.F.)
@return cBloqueios, caracter, string com os bloqueios relacionados ao processo
/*/
METHOD blocks(oJson, lResumido) CLASS PCPLockControl

	Local cBloqueios   := ""
	Local cComplemento := ""
	Local nInd
	Local nTotal     := Len(oJson["aRotinas"])

	Default lResumido := .T.

	For nInd := 1 to nTotal
		cComplemento := ""

		If !Empty(cBloqueios)
			cBloqueios += ", "
		EndIf

		If lResumido
			cBloqueios += oJson["aRotinas"][nInd][AROTINAS_ROTINA]
		Else
			cBloqueios += Self:getName(oJson["aRotinas"][nInd][AROTINAS_ROTINA])
		EndIf

		If !Empty(oJson["aRotinas"][nInd][AROTINAS_IDROTINA])
			cComplemento := oJson["aRotinas"][nInd][AROTINAS_IDROTINA]
		EndIf

		If !Empty(oJson["aRotinas"][nInd][AROTINAS_USUARIO])
			If Empty(cComplemento)
				cComplemento := oJson["aRotinas"][nInd][AROTINAS_USUARIO]
			Else
				cComplemento += "-" + oJson["aRotinas"][nInd][AROTINAS_USUARIO]
			EndIf
		EndIf

		cBloqueios += "(" + cComplemento + ")"
	Next


Return cBloqueios

/*/{Protheus.doc} showMsgRun
Abre tela FwMsgRun Default
@type  Method
@author  brunno.costa
@since   14/08/2020
@version P12.1.27
@param 01 - cProcesso, caracter, codigo do processo relacionado
@param 02 - bBlock   , bloco   , bloco de código para execução
@param 03 - cUsuario , caracter, usuario relacionado ao bloqueio
@param 04 - cRotina  , caracter, codigo da rotina relacionada
/*/
METHOD showMsgRun(cProcesso, bBlock, cUsuario, cRotina) CLASS PCPLockControl
	Default bBlock := {|| }
	If Empty(cUsuario)
		//"Aguardando liberação do '" + "' em uso na rotina:"
		FWMsgRun(, bBlock , STR0004+Self:getProcessName(cProcesso)+STR0007, "'"+Self:getName(cRotina) + "'")
	Else
		//"Aguardando liberação do '" + "' por '" + " na rotina '"
		FWMsgRun(, bBlock , STR0004+Self:getProcessName(cProcesso)+STR0005+cUsuario+"':", STR0006+Self:getName(cRotina) + "'")
	EndIf
Return

/*/{Protheus.doc} showHelp
Exibe Help em Tela ou no Console
@type  Method
@author  brunno.costa
@since   14/08/2020
@version P12.1.27
@param 01 - lTela    , logico    , indica se deve exibir o help em tela
@param 02 - oJson    , JsonObject, objeto json da operacao
@param 03 - cFileName, caracter  , nome do arquivo de lock
@param 04 - cProcesso, caracter  , codigo de identificacao do processo
@return cError, caracter, retorna mensagem de erro
/*/
METHOD showHelp(lTela, oJson, cFileName, cProcesso) CLASS PCPLockControl

	Local cBloqueios := Self:blocks(oJson, .F.)

	//"O processo '" + "' encontra-se bloqueado nas rotinas: "
	//"Tente novamente mais tarde ou contate o departamento de TI e verifique as configurações de acesso do AppServer ao diretório '\RootPath\SEMAFORO\' e arquivo '"
	cError := STR0001+Self:getProcessName(cProcesso)+STR0002+cBloqueios+"."
	cError += STR0003+cFileName+".tmp'"

	If lTela
		Help(,,"PCPLCl"+cValToChar(ProcLine())+ProcName(2)+"l"+cValToChar(ProcLine(2)),,STR0001+Self:getProcessName(cProcesso)+STR0002+cBloqueios+".",1,0,,,,,,{STR0003 + cFileName+".tmp'"})
	EndIf

	LogMsg('PCPLockControl', 0, 0, 1, '', '', ProcName(2) + cValToChar(ProcLine(2)) + ": " + cError)

Return cError

/*/{Protheus.doc} PCPLock
Faz o bloqueio de execução para uma determinada rotina
@type Function
@author marcelo.neumann
@since 04/06/2021
@version P12
@param 01 cRotina , caracter, rotina que está realizando o lock
@param 02 lAguarda, lógico  , indica de deve aguardar caso não consiga realizar o lock
@return   lReturn , lógico  , indica se conseguiu realizar o lock
/*/
Function PCPLock(cRotina, lAguarda)
	Local aRotCheck  := {}
	Local lReturn    := .T.
	Local nIndex     := 0
	Local nTotal     := 0
	Default lAguarda := .F.

	cRotina := AllTrim(cRotina)

	//Rotinas que concorrem com a rotina que fará o lock
	If cRotina == "PCPA145"
		aAdd(aRotCheck, "PCPA146")

	ElseIf cRotina == "PCPA146"
		aAdd(aRotCheck, "PCPA145")
		aAdd(aRotCheck, "PCPA145INT")
	EndIf

	//Verifica as rotinas concorrentes, verificando se estão em execução
	nTotal := Len(aRotCheck)
	For nIndex := 1 To nTotal
		//Tenta fazer o lock das rotinas concorrentes
		If !LockByName(PREF_LOCK + aRotCheck[nIndex], .T. /*lEmpresa*/, .T. /*lFilial*/)
			If lAguarda
				LogMsg("PCPLock", 0, 0, 1, "", "", "PCPLock - (" + cRotina + ") " + STR0019 + " " + aRotCheck[nIndex]) //Aguardando o desbloqueio da rotina
				Sleep(5000)
				nIndex--
			Else
				lReturn := .F.
				Exit
			EndIf
		EndIf
	Next nIndex

	//Bloqueia a rotina
	While lReturn
		lReturn := LockByName(PREF_LOCK + cRotina, .T. /*lEmpresa*/, .T. /*lFilial*/)
		If !lReturn .And. lAguarda
			LogMsg("PCPLock", 0, 0, 1, "", "", "PCPLock - (" + cRotina + ") " + STR0019)
			Sleep(5000)
			lReturn := .T.
		Else
			Exit	
		EndIf	
	EndDo	

	//Desbloqueia as rotinas concorrentes que foram reservadas acima
	For nIndex := 1 To nTotal
		PCPUnlock(aRotCheck[nIndex])
	Next nIndex

	aSize(aRotCheck, 0)

Return lReturn

/*/{Protheus.doc} PCPUnlock
Faz o desbloqueio de uma determinada rotina
@type Function
@author marcelo.neumann
@since 04/06/2021
@version P12
@param cRotina, caracter, rotina que está sendo desbloqueada
@return Nil
/*/
Function PCPUnlock(cRotina)

	UnLockByName(PREF_LOCK + AllTrim(cRotina), .T. /*lEmpresa*/, .T. /*lFilial*/)

Return 

/*/{Protheus.doc} semaforo
Controle de semáforos
@type Static Method
@author Marcelo Neumann
@since 02/06/2023
@version P12
@param 01 cOpcao    , caracter, Operação do semáforo (LOCK ou UNLOCK)
@param 02 cChave    , caracter, Nome do semáforo a ser controlado
@param 03 nTentativa, numérico, Número máximo de tentativas de realizar o lock
@param 04 lEmpresa  , lógico  , Indica se o controle será feito por empresa
@param 05 lFilial   , lógico  , Indica se o controle será feito por filial
@return   lRet      , lógico  , Indica o sucesso na obtenção do semáforo
/*/
METHOD semaforo(cOpcao, cChave, nTentativa, lEmpresa, lFilial) CLASS PCPLockControl
	Local lRet := .T.
	Local nTry := 0
	Default nTentativa := 1000
	Default lEmpresa   := .T.
	Default lFilial    := .T.

	If cOpcao == 'LOCK'
		While !LockByName(cChave, lEmpresa, lFilial)
			nTry++
			If nTry > nTentativa
				//Não conseguiu o lock, retorna false.
				lRet := .F.
				Exit
			EndIf
			Sleep(200)
		End
	Else
		UnLockByName(cChave, lEmpresa, lFilial)
	EndIf

Return lRet
