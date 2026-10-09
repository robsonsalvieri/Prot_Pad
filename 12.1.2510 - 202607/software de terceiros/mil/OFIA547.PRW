#Include "Protheus.ch"
#Include "FWMVCDEF.ch"
#include "TBICONN.CH"
#Include "OFIA547.CH"

/* CONSTANTES DE MODO DE CONSULTA */
#DEFINE SOMENTE_API        "1"
#DEFINE PRIORIZAR_TABELA   "2"

/*=======================================================================================*/
/*/{Protheus.doc} OFIA547
@description Função principal responsável por consumir a API ARMS – GetContractInformation,
             seguindo o padrão estrutural da rotina OFIA544 (SCOB), porém adaptada às regras
             específicas do ARMS. Permite consulta e/ou inclusão de contratos no Protheus DMS.
             Pode ser chamada diretamente por outros módulos do DMS (Oficina, Peças, Veículos).

@author      Lucas Brustolin
@since       2025
@version     12.1.2510
@type        Function
@param       cChassi       | Chassi do veículo a consultar na API ARMS.
@param       lInsContrato  | Define se o contrato deve ser gravado automaticamente (lógico).
@return      Char / JSON   | Retorno em formato JSON contendo o resultado da operação.
@obs         Executa requisição GET para o endpoint GetContractInformation e realiza
             inclusão automática do contrato, caso o parâmetro lInsContrato seja verdadeiro.
/*=======================================================================================*/
Function OFIA547(cChassi, lInsContrato)
    Local lRet      := .T.
    Local aArea     := FWGetArea()
    Local cRet      := ""
    Local cLogAuto  := ""
    Local jSonAuto  := ""
        
    private oClient   := Nil
    private oConfig   := Nil
    private oResult   := Nil
    private aParams   := {}
 
    Default cChassi         := ""
    Default lInsContrato    := .F.

    // -----------------------
    // 1. Monta parâmetros GET
    // -----------------------
    aParams := OA547001N_MontaParams(alltrim(cChassi))

    // -----------------------
    // 2. Recupera config VRN
    // -----------------------
    if !OA547002N_PegaConfigVrn()
        FMX_HELP("OFIA547", STR0001) // "Configuração ARMS não localizada na tabela VRN."
        FWRestArea(aArea)
        return .F.
    endif

    // ARMS_INTEGRACAO_ATIVA controla se API pode ser usada
    if oConfig["ARMS_INTEGRACAO_ATIVA"] <> "1"
        FMX_HELP("OFIA547", STR0002 ) // "Integração ARMS não está ativa."
        FWRestArea(aArea)
        return .F.
    endif

    // -----------------------
    // 3. Chama API ARMS via OFScaniaClient
    // -----------------------
    oResult := OA547003N_RequisitaContratoViaClient()

    // -----------------------
    // Tratamento retorno
    // -----------------------
    if oResult["status_code_res"] == "200" .And. Len(oResult) > 0

        // ----------------------------------------
        // Realiza inclusao do contrato
        // ----------------------------------------    
        If ( lInsContrato )
        
            lRet        := .T.
            cRet        := oClient:jResult
            jSonAuto    := JsonObject():New()

            lOkProcesso := OA547010N_ProcessaInclusao(oResult[1], @cLogAuto)


            if ( lOkProcesso )
                jSonAuto['status']  := STR0007 //'sucesso'
                jSonAuto['message'] := cLogAuto
               
            Else     
                jSonAuto['status']  := STR0008 //'erro'
                jSonAuto['message'] := cLogAuto

                lRet := .F.
            endif

            jSonAuto['response'] := oClient:jResult

            cRet := jSonAuto
        Else 
            lRet := .T.
            cRet := oClient:jResult
        EndIf 
        
    // ---------------------------------------------------------------------------------------
    // Se o retorno da requisição for 200, mas o array for vazio, significa que o veículo não 
    // tem contrato. Para este caso, gravar como "CHASSI SEM CONTRATO"
    // ---------------------------------------------------------------------------------------    
    ElseIf oResult["status_code_res"] == "200" .And. Len(oResult) == 0


        If ( lInsContrato )

            lRet        := .T.
            cRet        := oClient:jResult
            jSonAuto    := JsonObject():New()

            DbSelectArea("VW4")
            VW4->( DbSetorder(3) ) // VW4_FILIAL+VW4_CHASSI
            cChassi     := PadR(cChassi, TamSx3("VW4_CHASSI")[1]) 
            
            If  VW4->( !DbSeek( xFilial("VW4") + cChassi) )
            
                lOkProcesso := OA547060N_GravaChassi(cChassi, @cLogAuto)

                if ( lOkProcesso )
                    jSonAuto['status']  := STR0007 //'sucesso'
                    jSonAuto['message'] := cLogAuto              
                Else     
                    jSonAuto['status']  := STR0008 //'erro'
                    jSonAuto['message'] := cLogAuto
                    lRet := .F.
                endif            
            Else 
                jSonAuto['status']  := STR0007 //'sucesso'
                jSonAuto['message'] := STR0009 + cChassi // "Chassi já cadastrado:"  
            EndIf 

            jSonAuto['response'] := oClient:jResult
            
            cRet := jSonAuto
        
        Else 
            lRet := .T.
            cRet := oClient:jResult
        EndIf 
        

    elseif oResult["status_code_res"] == "401"
        FMX_HELP(STR0004, ; // "Erro Autenticação"
        STR0005) // "Token ARMS recusado. Verifique as configurações na rotina de parâmetros."
        lRet := .F.
        cRet := oClient:jResult
    else
        FMX_HELP("OFIA547", ;
        STR0006) // "A API ARMS retornou erro. Verifique parâmetros ou tente novamente."
        lRet := .F.
        cRet := oClient:jResult
    endif

    freeObj(oClient)
    freeObj(oConfig)
    freeObj(oResult)
    FWFreeArray(aParams)
    FWRestArea(aArea)

