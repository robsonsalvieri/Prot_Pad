#INCLUDE "TOTVS.CH"
#INCLUDE "PCPMultiThreadError.CH"

Static _cErrUID := Nil

/*/{Protheus.doc} PCPMultiThreadError
Controla Erros em Processamento Multi-Thread
@author  brunno.costa
@since   17/07/2020
@version P12.1.27
/*/
CLASS PCPMultiThreadError FROM LongClassName

	//Declaracao de propriedades da classe
	DATA cErrorUID          AS String
	DATA cIdLastOpen        AS String
	DATA cNameLastFunc      AS String
	DATA lExecutaRecover    AS Logic
	DATA nTentativasConexao AS Numeric

	//Metodos publicos
	METHOD new(cErrorUID, lCriaSecao, nTentConec) CONSTRUCTOR
	METHOD executa(cEmpAux, cFilAux, cFunName, oVar01, oVar02, oVar03, oVar04, oVar05, oVar06, oVar07, oVar08, oVar09, oVar10, nTentativa, bRecover, cRecover, cUserToken)
	METHOD final(aError)
	METHOD getaError()
	METHOD getcError(nTam)
	METHOD possuiErro()
	METHOD lock(cChave)
	METHOD unlock(cChave)
	METHOD startJob(cFunName, cEnv, lWait, cEmpAux, cFilAux, oVar01, oVar02, oVar03, oVar04, oVar05, oVar06, oVar07, oVar08, oVar09, oVar10, bRecover, cRecover)
	METHOD setError(cRot, cError, cStack, cEnv)
	METHOD abriuUltimaThread()

	//Metodos internos
	METHOD criarSecaoGlobal(cErrorUID)
	METHOD destroy()
	METHOD preparaAmbiente(cEmpAux, cFilAux, nTentativa, cUserToken)

ENDCLASS

/*/{Protheus.doc} new
Metodo construtor
@author  brunno.costa
@since   17/07/2020
@version P12.1.27
@param 01 - cErrorUID , caracter, nome da secao global que sera utilizada no controle de erros multi-thread
@param 02 - lCriaSecao, logico  , indica se deve criar a secao global
@param 03 - nTentConec, numero  , numero maximo de tentativas de conexao com ambiente RPCSETENV
@return Self, objeto, instancia da classe
/*/
METHOD new(cErrorUID, lCriaSecao, nTentConec) CLASS PCPMultiThreadError
	Default nTentConec := 10
	Default lCriaSecao := .F.

	Self:cErrorUID          := cErrorUID
	Self:lExecutaRecover    := .T.
	Self:nTentativasConexao := nTentConec

	_cErrUID := cErrorUID

	If lCriaSecao
		Self:criarSecaoGlobal(cErrorUID)
	EndIf

	If Type("dDataBase") == "D" .And. Empty(GetGlbValue(Self:cErrorUID + "DATABASE_THREAD"))
		//Seta variável global com a Database logada para usar nas threads
		PutGlbValue(Self:cErrorUID + "DATABASE_THREAD", DToS(dDataBase))
	EndIf

	If Type("__cUserId") == "C" .And. Empty(GetGlbValue(Self:cErrorUID + "CODUSER_THREAD"))
		//Seta variável global com o usuário logado para usar nas threads
		PutGlbValue(Self:cErrorUID + "CODUSER_THREAD", totvs.framework.users.rpc.getAuthToken())
	EndIf

Return Self

