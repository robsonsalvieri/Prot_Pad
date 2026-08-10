#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWLIBVERSION.CH"
#INCLUDE "FISA318.CH"

#DEFINE CRLF CHR(13) + CHR(10)

#DEFINE PROPERTY 				1
#DEFINE ERROR_CODE 				2
#DEFINE ERROR_MESSAGE 			3
#DEFINE ERROR_DETAILED_MESSAGE 	4

Static oStaticWebChannel := Nil

/*/{Protheus.doc} FISA318
    Função responsável por executar aplicativo POUI do Monitor Tributário;
    Valida se a rotina esta sendo chamada pelo modulo especifico provisionado

    @type  Function
    @author Fábio Mendonça
    @since 14/11/2024
    @version 1.0

    @see https://tdn.totvs.com.br/display/public/framework/FwCallApp
    @see https://tdn.totvs.com/pages/releaseview.action?pageId=555856401
/*/
Function FISA318()
    Local cAppName  as character
    Local lValidMod as logical

    cAppName  := "montrib"

    lValidMod := AmIIn(2 ,;    // Compras
                       5 ,;    // Faturamento
                       9 ,;    // Livros Fiscais
                       84 ;    // TAF
                        )

    MonitorMetrics("Step1") // Qualquer abertura do Monitor Tributário

    If HasMinimumRequirements()
        If !lValidMod
            FWAlertWarning(STR0068) // Esta funcionalidade só pode ser acessada nos seguintes módulos: Compras (02), Faturamento (05), Livros Fiscal (09) ou TAF    (84)
        Else
            FWCallApp(cAppName)
        EndIf
    EndIf
Return

/*/{Protheus.doc} FISA318F1SVGetApiData
    Recupera array de itens conforme endpoint
    
    @type  Static Function
    @author Fábio Mendonça
    @since 30/01/2025
    @version 1.0
    @param oFilterParams, json, Json com Parâmetros de Filtros do ON
    @return aResponseItems, array, Coleção de itens retornados pela API
    
    @see https://tdn.totvs.com/display/public/framework/FWRest
/*/
Function FISA318F1SVGetApiData(oFilterParams as json) as array
    Local cQueryString      as character
    Local aHeader           as array  
    Local aResponseItems    as array
    Local oRestClient       as object
    Local oResponse         as json

    oResponse       := JsonObject():new()
    aResponseItems  := {}

    // Retira queryStrings presentes no endpoint, caso existam (Cards de Tabela enviam query strings por default na requisição devido a implementação p-service-api do po-table)
    If At("?", oFilterParams["endpoint"][1]) > 0 
        oFilterParams["endpoint"][1] := Substr(oFilterParams["endpoint"][1], 1, (At("?", oFilterParams["endpoint"][1])) - 1)
    EndIf
    
    // Gerando conteúdo pro FwRest
    aHeader         := GetHttpHeader(oFilterParams["token"][1])
    cQueryString    := GetQueryStringFromJson(oFilterParams)
    
    oRestClient := FWRest():new(oFilterParams["host"][1])
    oRestClient:setPath(oFilterParams["endpoint"][1])
    
    If oRestClient:get(aHeader, cQueryString)
        oResponse:fromJson(oRestClient:getResult())
        
        If !Empty(oResponse["items"])
            aResponseItems := oResponse["items"]
        EndIf
    Else
        FWLogMsg("INFO",, "BusinessObject",,,, "an error ocurred when retrieving api data: " + oRestClient:getLastError())
        FWLogMsg("INFO",, "BusinessObject",,,,,,, {{"oFilterParams", oFilterParams:toJson()}, {"cQueryString", cQueryString}})
    EndIf  

    FwFreeObj(oRestClient) 
    FwFreeObj(oResponse) 
    FwFreeArray(aHeader)
Return aResponseItems

/*/{Protheus.doc} FISA318F2SVGetParametersByDashboard
    Retorna array com parâmetros conforme tipo do dashboard (Se dashboard de Visão Gerão, IPI, ICMS, etc.)
   
    @type  Function
    @author Fábio Mendonça
    @since 01/03/2025
    @version 1.0
    @param cDashboardName, character, Nome do Dashboard
    @return aSVParams, array, Array com parâmetros conforme tipo do dashboard
    
    @see https://tdn.totvs.com/pages/releaseview.action?pageId=625448935
/*/
Function FISA318F2SVGetParametersByDashboard(cDashboardName as character) as array
    Local aSVParams as array

    Default cDashboardName := ""

    aSVParams   := {}

    // Parâmetros de Filtro
    aAdd(aSVParams, {"branches",    STR0002, "string", .F.}) //"Filiais"
    aAdd(aSVParams, {"periodStart", STR0003, "string", .F.}) //"Período Inicial"
    aAdd(aSVParams, {"periodEnd",   STR0004, "string", .F.}) //"Período Final"

    If cDashboardName == "overview"
        aAdd(aSVParams, {"movimentType",   STR0005, "string", .F.}) //"Tipo de Movimento"
        aAdd(aSVParams, {"taxedMovements", STR0093, "string", .F.}) //"Considera movimentos Tributados ?"
    EndIf

    // Parâmetros Internos necessários para disparar as requisições FwRest a partir do ON SmartView
    aAdd(aSVParams, {"token",   "Chave de Integr.", "string", .F.}) 
    aAdd(aSVParams, {"endpoint","Endpoint", "string", .F.}) 
    aAdd(aSVParams, {"host",    "Host", "string", .F.})     
