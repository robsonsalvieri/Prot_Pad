#INCLUDE 'protheus.ch'
#INCLUDE 'PCPIPC.ch'

/*/{Protheus.doc} PCPIPCStart
Inicializa uma fila de JOBS
@author    brunno.costa
@since     14/02/2019
@version   1
@param 01 - cSemaforo, caracter, nome do semaforo que sera utilizado para a fila de Threads
@param 02 - nThreads , numero  , numero de Threads que serao abertas pela funcao
@param 03 - nAbertas , numero  , utilizacao interna em recursao, indica quantidade de threads ja abertas
@param 04 - xEmpAnt  , caracter, indica o codigo da empresa para abertura de ambiente
@param 05 - xFilAnt  , caracter, indica o codigo da filial para abertura de ambiente
@param 06 - cErrorUID, caracter, codigo identificador da secao global de controle de erros
@param 07 - cBlocoRec , caracter, string com o código para adicionar no bloco de recuperação
/*/
Function PCPIPCStart(cSemaforo, nThreads, nAbertas, xEmpAnt, xFilAnt, cErrorUID, cBlocoRec)
	Local cRecover   := ""
	Local nInd       := 1
	Local nResto     := nThreads
	Local oPCPError  := Nil
	Local cUIDGlobal := ""
	Default cSemaforo := "PCPIPC"
	Default nAbertas  := 0
	Default cErrorUID := "MULTITHREAD_PCPIPC"

	cUIDGlobal := "SEMAFORO_" + cSemaforo

	VarSetUID(cUIDGlobal, .T.)
	VarSetX(cUIDGlobal, "lActivated" , .T.)
	If nAbertas < 1
		VarSetX(cUIDGlobal, "nIniciando"  , nThreads)
		VarSetX(cUIDGlobal, "nThreads"    , nThreads)
		VarSetX(cUIDGlobal, "THR_COM_ERRO", 0)
		VarSetA(cUIDGlobal, "thread_ids"  , {})
	EndIf
	//Bloco de recuperação irá incrementar contador de threads com erro de execução.
	//Este contador será utilizado no momento de fechar as demais threads, para considerar
	//o número correto de threads abertas em utilização.
	If !Empty(cBlocoRec)
		cRecover := "{|| VarSetX('SEMAFORO_" + cSemaforo + "', 'THR_COM_ERRO', 0, 1, 1), " + cBlocoRec + "}"
	Else
		cRecover := "VarSetX('SEMAFORO_" + cSemaforo + "', 'THR_COM_ERRO', 0, 1, 1)"
	EndIf

	oPCPError := PCPMultiThreadError():New(cErrorUID, .F.)

	If nAbertas < 1
		nResto   := nThreads - 1
		nThreads := 1
	EndIf

	For nInd := 1 to nThreads
		oPCPError:startJob("PCPIPCJOB", GetEnvServer(), .F., xEmpAnt, xFilAnt, cSemaforo, cErrorUID,,,,,,,,,, cRecover)
		Sleep(200)
	Next

	If nAbertas == 0 .and. nResto > 0
		oPCPError:startJob("PCPIPCStart", GetEnvServer(), .T., , , cSemaforo, nResto, nAbertas + 1, xEmpAnt, xFilAnt, cErrorUID, cBlocoRec)
	EndIf

Return

/*/{Protheus.doc} PCPIPCFinish
Encerra as threads de determinada fila
@author    brunno.costa
@since     14/02/2019
@version   1
@param 01 - cSemaforo, caracter, nome do semaforo que sera utilizado para a fila de Threads
@param 02 - nMinCanc , numero  , número mínimo de tentativa consecutivas de fechamento da Thread
@param 03 - nQtdThr  , numero  , quantidade de threads a ser encerrada. Se não passar, será assumido o mesmo valor das tentativas
/*/
Function PCPIPCFinish(cSemaforo, nMinCanc, nQtdThr)
	Local nTentativas := 0
	Local nThreads    := 0
	Local nErros      := 0
	Local lRet        := .T.

	Default cSemaforo := "PCPIPCJOB"
	Default nMinCanc  := 1
	Default nQtdThr   := nMinCanc

	//Verifica se as threads ainda estão sendo iniciadas, e aguarda o término da inicialização
	PCPIPCWIni(cSemaforo, 1200)

	VarSetX( "SEMAFORO_" + cSemaforo, "lFinishing" , .T. )
	VarBeginT("SEMAFORO_" + cSemaforo, "lFinishing")
	lRet := VarGetX("SEMAFORO_" + cSemaforo, "nThreads", @nThreads)
	If nThreads > 0
		VarGetX("SEMAFORO_" + cSemaforo, "THR_COM_ERRO", @nErros)
		While nThreads - nErros > 0 .AND. (IPCCount(cSemaforo) > 0 .OR. nTentativas < nMinCanc)
			Sleep(500)
			If IPCCount(cSemaforo) > 0
				PCPIPCGO(cSemaforo, .T.)

				//Decrementa a quantidade de threads a serem encerradas
				nQtdThr--

				//Se ja fechou todas as threads, sai do loop
				If nQtdThr == 0
					Exit
				EndIf
			Else
				nTentativas++
				Sleep(1000)
				lRet := VarGetX("SEMAFORO_" + cSemaforo, "nThreads", @nThreads)
				LogMsg("PCPIPCJOB", 0, 0, 1, '', '', "************************************* PCPIPCFinish - " + cSemaforo + ' nThreads: ' + cValToChar(nThreads) + ' nMinCanc: ' + CValToChar(nMinCanc) + ' nTentativas: ' +cValtoChar(nTentativas) + " *************************************") // falha
			EndIf
		EndDo
	EndIf
	VarSetX( "SEMAFORO_" + cSemaforo, "lFinishing" , .F. )
	VarEndT("SEMAFORO_" + cSemaforo, "lFinishing")
	VarSetX( "SEMAFORO_" + cSemaforo, "lActivated" , .F. )

	If !VarClean("SEMAFORO_" + cSemaforo)
		LogMsg("PCPIPCJOB", 0, 0, 1, '', '', "************************************* " + STR0004 + " PCPIPCFinish VarClean(SEMAFORO_ + cSemaforo): " + AllTrim(cSemaforo) + " *************************************") // falha
	EndIf