/*/{Protheus.doc} startJob
Chamada Protegida da cFunName através de StartJOB() + PCPMLTHSTJ
@type  Method
@author  brunno.costa
@since   17/07/2020

@version P12.1.27
@param 01 - cFunName    , caracter    , indica o nome da funcao que sera executada pela Thread
@param 02 - cEnv        , caracter    , cEnv enviado para StartJOB()
@param 03 - lWait       , logico      , lWait enviado para StartJOB()
@param 04 - cEmpAux     , caracter    , empresa para abertura de ambiente
@param 05 - cFilAux     , caracter    , filial para abertura de ambiente
@param 06 -> 15 - oVar01, nao definido, 1a -> 10 variavel que sera repassada para a funcao
@param 16 - bRecover    , bloco       , bloco de codigo para execucao em recover
@param 17 - cRecover    , caracter    , bloco de código em formato string para execução em recover. Utilizado quando aberta nova thread.
@param 18 - lExecST     , Logico      , Indica que deve executar a função em single thread, caso a thread não abra.
@return xRet, Se lWait for verdadeiro (.T.) o retorno do StartJob será o retorno da função a ser executada como um JOB (cName), caso lWait seja falso (.F.) o retorno é nulo (NIL).
/*/
METHOD startJob(cFunName, cEnv, lWait, cEmpAux, cFilAux, oVar01, oVar02, oVar03, oVar04, oVar05, oVar06, oVar07, oVar08, oVar09, oVar10, bRecover, cRecover, lExecST) CLASS PCPMultiThreadError
	Local xRet      := Nil
	Local cToken    := ""
	Default lExecST := .F.

	cToken := totvs.framework.users.rpc.getAuthToken()

	Self:cIdLastOpen   := UUIDRandom()
	Self:cNameLastFunc := cFunName

	VarSetX(Self:cErrorUID, chaveAbreT(Self:cIdLastOpen), .F.)

	xRet := StartJob("PCPMLTHSTJ", cEnv, lWait, Self:cErrorUID, cEmpAux, cFilAux, cFunName, oVar01, oVar02, oVar03, oVar04, oVar05, oVar06, oVar07, oVar08, oVar09, oVar10, bRecover, cRecover, Self:cIdLastOpen, cToken)

	If lExecST .And. !Self:abriuUltimaThread()
		LogMsg('PCPMultiThreadError', 0, 0, 1, '', '', i18n("[#1[data]# - #2[hora]#] - Nao foi possivel abrir thread para executar a funcao #3[nomeFuncao]#. Executando em thread unica.", {DToC(Date()), Time(), cFunName}))

		xRet := &cFunName.(oVar01, oVar02, oVar03, oVar04, oVar05, oVar06, oVar07, oVar08, oVar09, oVar10)
		If !lWait
			xRet := Nil
		EndIf
	EndIf

Return xRet

/*/{Protheus.doc} PCPMLTHSTJ
Função Iniciao da Chamada PCPMultiThreadError:startJob()
@type  Method
@author  brunno.costa
@since   17/07/2020
@version P12.1.27
@param 01 - cErrorUID   , caracter    , codigo da secao de controle de erros global
@param 02 - cEmpAux     , caracter    , empresa para abertura de ambiente
@param 03 - cFilAux     , caracter    , filial para abertura de ambiente
@param 04 - cFunName    , caracter    , indica o nome da funcao que sera executada pela Thread
@param 05 -> 14 - oVar01, nao definido, 1a -> 10 variavel que sera repassada para a funcao
@param 15 - bRecover    , bloco       , bloco de codigo para execucao em recover
@param 16 - cRecover    , caracter    , bloco de código em formato string para execução em recover. Utilizado quando aberta nova thread.
@param 17 - cIdJob      , Caracter    , Id de execução do startjob.
@param 18 - cUserToken  , Caracter    , Token do usuario que abriu a thread.
@return Nil
/*/
Function PCPMLTHSTJ(cErrorUID, cEmpAux, cFilAux, cFunName, oVar01, oVar02, oVar03, oVar04, oVar05, oVar06, oVar07, oVar08, oVar09, oVar10, bRecover, cRecover, cIdJob, cUserToken)

	If canRun(cErrorUID, cIdJob)
		PCPMLTHEXE(cErrorUID, .F./*lCriaSecao*/, cEmpAux, cFilAux, cFunName, oVar01, oVar02, oVar03, oVar04, oVar05, oVar06, oVar07, oVar08, oVar09, oVar10, 1/*nTentativa*/, bRecover, cRecover, cUserToken)
		LogMsg("PCPMLTHERR", 0, 0, 1, '', '', "[INFO ][SERVER] [Thread " + cValToChar(ThreadID()) + "] Thread finished [-PCPMLTHSTJ " + cErrorUID + " " + cFunName + " - " + Time() + "]")
	EndIf

Return