Return aSVParams

/*/{Protheus.doc} FISA318F3SendInfoToExtractionProgressBar
    Envia ao aplicativo informações sobre o progresso das tarefas, via websocket
    
    @author Fábio Mendonça
    @since 26/02/2025
    @version 1.0
    @param cMessage, character, Descrição da etapa corrente
    @param lStatus, logical, Indicativo de sucesso ou não da etapa corrente
    @param nProgress, numeric, progresso geral atual do momento da chamada dessa função numa escala de 0 a 100
    @param lFinished, logical, Indicativo de finalização de envio de informações

    @see https://tdn.totvs.com/display/tec/TWebEngine
    @see https://tdn.totvs.com/display/tec/TWebChannel
/*/
Function FISA318F3SendInfoToExtractionProgressBar(cMessage as character, lStatus as logical, nProgress as numeric, lFinished as logical)
    Local oJsonProgress as object

    Default lFinished   := .F.

    If !FwIsInCallStack("FISA318")
        Return
    EndIf 

    oJsonProgress                       := JsonObject():new()
    oJsonProgress["stage"]              := JsonObject():new()
    oJsonProgress["stage"]["message"]   := cMessage
    oJsonProgress["stage"]["status"]    := lStatus
    oJsonProgress["totalProgress"]      := nProgress
    oJsonProgress["finished"]           := lFinished
    SendAdvplToJs("onboarding-extraction", oJsonProgress:toJson())

    FwFreeObj(oJsonProgress)
Return

/*/{Protheus.doc} FISA318F4GetDisplayNameComplement
    Obtém o carimbo de data e hora usado como complemento do Nome de Exibição do Objeto de Negócio
    
    @author Fábio Mendonça
    @since 29/03/2025
    @version 1.0
    @return  , character, Carimbo de data e hora formatado
/*/
Function FISA318F4GetDisplayNameComplement()
Return StrTran(DToC(Date()), "/", "-") + "_" + StrTran(Time(), ":", "-")

/*/{Protheus.doc} FISA318F5GetBearerToken
    Recupera token de acesso para autenticar API's Rest no Protheus
    
    @author Fábio Mendonça
    @since 04/04/2025
    @version 1.0
    @param oFilterParams, json, Json com Parâmetros de Filtros do ON
    @param cUserName, character, Usuário do sistema
    @param cPassword, character, Senha do Usuário sistema
    @return aResponseItems, array, Coleção de itens retornados pela API
    
    @see https://tdn.totvs.com/display/public/framework/FWRest
    @see https://tdn.totvs.com/pages/releaseview.action?pageId=465383509
/*/
Function FISA318F5GetBearerToken(cHost as character, cUserName as character, cPassword as character) as character
    Local cEndpoint         := "/api/oauth2/v1/token?grant_type=password"
    Local cToken            := ""
    Local aHeader           := {} 
    Local oRestClient       := FWRest():new(cHost)
    Local oResponse         := JsonObject():new()  

    Default cUserName   := "admin"
    Default cPassword   := "1234"

    aAdd(aHeader, "Accept: application/json")
    aAdd(aHeader, "username: " + cUserName)
    aAdd(aHeader, "password: " + cPassword)

    oRestClient:setPath(cEndpoint)
    
    If oRestClient:post(aHeader)
        oResponse:fromJson(oRestClient:getResult())
        cToken := oResponse["access_token"]
    Else
        FWLogMsg("INFO",, "BusinessObject",,,, "an error ocurred when retrieving bearer token: " + oRestClient:getLastError())
        FWLogMsg("INFO",, "BusinessObject",,,,,,, {{"cUserName", cUserName}, {"cPassword", cPassword}, {"cHost", cHost}})
    EndIf  

    FwFreeArray(aHeader)
    FwFreeObj(oRestClient) 
    FwFreeObj(oResponse) 
Return cToken

