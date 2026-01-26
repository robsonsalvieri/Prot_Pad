#INCLUDE 'protheus.ch'
#INCLUDE 'MrpDados.ch'

/*/{Protheus.doc} MrpDados
Classe para manipulação de dados via variaveis globais
@author    brunno.costa
@since     31/07/2019
@version   1
/*/
CLASS MrpDados_Status FROM LongClassName

	DATA cTicket    AS STRING
	DATA cUIDStatus AS STRING
	DATA nTamMsg    AS NUMERIC

	METHOD new() CONSTRUCTOR
	METHOD setStatus(cControle, cStatus)
	METHOD getStatus(cControle)
	METHOD persistir(oDados)
	METHOD destruir()
	METHOD preparaAmbiente()
	METHOD gravaErro()

ENDCLASS

/*/{Protheus.doc} MrpDados_Status
Método construtor da classe MrpDados_Status
@author    brunno.costa
@since     31/07/2019
@version   1
@param 01 - cTicket, caracter, identificador do ticket
@return Self, objeto, instancia desta classe
/*/
METHOD New(cTicket) CLASS MrpDados_Status

	::cTicket    := cTicket
	::cUIDStatus := "UIDs_PCPMRP_Status_" + cTicket
	::nTamMsg    := 0

	//Força criação de controle de status global
	VarSetUID(::cUIDStatus, .T.)

Return Self

/*/{Protheus.doc} setStatus
Seta conteúdo em variáveis globais
@author    brunno.costa
@since     31/07/2019
@version   1
@param 01 - cControle, caracter, identificador do controle de status
@param 02 - cStatus  , caracter, identificador do status
@return   - lReturn  , logico  , identificador de sucesso na alteracao
/*/
METHOD setStatus(cControle, cStatus) CLASS MrpDados_Status
Return VarSetXD(::cUIDStatus, cControle, cStatus)

/*/{Protheus.doc} getStatus
Retorna conteúdo de variáveis globais
@author    brunno.costa
@since     31/07/2019
@version   1
@param 01 - cControle, caracter, identificador do controle de status
@param 02 - lOk    lógico  , indica falha ou sucesso na recuperação do status da sessão de variáveis globais
@return   - cStatus  , caracter, identificador do status
/*/
METHOD getStatus(cControle, lOk) CLASS MrpDados_Status
	Local cStatus := '1'
	Local oAux

	VarGetXD(::cUIDStatus, cControle, @oAux)
	If oAux == Nil
		lOk := .F.
	Else
		lOk     := .T.
		cStatus := oAux
	EndIf
Return cStatus