/*/{Protheus.doc} canRun
Retorna se o startJob executado pode continuar com a execução.
@type  Static Function
@author Lucas Fagundes
@since 04/07/2024
@version P12
@param cUIDGlb, Caracter, Secao de variaveis globais.
@param cIdJob , Caracter, Id gerado para a execução do startJob.
@return lRun, Logico, Indica se pode rodar a função (não foi executada em single thread).
/*/
Static Function canRun(cUIDGlb, cIdJOb)
	Local cChaveAbre := chaveAbreT(cIdJob)
	Local lRodouST   := .F.
	Local lRun       := .T.

	VarBeginT(cUIDGlb, cChaveAbre)

	VarGetXD(cUIDGlb, cChaveAbre, @lRodouST)
	lRun := !lRodouST

	If lRun
		VarSetX(cUIDGlb, cChaveAbre, .T.)
	EndIf

	VarEndT(cUIDGlb, cChaveAbre)

Return lRun

/*/{Protheus.doc} PCPMLTHEXE
Chamada da Execucao da Classe PCPMultiThreadError em Function
@type  Method
@author  brunno.costa
@since   17/07/2020
@version P12.1.27
@param 01 - cErrorUID   , caracter    , codigo da secao de controle de erros global
@param 02 - lCriaSecao  , logico      , indica se deve criar a secao de variaveis globais
@param 03 - cEmpAux     , caracter    , empresa para abertura de ambiente
@param 04 - cFilAux     , caracter    , filial para abertura de ambiente
@param 05 - cFunName    , caracter    , indica o nome da funcao que sera executada pela Thread
@param 06 -> 15 - oVar01, nao definido, 1a -> 10 variavel que sera repassada para a funcao
@param 16 - nTentativa  , numero      , indica a numeracao de tentativas de conexao ao ambiente
@param 17 - bRecover    , bloco       , bloco de codigo para execucao em recover
@param 18 - cRecover    , caracter    , bloco de código em formato string para execução em recover. Utilizado quando aberta nova thread.
@param 19 - cUserToken  , Caracter    , Token do usuario que abriu a thread.
@return Nil
/*/
Function PCPMLTHEXE(cErrorUID, lCriaSecao, cEmpAux, cFilAux, cFunName, oVar01, oVar02, oVar03, oVar04, oVar05, oVar06, oVar07, oVar08, oVar09, oVar10, nTentativa, bRecover, cRecover, cUserToken)
	Local oSelf
	
	Default lCriaSecao := .F.
	Default nTentativa := 1

	_cErrUID := cErrorUID

	oSelf := PCPMultiThreadError():New(cErrorUID, lCriaSecao)
	SET DATE FRENCH; Set(_SET_EPOCH, 1980)
	oSelf:executa(cEmpAux, cFilAux, cFunName, oVar01, oVar02, oVar03, oVar04, oVar05, oVar06, oVar07, oVar08, oVar09, oVar10, nTentativa, bRecover, cRecover, cUserToken)

	_cErrUID := Nil
Return

/*/{Protheus.doc} executa
Executa Function cFunName Protegida com ErrorBlock - Assíncrono
@type  Method
@author  brunno.costa
@since   17/07/2020
@version P12.1.27
@param 01 - cEmpAux     , caracter    , empresa para abertura de ambiente
@param 02 - cFilAux     , caracter    , filial para abertura de ambiente
@param 03 - cFunName    , caracter    , indica o nome da funcao que sera executada pela Thread
@param 04 -> 13 - oVar01, nao definido, 1a -> 10 variavel que sera repassada para a funcao
@param 14 - nTentativa  , numero      , indica a numeracao de tentativas de conexao ao ambiente
@param 15 - bRecover    , bloco       , bloco de codigo para execucao em recover
@param 16 - cRecover    , caracter    , bloco de código em formato string para execução em recover. Utilizado quando aberta nova thread.
@param 17 - cUserToken  , Caracter    , Token do usuario que abriu a thread.
@return Nil
/*/
METHOD executa(cEmpAux, cFilAux, cFunName, oVar01, oVar02, oVar03, oVar04, oVar05, oVar06, oVar07, oVar08, oVar09, oVar10, nTentativa, bRecover, cRecover, cUserToken) CLASS PCPMultiThreadError
	Local lExecuta := .T.
	Local oBkpError

	Default nTentativa := 1

	If cEmpAux != NIL .AND. cFilAux != NIL .AND. !Empty(cEmpAux + cFilAux)
		lExecuta := Self:preparaAmbiente(cEmpAux, cFilAux, nTentativa, cUserToken)
	EndIf

	If lExecuta
		If !Empty(cFunName)

			Self:lExecutaRecover := .T.

			nTentativa := Self:nTentativasConexao + 1
			oBkpError  := ErrorBlock( { |oErro| PCPMLTHERR(oErro, Self:cErrorUID, nTentativa, Self:nTentativasConexao), ;
			                                    checkRecov(Self, cRecover), ;
			                                    Break(oErro) } )

			BEGIN SEQUENCE
				&cFunName.(oVar01, oVar02, oVar03, oVar04, oVar05, oVar06, oVar07, oVar08, oVar09, oVar10)

			RECOVER
				If Self:lExecutaRecover
					exeRecover(bRecover, cRecover)
				EndIf

			END SEQUENCE

			ErrorBlock( oBkpError )
		EndIf

	ElseIf nTentativa <= Self:nTentativasConexao
		//Inicia nova thread para tentar a preparacao do ambiente novamente
		StartJob("PCPMLTHEXE", getEnvServer(), .F./*lWait*/, Self:cErrorUID, .F./*lCriaSecao*/, cEmpAux, cFilAux, cFunName, oVar01, oVar02, oVar03, oVar04, oVar05, oVar06, oVar07, oVar08, oVar09, oVar10, (nTentativa + 1), bRecover, cRecover, cUserToken)
	EndIf

