#INCLUDE 'PROTHEUS.CH'


Static cThread := "RmiSenhas - Thread: " + cValToChar(ThreadID())

/*/{Protheus.doc} RmiSenhas
    Função responsavel em realizar a atualização das senhas na Central PDV ou no PDV.
    IMPORTANTE: Essa rotina devera estar schedulada no Protheus.

    @type  Function
    @author Bruno Almeida
    @since 15/04/2024
    @version P12
    @param cMsgError, Caractere, Parâmetro passado por referencia para retornar mensagem de erro na execução.
    @return Nil
/*/
Function RmiSenhas(cMsgError)

	Local cIni 			:= Time()
	Local cMessage  	:= ""
	Local cIp       	:= ""
	Local cPorta    	:= ""
	Local cAmbiente 	:= ""
	Local cModoExec		:= ""
	Local lSyncMenu		:= .F.
	Local lSyncTotal	:= .F.
	Local lRet			:= .T.

	Default cMsgError 	:= ""

	cIp       		:= SuperGetMV("MV_LJILLIP", .F., "")
	cPorta    		:= SuperGetMV("MV_LJILLPO", .F., "")
	cAmbiente 		:= SuperGetMV("MV_LJILLEN", .F., "")
	cModoExec		:= SuperGetMV("MV_LJILMOD", .F., "1")
	lSyncMenu		:= SuperGetMV("MV_LJILSM", .F., .F.)
	lSyncTotal		:= SuperGetMV("MV_LJILST", .F., .F.)

	//Inicio Validações
	LjGrvLog(cThread, "---- Iniciando Validações 	: " + FwTimeStamp(2) 		)
	If LockByName('RMISENHAS', .F., .F.)
		// Validação de Parâmetros
		If Empty(cIp) .OR. Valtype(cIp) <> 'C'
				LjGrvLog(cThread, "[MV_LJILLIP] - IP/HOST Inválido						: " + ALLTOCHAR(cIp)		)
				lRet:= .F.
		ElseIf Empty(cPorta) .OR. Valtype(cPorta) <> 'C'
				LjGrvLog(cThread, "[MV_LJILLPO] - PORTA Inválido						: " + ALLTOCHAR(cPorta)		)
				lRet:= .F.
		ElseIf Empty(cAmbiente) .OR. Valtype(cAmbiente) <> 'C'				
				LjGrvLog(cThread, "[MV_LJILLEN] - AMBIENTE Inválido						: " + ALLTOCHAR(cAmbiente)	)
				lRet:= .F.
		ElseIf Empty(cModoExec) .OR. Valtype(cModoExec) <> 'C' 		
				LjGrvLog(cThread, "[MV_LJILMOD] - MODO Inválido							: " + ALLTOCHAR(cModoExec)	)
				lRet:= .F.
		ElseIf  Valtype(lSyncMenu) <> 'L' .AND. cModoExec == '2'				
				LjGrvLog(cThread, "[MV_LJILSM] - INTEGRA MENUS(MODO 2) Inválido			: " + ALLTOCHAR(lSyncMenu)	)
				lRet:= .F.
		ElseIf  Valtype(lSyncTotal) <> 'L' .AND. cModoExec == '2'				
				LjGrvLog(cThread, "[MV_LJILST] - SINCRONISMO COMPLETO (MODO 2) Inválido	: " + ALLTOCHAR(lSyncTotal)	)
				lRet:= .F.
		EndIf

		// Valida Existencia da Função Incremental na Lib
		If lRet 
			If cModoExec == '2'
				If FindFunction("totvs.framework.user.sync.incremental",.T.)
					lRet:= .T.
				Else
					LjGrvLog(cThread, "Função totvs.framework.user.sync.incremental não existe na Lib")
					lRet:= .F.
				EndIf
			EndIf
		EndIf
		LjGrvLog(cThread, "---- Finaliza Validações 	: " + FwTimeStamp(2) 		)
		//Finaliza Validações

		//Inicio Processamento
		If lRet
			// Log de Inicio Execução - Parâmetros
			LjGrvLog(cThread, "---- Iniciando Processamento 					: " + FwTimeStamp(2) 		)
			LjGrvLog(cThread, "[MV_LJILLIP] - IP/HOST 							: " + cIp       			)
			LjGrvLog(cThread, "[MV_LJILLPO] - PORTA 							: " + cPorta    			)
			LjGrvLog(cThread, "[MV_LJILLEN] - AMBIENTE 							: " + cAmbiente 			)
			LjGrvLog(cThread, "[MV_LJILMOD] - MODO 								: " + cModoExec				)
			LjGrvLog(cThread, "[MV_LJILSM]  - INTEGRA MENUS(MODO 2) 			: " + ALLTOCHAR(lSyncMenu)	)
			LjGrvLog(cThread, "[MV_LJILST]  - SINCRONISMO COMPLETO (MODO 2) 	: " + ALLTOCHAR(lSyncTotal)	)

			If 	cModoExec == '1' // Carga Completa
					lRet:= MPUsrSync( "", "", AllTrim(cAmbiente), AllTrim(cIP), Val(cPorta), @cMessage )
			ElseIf cModoExec == '2' // Carga Incremental
					lRet:= (totvs.framework.user.sync.incremental(cIP, Val(cPorta), cAmbiente, @cMessage,lSyncMenu,lSyncTotal))
			EndIf

			LjGrvLog(cThread, "Mensagem de Retorno			 					: " + cMessage		   )
			LjGrvLog(cThread, "---- Finalizando Processamento					: " + FwTimeStamp(2)   )
			LjGrvLog(cThread, "---- Tempo de Processamento						: " + ElapTime(cIni,Time()) )
		EndIf
		
		If !lRet
			LjGrvLog(cThread, "---- Falha de Processamento						:  " + ElapTime(cIni,Time()) )
			cMsgError := (cThread + "---- Falha de Processamento						:  " + ElapTime(cIni,Time()))
		EndIf
	Else
		LjGrvLog(cThread, "A rotina esta sendo executada em outra instância")
	EndIF

Return Nil


/*/{Protheus.doc} SchedDef
    Função para chamar o pergunte no momento em que estiver 

    @type  Function
    @author Bruno Almeida
    @since 15/04/2024
    @version P12
    @param
    @return Nil
/*/
Static Function SchedDef()

	Local aParam  := {}

	aParam := { "P"                 ,;  //Tipo R para relatorio P para processo
	"ParamDef"          ,;  //Pergunte do relatorio, caso nao use passar ParamDef
            /*Alias*/           ,;	
            /*Array de ordens*/ ,;
            /*Titulo*/          }

Return aParam