/*/{Protheus.doc} persistir
Método de persistência dos status
@author    brunno.costa
@since     31/07/2019
@version   1
@param 01 - cControle, caracter, identificador do controle de status
@return   - cStatus  , caracter, identificador do status
/*/
METHOD persistir(oDados) CLASS MrpDados_Status
	Local nStatus
	Local cQuery
	Local cAux
	Local lOk    := .T.
	Local nOk    := 0

	If AllTrim(oDados:oParametros["cAutomacao"]) != "1"
		//Prepara Ambiente
		::preparaAmbiente(oDados)

		SET DATE FRENCH; Set(_SET_EPOCH, 1980)

		cQuery := " UPDATE " + RetSqlName("HW3")
		cQuery += " SET "

		cAux := ::getStatus("status", @lOk)
		If lOk
			cQuery += " HW3_STATUS = (CASE WHEN HW3_STATUS < '" + cAux + "' OR HW3_STATUS IS NULL THEN '" + cAux + "' ELSE HW3_STATUS END) "
			nOk++
		EndIf

		cAux := ::getStatus("memoria", @lOk)
		If lOk
			If nOk > 0
				cQuery += ","
			EndIf
			cQuery += " HW3_STATCM = (CASE WHEN (HW3_STATCM > '0' AND HW3_STATCM < '" + cAux + "') OR (HW3_STATCM IS NULL) THEN '" + cAux + "' ELSE HW3_STATCM END) "
			nOk++
		EndIf

		cAux := ::getStatus("niveis", @lOk)
		If lOk
			If nOk > 0
				cQuery += ","
			EndIf
			cQuery += " HW3_STATRN = (CASE WHEN HW3_STATRN < '" + cAux + "' OR HW3_STATRN IS NULL THEN '" + cAux + "' ELSE HW3_STATRN END) "
			nOk++
		EndIf

		cAux := ::getStatus("calculo", @lOk)
		If lOk
			If nOk > 0
				cQuery += ","
			EndIf
			cQuery += " HW3_STATCA = (CASE WHEN HW3_STATCA < '" + cAux + "' OR HW3_STATCA IS NULL THEN '" + cAux + "' ELSE HW3_STATCA END) "
			nOk++
		EndIf

		cAux := ::getStatus("persistencia", @lOk)
		If lOk
			If nOk > 0
				cQuery += ","
			EndIf
			cQuery += " HW3_STATPE = (CASE WHEN HW3_STATPE < '" + cAux + "' OR HW3_STATPE IS NULL THEN '" + cAux + "' ELSE HW3_STATPE END) "
			nOk++
		EndIf

		cAux := ::getStatus("mensagem", @lOk)
		If lOk
			If nOk > 0
				cQuery += ","
			EndIf
			If Self:nTamMsg == 0
				Self:nTamMsg := GetSx3Cache("HW3_MSG", "X3_TAMANHO")
			EndIf
			cQuery += " HW3_MSG = '" + PadR(cAux, Self:nTamMsg) + "' "
			nOk++
		EndIf

		//Data e Hora de Cancelamento
		If ::getStatus("status") == "4"
			If nOk > 0
				cQuery += ","
			EndIf
			cQuery += " HW3_DTCANC = (CASE WHEN HW3_DTCANC = ' ' OR HW3_DTCANC IS NULL THEN '" + DtoS(Date()) + "' ELSE HW3_DTCANC END), "
			cQuery += " HW3_HRCANC = (CASE WHEN HW3_HRCANC = ' ' OR HW3_HRCANC IS NULL THEN '" + Time()       + "' ELSE HW3_HRCANC END) "
			nOk++
		EndIf

		//Data e Hora de Conclusão Carga Memória Inicial
		If ::getStatus("memoria_inicial") == "3"
			If nOk > 0
				cQuery += ","
			EndIf
			cQuery += " HW3_DTFCMI = (CASE WHEN HW3_DTFCMI = ' ' OR HW3_DTFCMI IS NULL THEN '" + DtoS(Date()) + "' ELSE HW3_DTFCMI END), "
			cQuery += " HW3_HRFCMI = (CASE WHEN HW3_HRFCMI = ' ' OR HW3_HRFCMI IS NULL THEN '" + Time()       + "' ELSE HW3_HRFCMI END) "
			nOk++
		EndIf

		//Data e Hora de Conclusão Carga Memória
		If ::getStatus("memoria") == "3"
			If nOk > 0
				cQuery += ","
			EndIf
			cQuery += " HW3_DTFCMG = (CASE WHEN HW3_DTFCMG = ' ' OR HW3_DTFCMG IS NULL THEN '" + DtoS(Date()) + "' ELSE HW3_DTFCMG END), "
			cQuery += " HW3_HRFCMG = (CASE WHEN HW3_HRFCMG = ' ' OR HW3_HRFCMG IS NULL THEN '" + Time()       + "' ELSE HW3_HRFCMG END) "
			nOk++
		EndIf

		If nOk > 0
			cQuery += " WHERE     (D_E_L_E_T_ = ' ') AND (HW3_TICKET = '" + ::cTicket + "') "
			nStatus := TCSqlExec(cQuery)

			//Data e Hora de Conclusão
			If ::getStatus("status") $ "|3|4|" .OR. ::getStatus("memoria") $ "|4|9|"
				cQuery := " UPDATE " + RetSqlName("HW3")
				cQuery += " SET "
				cQuery += " HW3_DTFIM = (CASE WHEN (HW3_DTFIM = ' ' OR HW3_DTFIM IS NULL) AND HW3_STATCM IN ('4','9') AND HW3_STATUS IN ('3','4', '6') THEN '" + DtoS(Date()) + "' ELSE HW3_DTFIM END), "
				cQuery += " HW3_HRFIM = (CASE WHEN (HW3_HRFIM = ' ' OR HW3_HRFIM IS NULL) AND HW3_STATCM IN ('4','9') AND HW3_STATUS IN ('3','4', '6') THEN '" + Time()       + "' ELSE HW3_HRFIM END) "
				cQuery += " WHERE     (D_E_L_E_T_ = ' ') AND (HW3_TICKET = '" + ::cTicket + "') "
				nStatus := TCSqlExec(cQuery)
			EndIf

			If (nStatus < 0)
				LogMsg('MRPLOG-Status', 0, 0, 1, '', '', STR0072 + TCSQLError()) //"Erro na persistencia dos status: "
			EndIf
		EndIf

	EndIf

