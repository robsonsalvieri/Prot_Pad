#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'OFIA544.CH'

#DEFINE TAM_CHASSI_COMPLETO 17
#DEFINE TAM_CHASSI_REDUZIDO 7

/*/{Protheus.doc} OFIA544
    Função para pré cadastro de veículos SCANIA via api SCOB
    @type  Function
    @author Renan Migliaris
    @since 02/10/2025
    /*/
Function OFIA544(cMotor, cChassis, lAuto, aInfoVei)
    local lRet := .t.
    local aArea := FwGetArea()
    private aParams := {}
    private oClient
    private oConfig
    private oResult
    private aErros := {}
    private lPosPe := .f.
    private lPrePe := .f.
    
    default cMotor := ''
    default cChassis := ''
    default lAuto := .f.

    if OA5440178_IntegrarSCOB()
        FWMsgRun(, {|oSay| lRet := OA5440188_ChamaAPI(oSay, cMotor, cChassis, lAuto, aInfoVei) }, STR0016, STR0017) // "Por favor aguarde", "Consultando chassi na base da Scania..."
    endif 
    FwRestArea(aArea)
Return lRet 

/*/{Protheus.doc} OA544001J_PegaConfigVrn
    Recupera a configuração cadastrada pelo usuário na VRN
    @type  Static Function
    @author Renan Migliaris
    @since 02/10/2025
/*/
Static Function OA544001J_PegaConfigVrn(cForceEnv)
    local lRet := .t.
    local cEnv := ''
    local cPropEnv := ''
    local jJson := JsonObject():new()
    local aArea := FWGetArea()

    default cForceEnv := ""
    oConfig := nil

    DbSelectArea('VRN')
    VRN->(DbSetOrder(1))
    
    if VRN->(DbSeek(xFilial('VRN')+"OFIA541"))
        jJson:FromJson(VRN->VRN_CONFIG)
    endif 

    FWRestArea(aArea)

    if !Empty(cForceEnv)
        cEnv := cForceEnv
    else
        cEnv := totvs.framework.environment.type.envAppGet(.T.)
    endif

    if cEnv == '3' .or. cEnv == '2'
        cPropEnv := 'HOMOLOGACAO'
    elseif cEnv == '1'
        cPropEnv := 'PRODUCAO'
    endif

    if jJson:HasProperty('SCOB') .and. jJson['SCOB']:HasProperty(cPropEnv)
        oConfig := jJson['SCOB'][cPropEnv]
    else
        oConfig := JsonObject():new()
        lRet    := .f.
    endif
Return lRet 

/*/{Protheus.doc} OA544002J_RequisitaInformacaoDoVEiculoViaClient
    Vai realizar o set do client para pegar o resultado da api
    @type  Static Function
    @author Renan Migliaris
    @since 02/10/2025
/*/
Static Function OA544002J_RequisitaInformacaoDoVEiculoViaClient()
    oClient := OFScaniaClient():new()

    //alimentando a classe com as informações de autenticação
    oClient:setUrlBaseAuthApi(alltrim(oConfig["CFG_URL"]), alltrim(oConfig["CFG_AUTHPATH"]));
        :setClientId(alltrim(oConfig["CFG_CLIENTEID"]));
        :setSecret(alltrim(oConfig["CFG_CLIENTESECRET"]));
        :setGrantType(alltrim(oConfig["CFG_GRANTTYPE"]))

    //informações para a requisição de veículos
    oClient:setOriginAsScob();
        :setTypeAsScob();
        :setUrlBaseRequests(alltrim(oConfig["CFG_URLBASE"]));
        :setEndPoint(alltrim(oConfig["CFG_ENDPOINT"]));
        :setGetParams(aParams);
        :getEndpointResult("post");

    oResult := JsonObject():new()
    oResult := oClient:jResult
Return


/*/{Protheus.doc} OA544003J_ExecutaPreCadastroDoVeiculo
    vai chamar a model do VEIA070 para executar o pré-cadastro do veículo
    @type  Static Function
    @author Renan Migliaris
    @since 02/10/2025
/*/
Static Function OA544003J_ExecutaPreCadastroDoVeiculo(lAuto, oSay)
    local lRet := .t.
    local aDados := OA544004J_RetornaDadosDoVeiculo(lAuto)

    if len(aDados) == 0
        return .f.
    endif

    lRet := OA544005J_PreCadastraVeiculo(aDados, lAuto, oSay)