/*/{Protheus.doc} FISA318F6HasApiRequiredProperties
	Verifica se tem parâmetros obrigatórios na requisição da API
	
	@type  Static Function
	@author Fábio Mendonça
	@since 06/05/2025
	@version 1.0
    @param aReqProperties, array, Array bidimensional com query strings que se deseja verificar se existem na requisição
        [                               --> Array com array(s) de propriedade(s) a verificar na requisição
            [                           --> Array com propriedade a ser verificada e código http, mensagem e mensagem detalhada de erro caso a  propriedade não exista na requisição
                PROPERTY,               --> Propriedade que se deseja verificar existência entre os query strings da requisição
                ERROR_CODE,             --> (Opcional, Default 400) Código de erro que se deseja exibir na propriedade "code" da resposta de erro HTTP
                ERROR_MESSAGE,          --> (Opcional, Default STR0074 com propriedade pesquisada) Texto que se deseja exibir na propriedade "message" da resposta de erro HTTP
                ERROR_DETAILED_MESSAGE  --> (Opcional, Default "") Texto se deseja exibir na propriedade "detailedMessage" da resposta de erro HTTP
            ]
        ]
	@param oReqProperties, json, Json com parâmetros da requisição
	@param oResponse, json, (Referência) Json de com feedback de que falta parâmetro obrigatório na requisição
    @param nHttpErrorCode, numeric, Permite informar Código de Erro HTTP customizado a ser enviado no corpo do response
	@return lHasRequiredProperties, logical, Sinaliza se a requisição tem as propriedades obrigatórias

	@see https://tdn.totvs.com/pages/releaseview.action?pageId=484701395
    @see https://tdn.totvs.com/display/tec/4+-+Entendendo+o+objeto+oREST
/*/
Function FISA318F6HasApiRequiredProperties(aReqProperties as array, oReqProperties as json, oResponse as json, nHttpErrorCode as numeric) as logical
	Local lHasReqProperties	as logical
    Local lSendResponse     as logical
	Local nI				as numeric
    Local nCode             as numeric
	Local cMessage			as character
	Local cDftMessage		as character
	Local cDtldMessage		as character
	Local cNameProperty		as character
	Local aProperty			as array

	Default	nHttpErrorCode  := 400
	Default oReqProperties	:= JsonObject():New()

	lHasReqProperties	:= .T.
	cDftMessage			:= STR0074 //"O parâmetro 'XXX' é obrigatório e não foi informado."
    lSendResponse       := IIf(oResponse == Nil, .T., .F.)

	For nI := 1 to Len(aReqProperties)
		aProperty		:= aReqProperties[nI]
		cNameProperty	:= aProperty[PROPERTY]

		If oReqProperties[cNameProperty] == Nil
            nCode           := IIf(Len(aProperty) >= 2, aProperty[ERROR_CODE], nHttpErrorCode)
			cMessage		:= IIf(Len(aProperty) >= 3, aProperty[ERROR_MESSAGE], "")
			cDtldMessage	:= IIf(Len(aProperty) >= 4, aProperty[ERROR_DETAILED_MESSAGE], "")

            oResponse                       := JsonObject():New()
			oResponse["code"]				:= nCode
			oResponse["message"]			:= IIf(Empty(cMessage), StrTran(cDftMessage, "XXX", cNameProperty),	cMessage)
			oResponse["detailedMessage"]	:= IIf(Empty(cDtldMessage), "", cDtldMessage)
            
            oRest:setStatusCode(nHttpErrorCode)

            If lSendResponse
                oRest:setKeyHeaderResponse('Content-Type', 'application/json')
                oRest:setResponse(oResponse)
            EndIf

			lHasReqProperties := .F.

			Exit
		EndIf
	Next

	FwFreeArray(aProperty)
Return lHasReqProperties