Return

/*/{Protheus.doc} destruir
Destroi os objetos e variaveis da camada de dados
@author brunno.costa
@since 31/07/2019
@version 1.0
@param 01 - aArea, array Array com area a ser restaurada
/*/
METHOD destruir() CLASS MrpDados_Status
	Local lRet := VarClean(::cUIDStatus)
	If !lRet
		LogMsg("MrpDados_Status", 0, 0, 1, '', '', "**************************** Falha VarClean(::cUIDStatus): " + AllTrim(::cUIDStatus) + " ****************************")
	EndIf
Return lRet

/*/{Protheus.doc} preparaAmbiente
Prepara o ambiente (conexao com banco) de acordo com os parâmetros
@author brunno.costa
@since  31/07/2019
@version 1.0
@param 01 - oDados    , objeto, instancia da camada de dados
@param 02 - nTentativa, número, quantidade de tentativas de abertura de ambient (recursiva)
/*/
METHOD preparaAmbiente(oDados, nTentativa) CLASS MrpDados_Status

	Local lRet       := .T.
	Local bOldBlock  := ErrorBlock( {|oErro| PCPMRPLogE(oErro)  } )
	Local lConectado := .F.

	Default nTentativa := 1

	BEGIN SEQUENCE
		If Type("cEmpAnt") == "U"
			If Empty(oDados:oParametros["cEmpAnt"]) .Or. Empty(oDados:oParametros["cFilAnt"])
				lRet := .F.
			Else
				RpcSetType(3)
				lConectado := RpcSetEnv(oDados:oParametros["cEmpAnt"], oDados:oParametros["cFilAnt"], Nil, Nil, "PCP", Nil,,,/*9-lShowFinal->lMsFinalAuto*/)
				If nTentativa > 1
					LogMsg("PCPIPCJOB", 0, 0, 1, '', '', "MrpDados_Status:preparaAmbiente - " + cValToChar(ThreadID()) + STR0074 + cValToChar(nTentativa) + " de 10") //" - Sucesso na conexao com o ambiente. Tentativa: "
				EndIf
			EndIf
		Else
			If nTentativa == 1
				lConectado := .T.
			EndIf
		EndIf

	RECOVER
		While lRet .AND. !lConectado
			If nTentativa > 10
				lRet := .F.
				Exit
			Else
				LogMsg("PCPIPCJOB", 0, 0, 1, '', '', "MrpDados_Status:preparaAmbiente - " + cValToChar(ThreadID()) + STR0075 + cValToChar(nTentativa+1) + " de 10") //" - Falha na conexao com o ambiente. Executando nova tentativa: "
				Sleep(1000)
				lRet := Self:preparaAmbiente(oDados, (nTentativa + 1))
			EndIf
		EndDo
	END SEQUENCE

	//Redefine bloco de erro anterior
	ErrorBlock( bOldBlock )

Return lRet

/*/{Protheus.doc} PCPMRPLogE
Função para tratar erros de execução do JOB

@author    brunno.costa
@since     10/03/2020
@version   1
@param 01 - e, object, Objeto com as informações do erro ocorrido.
@retorna true para indicar que a operação será repetida
/*/
Function PCPMRPLogE(oErro)
	LogMsg("PCPIPCJOB", 0, 0, 1, '', '', "MrpDados_Status:preparaAmbiente - " + cValToChar(ThreadID()) + " - " + AllTrim(oErro:description) + CHR(10) + AllTrim(oErro:ErrorStack) + CHR(10) + oErro:ErrorEnv)
Return .T.

/*/{Protheus.doc} gravaErro
Grava o erro para ser retornado
@author marcelo.neumann
@since 23/10/2019
@version 1.0
@param 01 - cStatusNam, caracter, nome do status que está sendo gravado (Ex.: "memoria", "calculo")
@param 02 - cMsg      , caracter, mensagem a ser gravada
@param Nil
/*/
METHOD gravaErro(cStatusNam, cMsg) CLASS MrpDados_Status

	Default cMsg := STR0071 //"Ocorreu algum erro no processamento."

	::setStatus(cStatusNam, "9" ) //9-"Erro"
	::setStatus("mensagem", cMsg)
	::setStatus("status"  , "4" ) //4-"Cancelado"

Return