Return lRet

/*/{Protheus.doc} OA544004J_RetornaDadosDoVeiculo
    retorna o array de dados do veículo para execução automática do mvc
    @type  Static Function
    @author Renan Migliaris
    @since 02/10/2025
/*/
Static Function OA544004J_RetornaDadosDoVeiculo(lAuto)
    local aDados := {}
    local aJsonProps := {}
    local nx := 0
    local oVehicle := nil
    local aPeParam := {}

    oVehicle := OA544007J_MontaDadosDoVeiculo()
    if OA544010J_FazAVerificacaoDosDadosSeremGravados(oVehicle)

        oVehicle:delname('productType') //se tudo estiver certo eu deleto essa proprieda pq ela não vai ser necessária no exec do MVC

        if lPrePe //ponto de entrada de pré cadastro aonde o usuário vai manipular o oVehicle para adicionar o que deseja. 
            aadd(aPeParam, oVehicle)
            oVehicle := ExecBlock("OF544PRE", .f., .f., aPeParam)
        endif

        aJsonProps := oVehicle:GetNames()

        for nx := 1 to len(aJsonProps)
            aadd(aDados, {aJsonProps[nx], oVehicle[aJsonProps[nx]]})
        next
    else
        FMX_HELP("OFIA544005", STR0002, OA544011J_MontaErroDoHelpComRelacaoAosDadosDaBase()) //ERRO
        return {}
    endif

Return aDados

/*/{Protheus.doc} OA544005J_PreCadastraVeiculo
    Função que vai instanciar a model para realizazr o pré-cadastro do veiculo advindo da API
    @type  Static Function
    @author Renan migliaris
    @since 02/10/2025
/*/
Static Function OA544005J_PreCadastraVeiculo(aDados, lAuto, oSay)
    local lRet := .t.
    local lOk := .t.
    local nx := 0
    local aExErr := {}
    local oModel := FwLoadModel('VEIA070')
	default lAuto := .f.
    // local oStru := FwFormStruct(1, 'VV1')
    
    oModel:setOperation(MODEL_OPERATION_INSERT)
    oModel:activate()
    
    OA544013J_SetaPropriedadesDaVV1ComoNaoObrigatorias(@oModel)

    for nx := 1 to len(aDados)
        oModel:setValue('MODEL_VV1', aDados[nx][1], aDados[nx][2])
    next

    lOk := oModel:VldData()
    if lOk
        oModel:CommitData()
        if !lAuto .and. !IsBlind()
            oSay:SetText(STR0007)
        endif
        lRet := .t.
    endif

    if !lOk
        aExErr := oModel:GetErrorMessage()
        if !lAuto .and. !IsBlind()
            MostraErro()
        endif
        lRet := .f.
    endif

    if lPosPe
        ExecBlock("OF544POS", .f., .f., {})
    endif

Return lRet 

/*/{Protheus.doc} OA544006J_MontaOArrayDeParametrosParaRequestDoVeiculo
    Retorna o array de parÂmetros para montar a URI no client
    @type  Static Function
    @author Renan Migliaris
    @since 03/10/2025
/*/
Static Function OA544006J_MontaOArrayDeParametrosParaRequestDoVeiculo(cMotor, cChassis)
    local aParams := {}

    if !Empty(cMotor)
        aadd(aParams, {"motor", cMotor})
    endif

    if !Empty(cChassis)
        aadd(aParams, {"chassis", cChassis})
    endif

Return aParams