Return( cRet )

/*/{Protheus.doc} OA547001N_MontaParams
@description Monta o array de parâmetros utilizado para compor a requisição GET da API ARMS.
             Essa função padroniza os parâmetros esperados pelo endpoint de consulta de contrato.

@author      Lucas Brustolin
@since       2025
@version     1.0
@type        Static Function
@param       cChassi  | Código do chassi a ser enviado para a API ARMS.
@return      Array    | Array contendo os parâmetros chave/valor para a requisição.
/*/
Static Function OA547001N_MontaParams(cChassi)
    local aPar := {}

    if !Empty(cChassi)
        aadd(aPar, {"chassi", cChassi})
    endif

Return aPar

/*/{Protheus.doc} OA547002N_PegaConfigVrn
@description Recupera as configurações da integração ARMS armazenadas na tabela VRN.
             Interpreta o JSON da coluna VRN_CONFIG e seleciona o ambiente correto
             (Produção ou Homologação) de acordo com o ambiente ativo do AppServer.

@author      Lucas Brustolin
@since       2025
@version     1.0
@type        Static Function
@return      Logical | Verdadeiro (.T.) se as configurações ARMS foram carregadas com sucesso.
/*/
Static Function OA547002N_PegaConfigVrn()
    local jCfg := JsonObject():new()
    local cEnv := ""
    local cPropEnv := ""

    oConfig := nil

    DbSelectArea("VRN")
    DbSetOrder(1)

    if DbSeek(xFilial("VRN")+"OFIA541")
        jCfg:FromJson(VRN->VRN_CONFIG)
    endif

    DbCloseArea()

    // Ambiente da CFGA750
    cEnv := totvs.framework.environment.type.envAppGet(.T.)
    if cEnv == "3" .or. cEnv == "2"
        cPropEnv := "HOMOLOGACAO" 
    else
        cPropEnv := "PRODUCAO"
    endif

    if jCfg:HasProperty("ARMS") .and. jCfg["ARMS"]:HasProperty(cPropEnv)
        oConfig := jCfg["ARMS"][cPropEnv]
        return .T.
    endif

Return .F.

