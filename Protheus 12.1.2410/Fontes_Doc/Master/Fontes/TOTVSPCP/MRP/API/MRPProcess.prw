#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "mrpprocess.CH"

Static _aMapExec  := MapFields(1)
Static _aMapParam := MapFields(2)

#DEFINE LISTA_DE_PARAMETROS  "listOfMRPParameters"
#DEFINE CAMPOS_LOGICOS "|demandsProcessed|lAguardaDescarga|lGeraDoc|eventLog||lUsesProductIndicator|lRastreiaEntradas|"
#DEFINE CAMPOS_NUMERICOS "|nThreads|nThreads_RAS|nThreads_MAT|nThreads_AGL|"
#DEFINE PARAMETROS_ARM "|armazemDe|armazemAte"

/*/{Protheus.doc} mrpprocess
API de integracao de Processos do MRP

@type  WSCLASS
@author brunno.costa
@since 31/07/2019
@version P12.1.27
/*/
WSRESTFUL mrpprocess DESCRIPTION STR0001 FORMAT APPLICATION_JSON //"Processos do MRP"
	WSDATA branchId   AS STRING  OPTIONAL
	WSDATA ticket     AS STRING  OPTIONAL
	WSDATA Fields     AS STRING  OPTIONAL
	WSDATA Order      AS STRING  OPTIONAL
	WSDATA Page       AS INTEGER OPTIONAL
	WSDATA PageSize   AS INTEGER OPTIONAL

	WSMETHOD GET ALL;
		DESCRIPTION STR0002; //"Retorna todos os Processos do MRP"
		WSSYNTAX "api/pcp/v1/mrpprocess" ;
		PATH "/api/pcp/v1/mrpprocess" ;
		TTALK "v1"

	WSMETHOD GET PROCESS;
		DESCRIPTION STR0003; //"Retorna um processo do MRP especifico"
		WSSYNTAX "api/pcp/v1/mrpprocess/{branchId}/{ticket}" ;
		PATH "/api/pcp/v1/mrpprocess/{branchId}/{ticket}" ;
		TTALK "v1"

	WSMETHOD GET STATUS;
		DESCRIPTION STR0004; //"Retorna status do Último processamento do MRP"
		WSSYNTAX "api/pcp/v1/mrpprocess/status" ;
		PATH "/api/pcp/v1/mrpprocess/status" ;
		TTALK "v1"

	WSMETHOD POST START;
		DESCRIPTION STR0010; //"Reserva execução do MRP para usuário atual e inicia carga em memória"
		WSSYNTAX "api/pcp/v1/mrpprocess" ;
		PATH "/api/pcp/v1/mrpprocess" ;
		TTALK "v1"

	WSMETHOD POST INITLOAD;
		DESCRIPTION STR0022; //"Inicia a carga de dados em memória para o processamento do MRP."
		WSSYNTAX "api/pcp/v1/mrpprocess/initload" ;
		PATH "/api/pcp/v1/mrpprocess/initload" ;
		TTALK "v1"

	WSMETHOD POST CALCULATE;
		DESCRIPTION STR0011; //"Inicia o cálculo do MRP"
		WSSYNTAX "api/pcp/v1/mrpprocess/calculate" ;
		PATH "/api/pcp/v1/mrpprocess/calculate" ;
		TTALK "v1"

	WSMETHOD POST CANCEL;
		DESCRIPTION STR0005; //"Cancela execução do MRP"
		WSSYNTAX "api/pcp/v1/mrpprocess/cancel" ;
		PATH "/api/pcp/v1/mrpprocess/cancel" ;
		TTALK "v1"

ENDWSRESTFUL

/*/{Protheus.doc} GET ALL /api/pcp/v1/mrpprocess
Retorna todos os Processos MRP

@type  WSMETHOD
@author brunno.costa
@since 31/07/2019
@version P12.1.27
@param	Order   , caracter, Ordenacao da tabela principal
@param	Page    , numerico, Número da pagina inicial da consulta
@param	PageSize, numerico, Número de registro por paginas
@param	Fields  , caracter, Campos que serão retornados no GET.
@return lRet    , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET ALL QUERYPARAM Order, Page, PageSize, Fields WSSERVICE mrpprocess
		Local aReturn := {}
	Local lRet    := .T.

	Self:SetContentType("application/json")

	aReturn := MrpGAll(Self:aQueryString, Self:Order, Self:Page, Self:PageSize, Self:Fields)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	aReturn := Nil

Return lRet

/*/{Protheus.doc} GET PROCESS /api/pcp/v1/mrpprocess
Retorna um processo especifica do MRP

@type  WSMETHOD
@author brunno.costa
@since 31/07/2019
@version P12.1.27
@param	branchId, Character, Codigo da filial para fazer a pesquisa
@param	ticket  , Character, Codigo único do processo para fazer a pesquisa.
@param	Fields  , Character, Campos que serão retornados no GET.
@return lRet    , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET PROCESS PATHPARAM branchId, ticket QUERYPARAM Fields WSSERVICE mrpprocess
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a funcao para retornar os dados.
	aReturn := MrpGet(Self:branchId, Self:ticket, Self:Fields)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	aReturn := Nil

Return lRet

/*/{Protheus.doc} GET STATUS /api/pcp/v1/mrpprocess/status
Retorna o último processo executado no MRP

@type  WSMETHOD
@author brunno.costa
@since 31/07/2019
@version P12.1.27
@return lRet    , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET STATUS WSSERVICE mrpprocess
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a funcao para retornar os dados.
	aReturn := MrpGStatus()
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	aReturn := Nil

Return lRet

/*/{Protheus.doc} MrpGStatus
Funcao para disparar as acoes da API de Processos do MRP, para o metodo GET (Consulta) do processo atual.

@type  Function
@author brunno.costa
@since 31/07/2019
@version P12.1.27
@return aReturn, Array, Array com as informacoes da requisicao.
                        aReturn[1] - Logico    - Indica se a requisicao foi processada com sucesso ou Nao.
						aReturn[2] - Character - JSON com o resultado da requisicao, ou com a mensagem de erro.
						aReturn[3] - Numeric   - Codigo de erro identificado pelo MRPApi.
/*/
Function MrpGStatus()
	Local aReturn   := {}

	//Recupera Json do último processamento
	aReturn := UltimoProc()

Return aReturn

/*/{Protheus.doc} POST START /api/pcp/v1/mrpprocess
Inicia um processo do MRP

@type  WSMETHOD
@author brunno.costa
@since 31/07/2019
@version P12.1.27
@return lRet, Logico, Informa se o processo foi executado com sucesso.
/*/
WSMETHOD POST START WSSERVICE mrpprocess
	Local aReturn  := {}
	Local cBody    := ""
	Local cError   := ""
	Local lRet     := .T.
	Local oBody    := JsonObject():New()

	Self:SetContentType("application/json")
	cBody := Self:GetContent()
	cError := oBody:FromJson(cBody)

	If cError == Nil
		aReturn := MrpPStart(oBody)
		HTTPSetStatus(aReturn[1])
		Self:SetResponse(EncodeUtf8(aReturn[2]))
	Else
		//Ocorreu erro ao transformar os dados recebidos em objeto JSON.
		lRet    := .F.
		SetRestFault(400, EncodeUtf8(STR0006), .T., , cError ) //"Nao foi possível interpretar os dados recebidos."
	EndIf

	FreeObj(oBody)
	oBody   := Nil
	aReturn := Nil

Return lRet

/*/{Protheus.doc} MrpPStart
Dispara as acoes da API de Processos do MRP, para o metodo POST START (Reserva MRP).

@type    Function
@author  brunno.costa
@since   31/07/2019
@version P12.1.27
@param 01 -  oBody     , JsonObject, Objeto JSON com as informacoes recebidas no corpo da requisicao.
@param 02 -  cAutomacao, caracter  , indica parâmetro cAutomacao relacionado a execução. 0 - Nenhuma. 1 - Automação CSV, 2 - Automação com Banco
@return aReturn, Array, Array contendo o Codigo HTTP que devera ser retornado pela API, e o JSON formatado com todos os dados de retorno.
                        Array[1] -> Numeric. Codigo HTTP de retorno (201 - Created; 207 - MultiStatus; 400 - Bad Request; 200 - OK)
                        Array[2] -> Character. JSON no formato definido pela API para ser retornado.