/*/{Protheus.doc} OA544007J_MontaDadosDoVeiculo
    Depois que requisitei o veículo para a API 
    Esse cara vai tratar o caso especial do motor, retornando um json com as informações pertinentes dele 
    @type  Static Function
    @author Renan Migliaris
    @since 03/10/2025
/*/
Static Function OA544007J_MontaDadosDoVeiculo()
    local oVehicle := JsonObject():new()
    local cProdType := oResult["content"]["productType"] //1 = Caminhão, 2 = Onibus, 3 = Motor
    local cModVei := ''
    local cCorVei := ''

    cModVei := OA544008J_RetornaVV1ParaGravacaoAPartirDoFornecidoPelaApi(oResult["content"]["model"], oConfig['CFG_CODMAR'])
    cCorVei := OA544009J_VerificaCorDoVeiculoParaGravacaoApartirDoFornecidoPelaApi(oResult["content"]["colourCode"], cProdType , oConfig['CFG_CODMAR'])

    //esse cara aqui vou usar para as validações no objeto json (caso de motor, caminhão, ônibus)
    oVehicle['productType'] := oResult['content']['productType']

    //informações pré-parametrizadas pelo usuario na OFIA541
    oVehicle['VV1_LOCPAD'] := oConfig['CFG_LOCPAD']

    //informações fixas 
    oVehicle['VV1_CODMAR'] := oConfig['CFG_CODMAR']
    oVehicle['VV1_CODORI'] := '0'
    oVehicle['VV1_PROVEI'] := ''
    oVehicle['VV1_ESTVEI'] := ''
    oVehicle['VV1_MODVEI'] := cModVei

    //Informações advindas da API 
    oVehicle['VV1_PESLIQ'] := oResult["content"]["netWeight"]
    oVehicle['VV1_NUMMOT'] := oResult["content"]["number"]
    oVehicle['VV1_QTDCIL'] := oResult["content"]["cylinder"]
    oVehicle['VV1_POTMOT'] := oResult["content"]["power"]
    if valtype(oResult["content"]["strokeVolume"]) == "C"
        oVehicle['VV1_CILMOT'] := val(oResult["content"]["strokeVolume"])
    endif
    oVehicle['VV1_QTDEIX'] := oResult["content"]["axes"]
    oVehicle['VV1_DESVEI'] := oResult["content"]["descrTypev"]
    oVehicle['VV1_PESBRU'] := 0

    if cProdType == "3"
        oVehicle["VV1_FABMOD"] := cValToChar(oResult["content"]["assemblyYear"]) + cValToChar(oResult["content"]["assemblyYear"])
        oVehicle["VV1_CHASSI"] := oResult["content"]["number"]
    elseif cProdType == "1" .or. cProdType == "2" //Ou sejam caso não for motor são esperadas essas informacoes
        oVehicle['VV1_TIPMOT'] := oResult["content"]["engineType"]
        if valtype(oResult["content"]["axleDistance"]) == "C"
            oVehicle['VV1_DISEIX'] := getDToVal(oResult["content"]["axleDistance"])
        endif
        oVehicle['VV1_SERMOT'] := oResult["content"]["vehicleSeries"]
        oVehicle["VV1_FABMOD"] := cValtochar(oResult["content"]["assemblyYear"]) + cValToChar(oResult["content"]["modelYear"])
        if valtype(oResult["content"]["grossVehicleWeight"]) == "C"
            oVehicle['VV1_PESBRU'] := val(oResult["content"]["grossVehicleWeight"])
        endif
        oVehicle['VV1_CHASSI'] := oResult["content"]["chassi"]
        oVehicle["VV1_CORVEI"] := cCorVei
    endif

Return oVehicle


/*/{Protheus.doc} OA544008J_RetornaVV1ParaGravacaoAPartirDoFornecidoPelaApi
    Para a gravação do VV1_MODVEI é necessário que o model informado pela API exista na VV2_MODFAB
    Caso exista, a rotina vai gravar VV2_MODVEI
    Esse método vai fazer essa validação e já retornar para o json que vou utilizar o valor certo para gravação
    @type  Static Function
    @author Renan Migliaris
    @since 04/10/2025
/*/
Static Function OA544008J_RetornaVV1ParaGravacaoAPartirDoFornecidoPelaApi(cModel, cCodMar)
    local cModVei := '' //variavel a ser retornada para gravação
    local cQuery := ''
    local cMyFilial := xFilial('VV2')
    local cFixQuery := ''
    local cAlias := ''
    local oStatement := nil

    if valtype(cModel) == "C"
        oStatement := FWPreparedStatement():new()

        cQuery := " SELECT "
        cQuery += "     VV2.VV2_MODVEI "
        cQuery += " FROM "
        cQuery += retsqlname("VV2") + " VV2 "
        cQuery += " WHERE "
        cQuery += "     VV2.VV2_FILIAL = ? "
        cQuery += " AND "
        cQuery += "     VV2.D_E_L_E_T_ = ? "
        cQuery += " AND "
        cQuery += "     VV2.VV2_MODFAB = ? "

        oStatement:setQuery(cQuery)
        oStatement:setString(1, cMyFilial)
        oStatement:setString(2, ' ')
        oStatement:setString(3, cModel)

        cFixQuery := oStatement:getFixQuery()

        cAlias := GetNextAlias()

        dbUseArea(.t., "TOPCONN", TcGenQry(,, cFixQuery), cAlias, .f., .t.)
        
        while !(cAlias)->(Eof())
            if !Empty((cAlias)->VV2_MODVEI)
                cModVei := (cAlias)->VV2_MODVEI
            endif
            dbSkip()
        endDo

        (cAlias)->(DbCloseArea())


        if empty(cModVei)
            cModVei := OA5440168_RegistrarModelo(cModel, cCodMar)
        endif    

        freeObj(oStatement)
    end