Return Nil

/*/{Protheus.doc} PCPMLTHERR
Função para tratar erros de execução do JOB
@type  Method
@author  brunno.costa
@since   17/07/2020
@version P12.1.27
@param 01 - oErro     , objeto    , instancia do parametro default de erro da ErrorBLock()
@param 02 - cErrorUID , caracter  , codigo identificador da secao de controle de erros
@param 03 - nTentativa, numero    , indicador da quantidade de tentativas de conexao com o ambiente RPCSETENV
@param 04 - nMaximo   , numero    , indicador da quantidade maxima de tentativas de conexao com o ambiente RPCSETENV
@return Nil
/*/
Function PCPMLTHERR(oErro, cErrorUID, nTentativa, nMaximo)
	Local aError
	Local lRetAux := .F.

	Default nTentativa := nMaximo + 1

	LogMsg("PCPMLTHERR", 0, 0, 1, '', '', "PCPMLTHERR - " + cValToChar(ThreadID()) + " - " + AllTrim(oErro:description) + CHR(10) + AllTrim(oErro:ErrorStack) + CHR(10) + oErro:ErrorEnv)

	If nTentativa > nMaximo
		If !VarIsUID(cErrorUID)
			VarSetUID(cErrorUID)
		EndIf
		VarBeginT(cErrorUID, "aError")
		lRetAux := VarGetA(cErrorUID, "aError", @aError)
		If !lRetAux .OR. aError == Nil
			aError := {}
		EndIf
		aAdd(aError, {"PCPIPCLogE"              ,;
		              AllTrim(oErro:description),;
					  AllTrim(oErro:ErrorStack) ,;
					  oErro:ErrorEnv            })
		VarSetA(cErrorUID, "aError", aError)
		VarSetX(cErrorUID, "lError", .T.)
		VarEndT(cErrorUID, "aError")
	EndIf

Return