/*/
Function MrpPStart(oBody, cAutomacao)
	Local aReturn      := {201, ""}
	Local aUltProc
	Local cChaveLock   := "MrpPStart"
	Local cProxID      := ""
	Local lDisponivel  := .T.
	Local lTransaction := .F.
	Local oBodyX       := JsonObject():New()
	Local oMRPApi      := defMRPApi("POST","") //Instancia da classe MRPApi para o metodo POST
	Local oJsonAux     := JsonObject():New()

	BEGIN TRANSACTION
	If !(travar(cChaveLock))
		LogMsg('MrpProcess', 0, 0, 1, '', '', STR0013) //"Não foi possível obter semáforo de início do processamento."
		lDisponivel := .F.

		oJsonAux["lResult"] := .F.
		oJsonAux["message"] := STR0014 //"Erro ao fazer bloqueio de semáforo."
		oJsonAux["detailedMessage"] := STR0015 //"O limite de tentativas para obtenção do semáforo foi atingido."
		aReturn[1] := 503
		aReturn[2] := oJsonAux:toJson()
	Else
		//Verifica se o MRP está Disponível
		If AllTrim(cAutomacao) != "1"
			aUltProc := UltimoProc()
		EndIf
		If !Empty(aUltProc)
			oJsonAux:fromJson(aUltProc[2])
			If oJsonAux["status"] != Nil .AND. oJsonAux["status"] $ "1,2" .AND. cAutomacao != "2"
				lDisponivel   := .F.
			EndIf
		EndIf

		If !lDisponivel
			aReturn[1] := 503
			oJsonAux["lResult"] := .F.
			aReturn[2] := oJsonAux:toJson()

		Else
			//Verifica próximo ticket
			cProxID    := ProxTicket(cAutomacao)

			//Seta as funcoes de validacao de cada mapeamento.
			oMRPApi:setValidData("fields"            , "MrpVld")
			oMRPApi:setValidData(LISTA_DE_PARAMETROS , "MrpVld")

			//Adiciona os Processos recebidos no corpo da requisicao (BODY)
			oBodyX["items"]                                := Array(1)
			oBodyX["items"][1]                             := oBody
			oBodyX["items"][1]["ticket"                  ] := cProxID
			oBodyX["items"][1]["startDate"               ] := convDate(Date())
			oBodyX["items"][1]["startTime"               ] := Time()
			oBodyX["items"][1]["status"                  ] := "1" //Reservado
			oBodyX["items"][1]["memoryLoadStatus"        ] := "1" //"Pendente"
			oBodyX["items"][1]["statusLevelsStructure"   ] := "1" //"Pendente"
			oBodyX["items"][1]["mrpCalculationStatus"    ] := "1" //"Pendente"
			oBodyX["items"][1]["statusPersistenceResults"] := "1" //"Pendente"
			oMRPApi:setBody(oBodyX)

			//Executa o processamento do POST
			oMRPApi:processar("fields")

			//Recupera o status do processamento
			aReturn[1] := oMRPApi:getStatus()

			//Recupera o JSON com os dados do retorno do processo.
			If AllTrim(cAutomacao) != "1"
				oJsonAux:fromJson(oMRPApi:getRetorno(1))
				If aReturn[1] == 201
					oJsonAux["lResult"]             := .T.
					If ValType(oJsonAux["items"]) == "A"
						oJsonAux["items"][1]["lResult"] := .T.
						aReturn[2] := oJsonAux["items"][1]:toJson()
					EndIf
				Else
					oJsonAux["lResult"] := .F.
					If ValType(oJsonAux["details"]) == "A"
						oJsonAux["message"] := oJsonAux["details"][1]["message"]
						aReturn[2] := oJsonAux:toJson()
					EndIf
				EndIf
			EndIf

		EndIf

		//Destrava controle de anti-paralelismo global
		liberar(cChaveLock)
	EndIf
	lTransaction := .T.
	END TRANSACTION

	If !lTransaction
		aReturn[1] := 503
		oJsonAux["lResult"] := .F.
	EndIf

	//Libera o objeto MRPApi da memoria.
	oMRPApi:Destroy()
	If oBody[LISTA_DE_PARAMETROS] != Nil
		aSize(oBody[LISTA_DE_PARAMETROS], 0)
	EndIf
	If oBodyX["items"] != Nil
		If oBodyX["items"][1][LISTA_DE_PARAMETROS] != Nil
			aSize(oBodyX["items"][1][LISTA_DE_PARAMETROS], 0)
		EndIf
		aSize(oBodyX["items"], 0)
	EndIf
	If oJsonAux["items"] != Nil
		If oJsonAux["items"][1][LISTA_DE_PARAMETROS] != Nil
			aSize(oJsonAux["items"][1][LISTA_DE_PARAMETROS], 0)
		EndIf
		aSize(oJsonAux["items"], 0)
	EndIf
	FreeObj(oBody)
	FreeObj(oBodyX)
	FreeObj(oMRPApi)
	FreeObj(oJsonAux)
	oBody    := Nil
	oBodyX   := Nil
	oMRPApi  := Nil
	oJsonAux := Nil
Return aReturn

/*/{Protheus.doc} POST START /api/pcp/v1/mrpprocess
Inicia a carga de memória do MRP

@type  WSMETHOD
@author lucas.franca
@since 05/02/2020
@version P12.1.27
@return lRet, Logico, Informa se o processo foi executado com sucesso.
/*/
WSMETHOD POST INITLOAD WSSERVICE mrpprocess
	Local aReturn  := {}
	Local cBody    := ""
	Local cError   := ""
	Local lRet     := .T.
	Local oBody    := JsonObject():New()

	Self:SetContentType("application/json")
	cBody := Self:GetContent()
	cError := oBody:FromJson(cBody)

	If cError == Nil
		aReturn := MrpPLoad(oBody)
		HTTPSetStatus(aReturn[1])
		Self:SetResponse(EncodeUtf8(aReturn[2]))
	Else
		//Ocorreu erro ao transformar os dados recebidos em objeto JSON.
		lRet    := .F.
		SetRestFault(400, EncodeUtf8(STR0006), .T., , cError ) //"Nao foi possível interpretar os dados recebidos."
	EndIf

	FreeObj(oBody)
	oBody   := Nil
	aReturn := Nil

Return lRet

/*/{Protheus.doc} MrpPLoad
Dispara as ações para o início da carga dos dados em memória. (POST INITLOAD)

@type    Function
@author  lucas.franca
@since   05/02/2020
@version P12.1.27
@param 01 -  oBody     , JsonObject, Objeto JSON com as informacoes recebidas no corpo da requisicao.
@return aReturn, Array, Array contendo o Codigo HTTP que devera ser retornado pela API, e o JSON formatado com todos os dados de retorno.
                        Array[1] -> Numeric. Codigo HTTP de retorno (201 - Created; 207 - MultiStatus; 400 - Bad Request; 200 - OK)
                        Array[2] -> Character. JSON no formato definido pela API para ser retornado.
/*/
Function MrpPLoad(oBody)
	Local aReturn    := {201, ""}
	Local aUltProc   := {}
	Local cErrorUID  := ""
	Local cUIDPadrao := ""
	Local oPCPError  := Nil
	Local oJsonAux   := JsonObject():New()

	If oBody["ticket"] == Nil .Or. Empty(oBody["ticket"])
		oJsonAux["status"] := .F.
		oJsonAux["message"] := STR0016 //"Ticket não informado."
		oJsonAux["detailedMessage"] := STR0017 //"Para iniciar o processamento, é necessário reservar um ticket previamente."
		aReturn[1] := 400
		aReturn[2] := oJsonAux:ToJson()
	Else
		aUltProc := UltimoProc()
		If !Empty(aUltProc)
			oJsonAux:fromJson(aUltProc[2])
			If oJsonAux["ticket"] != Nil .AND. oJsonAux["ticket"] != oBody["ticket"]
				oJsonAux["status"] := .F.
				oJsonAux["message"] := STR0018 //"Ticket informado não é o último ticket reservado."
				oJsonAux["detailedMessage"] := STR0019 //"Somente o último ticket reservado poderá ser processado."
				aReturn[1] := 400
				aReturn[2] := oJsonAux:ToJson()
			Else
				//Inicia carga em memória das tabelas do MRP
				cUIDPadrao := "PCPA712_MRP_" + oBody["ticket"]
				cErrorUID := Iif(FindFunction("PCPMTERUID"), PCPMTERUID(cUIDPadrao), cUIDPadrao)
				oPCPError := PCPMultiThreadError():New(cErrorUID)
				oPCPError:startJob("MrpProcICM", GetEnvServer(), .F., Nil, Nil, oBody["ticket"], aUltProc[2])
			EndIf
		Else
			oJsonAux["status"] := .F.
			oJsonAux["message"] := STR0020 //"Ticket não reservado."
			oJsonAux["detailedMessage"] := STR0021 //"Para iniciar o processamento, é necessário reservar um ticket previamente."
			aReturn[1] := 400
			aReturn[2] := oJsonAux:ToJson()
		EndIf
	EndIf

	FreeObj(oJsonAux)
Return aReturn

/*/{Protheus.doc} MrpProcICM
Processamento MRP - Inicializa Carga em memória (JOB)