Return cModvei

/*/{Protheus.doc} OA544009J_VerificaCorDoVeiculoParaGravacaoApartirDoFornecidoPelaApi
    Verifica se a cor fornecida pela api está na VVC já vai tratar também caso motor (retornar vazio)
    @type  Static Function
    @author Renan Migliaris
    @since 06/10/2025
/*/
Static Function OA544009J_VerificaCorDoVeiculoParaGravacaoApartirDoFornecidoPelaApi(nCorApi, cProdType, cCodMar)
    local cCodCor := StrZero(nCorApi,2) // cValToChar(nCorApi)
    local cCodRet := ''
    local cQuery := ''
    local cFixQuery := ''
    local cAlias := ''
    local cMyFil := xFilial("VVC")
    local oStatement := nil

    default nCorApi := 0

    oStatement := FWPreparedStatement():new()

    if cProdType == "3" //motor, cor vazia no cadastro
        cCodCor := ''
        return cCodCor
    endif

    if cProdType <> "3"

        cQuery := " SELECT "
        cQuery += "     VVC.VVC_CORVEI"
        cQuery += " FROM "
        cQuery += retsqlname("VVC") + " VVC " 
        cQuery += " WHERE "
        cQuery += "     VVC.D_E_L_E_T_  =  ? "
        cQuery += " AND "
        cQuery += "     VVC.VVC_CODMAR = ? "
        cQuery += " AND "
        cQuery += "     VVC.VVC_CORREN = ? "
        cQuery += " AND "
        cQuery += "     VVC.VVC_FILIAL = ? "

        oStatement:setQuery(cQuery)
        oStatement:setString(1, ' ')
        oStatement:setString(2, cCodMar)
        oStatement:setSTring(3, cCodCor)
        oStatement:setString(4, cMyFil)
        
        cFixQuery := oStatement:getFixQuery(cQuery)

        cAlias := GetNextAlias()

        dbUseArea(.t., "TOPCONN", TcGenQry(,, cFixQuery), cAlias, .f., .t.)

        while !(cAlias)->(Eof())
            if !Empty((cAlias)->VVC_CORVEI)
                cCodRet := (cAlias)->VVC_CORVEI
            endif

            dbSkip()
        endDo

        (cAlias)->(DbCloseArea())

        if empty(cCodRet)
            cCodRet := OA5440158_RegistrarCor(cCodCor, cCodMar)
        endif
    endif

    freeobj(oStatement)
Return cCodRet

/*/{Protheus.doc} OA544010J_FazAVerificacaoDosDadosSeremGravados
    Função que vai receber o json do veículo que vou enviar para o execAuto 
    Aqui eu vou ver algumas regras de negócio como por exemplo a questão da cor ou do modVei
    Caso estiver tudo ok, retorno .t.
    Caso contrário .f.
    Chamo aqui a verificação do CHASSIS pq os outros dados são usados para popular o Json e ai já aproveito isso verificando apenas se está vazio. 
    @type  Static Function
    @author Renan Migliaris
    @since 06/10/2025
/*/
Static Function OA544010J_FazAVerificacaoDosDadosSeremGravados(oVehicle)
    local lRet := .t.
    local cTypeVehicle := oVehicle["productType"]

	if Empty(oVehicle['VV1_CHASSI'])
		aadd(aErros, STR0006) //"Pré-cadastro de veículo não configurado"
		return .f.
	endif

    if cTypeVehicle <> "3" .and. Empty(oVehicle["VV1_CORVEI"])
        lRet := .f.
        aadd(aErros, STR0010) //'Veiculo não possui cor cadastrada'
    endif

    if Empty(oVehicle["VV1_MODVEI"])
        lRet := .f.
        aadd(aErros, STR0011) //'Veiculo Não Possui Modelo Cadastrado'
    endif

    if OA544012J_VerificaSeOChassisOuMotorJaEstaoCadastrados(oVehicle['VV1_CHASSI'])
        lRet := .f.
        aadd(aErros, STR0012) //'Veículo já cadastrado na base'
    endif