/*/{Protheus.doc} OA547003N_RequisitaContratoViaClient
@description Cria e configura uma instância de OFScaniaClient() para autenticação e requisição
             ao endpoint GetContractInformation da API ARMS. Monta URLs, token e parâmetros
             de acesso conforme propriedades obtidas em VRN_CONFIG.

@author      Lucas Brustolin
@since       2025
@version     1.0
@type        Static Function
@return      JsonObject | Objeto JSON contendo o retorno da API ARMS.
/*/
Static Function OA547003N_RequisitaContratoViaClient()
    local cTokenUrl := ""
    local cPath     := ""
    local aParts    := {}
    local cFullTokenUrl := alltrim(oConfig["ARMS_TOKEN_URL"])

    oClient := OFScaniaClient():new()

    // ------------------------------------------
    // Tratamento especial do TOKEN ARMS
    // ------------------------------------------
    // Ex.: https://host/auth/realms/.../token
    aParts := StrTokArr(cFullTokenUrl, "/")

    // monta baseurl ? https://host
    cTokenUrl := aParts[1] + "//" + aParts[2]

    // path é todo o restante
    cPath := SubStr(cFullTokenUrl, Len(cTokenUrl)+1)

    // ------------------------------------------
    // Alimenta client com os dados do ARMS
    // ------------------------------------------
    oClient:setUrlBaseAuthApi(cTokenUrl, cPath);
           :setClientId(alltrim(oConfig["ARMS_CLIENTID"]));
           :setSecret(alltrim(oConfig["ARMS_CLIENTSEC"]));
           :setGrantType(alltrim(oConfig["ARMS_GRANTTYPE"]));
           :setScope(alltrim(oConfig["ARMS_SCOPE"]))

    // request base
    oClient:setUrlBaseRequests(alltrim(oConfig["ARMS_URLBASE"]));
           :setEndPoint(alltrim(oConfig["ARMS_ENDPOINT"]));
           :setGetParams(aParams)

    // Informar a origem/tipo para log (reutilizando métodos existentes)
    // sem criar métodos novos desnecessários
    oClient:setOriginAsArms()
    oClient:setTypeAsArms()

    // ARMS usa GET
    oResult := JsonObject():new()

    oResult := oClient:getEndpointResult("GET")

Return( oResult )

/*/{Protheus.doc} OA547010N_ProcessaInclusao
@description Executa o processamento completo de inclusão do contrato retornado pela API ARMS.
             Realiza normalização, validação e gravação do contrato (VW4) e dos itens (VW5)
             utilizando o modelo OFIA600. Retorna log detalhado da operação e status.

@author      Lucas Brustolin
@since       2025
@version     1.0
@type        Static Function
@param       oContrato | Objeto JSON com os dados retornados da API ARMS.
@param       cLogAuto  | Variável de log que armazena mensagens de execução e erros.
@return      Logical   | Verdadeiro (.T.) se a inclusão do contrato foi concluída com sucesso.
/*/
Static Function OA547010N_ProcessaInclusao(oContrato, cLogAuto)


    Local aNorm     := {}
    Local oVW4      := Nil
    Local aVW5      := {}
    Local aErros    := {}
    Local cMsg      := ""
    Local nI        := 0

    Default cLogAuto    := ""

    If ValType(oContrato) <> "J" 
        FMX_HELP("OFIA547", STR0010) // "Retorno ARMS inválido."
        Return .F.
    EndIf

    // Normalização
    aNorm := OA547020N_NormalizaContrato(oContrato)
    oVW4  := aNorm[1]
    aVW5  := aNorm[2]

    // Validação
    aErros := OA547030N_ValidaContrato(oVW4)

    If Len(aErros) > 0

        For nI := 1 To Len(aErros)
            If !Empty(cMsg)
                cMsg += ", "
            EndIf
            cMsg += aErros[nI]
        Next

        cLogAuto :=  cMsg
        Return .F.
    EndIf

    // Gravação
    If !OA547040N_GravaContrato(oVW4, aVW5, @cLogAuto)
        FMX_HELP("OFIA547", STR0011 + cLogAuto ) // "Erro ao gravar contrato. "
        Return .F.
    EndIf

Return .T.