/*/{Protheus.doc} FISA318F7OnboardProfile
    Manipulação do Profile para fins de controle de exibição de onboarding

    @type  Function
    @author Fábio Mendonça
    @since 09/03/2025
    @version 1.0
    @param nOper, numeric, Operação Desejada, sendo:
                            1 = GRAVAÇÃO
                            2 = LEITURA
                            3 = ATUALIZAÇÃO (DE PROPRIEDADES EM PROFILE EXISTENTE)
                                3.1 = Se propriedade não existir no Profile, INCLUI
                                3.2 = Se propriedade existir no Profile, ATUALIZA VALOR DA PROPRIEDADE EXISTENTE
           oJsonContent, JsonObject, Conteúdo do Profile conforme operação desejada:
                            1 - GRAVAÇÃO    => Envio de propriedades adicionais para se gravar no Profile (Datas De-Até da Extração, etc.)
                            2 - LEITURA     => [POR REFERÊNCIA] Retornará conteúdo do profile salvo na base
                            3 - ATUALIZAÇÃO => Json com propriedades e respectivos valores a serem atualizados/incluídos
    @return lSuccess, logical, Feedback se operação desejada foi realizada com sucesso

    @see https://tdn.totvs.com/display/public/framework/FWProfile
/*/
Function FISA318F7OnboardProfile(nOper as numeric, oJsonContent as json) as logical
    Local lSuccess      as logical
    Local cContent      as character
    Local oProfile      as object
    Local oJsonProfile  as json

    Default nOper           := 1
    Default oJsonContent    := JsonObject():new()

    lSuccess    := .F.

    oProfile    := FwProfile():new()
    oProfile:SetCompany(cEmpAnt)
    oProfile:SetBranch("")
    oProfile:setUser("000000") //Grava carimbo de passagem pelo onboarding no usuário admin (onboarding será exibido apenas pro primeiro cliente da companhia)
    oProfile:setProgram("FISA318")
    oProfile:setTask("TAX-MONITOR")
    oProfile:setType("ONBOARDING")

    Do Case
        Case nOper == 1
            oJsonProfile                            := JsonObject():new()
            // Propriedades de controle
            oJsonProfile["firstExecutionDate"]      := DateTimeUTC()
            oJsonProfile["firstExecutionUser"]      := __cUserID
            oJsonProfile["montribVersion"]          := oJsonContent["montribVersion"]
            // Propriedades adicionais
            oJsonProfile["extractionStartPeriod"]   := oJsonContent["startPeriod"]
            oJsonProfile["extractionEndPeriod"]     := oJsonContent["endPeriod"]

            oProfile:setStringProfile(oJsonProfile:toJson())
            oProfile:save(.T.)
            lSuccess    := .T.
            
        Case nOper == 2
            oProfile:loadStrProfile(.T.)
            cContent    := oProfile:getStringProfile()    
            oJsonContent:fromJson(cContent)
            lSuccess    := .T.

        Case nOper == 3
            oJsonProfile    := JsonObject():new()

            If FISA318F7OnboardProfile(2, @oJsonProfile) // Carrega dados do profile já existente  
                // Obtém Array de propriedades a atualizar
                // Se não existir, inclui propriedade; se existir, atualiza valor da propriedade
                aEval(oJsonContent:getNames(), {|property| oJsonProfile[property] := oJsonContent[property]})
                oProfile:setStringProfile(oJsonProfile:toJson())
                oProfile:save(.T.)
                lSuccess    := .T.
            EndIf          

    EndCase

    FwFreeObj(oProfile) 
    FwFreeObj(oJsonProfile)   
Return lSuccess

/*/{Protheus.doc} HasMinimumRequirements
    Verifica se possui os requisitos mínimos necessários para executar o TOTVS Inteligência Tributária
    
    @type  Static Function
    @author Fábio Mendonça
    @since 08/03/2025
    @version 1.0
    @return lHasMininumRequirements, logical, Indica se possui os requisitos mínimos necessários

    @see https://tdn.totvs.com/display/public/framework/FwLibVersion
    @see https://tdn.totvs.com/pages/releaseview.action?pageId=908346692
/*/
Static Function HasMinimumRequirements()
    Local lHasMininumRequirements  as logical
    Local cMinLib                  as character
    Local oProfileUpd              := JsonObject():New() as json
    Local oProfile                 := JsonObject():New() as json

    FISA318F7OnboardProfile(2, @oProfile)
    lHasMininumRequirements := .T.
    cMinLib                 := "20250224" //Release mínima para ter a classe totvs.framework.schedule.information

    If !(FindFunction("FIS319CriaTab") .Or. FindFunction("FIS319Extrator"))
        FWAlertError(CRLF + CRLF + STR0046, STR0047) //#"Pacote de Fontes desatualizado" ##"FONTES INTELIGÊNCIA TRIBUTÁRIA DESATUALIZADOS"
        lHasMininumRequirements := .F.
    EndIf

    If FwLibVersion() < cMinLib
        FWAlertError(CRLF + CRLF + STR0039 + cMinLib, STR0041) //#"Lib Mínima necessária: " ##"LIB MÍNIMA NÃO ATENDIDA"
        lHasMininumRequirements := .F.
    EndIf

    If !(FindFunction("FIS319CriaTab") .Or. FindFunction("FIS319Extrator"))
        FWAlertError(CRLF + CRLF + STR0046, STR0047) //#"Pacote de Fontes desatualizado" ##"FONTES INTELIGÊNCIA TRIBUTÁRIA DESATUALIZADOS"
        lHasMininumRequirements := .F.
    EndIf

    If !(ValidLSTIT())
        FWAlertWarning(STR0067) //#"Prezado Cliente, esta funcionalidade é uma oferta e para adquirir, por favor, entre em contato com seu Executivo de Soluções e Negócios."
        lHasMininumRequirements := .F.
    EndIf

    If oProfile:hasProperty("firstExecutionDate") .and. !vldTbPrf()
        If (MsgYesNo(STR0091,STR0092)) //"Foi identificado que seu ambiente não tem as tabelas necessárias para continuar a abertura    da rotina. Para prosseguir com a abertura da rotina, é necessário atualizar o modelo de dados. Deseja realizar esta    atualização?" #Requisitos necessários
            oProfileUpd["montribVersion"] := "recreate"
            FISA318F7OnboardProfile(3, oProfileUpd)
        Else
            lHasMininumRequirements := .F.
        EndIf
    EndIf

    FwFreeObj(oProfileUpd)
    FwFreeObj(oProfile)