Return lRet

/*/{Protheus.doc} OA544011J_MontaErroDoHelpComRelacaoAosDadosDaBase
    Esse cara vai pegar o que veio das validações realziadas no OA544010J_FazAVerificacaoDosDadosSeremGravados
    Com os erros que fui adicionando na private aErros, aqui eu monto um help para mostrar o que falta na base
    Por exemplo, se for um caminhão ou onibus e o CORVEI não estiver cadastrado na VVC adiciono aqui e assim por diante
    @type  Static Function
    @author Renan Migliaris
    @since 06/10/2025
/*/
Static Function OA544011J_MontaErroDoHelpComRelacaoAosDadosDaBase()
    local cErrMsg := ''
    local nx := 0

    if len(aErros) > 0
        for nx := 1 to len(aErros)
            if !Empty(cErrMsg)
                cErrMsg += ' ,'
            endif
            cErrMsg += allTrim(aErros[nx])
        next    
    endif
Return cErrMsg


/*/{Protheus.doc} OA544012J_VerificaSeOChassisOuMotorJaEstaoCadastrados
    Antes de executar o cadastro na VV1, esses dados passam por uma série de validações
    A verificação do chassis é uma delas
    Nesse caso bato lá na tabela e vejo se existe um chassis/motor já cadastrados 
    Caso existir .f.
    Caso não existir .t.
    @type  Static Function
    @author Renan Migliaris
    @since 06/10/2025
/*/
Static Function OA544012J_VerificaSeOChassisOuMotorJaEstaoCadastrados(cChaMot)
    local lRet := .f.

    if valtype(cChaMot) == "C" 
        DbSelectArea("VV1")
        DbSetOrder(2) //procurando pelo VV1_CHASSI
        
        if DbSeek(xFilial('VV1')+cChaMot)
            lRet := .t.
        endif

        DbCloseArea()
    endif
Return lRet

/*/{Protheus.doc} OA544013J_SetaPropriedadesDaVV1ComoNaoObrigatorias
    Por atendimento a regra de negócio da integração 
    esse método vai receber o model e setar algumas propriedades como não obrigatórias
    Algumas informações não vêm da api e não poderão ser inclusas nesses campos obrigatórios
    @type  Static Function
    @author Renan Migliaris
    @since 07/10/2025
/*/
Function OA544013J_SetaPropriedadesDaVV1ComoNaoObrigatorias(oModel)
    oModel:getModel('MODEL_VV1'):GetStruct():SetProperty('VV1_COMVEI', MODEL_FIELD_OBRIGAT, .f.)
    oModel:getModel('MODEL_VV1'):GetStruct():SetProperty('VV1_PROVEI', MODEL_FIELD_OBRIGAT, .f.)
    oModel:getModel('MODEL_VV1'):GetStruct():SetProperty('VV1_ESTVEI', MODEL_FIELD_OBRIGAT, .f.)
    oModel:getMOdel('MODEL_VV1'):GetStruct():SetProperty('VV1_CORVEI', MODEL_FIELD_OBRIGAT, .f.) //por conta do motor
Return

/*/{Protheus.doc} OA544014J_VerificaPontosDeEntradaPreCadastroDeVeiculo
    Vai verificar quais pontos de entrada estão compilados no RPO para alimentar as variáveis de controle
    @type  Static Function
    @author Renan Migliaris
    @since 20/10/2025
/*/
Static Function OA544014J_VerificaPontosDeEntradaPreCadastroDeVeiculo()
    if ExistBlock("OF544PRE")
        lPrePe := .t.
    endif

    if ExistBlock("OF544POS")
        lPosPe := .t.
    endif
Return .t.