/*/{Protheus.doc} preparaAmbiente
Prepara o ambiente (conexao com banco) de acordo com os parametros
@type  Method
@author  brunno.costa
@since   17/07/2020
@version P12.1.27
@param 01 - cEmpAux   , caracter, empresa para abertura de ambiente
@param 02 - cFilAux   , caracter, filial para abertura de ambiente
@param 03 - nTentativa, numero  , indicador da quantidade de tentativas de conexao com o ambiente RPCSETENV
@param 04 - cUserToken, Caracter, Token do usuario que abriu a thread.
@return lReturn, logico, indica se conseguiu conectar com o ambiente
/*/
METHOD preparaAmbiente(cEmpAux, cFilAux, nTentativa, cUserToken) CLASS PCPMultiThreadError
	Local cDataB    := Nil
	Local cTokenUsr := ""
	Local oBkpError := ErrorBlock( {|oErro| PCPMLTHERR(oErro, Self:cErrorUID, nTentativa, Self:nTentativasConexao), Break(oErro)} )
	Local lReturn   := .F.

	BEGIN SEQUENCE
		If Empty(cEmpAux)
			lReturn := .T.
		Else
			RpcSetType(3)
			lReturn := RpcSetEnv(cEmpAux, cFilAux, Nil, Nil, "PCP", Nil)
			If lReturn
				cDataB := GetGlbValue(Self:cErrorUID + "DATABASE_THREAD")
				If !Empty(cDataB)
					dDataBase := SToD(cDataB)
				EndIf

				cTokenUsr := GetGlbValue(Self:cErrorUID + "CODUSER_THREAD")
				If Empty(cTokenUsr)
					cTokenUsr := cUserToken
				EndIf
				If !Empty(cTokenUsr)
					totvs.framework.users.rpc.authByToken(cTokenUsr)
				Endif

				If nTentativa > 1
					LogMsg("PCPMLTHERR", 0, 0, 1, '', '', "PCPMLTHERR - " + cValToChar(ThreadID()) + STR0001 + cValToChar(nTentativa) + STR0002 + cValToChar(Self:nTentativasConexao)) //" - Sucesso no preparo do ambiente. Tentativa: " + " de "
				EndIf
			EndIf
		EndIf

	RECOVER
		If !Empty(cEmpAux) .And. !lReturn
			If nTentativa <= Self:nTentativasConexao
				Sleep(1000)
				LogMsg("PCPMLTHERR", 0, 0, 1, '', '', "PCPMLTHERR - " + cValToChar(ThreadID()) + STR0003 + cValToChar(nTentativa+1) + STR0002 + cValToChar(Self:nTentativasConexao)) //" - Falha no preparo do ambiente. Executando nova tentativa. " + " de "
			EndIf
		EndIf

	END SEQUENCE

	ErrorBlock( oBkpError )

Return lReturn

/*/{Protheus.doc} criarSecaoGlobal
Cria a seção de variáveis globais que será utilizada no processamento
@type  Method
@author  brunno.costa
@since   17/07/2020
@version P12.1.27
@param 01 - cErrorUID, caracter, codigo identificaor da secao global
@return Nil
/*/
METHOD criarSecaoGlobal(cErrorUID) CLASS PCPMultiThreadError
	Default cErrorUID := Self:cErrorUID
	If !VarSetUID(Self:cErrorUID)
		LogMsg("PCPMultiThreadError", 0, 0, 1, '', '', "PCPMultiThreadError - " + Self:cErrorUID + STR0004) //" - Erro na criação da seção de variáveis globais."
	EndIf
Return Nil

/*/{Protheus.doc} possuiErro
Verifica a Ocorrencia de Erros
@type  Method
@author  brunno.costa
@since   17/07/2020
@version P12.1.27
@return lError, logico, indica ocorrencia de erro na execucao multithread
/*/
METHOD possuiErro() CLASS PCPMultiThreadError
	Local lError    := .F.
	Local lRetAux

	If VarIsUID(Self:cErrorUID)
		VarGetX(Self:cErrorUID, "lError", @lRetAux)
		If lRetAux != Nil .AND. lRetAux
			lError := .T.
		EndIf
	EndIf

Return lError

/*/{Protheus.doc} getaError
Retorna Array de Erro
@type  Method
@author  brunno.costa
@since   17/07/2020
@version P12.1.27
@return aError, array, retorna array de erro: aError[x] := {{"PCPIPCLogE"              ,;
															AllTrim(oErro:description),;
															AllTrim(oErro:ErrorStack) ,;
															oErro:ErrorEnv            })}
/*/
METHOD getaError() CLASS PCPMultiThreadError
	Local aError    := {}
	VarGetA(Self:cErrorUID, "aError", @aError)
	If aError == Nil
		aError := {}
	EndIf
Return aError

/*/{Protheus.doc} destroy
Destroi Sessao de Variaveis Globais
@type  Method
@author  brunno.costa
@since   17/07/2020
@version P12.1.27
@return lRet, logico, Indica se conseguiu remover todos os valores das chaves da sessão <cUID> das tableas "Tabela X" e "Tabela A", assim como todas as transações de chaves.
/*/
METHOD destroy() CLASS PCPMultiThreadError

	Self:cIdLastOpen := Nil

	_cErrUID := Nil

	//Limpa a variável global com a Database usada nas threads
	ClearGlbValue(Self:cErrorUID + "DATABASE_THREAD")
	//Limpa a variável global com o código do usuário logado nas threads
	ClearGlbValue(Self:cErrorUID + "CODUSER_THREAD")

Return VarClean(Self:cErrorUID)