@type  WSCLASS
@author brunno.costa
@since 31/07/2019
@version P12.1.27
@param 01 - cTicket, caracter, ticket a ser utilizado para o próximo ID de processamento
@param 02 - cBody  , caracter, string JSON
/*/
Function MrpProcICM(cTicket, cBody)
	Local oParametros
	Local oBody

	If !Empty(cTicket)
		oBody       := JsonObject():New()
		oBody:fromJson(cBody)
		oParametros := ArrToParam(oBody[LISTA_DE_PARAMETROS])

		//Cria chave de execucao
		oParametros["cChaveExec"]       := "MRP_TICKET_" + cTicket
		oParametros["nOpcCarga"]        := 1 //Apenas Carga Inicial
		oParametros["cSemaforoThreads"] := nomeJobs(cTicket)
		oParametros["ticket"]           := cTicket

		//Leitura parametros de entrada JSON
		oMrpAplicacao := MrpAplicacao():New()
		oMrpAplicacao:parametrosDefault(@oParametros)

		//Inicializa Carga em Memória
		oMrpAplicacao:inicializaCarga(oParametros)

	EndIf

	//Limpa memória
	FreeObj( oMrpAplicacao )
	FreeObj( oParametros )
	FreeObj( oBody )
	oMrpAplicacao := Nil
	oParametros   := Nil
	oBody         := Nil

Return

/*/{Protheus.doc} POST CALCULATE /api/pcp/v1/mrpprocess/calculate
Dispara solicitação de cálculo do MRP

@type  WSMETHOD
@author brunno.costa
@since 31/07/2019
@version P12.1.27
@return lRet, Logico, Informa se o processo foi executado com sucesso.
/*/
WSMETHOD POST CALCULATE WSSERVICE mrpprocess
	Local aReturn  := {}
	Local cBody    := ""
	Local cError   := ""
	Local lRet     := .T.
	Local oBody    := JsonObject():New()

	Self:SetContentType("application/json")
	cBody := Self:GetContent()
	cError := oBody:FromJson(cBody)

	If cError == Nil
		aReturn := MrpPCalcul(oBody)
		HTTPSetStatus(aReturn[1])
		Self:SetResponse(EncodeUtf8(aReturn[2]))
	Else
		//Ocorreu erro ao transformar os dados recebidos em objeto JSON.
		lRet    := .F.
		SetRestFault(400, EncodeUtf8(STR0006), .T., , cError ) //"Nao foi possível interpretar os dados recebidos."
	EndIf

	FreeObj(oBody)
	oBody   := Nil
	aReturn := Nil

Return lRet

/*/{Protheus.doc} MrpPCalcul
Recebe parâmetros, registra e inicia cálculo do MRP

@type    Function
@author  brunno.costa
@since 31/07/2019
@version P12.1.27
@param 01 -  oBody     , JsonObject, Objeto JSON com as informacoes recebidas no corpo da requisicao.
@param 02 -  cAutomacao, caracter  , indica parâmetro cAutomacao relacionado a execução. 0 - Nenhuma. 1 - Automação CSV, 2 - Automação com Banco
@return aReturn, Array, Array contendo o Codigo HTTP que devera ser retornado pela API, e o JSON formatado com todos os dados de retorno.
                        Array[1] -> Numeric. Codigo HTTP de retorno (201 - Created; 207 - MultiStatus; 400 - Bad Request; 200 - OK)
                        Array[2] -> Character. JSON no formato definido pela API para ser retornado.
/*/
Function MrpPCalcul(oBody, cAutomacao)
	Local aReturn      := {201, ""}
	Local aUltProc     := {}
	Local cErrorUID    := ""
	Local cMyKey       := "LOCK"
	Local cMyUID       := "MrpParallel" + cFilAnt
	Local cTicket      := ""
	Local lDisponivel  := .T.
	Local lTransaction := .F.
	Local oBodyX       := Nil
	Local oJsonAux     := JsonObject():New()
	Local oMRPApi      := defMRPApi("POST","") //Instancia da classe MRPApi para o metodo POST
	Local oPCPError    := Nil

	Default cAutomacao := "0"

	BEGIN TRANSACTION
	//Trava controle de anti-paralelismo global
	lRet := VarSetUID(cMyUID, .T.)
	If ( !lRet )
		LogMsg('MrpProcess', 0, 0, 1, '', '', "Erro na criação da sessão [" + cMyUID + "]. Ver log para detalhes.")

	ElseIf VarBeginT( cMyUID, cMyKey )

		//Verifica se o MRP está Disponível
		If AllTrim(cAutomacao) != "1"
			aUltProc := UltimoProc()
			If !Empty(aUltProc)
				oJsonAux:fromJson(aUltProc[2])
				If !aUltProc[1] .Or. (oJsonAux["status"] $ "1,2" .AND. cAutomacao != "2" .AND. oBody["user"] != oJsonAux["user"])
					lDisponivel   := .F.
				Else
					cTicket := oJsonAux["ticket"]
				EndIf
			EndIf
		EndIf

		If !lDisponivel
			oJsonAux:fromJson(aUltProc[2])
			aReturn[1] := aUltProc[3]
			aReturn[2] := oJsonAux:toJson()

		Else
			//Passa parâmetros para início da execução do MRP
			PutGlbValue('THREAD_MASTER_'+cTicket,'0') //Global para identificar que a thread principal do MRP caiu por erro de execução. Utilizada para cancelar o ticket e liberar a memória/threads.
			cErrorUID := Iif(FindFunction("PCPMTERUID"), PCPMTERUID(), "PCPA712_MRP_" + cTicket)
			oPCPError := PCPMultiThreadError():New(cErrorUID)
			oPCPError:startJob("MrpProcExe", GetEnvServer(), .F., cEmpAnt, cFilAnt, oBody:toJson(), cTicket,,,,,,,,,, "PutGlbValue('THREAD_MASTER_"+cTicket+"','1')")

			//Seta as funcoes de validacao de cada mapeamento.
			oMRPApi:setValidData("fields"            , "MrpVld")
			oMRPApi:setValidData(LISTA_DE_PARAMETROS , "MrpVld")

			//Adiciona os Processos recebidos no corpo da requisicao (BODY)
			oBodyX := JsonObject():New()
			oBodyX["items"]    := Array(1)
			oBodyX["items"][1] := oBody
			oMRPApi:setBody(oBodyX)

			//Executa o processamento do POST
			oMRPApi:processar("fields")

			//Recupera o status do processamento
			aReturn[1] := oMRPApi:getStatus()

			//Recupera o JSON com os dados do retorno do processo.
			oJsonAux:fromJson(oMRPApi:getRetorno(1))
			If oJsonAux["items"] == nil .or. oJsonAux["items"][1] == Nil
				aReturn[1]          := 503
				oJsonAux["details"][1]["lResult"] := .F.
				aReturn[2] := oJsonAux["details"][1]:toJson()
			Else
				oJsonAux["items"][1]["lResult"] := .T.
				aReturn[2] := oJsonAux["items"][1]:toJson()
			EndIf

		EndIf

		//Destrava controle de anti-paralelismo global
		VarEndT( cMyUID, cMyKey )
		lRet := VarClean(cMyUID)
		If ( !lRet )
			LogMsg('MrpProcess', 0, 0, 1, '', '', "Erro na deleção dos valores/transações das chaves da sessão [" + cMyUID + "]. Ver log para detalhes.")
		EndIf
	EndIf
	lTransaction := .T.
	END TRANSACTION

	If !lTransaction
		VarEndT( cMyUID, cMyKey )
		aReturn[1] := 503
		oJsonAux["lResult"] := .F.
	EndIf

	//Libera o objeto MRPApi da memoria.
	oMRPApi:Destroy()
	If oBody[LISTA_DE_PARAMETROS] != Nil
		aSize(oBody[LISTA_DE_PARAMETROS], 0)
	EndIf
	If oBodyX != Nil .AND. oBodyX["items"] != Nil
		If oBodyX["items"][1][LISTA_DE_PARAMETROS] != Nil
			aSize(oBodyX["items"][1][LISTA_DE_PARAMETROS], 0)
		EndIf
		aSize(oBodyX["items"], 0)
	EndIf
	If oJsonAux != NIL .AND. oJsonAux["items"] != Nil
		If oJsonAux["items"][1][LISTA_DE_PARAMETROS] != Nil
			aSize(oJsonAux["items"][1][LISTA_DE_PARAMETROS], 0)
		EndIf
		aSize(oJsonAux["items"], 0)
	EndIf
	FreeObj(oBody)
	FreeObj(oBodyX)
	FreeObj(oMRPApi)
	FreeObj(oJsonAux)
	oBody    := Nil
	oBodyX   := Nil
	oMRPApi  := Nil
	oJsonAux := Nil
Return aReturn

/*/{Protheus.doc} MrpProcExe
Inicia o cálculo do MRP (JOB)