/*/{Protheus.doc} OA5440158_RegistrarCor
    Registra o grupo da cor (se necessário) e a cor para que o cadastramento do veiculo possa ser realizado
    @type  Static Function
    @author Paulo Roberto Alves Pereira
    @since 08/05/2026
/*/
Static Function OA5440158_RegistrarCor(cCodCor, cCodMar)
    local aArea, cCor, cGrupo, cAlias, cFil
    local cRet := ""    

	cCor := oResult["content"]["externalColour"]

    if valtype(cCodCor) == "C" .and. valtype(cCodMar) == "C" .and. valtype(cCor) == "C"
        aArea := FWGetArea()

        cCor := AvKey(cCor, "VVQ_DESCRI")
        cAlias := "VVQ"
        cFil := xFilial(cAlias)
        DbSelectArea(cAlias)
        (cAlias)->(DBSetOrder(1))	
        if (cAlias)->(dbseek(cFil + cCor)) 
            cGrupo := (cAlias)->VVQ_GRUCOR
        else
            RecLock(cAlias,.T.)
            (cAlias)->VVQ_FILIAL := cFil
            (cAlias)->VVQ_GRUCOR := GetSXENum(cAlias,"VVQ_GRUCOR")
            (cAlias)->VVQ_DESCRI := cCor
            cGrupo := (cAlias)->VVQ_GRUCOR
            (cAlias)->(MsUnLock())
            ConfirmSx8()
        EndIf
        
        cAlias := "VVC"
        cFil := xFilial(cAlias)
        DbSelectArea(cAlias)
        (cAlias)->(DBSetOrder(2))
        cCor := AvKey(oResult["content"]["externalColour"], "VVC_DESCRI")
        cCodMar := AvKey(cCodMar, "VVC_CODMAR")
        if (cAlias)->(dbseek(cFil + cCodMar + cCor)) .and. !Empty((cAlias)->VVC_CORVEI)
            cRet := cCodRet := (cAlias)->VVC_CORVEI
        else
            RecLock(cAlias,.T.)
            (cAlias)->VVC_FILIAL := cFil
            (cAlias)->VVC_CORVEI := GetSXENum(cAlias,"VVC_CORVEI")
            (cAlias)->VVC_DESCRI := cCor
            (cAlias)->VVC_GRUCOR := cGrupo    
            (cAlias)->VVC_CORREN := cCodCor
            (cAlias)->VVC_COREDI := cCodCor
            (cAlias)->VVC_CODMAR := cCodMar
            cRet := (cAlias)->VVC_CORVEI
            (cAlias)->(MsUnLock())
            ConfirmSx8()    
        endif

        FWRestArea(aArea)
    endif
Return cRet


/*/{Protheus.doc} OA5440168_RegistrarModelo
    Registra o modelo para que o cadastramento do veiculo possa ser realizado
    @type  Static Function
    @author Paulo Roberto Alves Pereira
    @since 12/05/2026
/*/
Static Function OA5440168_RegistrarModelo(cModel, cCodMar)
    local aArea, cAlias, cFil, cGruMod, nTamGruMod
    local cRet := ""    

    if valtype(cModel) == "C" .and. valtype(cCodMar) == "C"
        nTamGruMod := TamSX3("VVR_GRUMOD")[1]
        cGruMod := SubStr(cModel, 1, nTamGruMod)
        if SubStr(cGruMod, nTamGruMod-1, 1) = " " .and. SubStr(cGruMod, nTamGruMod, 1) <> " "
            cGruMod := SubStr(cGruMod, 1, nTamGruMod-2) + space(2)
        endif

        aArea := FWGetArea()
        cAlias := "VVR"
        cFil := xFilial(cAlias)
        DbSelectArea(cAlias)
        (cAlias)->(DBSetOrder(2))	
        if !(cAlias)->(dbseek(cFil + cCodMar + cGruMod)) 
            RecLock(cAlias,.T.)
            (cAlias)->VVR_FILIAL := cFil
            (cAlias)->VVR_CODMAR := cCodMar
            (cAlias)->VVR_GRUMOD := cGruMod
            (cAlias)->VVR_DESCRI := cModel
            (cAlias)->(MsUnLock())
            ConfirmSx8()
        EndIf	

        cAlias := "VV2"
        cFil := xFilial(cAlias)
        DbSelectArea(cAlias)
        (cAlias)->(DBSetOrder(3))	
        if (cAlias)->(dbseek(cFil + cCodMar + cGruMod)) 
            cRet := (cAlias)->VV2_MODVEI
        else
            RecLock(cAlias,.T.)
            (cAlias)->VV2_FILIAL := cFil
            (cAlias)->VV2_CODMAR := cCodMar
            (cAlias)->VV2_GRUMOD := cGruMod
            (cAlias)->VV2_MODVEI := cModel
            (cAlias)->VV2_DESMOD := cModel
            (cAlias)->VV2_MODFAB := cModel
            cRet := (cAlias)->VV2_MODVEI
            (cAlias)->(MsUnLock())
            ConfirmSx8()
        EndIf	    
        
        FWRestArea(aArea)
    endif