Return lHasMininumRequirements

/*/{Protheus.doc} JsToAdvpl
    Recepciona comandos do aplicativo POUI do Monitor Tributário

    @type   Static Function
    @author Fábio Mendonça
    @since 03/01/2025
    @version 1.0
    @param oWebChannel, Object, Objeto TWebEngine
    @param cType, character, Código da ação desejada
    @param cContent, character, String Json com conteúdo da ação
/*/
Static Function JsToAdvpl(oWebChannel as object, cType as character, cContent as character)
    Default cContent := ""

    oStaticWebChannel := oWebChannel
    
    Do Case
        Case cType == "openInSV"
            OpenSV(cContent)
        Case cType == "onboarding"
            Onboarding(cContent)
        Case cType == "scheduler"
            Scheduler(cContent)
        Case cType == "taxMonitor"
            MonitorMetrics("Step4") // Uso diário do Monitor
            SendProfileInfoViaWebsocket("taxMonitor-profile")
    EndCase
Return

/*/{Protheus.doc} Scheduler
    Recebe requisições disparadas pelo componente de Scheduler

    @type  Static Function
    @author Fábio Mendonça
    @since 19/05/2025
    @version 1.0
    @param cJson, character, String JSON 
/*/
Static Function Scheduler(cJson as character)
    Local cStep             as character
    Local oSchedulerRequest as object

    oSchedulerRequest   := JsonObject():new()
    oSchedulerRequest:fromJson(cJson)

    cStep   := oSchedulerRequest["step"]

    Do Case
        Case cStep == "diagnostic"
            SchdlSendDiagnosticInfo()        
    EndCase

    FwFreeObj(oSchedulerRequest)
Return

/*/{Protheus.doc} SchdlSendDiagnosticInfo
    Obtém diagnóstico de requisitos de manutenção da interface do scheduler pelo usuário logado 

    @type  Static Function
    @author Fábio Mendonça
    @since 22/05/2025
    @version 1.0

    @see https://tdn.totvs.com/pages/releaseview.action?pageId=908346692
/*/
Static Function SchdlSendDiagnosticInfo()
    Local oResponse := JsonObject():new()   as json
    Local oScheduleInfo                     as object
    
    oScheduleInfo   := totvs.framework.schedule.information.ScheduleInformation():New()

    oResponse["hasAccess"]                  := __cUserID == "000000" // Verificação se usuário logado tem permissão de acesso
    oResponse["hasSmartSchedule"]           := oScheduleInfo:getSmartScheduleIsRunning() // Verificação se Smart Schedule está rodando no ambiente corrente
    oResponse["smartScheduleEnvironments"]  := oScheduleInfo:getEnvironmentsScheduleRunning(2) // Retorna quais ambientes tem Smart Schedule rodando

    SendAdvplToJs("scheduler-diagnostic", oResponse:toJson())

    FwFreeObj(oResponse)
    FwFreeObj(oScheduleInfo)
Return

/*/{Protheus.doc} SendAdvplToJs
    Adapter da TWebChannel:advplToJs para Logar no App Server as mensagens enviadas para o aplicativo POUI
    
    @type  Static Function
    @author Fábio Mendonça
    @since 17/05/2025
    @version 1.0
    @param cCodeType, character, Indica o tipo de mensagem que será enviada à página HTML
    @param cContent, character, Indica o conteudo que será enviado à pagina HTML.
  
    @see https://tdn.totvs.com/display/tec/TWebChannel%3AadvplToJs
    @see https://tdn.totvs.com/display/public/framework/FWLogMsg
/*/
Static Function SendAdvplToJs(cCodeType as character, cContent as character)
    oStaticWebChannel:advplToJs(cCodeType, cContent)

    FWLogMsg("DEBUG",, "BusinessObject",,,,,,, {{"cCodeType", cCodeType}, {"cContent", cContent}})
Return