@type  WSCLASS
@author brunno.costa
@since 31/07/2019
@version P12.1.27
@param   cBody  , caracter, string de Objeto JSON com as informacoes recebidas no corpo da requisicao.
@param   cTicket, caracter, string de Objeto JSON com as informacoes recebidas no corpo da requisicao.
/*/
Function MrpProcExe(cBody, cTicket)

	Local cErrorUID := ""
	Local oBody
	Local oParametros
	Local oPCPError := Nil

	If !Empty(cBody)
		oBody := JsonObject():New()
		oBody:fromJson(cBody)

		//Converte Array JSON (Formato API) em JSON MRP
		oParametros := ArrToParam(oBody[LISTA_DE_PARAMETROS])

		//Cria chave de execucao
		oParametros["cChaveExec"]       := "MRP_TICKET_" + cTicket
		oParametros["nOpcCarga"]        := 2 //Apenas Carga do Movimento
		oParametros["cSemaforoThreads"] := nomeJobs(cTicket)
		oParametros["ticket"]           := cTicket

		If ExistBlock("P712EXEC")
			cErrorUID := Iif(FindFunction("PCPMTERUID"), PCPMTERUID(), "PCPA712_MRP_" + cTicket)
			oPCPError := PCPMultiThreadError():New(cErrorUID)

			oPCPError:startJob("ExecBlock", GetEnvServer(), .T., oParametros["cEmpAnt"], oParametros["cFilAnt"], "P712EXEC", .F., .F., oParametros["ticket"],,,,,,,,)
		EndIf

		//Inicializa Execução do MRP
		oMrpAplicacao := MrpAplicacao():New()
		oMrpAplicacao:executar(oParametros)

	EndIf

	//Limpa memória
	FreeObj( oMrpAplicacao )
	FreeObj( oParametros )
	oMrpAplicacao := Nil
	oParametros   := Nil

Return

/*/{Protheus.doc} ArrToParam
Converte Array JSON (Formato API) em JSON MRP oParametros

@type  WSCLASS
@author brunno.costa
@since 31/07/2019
@version P12.1.27
@param 01 - aParametros, objeto, objeto json com os parâmetros da API
@return - oParametros, objeto, objeto json com os parâmetros do MRP
/*/
Static Function ArrToParam(aParametros)

	Local nIndex
	Local oParametros := JsonObject():New()
	Local cParametro
	Local cParAux
	Local nTotal      := Len(aParametros)

	//Converte Parametros Recebidos
	For nIndex := 1 to nTotal
		cParametro := aParametros[nIndex]["parameter"]
		cParAux    := AllTrim(cParametro)
		If ValType(aParametros[nIndex]["value"]) == "C"
			aParametros[nIndex]["value"] := AllTrim(aParametros[nIndex]["value"])
		EndIf

		Do Case
			//Parâmetros DATA
			Case cParAux == "mrpStartDate"
				oParametros["dDataIni"]                 := StoD(StrTran(aParametros[nIndex]["value"],'-',''))

			Case cParAux == "demandStartDate"
				oParametros["dInicioDemandas"]          := StoD(StrTran(aParametros[nIndex]["value"],'-',''))

			Case cParAux == "demandEndDate"
				oParametros["dFimDemandas"]             := StoD(StrTran(aParametros[nIndex]["value"],'-',''))

			//Parâmetros NUMÉRICOS
			Case cParAux == "periodType"
				oParametros["nTipoPeriodos"]            := Val(aParametros[nIndex]["value"])

			Case cParAux == "numberOfPeriods"
				oParametros["nPeriodos"]                := Val(aParametros[nIndex]["value"])

			Case cParAux == "leadTime"
				oParametros["nLeadTime"]                := Val(aParametros[nIndex]["value"])

			//Parâmetros LÓGICOS
			Case cParAux == "demandsProcessed"
				oParametros["lDemandsProcessed"]        := aParametros[nIndex]["value"] == "1"

			Case cParAux == "firmHorizon"
				oParametros["lHorizonteFirme"]          := aParametros[nIndex]["value"] == "1"

			Case cParAux == "consignedOut"
				oParametros["lEMTerceiro"]              := aParametros[nIndex]["value"] == "1"

			Case cParAux == "consignedIn"
				oParametros["lDETerceiro"]              := aParametros[nIndex]["value"] == "1"

			Case cParAux == "rejectedQuality"
				oParametros["lSubtraiRejeitosCQ"]       := aParametros[nIndex]["value"] == "1"

			Case cParAux == "blockedLot"
				oParametros["lSubtraiLoteBloqueado"]    := aParametros[nIndex]["value"] == "1"

			Case cParAux == "safetyStock"
				oParametros["lEstoqueSeguranca"]        := aParametros[nIndex]["value"] == "1"

			Case cParAux == "orderPoint"
				oParametros["lPontoPedido"]             := aParametros[nIndex]["value"] == "1"

			Case cParAux == "maxStock"
				oParametros["lEstoqueMaximo"]           := aParametros[nIndex]["value"] == "1"

			Case cParAux == "expiredLot"
				oParametros["lExpiredLot"]              := aParametros[nIndex]["value"] == "1"

			Case cParAux == "packingQuantityFirst"
				oParametros["lPackingQuantityFirst"]    := aParametros[nIndex]["value"] == "1"

			Case cParAux == "productionOrderPerLot"
				oParametros["lProductionOrderPerLot"]   := aParametros[nIndex]["value"] == "1"

			Case cParAux == "purchaseRequestPerLot"
				oParametros["lPurchaseRequestPerLot"]   := aParametros[nIndex]["value"] == "1"

			Case cParAux == "breakByMinimunLot"
				oParametros["lBreakByMinimunLot"]       := aParametros[nIndex]["value"] == "1"

			Case cParAux == "minimunLotAsEconomicLot"
				oParametros["lMinimunLotAsEconomicLot"] := aParametros[nIndex]["value"] == "1"

			Case cParAux == "usesProductIndicator"
				oParametros["lUsesProductIndicator"]     := aParametros[nIndex]["value"] == "1"

			Case cParAux == "usesInProcessLocation"
				oParametros["lUsesInProcessLocation"]   := aParametros[nIndex]["value"] == "1"

			Case cParAux == "inProcessLocation"
				oParametros["cInProcessLocation"]       := aParametros[nIndex]["value"]

			Case cParAux == "usesLaborProduct"
				oParametros["lUsesLaborProduct"]       := aParametros[nIndex]["value"] == "1"

			Case cParAux == "standardTimeUnit"
				oParametros["cStandardTimeUnit"]       := aParametros[nIndex]["value"]

			Case cParAux == "unitOfLaborInTheBOM"
				oParametros["cUnitOfLaborInTheBOM"]     := aParametros[nIndex]["value"]

			Case cParAux == "eventLog"
				oParametros["lEventLog"]                := aParametros[nIndex]["value"] == "1"

			Case "|" + cParAux + "|" $ CAMPOS_LOGICOS
				oParametros[cParAux]                    := aParametros[nIndex]["value"] == "1"

			Case "|" + cParAux + "|" $ CAMPOS_NUMERICOS
				oParametros[cParAux]                    := Val(aParametros[nIndex]["value"])

			//Parâmetros CARACTERES
			Case cParAux == "levelStart"
				oParametros["cLevelStart"]              := aParametros[nIndex]["value"]

			Case cParAux == "levelEnd"
				oParametros["cLevelEnd"]                := aParametros[nIndex]["value"]

			Case cParAux == "demandType"
				oParametros["cDemandType"]              := aParametros[nIndex]["value"]

			Case cParAux == "documentType"
				oParametros["cDocumentType"]            := aParametros[nIndex]["value"]

			Case cParAux == "consolidatePurchaseRequest"   //Aglutina SC
				oParametros["cConsolidatePurchaseRequest"] := aParametros[nIndex]["value"]

			Case cParAux == "consolidateProductionOrder"   //Aglutina OP
				oParametros["cConsolidateProductionOrder"] := aParametros[nIndex]["value"]

			Case cParAux == "productionOrderNumber"        //Incrementa número da OP
				oParametros["cProductionOrderNumber"]   := aParametros[nIndex]["value"]

			Case cParAux == "purchaseRequestNumber"        //Incrementa número da SC
				oParametros["cPurchaseRequestNumber"]   := aParametros[nIndex]["value"]

			Case cParAux == "productionOrderType"          //Tipo do documento
				oParametros["cProductionOrderType"]     := aParametros[nIndex]["value"]

			Case cParAux == "products"
				oParametros["cProducts"]                := aParametros[nIndex]["list"]

			Case cParAux == "productGroups"
				oParametros["cProductGroups"]           := aParametros[nIndex]["list"]

			Case cParAux == "productTypes"
				oParametros["cProductTypes"]            := aParametros[nIndex]["list"]

			Case cParAux == "documents"
				oParametros["cDocuments"]               := aParametros[nIndex]["list"]

			Case cParAux == "warehouses"
				oParametros["cWarehouses"]              := aParametros[nIndex]["list"]

			Case cParAux == "qualityWarehouse"
				oParametros["cQualityWarehouse"]		:= aParametros[nIndex]["list"]

			Case cParAux == "demandCodes"
				oParametros["cDemandCodes"]             := aParametros[nIndex]["list"]

			Case cParAux == "structurePrecision"
				If ValType(aParametros[nIndex]["value"]) == "C"
					oParametros["nStructurePrecision"] := Val(aParametros[nIndex]["value"])
				Else
					oParametros["nStructurePrecision"] := aParametros[nIndex]["value"]
				EndIf

			Case cParAux == "centralizedBranches"
				oParametros["centralizedBranches"]     := aParametros[nIndex]["list"]

			Otherwise
				oParametros[cParametro]           := aParametros[nIndex]["value"]

		EndCase
	Next
Return oParametros

/*/{Protheus.doc} POST CANCEL /api/pcp/v1/mrpprocess/cancel
Cancela a execução atual do MRP