Return

/*/{Protheus.doc} PCPIPCGO
Encerra as threads de determinada fila
@author    brunno.costa
@since     14/02/2019
@version   1
@param 01 - cSemaforo , caracter    , nome do semaforo da fila
@param 02 - lClose    , logico      , indica se deve fechar a Thread apos a execucao
@param 03 - cFunName  , caracter    , indica o nome da funcao que sera executada pela Thread
@param 04 - oVar1     , nao definido, 1a variavel que sera repassada para a funcao
@param 05 - oVar2     , nao definido, 2a variavel que sera repassada para a funcao
@param 06 - oVar3     , nao definido, 3a variavel que sera repassada para a funcao
@param 07 - oVar4     , nao definido, 4a variavel que sera repassada para a funcao
@param 08 - oVar5     , nao definido, 5a variavel que sera repassada para a funcao
@param 09 - oVar6     , nao definido, 6a variavel que sera repassada para a funcao
@param 10 - oVar7     , nao definido, 7a variavel que sera repassada para a funcao
@param 11 - oVar8     , nao definido, 8a variavel que sera repassada para a funcao
@param 12 - oVar9     , nao definido, 9a variavel que sera repassada para a funcao
@param 13 - lWait     , logico      , indica se a funcao deve aguardar uma Thread disponivel
                                      ou nao executar a a funcao em caso de indisponibilidade
@param 14 - lAllThread, logico      , indica que a função deve ser executada por todas as threads que foram abertas
/*/
Function PCPIPCGO(cSemaforo, lClose, cFunName, oVar1, oVar2, oVar3, oVar4, oVar5, oVar6, oVar7, oVar8, oVar9, lWait, lAllThread)
	Local aThreads   := {}
	Local cSemfCheck := ""
	Local lReturn    := .T.
	Local lRodou     := .F.
	Local lThdPend   := .T.
	Local nIndThread := 0
	Local nThreads   := 0

	Default cSemaforo := "PCPIPCJOB"
	Default lClose    := .F.
	Default cFunName  := ""
	Default lWait     := .T.
	Default lAllThread := .F.

	If lWait
		cSemfCheck := "SEMAFORO_" + cSemaforo

		If lAllThread
			lReturn := VarGetA(cSemfCheck, "thread_ids", @aThreads)

			If lReturn
				nThreads := Len(aThreads)

				For nIndThread := 1 To nThreads
					VarSetXD(cSemfCheck, "EXEC_ALL_THREAD_" + cValToChar(aThreads[nIndThread]), .F.)
				Next

				While lThdPend
					If IPCGo( cSemaforo, cFunName, lClose, oVar1, oVar2, oVar3, oVar4, oVar5, oVar6, oVar7, oVar8, oVar9, .T. )
						lThdPend := .F.

						Sleep(100)

						For nIndThread := 1 To nThreads
							VarGetX(cSemfCheck, "EXEC_ALL_THREAD_" + cValToChar(aThreads[nIndThread]), @lRodou)

							If !lRodou
								lThdPend := .T.
								Exit
							EndIf
						Next
					EndIf
				End

				For nIndThread := 1 To nThreads
					VarDelX(cSemfCheck, "EXEC_ALL_THREAD_" + cValToChar(aThreads[nIndThread]))
				Next

				aSize(aThreads, 0)
			EndIf
		Else
			While !IPCGo( cSemaforo, cFunName, lClose, oVar1, oVar2, oVar3, oVar4, oVar5, oVar6, oVar7, oVar8, oVar9, .F. )
				If !VarIsUID(cSemfCheck)
					lReturn := .F.
					Exit
				EndIf
			EndDo
		EndIf
	Else
		lReturn := IPCGo( cSemaforo, cFunName, lClose, oVar1, oVar2, oVar3, oVar4, oVar5, oVar6, oVar7, oVar8, oVar9, .F. )
	EndIf