/*/{Protheus.doc} OA547020N_NormalizaContrato
@description Converte o JSON retornado pela API ARMS nos objetos de dados internos
             utilizados pelo modelo OFIA600 (VW4 e VW5). Separa cabeçalho e subitens
             (Descontos, Dealers e E-mails) para gravação padronizada no DMS.

@author      Lucas Brustolin
@since       2025
@version     1.0
@type        Static Function
@param       oJson   | Objeto JSON recebido da API ARMS.
@return      Array   | Array com dois elementos: [1] Objeto VW4, [2] Array VW5.
/*/
Static Function OA547020N_NormalizaContrato(oJson)

    Local oVW4      := JsonObject():New()
    Local aVW5      := {}
    Local nI        := 0
    Local cCliente  := ""

    oVW4["VW4_FILIAL"] := xFilial("VW4")
    oVW4["VW4_CHASSI"] := AllTrim(cValToChar(oJson["chassi"]))

    // Garante que o numero da sequencia nao esta em uso
    // oVW4["VW4_SEQUEN"] := GetSx8Num("VW4","VW4_SEQUEN") //cValToChar(oJson["sequencia"])
    oVW4["VW4_SEQUEN"] := OA547005Q_ProxNumSX8()

    oVW4["VW4_NUMCTR"] := AllTrim(oJson["contrato"])

    oVW4["VW4_STATUS"] := Upper(AllTrim(oJson["status"]))
    oVW4["VW4_TIPO"]   := cValToChar(oJson["tipoContrato"])
    oVW4["VW4_DESTIP"] := AllTrim(oJson["descr_tipoContrato"])

    cCliente    := cValToChar(oJson["cliente"])

    oVW4["VW4_CLISCN"] := PADR(cCliente, TamSx3("VW4_CLISCN")[1])
    oVW4["VW4_CLIENT"] := "" // PADR(cCliente, TamSx3("VW4_CLIENT")[1])
    oVW4["VW4_LOJA"]   := "" 

    oVW4["VW4_NOMCLI"] := AllTrim(oJson["razao_soc_cliente"])
    oVW4["VW4_NOMRD"]  := AllTrim(oJson["razao_res_cliente"])

    oVW4["VW4_CDEAL"]  := cValToChar(oJson["dealer"])
    oVW4["VW4_NMDEA"]  := AllTrim(oJson["razao_soc_dealer"]) 
    oVW4["VW4_RNMDEA"] := AllTrim(oJson["razao_res_dealer"])

    oVW4["VW4_DTINI"]  := CTOD(Left(oJson["data_inicio"],10)) // "25/07/2024 00:00:00"
    oVW4["VW4_DTFIM"]  := CTOD(Left(oJson["data_fim"],10))

    oVW4["VW4_KMINI"]  := oJson["km_inicio"]
    oVW4["VW4_KMFIM"]  := oJson["km_fim"]

    oVW4["VW4_COBER"]  := AllTrim(oJson["cobertura"])
    oVW4["VW4_MODCHA"] := AllTrim(oJson["chassi_modelo"])
    

    oVW4["VW4_TPCOBR"] := AllTrim(oJson["tipoCobranca"])
    oVW4["VW4_DSTPCB"] := AllTrim(oJson["descr_tipoCobranca"])
    oVW4["VW4_TPMANU"] := AllTrim(oJson["tipoManutencao"])
    oVW4["VW4_DSMANU"] := AllTrim(oJson["descr_tipoManutencao"])

    // =========================================
    // VW5 – DESCONTOS (OBJETOS COMPLEXOS)
    // =========================================
    For nI := 1 To Len(oJson["descontosLocal"])

        oItem := JsonObject():New()
        oItem["VW5_IDDESC"] := cValToChar(oJson["descontosLocal"][nI]["descontoId"])
        oItem["VW5_DSID"]   := PADR(AllTrim(oJson["descontosLocal"][nI]["descr_descontoId"]),TamSx3("VW5_DSID")[1])
        oItem["VW5_TPDESC"] := AllTrim(oJson["descontosLocal"][nI]["descontoTipo"])
        oItem["VW5_DSTP"]   := AllTrim(oJson["descontosLocal"][nI]["descr_descontoTipo"])
        oItem["VW5_VLDESC"] := oJson["descontosLocal"][nI]["descontoValor"]

        AAdd(aVW5, { "DESC", oItem })
    Next

    // =========================================
    // VW5 – DEALERS (OBJETOS COMPLEXOS)
    // =========================================
    For nI := 1 To Len(oJson["dealersLocal"])

        oItem := JsonObject():New()
        oItem["VW5_DEALID"] := cValToChar(oJson["dealersLocal"][nI]["dealerId"])
        oItem["VW5_NMDEAL"] := AllTrim(oJson["dealersLocal"][nI]["razao_soc_dealerId"])
        oItem["VW5_RNMDEA"] := AllTrim(oJson["dealersLocal"][nI]["razao_res_dealerId"])

        AAdd(aVW5, { "DEAL", oItem })
    Next

    // =========================================
    // VW5 – EMAILS (STRINGS ? OBJETO SIMPLES)
    // =========================================
    For nI := 1 To Len(oJson["emailGestores"])
        oItem := JsonObject():New()
        oItem["VW5_EMAILG"] := AllTrim(oJson["emailGestores"][nI]["email_gestor"])
        AAdd(aVW5, { "MAIL", oItem })
    Next

Return { oVW4, aVW5 }

/*/{Protheus.doc} OA547030N_ValidaContrato
@description Realiza validações básicas sobre os dados do contrato (VW4),
             garantindo integridade mínima antes da gravação.
             Valida campos obrigatórios como chassi e datas de vigência.

@author      Lucas Brustolin
@since       2025
@version     1.0
@type        Static Function
@param       oVW4   | Objeto JSON representando o contrato normalizado.
@return      Array  | Lista de mensagens de erro encontradas durante a validação.
/*/
Static Function OA547030N_ValidaContrato(oVW4)

    Local aArea     := GetArea()
    Local aErros    := {}
                                                                                                                                
    If Empty(oVW4["VW4_CHASSI"])
        AAdd(aErros, STR0012) // "Chassi não informado."
    EndIf

    If Empty(oVW4["VW4_DTINI"]) .Or. Empty(oVW4["VW4_DTFIM"])
        AAdd(aErros, STR0013) // "Datas do contrato são inválidas."
    EndIf