/*/{Protheus.doc} OpenSV
    Executa objeto de negócio smart view conforme parâmetros informados

    @type  Static Function
    @author Fábio Mendonça
    @since 04/01/2025
    @version 1.0
    @param cJson, character, String JSON

    @see https://tdn.totvs.com/pages/releaseview.action?pageId=821179480
    @see https://tdn.totvs.com/pages/viewpage.action?pageId=772806491 (Quando issue TREPORTS-9960 for resolvida, voltar parâmetros de Data De/Até para tipo date e utilizar esse link para implementar a conversão de data)
/*/
Static Function OpenSV(cJson as character)
    Local cEndpoint     as character
    Local cHost         as character
    Local cToken        as character
    Local cSVLayout     as character
    Local aParams       as array
    Local oDashData     as object

    MonitorMetrics("Step5") // Uso do Smartview

    If !totvs.framework.smartview.util.isConfig()
        SendSVFinished(.T.)
        Return FWAlertError(STR0001) //"Smart View não configurado"
    EndIf

    oDashData   := JsonObject():new()
    oDashData:fromJson(cJson)

    // Coleta de parâmetros enviados pelo app
    cSVLayout   := oDashData["svLayoutId"]
    cHost       := oDashData["host"]
    cToken      := oDashData["token"]
    cEndpoint   := oDashData["endpoint"]

    // Coleta de nomes de parâmetros de negóçio enviados pelo app
    aParams     := oDashData["params"]:getNames()

    oSmartView := totvs.framework.smartview.callSmartView():new(cSVLayout, "data-grid") 

    // Set de parâmetros e execução do leiaute smartview solicitado pelo app
    aEval(aParams, {|paramName| oSmartView:setParam(paramName, oDashData["params"][paramName], "Disabled") })        

    // Set de Parâmetros Internos necessários para disparar as requisições FwRest a partir do ON SmartView
    oSmartView:setParam("host", cHost, "Disabled")
    oSmartView:setParam("endpoint", cEndpoint, "Disabled")
    oSmartView:setParam("token", cToken, "Disabled")

    oSmartView:setForceParams(.T.)
    oSmartView:executeSmartView()

    SendSVFinished(.T.)
    
    oSmartView:destroy()
    FwFreeArray(aParams)
    FwFreeObj(oSmartView)
    FwFreeObj(oDashData)
Return

/*/{Protheus.doc} Onboarding
    Recebe requisições disparadas pelo componente de Onboarding

    @type  Static Function
    @author Fábio Mendonça
    @since 21/02/2025
    @version 1.0
    @param cJson, character, String JSON 
/*/
Static Function Onboarding(cJson as character)
    Local cStep                 as character
    Local oOnBoardingRequest    as object

    oOnBoardingRequest   := JsonObject():new()
    oOnBoardingRequest:fromJson(cJson)

    cStep       := oOnBoardingRequest["step"]

    MonitorMetrics("Step2") // Início de jornada de Onboarding

    Do Case
        Case cStep == "diagnostic"
            SendDiagnosticInfo()
        Case cStep == "creation"
            CallCreationStep()
        Case cStep == "extraction"
            CallExtractionStep(;
                oOnBoardingRequest["extractionParams"]["start"],;
                oOnBoardingRequest["extractionParams"]["end"],;
                oOnBoardingRequest["extractionParams"]["montribVersion"];
            )
        Case cStep == "profile"
            SendProfileInfoViaWebsocket("onboarding-profile")
        
    EndCase

    FwFreeObj(oOnBoardingRequest)
Return

/*/{Protheus.doc} SendProfileInfoViaWebsocket
    Retorna Profile com informações de onboarding do usuário (caso já tenha sido submetido ao onboarding)
    
    @type  Static Function
    @author Fábio Mendonça
    @since 10/03/2025
    @version 1.0
    @param cResponseIdWebSocket, character, ID de resposta esperado pelo aplicativo

    @see https://tdn.totvs.com/pages/releaseview.action?pageId=908346692
/*/
Static Function SendProfileInfoViaWebsocket(cResponseIdWebSocket as character)
    Local nLastScheduleID                       as numeric
    Local aScheduleIDs                          as array
    Local oJsonProfile := JsonObject():new()    as object
    Local oScheduleInfo                         as object

    // Coleta de Schedule 
    FISA318F7OnboardProfile(2, @oJsonProfile)

    // Adição de ID do TIT Schedule mais recente às informações do cache de profile do aplicatvo POUI
    oScheduleInfo   := totvs.framework.schedule.information.ScheduleInformation():New()
    aScheduleIDs    := ASort(totvs.framework.schedule.utils.getSchedsByRotine("FISA319B"))
    nLastScheduleID := Len(aScheduleIDs)
    If nLastScheduleID > 0
        oJsonProfile["idSchedule"]  := aScheduleIDs[nLastScheduleID]
    EndIf

    SendAdvplToJs(cResponseIdWebSocket, oJsonProfile:toJson())

    FwFreeObj(oJsonProfile)
    FwFreeObj(oScheduleInfo)
    FwFreeArray(aScheduleIDs)