Return lReturn

/*/{Protheus.doc} PCPIPCJOB
Job de execucao das Threads da Fila
@author    brunno.costa
@since     14/02/2019
@version   1
@param 01 - cSemaforo , caracter, nome do semaforo que sera utilizado para a fila de Threads
@param 02 - cErrorUID, caracter, codigo identificador da secao global de controle de erros
/*/
Function PCPIPCJOB(cSemaforo, cErrorUID)
	Local cFunName  := ""
	Local cIDGlobal := "SEMAFORO_" + cSemaforo
	Local lAux      := .T.
	Local lClose    := .F.
	Local lPrimeiro := .T.
	Local lRet      := .F.
	Local lRodaAll  := .F.
	Local nThreadID := ThreadID()
	Local nTotal    := 0
	Local oVar1     := Nil
	Local oVar2     := Nil
	Local oVar3     := Nil
	Local oVar4     := Nil
	Local oVar5     := Nil
	Local oVar6     := Nil
	Local oVar7     := Nil
	Local oVar8     := Nil
	Local oVar9     := Nil

	SET DATE FRENCH; Set(_SET_EPOCH, 1980)

	While !KillApp()
		cFunName := ""
		lClose   := .F.
		oVar1    := NIL
		oVar2    := NIL
		oVar3    := NIL
		oVar4    := NIL
		oVar5    := NIL
		oVar6    := NIL
		oVar7    := NIL
		oVar8    := NIL
		oVar9    := NIL

		//Decrementa totalizador de threads preparadas
		If lPrimeiro
			lPrimeiro := .F.
			VarSetX(cIDGlobal, "nIniciando", @nTotal, 1, -1)
			VarSetA(cIDGlobal, "thread_ids", {}, 1, nThreadID)
		EndIf

		lRet := IpcWaitEx( cSemaforo, 10000, @cFunName, @lClose, @oVar1, @oVar2, @oVar3, @oVar4, @oVar5, @oVar6, @oVar7, @oVar8, @oVar9, @lRodaAll )

		FWMonitorMsg(cFunName)

		If lRet
			If lRodaAll
				VarGetXD(cIDGlobal, "EXEC_ALL_THREAD_" + cValToChar(nThreadID), @lRet)

				If !lRet
					lRet := .T.

					VarSetXD(cIDGlobal, "EXEC_ALL_THREAD_" + cValToChar(nThreadID), .T.)
				EndIf
			EndIf

			If lRet .And. !Empty(cFunName)
				&cFunName.(oVar1, oVar2, oVar3, oVar4, oVar5, oVar6, oVar7, oVar8, oVar9)
			EndIf
		EndIf

		If !lClose
			If VarIsUID(cIDGlobal)
				lRet := VarGetX( cIDGlobal, "lActivated", @lAux )
				If !lRet
					lAux := .F.
				EndIf
				lClose := !lAux
			Else
				lClose := .T.
			EndIf
		EndIf
		If lClose
			VarBeginT(cIDGlobal, "nThreads")
			VarSetX(cIDGlobal, "nThreads", @nTotal, 1, -1)
			VarEndT(cIDGlobal, "nThreads")
			Exit
		EndIf
	EndDo

Return

/*/{Protheus.doc} PCPIPCWIni
Aguarda a abertura e inicialização das threads

@author    lucas.franca
@since     12/03/2020
@version   1
@param 01 - cSemaforo, Character, Nome do semáforo de threads
@param 02 - nAguarda , Numerico , Quantidade máxima de vezes que ira verificar se abriu as threads.
@return lRet, Logico, Indica se conseguiu abrir com sucesso as threads.
/*/
Function PCPIPCWIni(cSemaforo, nAguarda)
	Local lRet       := .T.
	Local nTentativa := 0
	Local nTotal     := 0
	Default nAguarda := -1

	While lRet
		lRet := VarGetX("SEMAFORO_" + cSemaforo, "nIniciando", @nTotal)

		If lRet
			Sleep(100)
			If nTotal < 1
				Exit
			ElseIf nAguarda > 0
				nTentativa++

				If nTentativa > nAguarda
					lRet := .F.
					Exit
				EndIf
			EndIf
		EndIf
	End

Return lRet

/*/{Protheus.doc} PCPIPCWait
Aguarda a liberação de todas as threads abertas

@author    marcelo.neumann
@since     21/04/2022
@version   1
@param cSemaforo, Caracter, Nome do semáforo de threads
@return Nil
/*/
Function PCPIPCWait(cSemaforo)
	Local nThreads := 0

	If VarGetX("SEMAFORO_" + cSemaforo, "nThreads", @nThreads)
		While IPCCount(cSemaforo) < nThreads
			Sleep(500)
		EndDo
	EndIf

Return