RestArea(aArea)
Return( aErros )

/*/{Protheus.doc} OA547040N_GravaContrato
@description Realiza gravação do contrato ARMS no modelo OFIA600. Controla operação
             INSERT/UPDATE conforme existência prévia, popula cabeçalho VW4, recria
             itens VW5 (descontos, dealers, e-mails), executa validação e commit do MVC.
             Retorna mensagens completas de erro para cLogAuto e GRLog em caso de falha.
/author      Lucas Brustolin
@since       2025
@version     1.0
@type        Static Function
@param       oVW4      | Dados normalizados do cabeçalho VW4.
@param       aVW5      | Lista de subitens VW5 preparados para gravação.
@param       cLogAuto  | Log textual contendo mensagens de auditoria ou erro.
@return      Logical   | Verdadeiro (.T.) quando commit MVC é concluído com sucesso.
/*-------------------------------------------------------------------*/

Static Function OA547040N_GravaContrato(oVW4, aVW5, cLogAuto)

    Local oModel        := FWLoadModel("OFIA600")
    Local oFieldMaster  := Nil
    Local oGridDesc     := Nil
    Local oGridDeal     := Nil
    Local oGridMail     := Nil  
    Local cCampo        := ""
    Local aCampos       := oVW4:GetNames()
    Local cCpoChave     := ""
    Local cTipo         := ""
    Local aDataVW5      := Nil
    Local lExistCTR     := .F. 
    Local lRet          := .F. 
    Local nI            := 0 

    Default cLogAuto := ""

    lExistCTR := OA547050N_ExisteContrato( oVW4["VW4_CHASSI"], oVW4["VW4_NUMCTR"]  )

    oModel:SetOperation(IIF( lExistCTR ,MODEL_OPERATION_UPDATE, MODEL_OPERATION_INSERT ) )
    oModel:Activate()

    // Cabeçalho VW4
    oFieldMaster:= oModel:GetModel("MODEL_VW4")
    oGridDesc   := oModel:GetModel("MODEL_DESC")
    oGridDeal   := oModel:GetModel("MODEL_DEAL")
    oGridMail   := oModel:GetModel("MODEL_MAIL")

    //Campos chave nao são alterados
    cCpoChave := FWX2Unico("VW4") + "+VW4_SEQUEN"  

    // =============================
    // GRAVA VW4 (Cabeçalho)
    // =============================
    For nI := 1 To Len(aCampos)
    
        cCampo := aCampos[nI]

        // ----------------------------------
        // Alteracao de campo chave nao permitida.
        If ( lExistCTR )
            If cCampo $ cCpoChave
                Loop 
            EndIf 
        EndIf 
        
        oFieldMaster:SetValue(cCampo, oVW4[cCampo])
    
    Next

    // =============================
    // GRAVA VW5 (Itens)
    // =============================
    If oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. oModel:GetOperation() == MODEL_OPERATION_UPDATE 

        If ( lExistCTR .And. Len(aVW5) > 0 )

            If !oGridDesc:IsEmpty()
                oGridDesc:DelAllLine()
            EndIf

            If !oGridMail:IsEmpty()            
                oGridMail:DelAllLine()
            EndIf

            If !oGridDeal:IsEmpty()
                oGridDeal:DelAllLine()
            EndIf 
       
        EndIf

        oGridDesc:GoLine(1)
        oGridDeal:GoLine(1)
        oGridMail:GoLine(1)

        For nI := 1 To Len(aVW5)

            cTipo    := aVW5[nI][1]
            aDataVW5 := aVW5[nI][2]

            Do Case
            // --------------------
            // DESCONTOS
            // --------------------
            Case cTipo == "DESC"
                OA547004K_IncluirLinhaNaGridSeAplicavel(oGridDesc)
                oGridDesc:SetValue("VW5_IDDESC", aDataVW5["VW5_IDDESC"])
                oGridDesc:SetValue("VW5_DSID"  , aDataVW5["VW5_DSID"])
                oGridDesc:SetValue("VW5_TPDESC", aDataVW5["VW5_TPDESC"])
                oGridDesc:SetValue("VW5_DSTP"  , aDataVW5["VW5_DSTP"])
                oGridDesc:SetValue("VW5_VLDESC", aDataVW5["VW5_VLDESC"])
                
            // --------------------
            // EMAILS
            // --------------------
            Case cTipo == "MAIL"
                OA547004K_IncluirLinhaNaGridSeAplicavel(oGridMail)
                oGridMail:SetValue("VW5_EMAILG", aDataVW5["VW5_EMAILG"])
               
            // -------------------
            // DEALERS
            // --------------------
            Case cTipo == "DEAL"
                OA547004K_IncluirLinhaNaGridSeAplicavel(oGridDeal)
                oGridDeal:SetValue("VW5_DEALID", aDataVW5["VW5_DEALID"])
                oGridDeal:SetValue("VW5_NMDEAL", aDataVW5["VW5_NMDEAL"])
                oGridDeal:SetValue("VW5_RNMDEA", aDataVW5["VW5_RNMDEA"])
                
            EndCase

        Next
    EndIf 

    // Validar e gravar        
    If ( oModel:VldData() .And. oModel:CommitData() ) 
        cLogAuto    := STR0014 + IIF( lExistCTR, STR0015, STR0016 ) + STR0017 //  #Contrato # " atualizado" #  " incluído" # " com sucesso!"
        lRet        := .T. 
    Else         
       
        For nI := 1 To Len(oModel:GetErrorMessage())
			cLogAuto += cValToChar(oModel:GetErrorMessage()[nI]) + CRLF
		Next 

        AutoGRLog(cLogAuto)
        lRet := .F.
    EndIf

    oModel:DeActivate()
    oModel:Destroy()
    oModel := Nil