Return

/*/{Protheus.doc} CallExtractionStep
    Executa rotina de extração de indicadores dos metadados do TOTVS Inteligência Tributária e retorna pro aplicativo se teve êxito ou não

    @type  Static Function
    @author Fábio Mendonça
    @since 26/02/2025
    @version 1.0
    @param cStartPeriod, character, Data Inicial a ser realizada extração de indicadores para tabelas fato, no formato padrão de API's (aaaa-mm-dd)
    @param cEndPeriod, character, Data Final a ser realizada extração de indicadores para tabelas fato, no formato padrão de API's (aaaa-mm-dd)
    @param cMontribVersion, character, Versão do montrib.app em que a extração está sendo executada

    @see https://tdn.totvs.com/pages/releaseview.action?pageId=484701395
/*/
Static Function CallExtractionStep(cStartPeriod as character, cEndPeriod as character, cMontribVersion as character)
    Local oJson      as json
    Local lProfileOk as logical
    
    If FIS319Extrator(cStartPeriod, cEndPeriod)
        //Gravando informação de período de execução da primeira extração
        oJson                   := JsonObject():new()
        oJson["startPeriod"]    := cStartPeriod
        oJson["endPeriod"]      := cEndPeriod
        oJson["montribVersion"] := cMontribVersion

        lProfileOk := FISA318F7OnboardProfile(1, oJson)

        If lProfileOk
            MonitorMetrics("Step3") // Finalização com sucesso de Jornada de Onboarding
        EndIf
        
        //Envia último log da etapa de extração pro aplicativo
        FISA318F3SendInfoToExtractionProgressBar(STR0045, lProfileOk, 100, .T.) //"Gravadas informações no FwProfile"

        FwFreeObj(oJson)
    EndIf
Return

/*/{Protheus.doc} CallCreationStep
    Executa rotina de criação dos metadados do TOTVS Inteligência Tributária e retorna pro aplicativo se teve êxito ou não

    @type  Static Function
    @author Fábio Mendonça
    @since 26/02/2025
    @version 1.0
/*/
Static Function CallCreationStep()
    Local oResponse as object

    oResponse               := JsonObject():new()
    oResponse["success"]    := FIS319CriaTab()

    SendAdvplToJs("onboarding-creation", oResponse:toJson())

    FwFreeObj(oResponse)
Return

/*/{Protheus.doc} SendDiagnosticInfo
    Obtém diagnóstico dos requisitos mínimos para abrir o app do Monitor Tributário

    @type  Static Function
    @author Fábio Mendonça
    @since 25/02/2025
    @version 1.0
/*/
Static Function SendDiagnosticInfo()
    Local oJsonResponse as object
    Local lUpdated      as logical

    // Verificação de Fontes
    lUpdated := FindFunction("FIS319CriaTab") .And. FindFunction("FIS319Extrator")

    oJsonResponse                       := JsonObject():new()
    oJsonResponse["updatedSources"]     := lUpdated
    oJsonResponse["duplicationInSF3"]   := FIS319TITGetDuplicateSF3()
    SendAdvplToJs("onboarding-diagnostic", oJsonResponse:toJson())

    FwFreeObj(oJsonResponse)
Return

/*/{Protheus.doc} SendSVFinished
    Sinaliza para o aplicativo POUI que a integração com o SmartView foi finalizada

    @type  Static Function
    @author Fábio Mendonça
    @since 26/02/2025
    @version 1.0
    @param lResponse, logical, Retorno de Finalização do SmartView
/*/
Static Function SendSVFinished(lResponse as logical)
    Local oResponse as object

    Default lResponse := .T.

    oResponse               := JsonObject():new()
    oResponse["finished"]   := lResponse

    SendAdvplToJs("openInSV", oResponse:toJson())

    FwFreeObj(oResponse)
Return