@type  WSMETHOD
@author brunno.costa
@since 31/07/2019
@version P12.1.27
@return lRet, Logico, Informa se o processo foi executado com sucesso.
/*/
WSMETHOD POST CANCEL WSSERVICE mrpprocess
	Local aReturn  := {}
	Local cBody    := ""
	Local cError   := ""
	Local lRet     := .T.
	Local oBody    := JsonObject():New()

	Self:SetContentType("application/json")
	cBody  := Self:GetContent()
	cError := oBody:FromJson(cBody)

	If cError == Nil
		aReturn := MrpPCancel(oBody)
		HTTPSetStatus(aReturn[1])
		Self:SetResponse(EncodeUtf8(aReturn[2]))
	Else
		//Ocorreu erro ao transformar os dados recebidos em objeto JSON.
		lRet    := .F.
		SetRestFault(400, EncodeUtf8(STR0006), .T., , cError ) //"Nao foi possível interpretar os dados recebidos."
	EndIf

	FreeObj(oBody)
	oBody   := Nil
	aReturn := Nil

Return lRet

/*/{Protheus.doc} MrpPCancel
Dispara as acoes da API de Processos do MRP, para o metodo CANCEL (Cancela Execução).

@type  Function
@author brunno.costa
@since 31/07/2019
@version P12.1.27
@param 01 oBody , JsonObject, Objeto JSON com as informacoes recebidas no corpo da requisicao.
@return aReturn, Array, Array contendo o Codigo HTTP que devera ser retornado pela API, e o JSON formatado com todos os dados de retorno.
                        Array[1] -> Numeric. Codigo HTTP de retorno (201 - Created; 207 - MultiStatus; 400 - Bad Request; 200 - OK)
                        Array[2] -> Character. JSON no formato definido pela API para ser retornado.
/*/
Function MrpPCancel(oBody)
	Local aReturn   := {201, ""}
	Local aUltProc
	Local cUser
	Local lResult  := .T.
	Local oBodyX
	Local oMRPApi   := defMRPApi("POST","") //Instancia da classe MRPApi para o metodo DELETE
	Local oJsonAux  := JsonObject():New()

	//Recupera Json do último processamento
	aUltProc := UltimoProc()
	oJsonAux:fromJson(aUltProc[2])

	If !(oJsonAux["status"] $ "3,4,6") //!(Concluído/Cancelado)

		//Identifica usuário que solicitou o cancelamento
		cUser     := oBody["user"]
		If oBody["userCancellation"] != Nil
			cUser := oBody["userCancellation"]
		EndIf

		//Valida se é o mesmo usuário que solicitou o processamento
		If AllTriM(Upper(cUser)) != AllTrim(Upper(oJsonAux["user"]))
			lResult := .F.

		Else
			//Executa na Thread Atual
			MrpProcCan(oJsonAux["ticket"], ArrToParam(oJsonAux[LISTA_DE_PARAMETROS]):toJson())

			//Recupera Json do último processamento - Atualizado com data e hora
			aUltProc := UltimoProc()
			oJsonAux:fromJson(aUltProc[2])
			oJsonAux["userCancellation"] := cUser

		EndIf
	EndIf

	//Adiciona os Processos recebidos no corpo da requisicao (BODY)
	oJsonAux["lResult"] := lResult
	oBodyX := JsonObject():New()
	oBodyX["items"]      := Array(1)
	oBodyX["items"][1]   := oJsonAux
	oMRPApi:setBody(oBodyX)

	//Executa o processamento do POST
	oMRPApi:processar("fields")

	//Recupera o status do processamento
	aReturn[1] := oMRPApi:getStatus()

	//Recupera o JSON com os dados do retorno do processo.
	aReturn[2] := oMRPApi:getRetorno(1)
	oJsonAux:fromJson(aReturn[2])
	aReturn[2] := oJsonAux["items"][1]:toJson()

	//Libera o objeto MRPApi da memoria.
	oMRPApi:Destroy()
	If oBody[LISTA_DE_PARAMETROS] != Nil
		aSize(oBody[LISTA_DE_PARAMETROS], 0)
	EndIf
	If oBodyX["items"] != Nil
		If oBodyX["items"][1][LISTA_DE_PARAMETROS] != Nil
			aSize(oBodyX["items"][1][LISTA_DE_PARAMETROS], 0)
		EndIf
		aSize(oBodyX["items"], 0)
	EndIf
	If oJsonAux["items"] != Nil
		If oJsonAux["items"][1][LISTA_DE_PARAMETROS] != Nil
			aSize(oJsonAux["items"][1][LISTA_DE_PARAMETROS], 0)
		EndIf
		aSize(oJsonAux["items"], 0)
	EndIf
	FreeObj(oJsonAux)
	FreeObj(oMRPApi)
	FreeObj(oBody)
	FreeObj(oBodyX)
	oJsonAux := Nil
	oMRPApi  := Nil
	oBody    := Nil
	oBodyX   := Nil
Return aReturn

/*/{Protheus.doc} MrpProcCan
Processamento MRP - Cancela Execução (JOB)