Return( lRet )

/*/{Protheus.doc} OA547060N_GravaChassi
@description Inclui na tabela VW4 um chassi sem contrato quando a API ARMS retorna
             status 200 porém sem nenhum item. Gera o registro de cabeçalho marcando
             “CHASSI SEM CONTRATO”, valida e executa commit MVC, retornando log detalhado.
/author      Lucas Brustolin
@since       2025
@version     1.0
@type        Static Function
@param       cChassi  | Chassi informado pelo usuário ou rotina chamadora.
@param       cLogAuto | Variável para armazenar mensagens de execução.
@return      Logical  | Verdadeiro (.T.) quando a inclusão ocorre sem erros.
/*-------------------------------------------------------------------*/

Static Function OA547060N_GravaChassi(cChassi, cLogAuto)

    Local oModel        := FWLoadModel("OFIA600")
    Local oFieldMaster  := Nil
    Local nI            := 0
    Local lRet          := .F. 

    Default cLogAuto := ""

    oModel:SetOperation( MODEL_OPERATION_INSERT )
    oModel:Activate()

    // Cabeçalho VW4
    oFieldMaster:= oModel:GetModel("MODEL_VW4")
        
    oFieldMaster:SetValue("VW4_CHASSI", cChassi )
    oFieldMaster:SetValue("VW4_STATUS", STR0018 ) // "CHASSI SEM CONTRATO"
    
    // Validar e gravar
    lRet := oModel:VldData() .And. oModel:CommitData()
        
    If ( lRet )
        cLogAuto    := STR0019 // "Chassi incluído com sucesso!"
        ConfirmSx8()
    Else  
        RollBackSX8()
        cLogAuto := ""
        For nI := 1 To Len(oModel:GetErrorMessage())
			cLogAuto += cValToChar(oModel:GetErrorMessage()[nI]) + CRLF
		Next 

        AutoGRLog(cLogAuto)
        lRet := .F.
    EndIf

    oModel:DeActivate()
    oModel:Destroy()
    oModel := Nil

Return(lRet)

/*/{Protheus.doc} OA547050N_ExisteContrato
@description Verifica se já existe contrato VW4 cadastrado para o par
             (CHASSI, CONTRATO). Utilizado para decidir se o MVC executará
             INSERT ou UPDATE durante a integração ARMS.
/author      Lucas Brustolin
@since       2025
@version     1.0
@type        Static Function
@param       cChassi | Chassi do veículo.
@param       cNumCTR | Número do contrato ARMS.
@return      Logical | Verdadeiro (.T.) quando o contrato já existe na base.
/*-------------------------------------------------------------------*/
Static Function OA547050N_ExisteContrato(cChassi, cNumCTR)

    Local aArea     := GetArea()
    Local lRet      := .F.

    Default cChassi := "" 
    Default cNumCTR := ""
                                                                                                                                   

    cChassi := PadR(cChassi, TamSx3("VW4_CHASSI")[1]  )
    cNumCTR := PadR(cNumCTR, TamSx3("VW4_NUMCTR")[1]  )

    DbselectArea("VW4")     // Contratos Scania              
    VW4->( DbSetOrder(3))   // VW4_FILIAL+VW4_CHASSI+VW4_NUMCTR                                                                                                                                           

    lRet := VW4->( DbSeek(xFilial("VW4") + cChassi + cNumCTR )  )