Return cRet


/*/{Protheus.doc} OA5440178_IntegrarSCOB
    Verifica se a integração com SCOB deve ser utilizada
    @type  Function
    @author Paulo Roberto Alves Pereira
    @since 15/05/2026
/*/

Function OA5440178_IntegrarSCOB(cPar)
local lRet := .F.
private oConfig
default cPar := GetNewPar("MV_MIL0006","")

	if (cPar == "SCA") .and. OA544001J_PegaConfigVrn()		
		lRet := oConfig["CFG_INTEGRACAO_ATIVA"] == "1"        
		freeObj(oConfig)		
	endif
    
Return lRet


/*/{Protheus.doc} OA5440188_ChamaAPI
    Faz a integração com a API SCOB realizando o pré-cadastro ou retornando os dados no array aInfoVei
    @type  Static Function
    @author Paulo Roberto Alves Pereira
    @since 05/06/2026
/*/

static Function OA5440188_ChamaAPI(oSay, cMotor, cChassis, lAuto, aInfoVei)
local lRet := .t.
local oVehicle := nil    

    OA544014J_VerificaPontosDeEntradaPreCadastroDeVeiculo() //verifica pontos de entrada e popula lPosPe e lPrePe

    aParams := OA544006J_MontaOArrayDeParametrosParaRequestDoVeiculo(alltrim(cMotor), alltrim(cChassis))

    if OA544001J_PegaConfigVrn() .and. oConfig["CFG_PRECADAUT"] == "1"
        if !lAuto .and. !IsBlind()
            oSay:SetText(STR0018 + " " + cChassis) // "Consultando chassi"
        endif
        OA544002J_RequisitaInformacaoDoVEiculoViaClient() //ele quem vai montar o oResult
        if oResult["status_code_res"] == "200"
            if valtype(aInfoVei) == "A"
                oVehicle := OA544007J_MontaDadosDoVeiculo()
                aInfoVei := {}
                aadd(aInfoVei, oVehicle['VV1_CODMAR'])
                aadd(aInfoVei, oVehicle['VV1_CHASSI'])
                aadd(aInfoVei, oVehicle['VV1_MODVEI'])
                aadd(aInfoVei, oVehicle["VV1_CORVEI"])
                aadd(aInfoVei, oVehicle["VV1_FABMOD"])
                aadd(aInfoVei, oVehicle["VV1_LOCPAD"])
                lRet := .T.
            else
                lRet := OA544003J_ExecutaPreCadastroDoVeiculo(lAuto, oSay)
            endif
        elseif oResult["status_code_res"] == "401"
            FMX_HELP("OFIA544001", STR0013, STR0014) //"Erro Autenticação" //"Verifique As Configurações Informadas Na Rotina OFIA541 (Tela Configurações Scania)"
            lRet := .f.
        else
            FMX_HELP("OFIA544002", STR0002, STR0003) //ERRO //"Parametros Enviados Não Encontrados! Verique o preenchimento e tente novamente"
            lRet := .f.
        endif
    elseif !OA544001J_PegaConfigVrn()
        FMX_HELP("OFIA544003", STR0002, STR0004) //ERRO //"Configuracao Api Scania Nao Realizada"
        lRet := .f.
    elseif oConfig["CFG_PRECADAUT"] <> "1"
        FMX_HELP("OFIA544004", STR0005, STR0006) //"Atenção" //"Pré-cadastro de veículo não configurado"
        lRet := .f.
    endif 
    
    freeObj(oClient)
    freeObj(oConfig)
    freeObj(oResult)
    fwFreeArray(aParams)
    
Return lRet

/*/{Protheus.doc} OA5440198_ChassiReduzido
    Extrai o chassi reduzido    
    @type   Function
    @author Paulo Roberto Alves Pereira
    @since 11/06/2026
/*/

Function OA5440198_ChassiReduzido(cChassi)
local nTam
local cReduzido := ""

    nTam := len(alltrim(cChassi))
	if nTam == TAM_CHASSI_REDUZIDO 
	    cReduzido := alltrim(cChassi)
    elseif nTam == TAM_CHASSI_COMPLETO
	    cReduzido := right(alltrim(cChassi),TAM_CHASSI_REDUZIDO)
    endif

Return cReduzido