@type  WSCLASS
@author brunno.costa
@since 31/07/2019
@version P12.1.27
@param 01 cTicket    , caracter, informa o string do ticket relacionado a necessidade de cancelamento
@param 02 cParametros, caracter, string json referente dados parâmetros do MRP
/*/
Function MrpProcCan(cTicket, cParametros)
	Local aParam
	Local oParametros
	Local oMrpAplicacao

	If !Empty(cParametros)
		oParametros := JsonObject():New()
		oParametros:fromJson(cParametros)

		//Cria chave de execucao
		oParametros["cChaveExec"]       := "MRP_TICKET_" + cTicket
		oParametros["cSemaforoThreads"] := nomeJobs(cTicket)
		oParametros["ticket"]           := cTicket

		//Leitura parametros de entrada JSON
		oMrpAplicacao := MrpAplicacao():New()
		oMrpAplicacao:parametrosDefault(@oParametros)

		oMrpAplicacao:cancelaExecucao(oParametros)

	EndIf

	//Limpa memória
	FreeObj( oMrpAplicacao )
	FreeObj( oParametros )
	oMrpAplicacao := Nil
	oParametros   := Nil
	aParam        := Nil

Return

/*/{Protheus.doc} UltimoProc
Retorna array com os dados do último processamento do MRP

@type    Function
@author  brunno.costa
@since   31/07/2019
@version P12.1.27
@return aReturn, Array, Array contendo o Codigo HTTP que devera ser retornado pela API, e o JSON formatado com todos os dados de retorno.
                        Array[1] -> Numeric. Codigo HTTP de retorno (201 - Created; 207 - MultiStatus; 400 - Bad Request; 200 - OK)
                        Array[2] -> Character. JSON no formato definido pela API para ser retornado.
/*/
Static Function UltimoProc()
	Local aReturn   := {}
	Local cAliasQry := GetNextAlias()
	Local oJsonAux  := JsonObject():New()

	BeginSql Alias cAliasQry
		%noparser%
		SELECT HW3_FILIAL, HW3_TICKET
		  FROM %Table:HW3% HW3
				INNER JOIN (SELECT MAX(R_E_C_N_O_) AS RECNO
				              FROM %Table:HW3%
				             WHERE %NotDel%
		                       AND HW3_FILIAL = %Exp:xFilial("HW3")%) MAXREC
				ON HW3.R_E_C_N_O_ = MAXREC.RECNO
	EndSql
	If !(cAliasQry)->(Eof())
		aReturn := MrpGet((cAliasQry)->HW3_FILIAL, (cAliasQry)->HW3_TICKET)
	Else
		aReturn := Array(3)
		aReturn[1] := .F.
		oJsonAux["lResult"] := .F.
		oJsonAux["message"] := STR0012 //Nao existem registros validos.
    	oJsonAux["detailedMessage"] := STR0012 //Nao existem registros validos.
		aReturn[2] := oJsonAux:toJson()
		aReturn[3] := 503
	EndIf

	(cAliasQry)->(DbCloseArea())
Return aReturn

/*/{Protheus.doc} ProxTicket
Retorna próximo ID de Ticket

@type    Function
@author  brunno.costa
@since   31/07/2019
@version P12.1.27
@param 01 -  cAutomacao, caracter  , indica parâmetro cAutomacao relacionado a execução. 0 - Nenhuma. 1 - Automação CSV, 2 - Automação com Banco
@return cProxID, caracter, próximo ID de ticket
/*/
Static Function ProxTicket(cAutomacao)

	Local cAliasQry  := GetNextAlias()
	Local cProxID

	If AllTrim(cAutomacao) == "1"
		cProxID := PadL("1", 6, "0")
	Else
		BeginSql Alias cAliasQry
		%noparser%
		SELECT     MAX(HW3_TICKET) AS HW3_TICKET
		FROM          %Table:HW3%
		WHERE      %NotDel%
		EndSql

		If Empty((cAliasQry)->HW3_TICKET)
			cProxID := PadL("1", GetSx3Cache("HW3_TICKET","X3_TAMANHO"), "0")
		Else
			cProxID := Soma1(PadL((cAliasQry)->HW3_TICKET, GetSx3Cache("HW3_TICKET","X3_TAMANHO"), "0"))
		EndIf
		(cAliasQry)->(DbCloseArea())
	EndIf

Return cProxID

/*/{Protheus.doc} MrpGAll
Dispara as acoes da API de Processos do MRP, para o metodo GET (Consulta) para varias Processos.

@type  Function
@author brunno.costa
@since 31/07/2019
@version P12.1.27
@param aQuery   , Array    , Array com os dados que devem ser filtrados.
                             Exemplo: Array[1]
                                      Array[1][1] = "PRODUCT"
                                      Array[1][2] = "PRODUTO001"
                                      Array[2]
                                      Array[2][1] = "PRODUCTIONORDER"
                                      Array[2][2] = "00000101001"
@param cOrder   , Character, Ordenacao desejada do retorno.
@param nPage    , Numeric  , Pagina dos dados. Se Nao enviado, considera pagina 1.
@param nPageSize, Numeric  , Quantidade de registros retornados por pagina. Se Nao enviado, considera 20 registros por pagina.
@param cFields  , Character, Campos que devem ser retornados. Se Nao enviado, retorna todos os fields que possuem valor.
@return aReturn , Array    , Array com as informacoes da requisicao.
                             aReturn[1] - Logico    - Indica se a requisicao foi processada com sucesso ou Nao.
						     aReturn[2] - Character - JSON com o resultado da requisicao, ou com a mensagem de erro.
						     aReturn[3] - Numeric   - Codigo de erro identificado pelo MRPApi.
/*/
Function MrpGAll(aQuery, cOrder, nPage, nPageSize, cFields)
	Local aReturn := {}

	//Processa o GET
	aReturn := GetLine(.T., aQuery, cOrder, nPage, nPageSize, cFields)
Return aReturn

/*/{Protheus.doc} MrpGet
Funcao para disparar as acoes da API de Processos do MRP, para o metodo GET (Consulta) de um processo especifica.

@type  Function
@author brunno.costa
@since 31/07/2019
@version P12.1.27
@param cBranch , Caracter, Codigo da filial
@param cTicket , Caracter, Codigo único do processo
@param cFields , Caracter, Campos que devem ser retornados.
@return aReturn, Array, Array com as informacoes da requisicao.
                        aReturn[1] - Logico    - Indica se a requisicao foi processada com sucesso ou Nao.
						aReturn[2] - Character - JSON com o resultado da requisicao, ou com a mensagem de erro.
						aReturn[3] - Numeric   - Codigo de erro identificado pelo MRPApi.
/*/
Function MrpGet(cBranch, cTicket, cFields)
	Local aReturn   := {}
	Local aQryParam := {}

	//Adiciona os filtros de filial e produto como QueryParam.
	aAdd(aQryParam, {"BRANCHID", cBranch})
	aAdd(aQryParam, {"TICKET"  , cTicket})

	If !Empty(cFields)
		//Adiciona o FIELDS se for recebido.
		aAdd(aQryParam, {"FIELDS", cFields})
	EndIf

	//Chama a funcao para retornar os dados.
	aReturn := GetLine(.F., aQryParam, Nil, Nil, Nil, cFields)

Return aReturn

/*/{Protheus.doc} MapFields
Gera o array com o MAP dos fields da API e os fields da tabela HW3