/*/{Protheus.doc} final
Exibe Erros e Finaliza a Thread Atual
@type  Method
@author  brunno.costa
@since   17/07/2020
@version P12.1.27
@param 01 - aError, array, array de erro: aError[x] := {{"PCPIPCLogE"              ,;
                                                         AllTrim(oErro:description),;
                                                         AllTrim(oErro:ErrorStack) ,;
                                                         oErro:ErrorEnv            })}
@return Nil
/*/
METHOD final(aError) CLASS PCPMultiThreadError

	Local aError    := {}
	Local nInd      := 0
	Local nErros    := 0
	Local cMsgErro  := ""

	If aError == Nil .OR. Empty(aError)
		VarGetA(Self:cErrorUID, "aError", @aError)
		Self:destroy()
	EndIf

	If Empty(aError)
		Final(STR0005, STR0006) //"Erro indeterminado." , "Entre em contato com o departamento de TI e solicite consulta ao console.log."
	ELse
		nErros := Len(aError)
		For nInd := 1 to nErros
			cMsgErro += aError[nInd][2] +  aError[nInd][3] + aError[nInd][4] + CHR(10) + CHR(10)
		Next
		Final(STR0007, cMsgErro) //"Erro durante execução do MRP"
	EndIf

Return

/*/{Protheus.doc} getcError
Retorna o ErrorLog em uma string, caso não haja erro, retorna string vazia.
@author Lucas Fagundes
@since 21/03/2022
@version P12
@param nTam, Numerico, Posição final do array aError que será concatenado no ErrorLog.
@return cError, Caractere, String com o errorLog ocorrido.
/*/
METHOD getcError(nTam) CLASS PCPMultiThreadError
	Local aErro      := {}
	Local cError     := ""
	Local nIndex     := 0
	Local nIndexTam  := 0

	Default nTam := 4

	If Self:possuiErro()
		aErro := Self:getaError()
		For nIndex := 1 to Len(aErro)
			For nIndexTam := 1 to nTam
				cError += aErro[nIndex][nIndexTam]
			Next
		Next
	EndIf

Return cError

/*/{Protheus.doc} lock
Realiza um lock na chave recebida na sessão global da instancia.
@author Lucas Fagundes
@since 22/03/2022
@version P12
@param cChave, Caracter, Chave que irá receber o lock
@return lRet, Logico, Indica se conseguiu efetuar o lock
/*/
METHOD lock(cChave) CLASS PCPMultiThreadError
	Local lRet := .F.

	lRet := VarBeginT(Self:cErrorUID, cChave)
Return lRet

/*/{Protheus.doc} unlock
Realiza um unlock na chave recebida na sessão global da instancia.
@author Lucas Fagundes
@since 22/03/2022
@version P12
@param cChave, Caracter, Chave que irá receber o unlock
@return lRet, Logico, Indica se conseguiu efetuar o unlock
/*/
METHOD unlock(cChave) CLASS PCPMultiThreadError
	Local lRet := .F.

	lRet := VarEndT(Self:cErrorUID, cChave)
Return lRet

/*/{Protheus.doc} PCPMTEUID
Recupera o UID de erros do processo atual.

@type  Function
@author user
@since 29/03/2022
@version P12
@param cUIDPadrao, Character, Valor padrão que será retornado caso _cErrUID esteja vazio.
@return _cErrUID, Character, UID de erros da seção que está em execução pela classe.
/*/
Function PCPMTERUID(cUIDPadrao)
Return Iif(Empty(_cErrUID), cUIDPadrao, _cErrUID)

/*/{Protheus.doc} setError
Seta um erro na seção global
@author Lucas Fagundes
@since 06/02/2023
@version P12
@param cRot  , Caractere, Rotina que está realizando a gravação do erro.
@param cError, Caractere, Mensagem de erro que será gravada.
@param cStack, Caractere, Pilha de chamadas
@param cEnv  , Caractere, Informações do ambiente.
@return Nil
/*/
METHOD setError(cRot, cError, cStack, cEnv) CLASS PCPMultiThreadError
	Local aError  := {}
	Local lRetAux := .F.
	Default cEnv  := ""

	VarBeginT(Self:cErrorUID, "aError")

	lRetAux := VarGetA(Self:cErrorUID, "aError", @aError)

	If !lRetAux .OR. aError == Nil
		aError := {}
	EndIf

	aAdd(aError, {cRot   ,;
	              cError ,;
	              cStack ,;
	              cEnv   })

	VarSetA(Self:cErrorUID, "aError", aError)
	VarSetX(Self:cErrorUID, "lError", .T.)

	VarEndT(Self:cErrorUID, "aError")