RestArea(aArea)
Return( lRet )

/*=======================================================================================*/
/*/{Protheus.doc} OA547070N_ConsultaTipoContrato
@description Função responsável por retornar o TIPO DE CONTRATO SCANIA utilizado nos módulos
             Control Tower e Priorização de Atendimento.

             A função permite dois modos de operação, controlados pelo parâmetro cModoConsulta:

             - SOMENTE_API ("1")
                 ? Ignora totalmente a VW4.
                 ? Executa apenas consulta à API ARMS.

             - PRIORIZAR_TABELA ("2")
                 ? Primeiro verifica a tabela VW4 (tabela de Contratos Scania).
                 ? Se contrato válido encontrado, retorna de imediato.
                 ? Se inválido, retorna "NO_CONTRACT".
                 ? Se não encontrado, então consulta a API ARMS.

             RETORNOS VÁLIDOS (sempre string):
                 • Descrição do tipo de contrato      (ex.: "PRO PERSONAL")
                 • "NO_CONTRACT"
                 • "UNABLE_TO_DETERMINE_CONTRACT"

@author      Lucas Brustolin
@since       2025
@version     12.1.2510
@param       cChassi        | Chassi do veículo a consultar
@param       cModoConsulta  | SOMENTE_API ("1")  ou  PRIORIZAR_TABELA ("2")
@return      Character      | Resultado final em string
/*=======================================================================================*/
Function OA547070N_ConsultaTipoContrato(cChassi, cModoConsulta)

    Local cRet := "UNABLE_TO_DETERMINE_CONTRACT"

    Default cModoConsulta := PRIORIZAR_TABELA
    Default cChassi       := ""

    If Empty(AllTrim(cChassi))
        Return "UNABLE_TO_DETERMINE_CONTRACT"
    EndIf

	if !FWAliasInDic("VW4")
		Return "UNABLE_TO_DETERMINE_CONTRACT"
	endif

    // ===========================================
    // MODO 1 — PRIORIZAR TABELA VW4
    // ===========================================
    If AllTrim(cModoConsulta) == PRIORIZAR_TABELA

        cRet := OA547071N_ConsultaTabela(cChassi)

        // Retorno pode ser:
        //  descrição ? retorna
        //  NO_CONTRACT ? retorna
        //  CONSULTAR_API ? consulta API
        If cRet <> "CONSULTAR_API"
            Return cRet
        EndIf

    EndIf

    // ===========================================
    // MODO 2 — SOMENTE API OU FALHA NA TABELA
    // ===========================================
    cRet := OA547072N_ConsultaAPI(cChassi)

Return cRet

/*=======================================================================================*/
/*/{Protheus.doc} OA547071N_ConsultaTabela
@description Consulta a tabela VW4 para identificar o tipo de contrato Scania.

RETORNOS:
    ? Descrição do Tipo de Contrato  (caso contrato válido)
    ? "NO_CONTRACT"                  (registro encontrado porém inválido)
    ? "CONSULTAR_API"                (não encontrado na VW4)

Contrato válido SOMENTE quando:
    Status = "ATIVO"
    VW4_TIPO preenchido
    VW4_NUMCTR preenchido

@param   cChassi
@return  String
/*=======================================================================================*/
Static Function OA547071N_ConsultaTabela(cChassi)

    Local aArea     := GetArea()
    Local cChassiDB := PadR(cChassi, TamSx3("VW4_CHASSI")[1])
    Local cDesc     := ""

    DbSelectArea("VW4")
    VW4->(DbSetOrder(3))  // VW4_FILIAL + VW4_CHASSI

    If !VW4->(DbSeek(xFilial("VW4") + cChassiDB))
        RestArea(aArea)
        Return "CONSULTAR_API"
    EndIf

    // Contrato inválido
    If !OA547073N_ContratoValido()
        RestArea(aArea)
        Return "NO_CONTRACT"
    EndIf

    // Contrato válido
    cDesc := AllTrim(VW4->VW4_DESTIP)

    RestArea(aArea)
Return cDesc