@type  Static Function
@author brunno.costa
@since 31/07/2019
@version P12.1.27
@return aFields, Array, Array contendo o MAP dos fields da API e da tabela
/*/
Static Function MapFields(nType)
	Local aFields := {}

/*
	O array de mapeamento do JSON e composto por:
	aArray[1]
	aArray[1][1] = Nome do elemento do JSON que contem a informacao.
	aArray[1][2] = Nome da coluna da tabela correspondente a informacao.
	aArray[1][3] = Tipo de dado no banco de dados.
	aArray[1][4] = Tamanho do campo.
	aArray[1][5] = Decimais do campo, quando e do tipo numerico.
*/

	If nType == 1
		//Estrutura do cabeçalho
			aFields := { ;
						{"branchId"                , "HW3_FILIAL", "C", FWSizeFilial()                        , 0},;
						{"ticket"                  , "HW3_TICKET", "C", GetSx3Cache("HW3_TICKET","X3_TAMANHO"), 0},;
						{"startDate"               , "HW3_DTINIC", "D", GetSx3Cache("HW3_DTINIC","X3_TAMANHO"), 0},;
						{"startTime"               , "HW3_HRINIC", "C", GetSx3Cache("HW3_HRINIC","X3_TAMANHO"), 0},;
						{"endDate"                 , "HW3_DTFIM" , "D", GetSx3Cache("HW3_DTFIM" ,"X3_TAMANHO"), 0},;
						{"endTime"                 , "HW3_HRFIM" , "C", GetSx3Cache("HW3_HRFIM" ,"X3_TAMANHO"), 0},;
						{"status"                  , "HW3_STATUS", "C", GetSx3Cache("HW3_STATUS","X3_TAMANHO"), 0},;
						{"dateEndLoadInitialMemory", "HW3_DTFCMI", "D", GetSx3Cache("HW3_DTFCMI","X3_TAMANHO"), 0},;
						{"endTimeLoadInitialMemory", "HW3_HRFCMI", "C", GetSx3Cache("HW3_HRFCMI","X3_TAMANHO"), 0},;
						{"dateEndLoadMemory"       , "HW3_DTFCMG", "D", GetSx3Cache("HW3_DTFCMG","X3_TAMANHO"), 0},;
						{"endTimeLoadMemory"       , "HW3_HRFCMG", "C", GetSx3Cache("HW3_HRFCMG","X3_TAMANHO"), 0},;
						{"memoryLoadStatus"        , "HW3_STATCM", "C", GetSx3Cache("HW3_STATCM","X3_TAMANHO"), 0},;
						{"statusLevelsStructure"   , "HW3_STATRN", "C", GetSx3Cache("HW3_STATRN","X3_TAMANHO"), 0},;
						{"mrpCalculationStatus"    , "HW3_STATCA", "C", GetSx3Cache("HW3_STATCA","X3_TAMANHO"), 0},;
						{"statusPersistenceResults", "HW3_STATPE", "C", GetSx3Cache("HW3_STATPE","X3_TAMANHO"), 0},;
						{"user"                    , "HW3_USER"  , "C", GetSx3Cache("HW3_USER"  ,"X3_TAMANHO"), 0},;
						{"userCancellation"        , "HW3_USRCAN", "C", GetSx3Cache("HW3_USRCAN","X3_TAMANHO"), 0},;
						{"cancellationDate"        , "HW3_DTCANC", "D", GetSx3Cache("HW3_DTCANC","X3_TAMANHO"), 0},;
						{"cancellationTime"        , "HW3_HRCANC", "C", GetSx3Cache("HW3_HRCANC","X3_TAMANHO"), 0},;
						{"message"                 , "HW3_MSG"   , "C", GetSx3Cache("HW3_MSG"   ,"X3_TAMANHO"), 0};
					}
	ElseIf nType == 2
		//Parâmetros da execução

		aFields := { ;
	            {"parameter"          , "HW1_PARAM" , "C", GetSx3Cache("HW1_PARAM" ,"X3_TAMANHO"), 0},;
	            {"value"              , "HW1_VAL"   , "C", GetSx3Cache("HW1_VAL"   ,"X3_TAMANHO"), 0},;
	            {"list"               , "HW1_LISTA" , "M",                                     8 , 0};
	           }
	EndIf

Return aFields

/*/{Protheus.doc} GetLine
Executa o processamento do metodo GET de acordo com os Processos recebidos.

@type  Static Function
@author brunno.costa
@since 31/07/2019
@version P12.1.27
@param lLista   , Logic    , Indica se devera retornar uma lista de registros (.T.), ou apenas um registro (.F.).
@param aQuery   , Array    , Array com os dados que devem ser filtrados.
                             Exemplo: Array[1]
                                      Array[1][1] = "PRODUCT"
                                      Array[1][2] = "PRODUTO001"
                                      Array[2]
                                      Array[2][1] = "PRODUCTIONORDER"
                                      Array[2][2] = "00000101001"
@param cOrder   , Character, Ordenacao desejada do retorno.
@param nPage    , Numeric  , Pagina dos dados. Se Nao enviado, considera pagina 1.
@param nPageSize, Numeric  , Quantidade de registros retornados por pagina. Se Nao enviado, considera 20 registros por pagina.
@param cFields  , Character, Campos que devem ser retornados. Se Nao enviado, retorna todos os fields que possuem valor.
@return aReturn , Array    , Array com as informacoes da requisicao.
                             aReturn[1] - Logico    - Indica se a requisicao foi processada com sucesso ou Nao.
						     aReturn[2] - Character - JSON com o resultado da requisicao, ou com a mensagem de erro.
						     aReturn[3] - Numeric   - Codigo de erro identificado pelo MRPApi.
/*/
Static Function GetLine(lLista, aQuery, cOrder, nPage, nPageSize, cFields)
	Local aParam
	Local aReturn  := {.T.,"",200}
	Local nInd
	Local oMRPApi  := defMRPApi("GET",cOrder) //Instancia da classe MRPApi para o metodo GET
	Local oJsonAux := JsonObject():New()
	Local oParametros
	Local oMrpAplicacao
	Local cAuxStatus

	//Seta os Processos de paginacao, filtros e campos para retorno
	oMRPApi:setFields(cFields)
	oMRPApi:setPage(nPage)
	oMRPApi:setPageSize(nPageSize)
	oMRPApi:setQueryParams(aQuery)
	oMRPApi:setUmRegistro(!lLista)

	//Executa o processamento
	aReturn[1] := oMRPApi:processar("fields")

	//Retorna o status do processamento
	aReturn[3] := oMRPApi:getStatus()

	If aReturn[1]
		//Se processou com sucesso, recupera o JSON com os dados.
		aReturn[2] := oMRPApi:getRetorno(1)
	Else
		//Ocorreu algum erro no processo. Recupera mensagem de erro.
		aReturn[2] := oMRPApi:getMessage()
	EndIf

	//Avalia o Status do Cálculo do MRP / Carga em Memória
	oJsonAux:fromJson(aReturn[2])
	If !Empty(oJsonAux["ticket"])

		If (oJsonAux["status"] $ "3|4")
			oJsonAux["documentEventLogStatus"] := oJsonAux["status"]
			oJsonAux["rastreiaEntradasStatus"] := oJsonAux["status"]
		Else
			GetGlbVars("PCP_aParam" + oJsonAux["ticket"], @aParam)
			oParametros := JsonObject():New()
			If aParam != Nil
				oParametros:fromJson(aParam[1])
				//Retorna Data para padrão de oParametros
				For nInd := 1 to Len(aParam[3])
					oParametros[aParam[3][nInd]] := StoD(StrTran(oParametros[aParam[3][nInd]], "-", ""))
				Next
			EndIf

			//Cria chave de execucao
			oParametros["cChaveExec"]       := "MRP_TICKET_" + oJsonAux["ticket"]
			oParametros["cSemaforoThreads"] := nomeJobs(oJsonAux["ticket"])
			oParametros["ticket"]           := oJsonAux["ticket"]

			//Retorna % do andamento do cálculo
			oMrpAplicacao                          := MrpAplicacao():New()
			oJsonAux["memoryLoadPercentage"]       := oMrpAplicacao:cargaPercentual(@oParametros)
			oJsonAux["calculationPercentage"]      := oMrpAplicacao:calculoPercentual(@oParametros)

			//Retorna o % do andamento da análise do Log de Eventos
			oJsonAux["documentEventLogPercentage"] := oMrpAplicacao:eventoPercentual(@oParametros, @cAuxStatus)
			oJsonAux["documentEventLogStatus"]     := cAuxStatus

			//Retorna o % do processamento da rastreabilidade de demandas
			oJsonAux["rastreiaEntradasPercentage"] := oMrpAplicacao:rasDemPercentual(@oParametros, @cAuxStatus)
			oJsonAux["rastreiaEntradasStatus"]     := cAuxStatus
		EndIf

		aReturn[2] := oJsonAux:toJson()
	EndIf

	If oParametros <> Nil
		FreeObj(oParametros)
	EndIf
	If oMrpAplicacao <> Nil
		FreeObj(oMrpAplicacao)
	EndIf
	FreeObj(oJsonAux)
	oParametros   := Nil
	oMrpAplicacao := Nil
	oJsonAux      := Nil

	//Libera o objeto MRPApi da memoria.
	oMRPApi:Destroy()
	FreeObj(oMRPApi)
	oMRPApi := Nil