Return Nil

/*/{Protheus.doc} checkRecov
Verifica se o bloco de recuperação pode ser executado na thread
atual, ou se deve ser aberta uma nova thread para executar o RECOVER.

Se a thread atual estiver com transação aberta, desarma a transação
e abre nova thread para realizar a execução do RECOVER.

Se a thread atual não estiver com transação aberta, não faz nada
e segue o processo para executar a instrução RECOVER do bloco de recuperação.

@author lucas.franca
@since 08/04/2024
@version P12
@param 01 oMThrErr, Object   , Instância da classe PCPMultiThreadError.
@param 02 cRecover, Caractere, Bloco de código em formato string para execução em recover
@return Nil
/*/
Static Function checkRecov(oMThrErr, cRecover)

	If InTransact()
		DisarmTransaction()

		oMThrErr:lExecutaRecover := .F.

		oMThrErr:startJob("PCPMLTHREC", GetEnvServer(), .T., cEmpAnt, cFilAnt, cRecover)
	EndIf

Return

/*/{Protheus.doc} PCPMLTHREC
Função executada em nova thread para executar o bloco de erro
quando a thread onde ocorreu o erro está com transação aberta.

@author lucas.franca
@since 08/04/2024
@version P12
@param 01 cRecover, Caractere, Bloco de código em formato string para execução em recover
@return Nil
/*/
Function PCPMLTHREC(cRecover)
	exeRecover(Nil, cRecover)
Return

/*/{Protheus.doc} exeRecover
Executa o bloco de erro (independente de ter ou não transação)
@author Marcelo Neumann
@since 11/12/2023
@version P12
@param 01 bRecover, Bloco    , Bloco de codigo para execucao em recover
@param 02 cRecover, Caractere, Bloco de código em formato string para execução em recover
@return Nil
/*/
Static Function exeRecover(bRecover, cRecover)

	If bRecover != Nil
		Eval(bRecover)
	EndIf

	If !Empty(cRecover)
		If Left(AllTrim(cRecover), 2) == "{|"
			//Se a string for um bloco de código, executa com o "Eval".
			Eval(&cRecover)
		Else
			//Se não for um bloco de código, apenas executa a instrução
			&cRecover
		EndIf
	EndIf

Return

/*/{Protheus.doc} abriuUltimaThread
Verifica a flag global que indica se abriu a ultima thread que fez o startJob(), sem validar a criação do ambiente.
@author Lucas Fagundes
@since 03/06/2024
@version P12
@return lAbriu, Lógico, Retorna se abriu a ultima thread.
/*/
Method abriuUltimaThread() Class PCPMultiThreadError
	Local cChaveGlb := chaveAbreT(Self:cIdLastOpen)
	Local lAbriu    := .F.
	Local lError    := .F.
	Local nCont     := 0
	Local xRet      := Nil
	Local nWait     := 600

	While !lAbriu .And. nCont < nWait
		nCont++
		lError := !VarGetXD(Self:cErrorUID, cChaveGlb, @xRet)

		lAbriu := !lError .And. xRet
		If !lAbriu
			If (nCont % 100) == 0
				LogMsg("PCPMultiThreadError", 0, 0, 1, "", "", "Aguardando abertura do ultimo startJob para iniciar a funcao " + Self:cNameLastFunc)
			EndIf
			Sleep(100)
		EndIf
	End

	If !lAbriu
		Self:lock(cChaveGlb)

		lError := !VarGetXD(Self:cErrorUID, cChaveGlb, @xRet)

		lAbriu := !lError .And. xRet
		If !lAbriu
			VarSetX(Self:cErrorUID, cChaveGlb, .T.)
		EndIf

		Self:unlock(cChaveGlb)
	EndIf

Return lAbriu

/*/{Protheus.doc} chaveAbreT
Retorna chave utilizada para controlar na global a execução do ultimo startJob.
@type  Static Function
@author Lucas Fagundes
@since 28/06/2024
@version P12
@param cIdExec, Caracter, ID de execução do startJob.
@return cChave, Caracter, Chave para controlar na global a abertura da thread.
/*/
Static Function chaveAbreT(cIdExec)

Return "ABRIU_ULTIMA_THREAD" + cIdExec