/*=======================================================================================*/
/*/{Protheus.doc} OA547072N_ConsultaAPI
@description Executa consulta na API ARMS usando OFIA547 (somente consulta, sem gravação).

RETORNOS:
    ? Descrição do contrato (válido)
    ? "NO_CONTRACT"       (lista vazia ou contrato inválido)
    ? "UNABLE_TO_DETERMINE_CONTRACT" (erro API)

@param   cChassi
@return  String
/*=======================================================================================*/
Static Function OA547072N_ConsultaAPI(cChassi)

    Local oRetAPI := Nil

    // Consulta API — modo consulta, sem gravação
    oRetAPI := OFIA547(cChassi, .T.)

    If ValType(oRetAPI) <> "A" .And. ValType(oRetAPI) <> "J" .or. ValType(oRetAPI['response']) == "U"
        Return "UNABLE_TO_DETERMINE_CONTRACT"
    EndIf

    // Erro de autenticação
    If oRetAPI["status_code_res"] == "401"
        Return "UNABLE_TO_DETERMINE_CONTRACT"
    EndIf

    // API retornou 200 sem contrato
    If oRetAPI['response']["status_code_res"] == "200" .And. Len(oRetAPI['response']) == 0
        Return "NO_CONTRACT"
    EndIf

    // API retornou objeto de contrato
    If Len(oRetAPI['response']) > 0

        If !OA547074N_RetornoAPIOk(oRetAPI['response'][1])
            Return "NO_CONTRACT"
        EndIf

        Return AllTrim(oRetAPI['response'][1]['descr_tipoContrato'])
    EndIf

Return "UNABLE_TO_DETERMINE_CONTRACT"

/*=======================================================================================*/
/*/{Protheus.doc} OA547073N_ContratoValido
@description Verifica o registro atual da VW4 para contrato válido.

Contrato válido quando:
    Status = "ATIVO"
    VW4_TIPO preenchido
    VW4_NUMCTR preenchido

@return Logical
/*=======================================================================================*/
Static Function OA547073N_ContratoValido()

    If Empty(AllTrim(VW4->VW4_STATUS))
        Return .F.
    EndIf

    If Upper(AllTrim(VW4->VW4_STATUS)) <> "ATIVO"
        Return .F.
    EndIf

    If Empty(AllTrim(VW4->VW4_TIPO))
        Return .F.
    EndIf

    If Empty(AllTrim(VW4->VW4_NUMCTR))
        Return .F.
    EndIf

Return .T.

/*=======================================================================================*/
/*/{Protheus.doc} OA547074N_RetornoAPIOk
@description Verifica se o JSON da API contém um contrato válido.

Contrato válido quando:
    status = "ATIVO"
    tipoContrato preenchido
    contrato preenchido

@param   oJson | JSON retornado pela API
@return  Logical
/*=======================================================================================*/
Static Function OA547074N_RetornoAPIOk(oJson)

    If Empty(AllTrim(oJson["status"]))
        Return .F.
    EndIf

    If Upper(AllTrim(oJson["status"])) <> "ATIVO"
        Return .F.
    EndIf

    If Empty(cValToChar(oJson["tipoContrato"]))
        Return .F.
    EndIf

    If Empty(AllTrim(oJson["contrato"]))
        Return .F.
    EndIf

Return .T.

/*/{Protheus.doc} OA547004K_IncluirLinhaNaGridSeAplicavel
    Função para controlar a inserção de linhas nas diferentes abas
    do modelo, a fim de não criar registros vazios na base de dados (VW5)
    @type  Static Function
    @author Lucas Oliveira
    @since 13/01/2026
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function OA547004K_IncluirLinhaNaGridSeAplicavel(oSubModel)

    If !oSubModel:IsEmpty()
        oSubModel:AddLine()
    Endif

Return Nil

/*/{Protheus.doc} OA547005Q_ProxNumSX8
Função que garante não gerar duplicidade e erro de chave duplicada,
antes de gravar o numero, validar sua existencia
@type static function
@version  1.0
@author Matheus Miranda
@since 15/05/2026
@return character, Retorna o proximo numero do VW4_SEQUEN
@see (links_or_references)
/*/
Static Function OA547005Q_ProxNumSX8()

    Local cProxVW4Sequen := ""
   
    VW4->(DBSetOrder(1)) //VW4_FILIAL+VW4_SEQUEN

    // Percorre todos os itens, garantindo a sequencia é unica
    // Os que ja foram incluidos, confirma e fecha a transacao
    While .T.
        cProxVW4Sequen  := GetSx8Num("VW4","VW4_SEQUEN")
        ConfirmSX8()
        If !VW4->(DBSeek(xFilial("VW4") + cProxVW4Sequen))
            Exit
        Endif
    Enddo

Return cProxVW4Sequen