/*/{Protheus.doc} GetQueryStringFromJson
    Gera uma string no formato Query String Component conforme json que contém parâmetros do ON
    
    @type  Static Function
    @author Fábio Mendonça
    @since 01/03/2025
    @version 1.0
   @param oSvParams, json, Json com Parâmetros de Filtros do ON
    @return cQueryString, character, query string no formato Query String Component
    
    @see https://tdn.totvs.com/pages/releaseview.action?pageId=625448935
/*/
Static Function GetQueryStringFromJson(oSvParams as json) as character
    Local cQueryString      as character
    Local aControlFields    as array
    Local aParams           as array
    Local oFilterParams     as json

    // Cópia de objeto para manipulação futura
    oFilterParams   := JsonObject():new()
    oFilterParams:fromJson(oSvParams:toJson())

    // Tratamento de encode url
    oFilterParams["branches"][1]    := StrTran(oFilterParams["branches"][1], " ", "%20")

    // Exclusão de propriedades de controle
    aControlFields  := {"token", "endpoint", "host"}
    aEval(aControlFields, {|property| oFilterParams:delName(property) })

    // Construção da query string
    aParams         := oFilterParams:getNames()
    cQueryString    := ""
    aEval(aParams, {|paramName| cQueryString += (paramName + "=" + oFilterParams[paramName][1] + "&") })
    cQueryString    += "page=1&pageSize=9999999"

    FwFreeObj(oFilterParams)
    FwFreeArray(aParams)
Return cQueryString

/*/{Protheus.doc} GetHttpHeader
    Gera cabeçalhos HTTP para ser usado no disparo de requisições via FwRest
    
    @type  Static Function
    @author Fábio Mendonça
    @since 01/03/2025
    @version 1.0
    @param cToken, character, Bearer Token que será incluso no cabeçalho HTTP
    @return aHeader, array, array de cabeçalhos HTTP
    
    @see https://tdn.totvs.com/display/public/framework/FWRest
/*/
Static Function GetHttpHeader(cToken as character) as array
    Local aHeader   as array

    aHeader := {}

    Aadd(aHeader, "Authorization: Bearer " + cToken)
    Aadd(aHeader, "Content-Type: application/json; charset=UTF-8")
    Aadd(aHeader, "Accept: */*")
    Aadd(aHeader, "User-Agent: Chrome/65.0 (compatible; Protheus " + GetBuild() + ")")
Return aHeader

/*/{Protheus.doc} MonitorMetrics
	Envia para LS do cliente métricas de uso do Monitor Tributário
	
	@type  Static Function
	@author Fabio Mendonça
	@since 17/03/2025
	@version 1.0
	@param cComplement, character, Complemento opcional para identificação da Métrica
/*/
//----------------------------------------------------------------------
Static Function MonitorMetrics(cComplement as character)
	Local cMetricName as character
	Local cIdLog	  as character
	Local cUserId     as character
	Local cModule 	  as character

	Default cComplement := ""

	cIdLog      := "LS006"
	cModule     := "09"
	cMetricName := "FISMonTrib" + cComplement
	cUserId     := IIf(Empty(__cUserID), "000000", __cUserID)

	If FindFunction("FWLSPutAsyncInfo")
		FWLSPutAsyncInfo(cIdLog, cUserId, cModule, cMetricName)
	EndIf	
Return

/*/{Protheus.doc} ValidLSTIT
    (Valida se existe licenca especifica do TOTVS Inteligencia Tributaria
    no licenses do cliente;  
    Codigo(s) representante da(s) licenca(s): 4284)
    @type  Static Function
    @author Caique Carlos
    @since 24/04/2025
    @version 1.0
    @return lValid, logico, retorna se existe licensa no LS do cliente
/*/
Static Function ValidLSTIT()
    Local aIdsLS   as array
    Local nIndex   as numeric
    Local lValidLS as logical

    lValidLS := .F.
    aIdsLS   := {}
    aAdd(aIdsLS, 4284) 

    For nIndex := 1 to Len(aIdsLS)
        If (!lValidLS)
            lValidLS := FWLSEnable(aIdsLS[nIndex])
        Endif
    Next i

Return lValidLS

/*/{Protheus.doc} vldTbPrf
    Valida se existe perfil já gravado e se as tabelas existem
    Caso negativo, sera dado a opcao de prosseguir 
    com onboarding  ou nao
    @type  Static Function
    @author Caique Carlos
    @since 05/09/2025
    @version 1.0
    @return lVldTbls, logico, retorna se as tabela existem ou nao
/*/
Static Function vldTbPrf()
    Local aTables     := {"CJX","CJY","CJZ","CK0"} as array
    Local nIndice     := 1                         as numeric
	Local lVldTbls    := .T.                       as logical
    Local cTable      := ""                        as character
    Local cAliasTable := ""                        as character

    While nIndice <= Len(aTables) .and. lVldTbls
        cAliasTable := aTables[nIndice]

        If FWAliasInDic(cAliasTable)
            DbSelectArea((cAliasTable))
        Else
            cTable := cAliasTable + cEmpAnt + "0"
            dbUseArea(.T., __CRDD, cTable, (cAliasTable), .T., .F.)
        EndIf

        If Select(cAliasTable) == 0
            lVldTbls := .F.
        Else
            (cAliasTable)->(dbCloseArea())
        EndIF
        nIndice ++
    EndDo

    FwFreeArray(aTables)
Return lVldTbls