Return aReturn

/*/{Protheus.doc} MrpVld
Funcao responsavel por validar as informacoes recebidas.

@type  Function
@author brunno.costa
@since 31/07/2019
@version P12.1.27
@param oMRPApi   , Object   , Referência da classe MRPApi que esta processando os dados.
@param cMapCode  , Character, Codigo do mapeamento que sera validado
@param oItem     , Object   , Referência do objeto JSON com os dados que devem ser validados.
@return lRet     , Logico   , Identifica se os dados estão validos.
/*/
Function MrpVld(oMRPApi, cMapCode, oItem)
	Local aNoPostFld := {"endDate","endTime","dateEndLoadInitialMemory",;
						"endTimeLoadInitialMemory","dateEndLoadMemory","endTimeLoadMemory",;
						"cancellationDate","cancellationTime"}
	Local cMsg := ""
	Local lRet := .T.
	Local nIndAux
	Local nFields    := Len(aNoPostFld)

	If cMapCode == "fields"
		If Empty(oItem["branchId"])
			lRet := .F.
			oMRPApi:SetError(400, STR0023) // "Filial não informada."
		EndIf

		If lRet .And. Empty(oItem["user"])
			lRet := .F.
			oMRPApi:SetError(400, STR0024) // "Usuário não informado."
		EndIf

		If lRet
			For nIndAux := 1 to nFields
				If oItem[aNoPostFld[nIndAux]] != Nil .and. !Empty(oItem[aNoPostFld[nIndAux]])
					lRet := .F.
					oMRPApi:SetError(400, STR0029 + " '" + aNoPostFld[nIndAux] + "' " + STR0025) // "Parâmetro" " 'X' " "é de utilização interna e não deveria ser informado. Mantenha esta informação sem preenchimento."
					Exit
				EndIf
			Next
		EndIf

	ElseIf cMapCode == LISTA_DE_PARAMETROS
		If lRet .And. Empty(oItem["parameter"])
			lRet := .F.
			cMsg := STR0026 // "Código do parâmetro não foi informado na lista de parâmetros do MRP. Informe corretamente o código do parâmetro para prosseguir com a execução do MRP."

			If !Empty(oItem["value"])
				cMsg += Chr(13)+Chr(10) + STR0027 + oItem["value"] // "Valor: "
			ElseIf !Empty(oItem["list"])
				cMsg +=  Chr(13)+Chr(10) + STR0027 + oItem["list"] // "Valor: "
			EndIf

			oMRPApi:SetError(400, cMsg)
		EndIf

		If lRet .And. Empty(oItem["value"]) .And. Empty(oItem["list"]) .And. !(oItem["parameter"] $ PARAMETROS_ARM)
			lRet := .F.
			oMRPApi:SetError(400, STR0028 + oItem["parameter"] + ".") // "Valor não informado para o parâmetro "
		EndIf

	EndIf
Return lRet

/*/{Protheus.doc} defMRPApi
Faz a instancia da classe MRPAPI e seta as propriedades basicas.

@type  Static Function
@author brunno.costa
@since 31/07/2019
@version P12.1.27
@param cMethod  , Character, Metodo que sera executado (GET/POST/DELETE)
@param cOrder   , Character, Ordenacao para o GET
@return oMRPApi , Object   , Referência da classe MRPApi com as definicoes ja executadas.
/*/
Static Function defMRPApi(cMethod, cOrder)
	Local oMRPApi := MRPApi():New(cMethod)

	//Seta o APIMAP do item principal (cabeçalho)
	oMRPApi:setAPIMap("fields", _aMapExec , "HW3", .F., cOrder)

	//Seta o APIMAP da lista de parametros
	oMRPApi:setAPIMap(LISTA_DE_PARAMETROS , _aMapParam, "HW1", .F., cOrder)

	//Seta os campos utilizados para busca de registros.
	oMRPApi:setKeySearch("fields",{"HW3_FILIAL","HW3_TICKET"})

	//Seta os campos utilizados para busca de registros.
	oMRPApi:setKeySearch(LISTA_DE_PARAMETROS,{"HW1_FILIAL","HW1_TICKET", "HW1_PARAM"})

	//Adiciona o relacionamento entre o cabeçalho e os parametros
	aRelac := {}
	aAdd(aRelac, {"HW3_FILIAL", "HW1_FILIAL"})
	aAdd(aRelac, {"HW3_TICKET", "HW1_TICKET"})
	oMRPApi:setMapRelation("fields", LISTA_DE_PARAMETROS, aRelac, .F.)

Return oMRPApi

/*/{Protheus.doc} convDate
Converte uma data do tipo DATE para o formato string AAAA-MM-DD

@type  Static Function
@author brunno.costa
@since 29/07/2019
@version P12.1.27
@param dData, Date, Data que será convertida
@return cData, Caracter, Data convertida para o formato utilizado na integração.
/*/
Static Function convDate(dData)
	Local cData := ""

	cData := StrZero(Year(dData),4) + "-" + StrZero(Month(dData),2) + "-" + StrZero(Day(dData),2)
Return cData

/*/{Protheus.doc} travar
Faz a trava de um semáforo.

@type  Static Function
@author lucas.franca
@since 04/02/2020
@version P12.1.27
@param cChave, Character, Chave de bloqueio para o semáforo
@return lOk, Logic, Identifica se conseguiu o lock do semáforo
/*/
Static Function travar(cChave)
	Local lOk  := .T.
	Local nTry := 0

	While !LockByName(cChave,.F.,.F.)
		nTry++
		If nTry > 1000
			lOk := .F.
			Exit
		EndIf
		Sleep(500)
	End
Return lOk

/*/{Protheus.doc} liberar
Faz a liberação de um semáforo.

@type  Static Function
@author lucas.franca
@since 04/02/2020
@version P12.1.27
@param cChave, Character, Chave de bloqueio para o semáforo
@return Nil
/*/
Static Function liberar(cChave)

	UnLockByName(cChave,.F.,.F.)
Return Nil

/*/{Protheus.doc} nomeJobs
Retorna o nome utilizado pelo JOB de acordo com o ticket do MRP.

@type  Static Function
@author lucas.franca
@since 13/03/2020
@version P12.1.30
@param cTicket, Character, Ticket do MRP
@return cJobName, Character, Nome utilizado pelo JOB
/*/
Static Function nomeJobs(cTicket)
	Local cJobName := "MRP_T" + Right(cTicket,3) + "_C"
Return cJobName

/*/{Protheus.doc} MrpAddPar
Grava um novo parâmetro na tabela HW1 (HW1_LISTA)

@type  Function
@author lucas.franca
@since 03/02/2022
@version P12
@param 01 cTicket   , Character, Ticket do MRP
@param 02 cCodParam , Character, Código do parâmetro
@param 03 cParamList, Character, Valor do parâmetro (lista)
@param 04 cParamVal , Character, Valor do parâmetro (valor)
@return Nil
/*/
Function MrpAddPar(cTicket, cCodParam, cParamList, cParamVal)

	cCodParam := PadR(cCodParam, GetSX3Cache("HW1_PARAM", "X3_TAMANHO"))

	If !HW1->(dbSeek(xFilial("HW1") + cTicket + cCodParam))
		RecLock("HW1", .T.)
			HW1->HW1_FILIAL := xFilial("HW1")
			HW1->HW1_TICKET := cTicket
			HW1->HW1_PARAM  := cCodParam
			HW1->HW1_VAL    := cParamVal
			HW1->HW1_LISTA  := cParamList
		HW1->(MsUnLock())
	EndIf

Return Nil

//dummy function
Function MrpProcess()
Return
