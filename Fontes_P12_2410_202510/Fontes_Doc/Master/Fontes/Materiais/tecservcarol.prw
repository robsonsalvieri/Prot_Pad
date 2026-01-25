#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TECSERVCAROL.CH"
//------------------------------------------------------------------------------
/*/{Protheus.doc} ServCarol
@author	Diego Bezerra
@since	10/04/2023
@description Classe utilizada para integrações entre o módulo Prestadores de Serviço Terceirização (GS) e
a plataforma Carol. 

    Como usar: 
    1) Instanciar a classe e passar o endereço da api da plataforma Carol:
    -- 
    -- Local cApiPath := 'pathdaapicarol'
    -- Local oServCarol := ServCarol():new(cApiPath)
    --
    2) Definir o conector:
    --
    -- oServCarol:defConector('codigodoconector')
    --
    3) Definir a organização:
    -- 
    -- oServCarol:defOrg('codigodaorganizacao')
    -- 
    4) Definir o dominio:
    -- 
    -- oServCarol:defDomin('codigododominio')
    --
    5) Definir usuário e senha de acesso:
    -- 
    -- oServCarol:defUser('username')
    -- oServCarol:defPw('password')
    -- 
    6) Definir endpoint de autenticação. cPathAuth não é obrigatório. Caso não seja informado, será considerado : /api/v3/oauth2/token
    -- 
    -- oServCarol:defEndpoint('cPathAuth')
    --
    7) Gerar apiKey: cPathAuthKey não é obrigatório. Caso não seja informado, será considerado: /api/v1/apiKey/issue
    -- 
    -- oServCarol:defAuthKey('cPathAuthKey')
    -- 
    8) Enviar dados para uma staging table (após autenticação). Apenas os parâmetros cTable e cBodyReq são obrigatórios. 
    --
    -- oServCarol:addStagingValue(cTable,cBodyReq,aParams,cConector,cEndPoint,cAuth,aCustomHeaders)
    --
    9) Buscar dados da tabela clockinrecords (staging table)
    -- 
**********************************************************************************/
Class ServCarol
    data lGeraLog        AS BOOLEAN
    data cNomeLog        AS CHARACTER
    data aLog            AS ARRAY
    /* 
        Endereço de Acesso ao EndPoint.
        pode ser definido pelo parâmetro MV_APICLO1 no protheus
    */
    data cBaseUrl       AS CHARACTER

    /*
        Patch de acesso ao EndPoint 
        pode ser definido pelo parâmetro MV_APICLO2 no protheus
    */
    data cPathW         AS CHARACTER
    
    /*
        Id do conector Carol
        pode ser definido pelo parâmetro MV_APICLO3 no protheus
    */
    data cConec        AS CHARACTER

    data cEndPoint     AS CHARACTER

    /*
        Username de acesso ao EndPoint
        pode ser definido pelo parâmetro MV_APICLO4 no protheus
    */
    data cUsern         AS CHARACTER

    /*
        Password de acesso ao EndPoint
        pode ser definido pelo parâmetro MV_APICLO5 no protheus
    */
    data cPassW         AS CHARACTER

    /*
        Domain name de acesso ao EndPoint
        pode ser definido pelo parâmetro MV_APICLO6 no protheus
    */
    data cDomin         AS CHARACTER

    /*
        Path do EndPoint DeviceList
        pode ser definido pelo parâmetro MV_APICLO7 no protheus
    */
    data cPathD         AS CHARACTER

    /*
        Path do EndPoint clockinrecordsList
        pode ser definido pelo parâmetro MV_APICLO8 no protheus
    */
    data cPathM         AS CHARACTER

    /*
        Nome da organização de acesso ao EndPoint
        pode ser definido pelo parâmetro MV_APICLO9 no protheus
    */
    data cOrg          AS CHARACTER
    data cOrgId        AS CHARACTER

    data cTenantId     AS CHARACTER
    
    // .T. == token válido
    data lApiToken     AS BOOLEAN
    
    /*
        Código do apiToken (conector token)
        pode ser obtido pelo parâmetro MV_APICLOA no protheus
    */
    data cApiToken      AS CHARACTER

    /*
        Tamanho da pagina de retorno da API
    */
    data cPageSize      AS CHARACTER

    data cToken         AS CHARACTER

    //X-Auth-Key
    data cAuthKey       AS CHARACTER

    //X-Auth-ConnectorId
    data cConnectorId    AS CHARACTER

    data lOrgExist      AS LOGICAL
    data lHasError      AS LOGICAL
    data cLasMsgErr     AS CHARACTER // "{method:}"
    data aError         AS ARRAY
    data lError         AS LOGICAL
    
    method new()
    method genClientRest()
    method auth()

    method getBaseUrl()
    method getEndpoint()
    method getAuthToken()
    method getAuthKey()
    method getUser()
    method getPw()
    method getConector()
    method getOrg()
    method getDomin()
    method getError()
    method getLError()
    method getMark()

    method defAuthToken()
    //method defBaseUrl()
    method defEndpoint()
    method defConector()
    method defUser()
    method defPw()
    method defOrg()
    method defOrgId()
    method defTenantId()
    method defDomin()
    method defAuthKey()
    method defError()
    method defLError()
    method defLToken()
    method defLog()

    method defApiToken()
    method getApiToken()
    method validToken()

    method getAppointments()
    
    method getOrgId()

    method getTenantId()
    method setTenantId()
    method query()
    method queryPolling()

    method gerarLog()
    
    method createUser()
    method resetPassword()  

    /* Método para gravar valores em staging tables na plataforma carol */
    method addStagingValue()
    /* Envia convite para utilização da plataforma carol */
    method sendUserInvite()
    /* Retorna logs de acesso de todos os usuários */
    method userLogs()
endClass

// Construtor da classe
method new(cBaseUrl,cAuthKey, cConnId, lGeraLog, cNomeLog) class ServCarol
    Default cAuthKey    := ''
    Default cConnId     := ''
    Default lGeraLog    := .F.
    Default cNomeLog    := 'integracaocarol'

    ::cBaseUrl      := cBaseUrl
    ::cEndPoint     := ""
    ::cPathW        := ""
    ::cConec        := ""
    ::cUsern        := ""
    ::cPassW        := ""
    ::cDomin        := ""
    ::cPathD        := ""
    ::cPathM        := ""
    ::cApiToken     := ""
    ::cPageSize     := 100
    ::cToken        := ""
    ::cAuthKey      := cAuthKey
    ::cOrg          := ""
    ::cOrgId        := ""
    ::cTenantId     := ""
    ::lApiToken     := .F.
    ::lOrgExist     := .F.
    ::aError        := {}
    ::lError        := .F.
    ::cAuthKey      := cAuthKey
    ::cConnectorId  := cConnId
    ::aLog          := {}
    ::lGeraLog      := lGeraLog
    ::cNomeLog      := cNomeLog
    
return

/**************************************************
                    DEF VALUES
***************************************************/
method defEndpoint(cSetValue) class ServCarol
    IF VALTYPE(cSetValue) == 'C'
        ::cEndpoint := cSetValue
    EndIf
return ::cEndpoint

method defConector(cSetValue) class ServCarol
    IF VALTYPE(cSetValue) == 'C'
        ::cConec := cSetValue
    EndIf
return ::cConec

method defUser(cSetValue) class ServCarol
    IF VALTYPE(cSetValue) == 'C'
        ::cUsern := cSetValue
    EndIf
return ::cUsern

method defPw(cSetValue) class ServCarol
    IF VALTYPE(cSetValue) == 'C'
        ::cPassW := cSetValue
    EndIf
return ::cPassW

method defOrg(cSetValue) class ServCarol
    IF VALTYPE(cSetValue) == 'C'
        ::cOrg := cSetValue
    EndIf
return ::cOrg

method defDomin(cSetValue) class ServCarol
    IF VALTYPE(cSetValue) == 'C'
        ::cDomin := cSetValue
    EndIf
return ::cDomin

method defAuthToken(cSetValue) class ServCarol
    IF VALTYPE(cSetValue) == 'C'
        ::cToken := cSetValue
    EndIf
return ::cToken

method defApiToken(cToken) class ServCarol
    Local cMsg := ''
    cMsg += DTOS(DDATABASE)
    If(VALTYPE(cToken)=='C')
        ::cApiToken := cToken
    EndIf
Return cToken

/* Tentativa de gerar apikey para autenticação.*/
method defAuthKey(cEndPoint) class ServCarol
    Local aHeader	:= {}
    Local cParams	:= ""
    Local cRet		:= ""
    Local oClient	:= ::genClientRest()
    Local oObj		:= Nil
    Local oRet		:= JsonObject():New()
    Local cMsgLog   := ""
    Local cTable    := ""

    Default cEndPoint   := "/api/v1/apiKey/issue"
    
    If !Empty(::getAuthToken()) .OR. !::lApiToken
        
        cParams := "connectorId=" + ::getConector() + "&
        cParams += "description=%7B%22en-US%22%3A%22API%20Token%20Protheus%22%7D"
        
        aAdd( aHeader, "Accept: application/json" )
        aAdd( aHeader, "Authorization:" + ::getAuthToken() )
        aAdd( aHeader, "Content-type: application/x-www-form-urlencoded" )
        aAdd( aHeader, "Origin:" + ::getBaseUrl() )
        aAdd( aHeader, "Referer:" + ::getBaseUrl() + "/" + ::getOrg() + "/carol-ui/environment/connector-tokens" )

        oClient:SetPath(cEndPoint)
        oClient:SetPostParams(cParams)
        oClient:Post(aHeader)
        cRet := oClient:GetResult()
        If FWJsonDeserialize(cRet, @oObj)
            If oObj <> Nil
                If oRet:fromJson(cRet) == Nil .And. oRet["errorCode"] == Nil
                    ::cAuthKey := oRet["X-Auth-Key"]
                    PutMv("MV_APICLOA",::cAuthKey)
				EndIf 
            EndIf
        EndIf

        If ::lGeraLog
            If VAL(oClient:oResponseh:cStatusCode) >= 200
                cMsgLog += DTOS(DDATABASE) + CRLF 
                cMsgLog += 'Tabela: ' + cTable + CRLF
                cMsgLog += 'Sucesso na inclusão' + CRLF 
                cMsgLog += '########################' + CRLF 

                ::defLog('Inclusão de registro na plataforma Carol', cMsgLog)
            Else
                cMsgLog += DTOS(DDATABASE) + CRLF 
                cMsgLog += 'Tabela: ' + cTable + CRLF
                cMsgLog += 'Erro na inclusão' + CRLF 
                cMsgLog += '########################' + CRLF 
                ::defLog('Erro na Inclusão de registro na plataforma Carol', cMsgLog)
            EndIf
        EndIf
    Else
        ::defError('Autenticação','Não foi possível gerar o token de autenticação' + CRLF + 'Código do erro: '+ oClient:oResponseh:cStatusCode + CRLF) 
    EndIf
return ::cAuthKey

// Grava log para ser processado, em arquivo, posteriormente
method defLog(cMethod, cMsg) class ServCarol
    Local cLog := ""
    
    cLog += '#### Processamento ####' + CRLF
    cLog += 'Método: ' + cMethod + CRLF
    cLog += cMsg + CRLF 
    cLog += '#### FIM ####' + CRLF 
    AADD(::aLog, cLog )
return cLog

// Define mensagem de erro para ser processada ou não em arquivo
method defError(cMethod,cMsg) class ServCarol
    Local cLog := ""
    If ::lGeraLog
        cLog += '###### ERRO #######' 
        cLog += 'Método :' + cMethod + CRLF
        cLog += cMsg + CRLF
        cLog += '###### FIM ########' + CRLF
        AADD(::aLog, cLog )
    EndIf
    IF VALTYPE(cMethod) == 'C' .AND. VALTYPE(cMsg) == 'C'
        AADD(::aError,{cMethod, cMsg})
    EndIf
return cLog

method defLError(lError) class ServCarol
    If VALTYPE(lError) == 'L'
        ::lError := lError
    EndIf
Return ::lError

method defLToken(lApiToken) class ServCarol
    If VALTYPE(lApiToken) == 'L'
        ::lApiToken := lApiToken
    EndIf
Return ::lApiToken

method defOrgId(cOrgId) class ServCarol
    If VALTYPE(cOrgId) == 'C'
        ::cOrgId := cOrgId
    EndIf
Return cOrgId

method defTenantId(cTenantId) class ServCarol
    If VALTYPE(cTenantId) == 'C'
        ::cTenantId := cTenantId
    EndIf
Return cTenantId

/**************************************************
                    GET VALUES
***************************************************/

method getEndpoint() class ServCarol
return ::cEndpoint

method getConector() class ServCarol
return ::cConec

method getBaseUrl() class ServCarol
return ::cBaseUrl

method getUser() class ServCarol
return ::cUsern

method getPw() class ServCarol
return ::cPassW

method getOrg() class ServCarol
return ::cOrg

method getDomin() class ServCarol
return ::cDomin

method getAuthToken() class ServCarol
return ::cToken

method getAuthKey() class ServCarol
return ::cAuthKey

method genClientRest() class ServCarol
    Local oClient := FwRest():New(::getBaseUrl())
    oClient:SetPath(::getEndpoint())
Return oClient

method getLError() class ServCarol
Return ::lError

method getError() class ServCarol
return ::aError

method getApiToken() class ServCarol
Return ::cApiToken

/* Autenticação */
method auth(cPath,cAuthType,cParamKey,lGeraToken,cTknApiEnd) class ServCarol
    Local aHeader   := {}
    Local cParams   := ""
    Local cResponse := ""
    Local cMsgErr   := ""
    Local oRest     := Nil
    Local oResp     := Nil
    Local oRet      := JsonObject():New()

    Default cPath       := "/api/v3/oauth2/token"
    Default cAuthType   := 'user' //user - chaveAuth
    Default cParamKey   := "MV_APICLOA"         
    Default cTknApiEnd  := "/api/v1/apiKey/issue"
    Default lGeraToken  := .F.

    ::defEndPoint(cPath)

    oRest := ::genClientRest()
    // A autenticação não é necessária, com usuario e senha, caso o token de api ainda esteja válido
    If cAuthType == 'user'
        AAdd( aHeader, "Accept: application/json" )
	    AAdd( aHeader, "Content-Type: application/x-www-form-urlencoded" )
        
        cParams := "grant_type=password&"
        cParams += "connectorId=" + ::getConector() + "&"
        cParams += "username=" + ::getUser() + "&"
        cParams += "password=" + ::getPw() + "&"
        cParams += "subdomain=" + AllTrim(::getOrg()) + "&"
        cParams += "orgSubdomain=" + ::getDomin()
        oRest:SetPostParams(cParams)

        If oRest:Post(aHeader)
            If FWJsonDeserialize(oRest:GetResult(),@oResp)
                If oResp <> NIL
                    cResponse := oRest:GetResult()
                    oRet:fromJson(cResponse)
                    If AttIsMemberOf(oResp, 'ACCESS_TOKEN') .AND. oResp:ACCESS_TOKEN <> ''
                        ::defAuthToken(oResp:ACCESS_TOKEN)
                         If lGeraToken
                            ::defAuthKey(cTknApiEnd,cParamKey)
                         EndIf
                    EndIf
                EndIf
            EndIf
        Else
            If VAL(oRest:oResponseh:cStatusCode) > 299
                ::defLError(.T.)
                cMsgErr += STR0001 + CRLF //'Problema na autenticação. '
                cMsgErr += 'Reponse code: ' + oRest:oResponseh:cStatusCode + CRLF
                ::defError('Auth',cMsgErr)  
            EndIf
        EndIf
    EndIf
return

/* Inclusão de valores em staging table, na plataforma Carol*/
method addStagingValue(cTable,cBodyReq,aParams,cConector,cEndPoint,cAuth,aCustomHeader) class ServCarol
    Local aHeaders	:= {}
    Local oClient	:= ::genClientRest()
    Local nI        := 1
    Local cUrlPar   := ""
    Local cResult   := ""
    Local cMsgLog   := ""

    Default aParams         := {}
    Default cEndPoint       := "/api/v3/staging/intake/"
    Default cBodyReq        := ""
    Default cConector       := ::getConector()
    Default aCustomHeader   := {}
    
    // cTable é a stagin table dentro da plataforma carol 
    // cEndpoint + cTable forma o endpoint de cada stagin table
    cEndPoint += cTable
    For nI := 1 to Len(aParams)
        If nI == 1
            cUrlPar += '?'
        EndIf
        cUrlPar += aParams[nI][1] + "=" + aParams[nI][2] 
        If nI < Len(aParams)
            cUrlPar += '&'
        EndIf
    Next nI
    
    aAdd( aHeaders, "Accept: application/json" )
    aAdd( aHeaders, "Content-type: application/json" )

    If ::lApiToken
        aAdd(aHeaders, 'X-Auth-Key: ' + ::getApiToken() )
        aAdd(aHeaders, 'X-Auth-ConnectorId: ' + ::getConector() )
    Else
        aAdd(aHeaders, 'Authorization: Bearer ' + ::getAuthToken() )
    EndIf

    oClient:SetPath(cEndPoint+cUrlPar)
    oClient:setPostParams(EncodeUTF8(cBodyReq))
    oClient:Post(aHeaders)
    cResult := oClient:GetResult()

    If ::lGeraLog
        If VAL(oClient:oResponseh:cStatusCode) >= 200
            cMsgLog += DTOS(DDATABASE) + CRLF 
            cMsgLog += 'Tabela: ' + cTable + CRLF
            cMsgLog += 'Sucesso na inclusão' + CRLF 
            cMsgLog += '########################' + CRLF 

            ::defLog('Inclusão de registro na plataforma Carol', cMsgLog)
        Else
            cMsgLog += DTOS(DDATABASE) + CRLF 
            cMsgLog += 'Tabela: ' + cTable + CRLF
            cMsgLog += 'Erro na inclusão' + CRLF 
            cMsgLog += cResult
            cMsgLog += '########################' + CRLF 
            ::defLog('Erro na Inclusão de registro na plataforma Carol', cMsgLog)
        EndIf
    EndIf
return cResult

/* Inclusão de valores em staging table, na plataforma Carol*/
method sendUserInvite(cInviteType,cEmail,cUrl,cRoleName,cEndPoint) class ServCarol
    Local aHeaders	:= {}
    Local oClient	:= ::genClientRest()
    Local cResult   := ""
    Local cParams   := ""
    Local cMsgLog   := ""

    Default cEndPoint       := "/api/v3/users/invites"
    
    cParams += "inviteType=" + cInviteType + "&"
    cParams += "email=" + cEmail + "&"
    cParams += "url=" + cUrl + "&"
    cParams += "roleNames=" + cRoleName

    oClient:SetPostParamns(cParams)

    aAdd( aHeaders, "Accept: application/json" )
    AAdd( aHeaders, "Content-Type: application/x-www-form-urlencoded" )

    If ::lApiToken
        aAdd(aHeaders, 'X-Auth-Key: ' + ::getApiToken() )
        aAdd(aHeaders, 'X-Auth-ConnectorId: ' + ::getConector() )
    Else
        aAdd(aHeaders, 'Authorization: Bearer ' + ::getAuthToken() )
    EndIf

    oClient:SetPath(cEndPoint)
    oClient:Post(aHeaders)
    cResult := oClient:GetResult()

    If ::lGeraLog
        If VAL(oClient:oResponseh:cStatusCode) >= 200
            cMsgLog += DTOS(DDATABASE) + CRLF 
            cMsgLog += 'Email: ' + cEmail + CRLF
            cMsgLog += 'Sucesso no envio' + CRLF 
            cMsgLog += '########################' + CRLF 

            ::defLog('Envio de convite para utilização do aplicativo meu posto de trabalho by carol', cMsgLog)
        Else
            cMsgLog += DTOS(DDATABASE) + CRLF 
            cMsgLog += 'Tabela: ' + cEmail + CRLF
            cMsgLog += 'Erro no envio' + CRLF 
            cMsgLog += cResult
            cMsgLog += '########################' + CRLF 
            ::defLog('Erro no envio de convite para utilização do aplicativo meu posto de trabalho by carol', cMsgLog)
        EndIf
    EndIf
return cResult

/* Retorna logs de acesso de todos os usuários */
/* method userLogs(cEndPoint, nOffset, nPageSize, cOrder) class ServCarol
    Local aHeader	:= {}
    Local oClient	:= ::genClientRest()
    Local cResult   := ""
    Local cParams   := ""
    
    Default cEndPoint   := "/api/v3/users"
    Default nOffSet     := 0
    Default nPageSize   := 10
    Default cOrder      := 'ASC'
    
    cParams += "offset=" + cValToChar(nOffset) + "&"
    cParams += "pageSize=" + cValToChar(nPageSize) + "&"
    cParams += "sortOrder=" + cOrder

    oClient:SetPostParamns(cParams)

    aAdd( aHeader, "Accept: application/json" )
    AAdd( aHeader, "Content-Type: application/json" )
    aAdd( aHeader, "Authorization: Bearer " + ::getAuthToken() )

    oClient:SetPath(cEndPoint)
    oClient:Post(aHeader)
    cResult := oClient:GetResult()
    
return cResult
*/
// Consumir dados da namedquery meuposto_mesa
// Body Exemplo: {"initialDate":"2023-04-24","finalDate":"2023-04-24"}
method getAppointments(initialDate, finalDate, pageSize, sortOrder, cOffset, scrolable) class ServCarol

    Local aHeader       := {}
    Local oClient       := ::genClientRest()
    Local cResult       := ""
    Local cParams       := ""
    Local cBody         := ""
    Local oResponse
    Local aMark         := {}
    Local nCountRegs    := 0
    Local aTmp          := {}

    Default pageSize    := '10'
    Default sortOrder   := 'ASC'
    Default scrolable   := 'true'
    Default cOffset     := '0'
    Default cEndPoint   := "/api/v3/queries/named/meuposto_mesa"
    Default cFields	    := 'fields=mdmGoldenFieldAndValues.appname,mdmGoldenFieldAndValues.piscode,mdmGoldenFieldAndValues.nsrcode,mdmGoldenFieldAndValues.mdmeventdate,mdmGoldenFieldAndValues.eventdatestr,mdmGoldenFieldAndValues.mdmpersonid,mdmGoldenFieldAndValues.mdmname,mdmGoldenFieldAndValues.devicedescription,mdmGoldenFieldAndValues.mdmname,mdmGoldenFieldAndValues.devicecode,mdmGoldenFieldAndValues.coordinates,mdmGoldenFieldAndValues.isuserinsidegeofenceenum'

    cParams += 'offset=' + cOffset + '&'
    cParams += 'pageSize=' + pageSize + '&'
    cParams += 'sortOrder=' + sortOrder + '&'
    cParams += 'scrolable=' + scrolable
    cParams += cFields

    cEndPoint += '?'+cFields+'&sortOrder='+sortOrder

    cBody += '{"initialDate":"'+initialDate+'","finalDate":"'+finalDate+'"}'

    aAdd( aHeader, "Accept: application/json" )
    aAdd( aHeader, "Content-Type: application/json" )

    If ::lApiToken
        aAdd(aHeader, 'X-Auth-Key: ' + ::getApiToken() )
        aAdd(aHeader, 'X-Auth-ConnectorId: ' + ::getConector() )
    Else
        aAdd(aHeader, 'Authorization: Bearer ' + ::getAuthToken() )
    EndIf
   
    oClient:SetPath(cEndPoint)
    oClient:SetPostParams(EncodeUTF8(cBody))
    If oClient:Post(aHeader)
        If FWJsonDeserialize(oClient:GetResult(),@oResponse)
            cResult := oClient:GetResult()
            If oResponse["count"] > 0
                // Adicionar valores no array de marcações
                For nCountRegs := 1 to Len(oResponse["hits"])
                    aTmp := {}
                    If oResponse["hits"][nCountRegs]["mdmGoldenFieldAndValues"]["appname"] == "Meu Posto By Carol"
                        aAdd(aTmp,oResponse["hits"][nCountRegs]["mdmGoldenFieldAndValues"]["mdmeventdate"])
                        aAdd(aTmp,oResponse["hits"][nCountRegs]["mdmGoldenFieldAndValues"]["mdmpersonid"])
                        aAdd(aTmp,oResponse["hits"][nCountRegs]["mdmGoldenFieldAndValues"]["devicecode"])

                        If AttIsMemberOf(oResponse["hits"][nCountRegs]["mdmGoldenFieldAndValues"], "coordinates") .AND. ;
                                ValType(oResponse["hits"][nCountRegs]["mdmGoldenFieldAndValues"]["coordinates"]) != "U"
                                aAdd(aTmp,oResponse["hits"][nCountRegs]["mdmGoldenFieldAndValues"]["coordinates"]["lon"])
                                aAdd(aTmp,oResponse["hits"][nCountRegs]["mdmGoldenFieldAndValues"]["coordinates"]["lat"])
                                aAdd(aTmp, oResponse["hits"][nCountRegs]["mdmGoldenFieldAndValues"]["isuserinsidegeofenceenum"])
                        EndIf
                        aAdd(aMark, aTmp)
                    EndIf
                Next nCountRegs
            EndIf
        EndIf
    EndIF

return aMark

// Obtem o id da tenant, passando o nome da org
method getTenantId(cOrgname, cEndPoint) class ServCarol

Local cTenantId     := ''
Local aHeaders      := {}
Local cParams       := ''
Local cResult       := ''
Local oClient       := ::genClientRest()
Local oJson         := JsonObject():New()

Default cEndPoint   := '/api/v3/tenants/domain/' + cOrgname

aAdd(aHeaders, 'Accept: */*')
If ::lApiToken
    aAdd(aHeaders, 'X-Auth-Key: ' + ::getApiToken() )
    aAdd(aHeaders, 'X-Auth-ConnectorId: ' + ::getConector() )
Else
    aAdd(aHeaders, 'Authorization: Bearer ' + ::getAuthToken() )
EndIf

oClient:SetPath(cEndPoint)
oClient:Get(aHeaders,cParams)

If !Empty(cResult := oClient:GetResult())
    oJson:fromJson(cResult)
    If !Empty(oJson['mdmId'])
        cTenantId := ::defTenantId(oJson['mdmId'])
    EndIf
EndIf

Return cTenantId

// Obtem o id da org, passando o nome da org
method getOrgId(cOrgname, cEndPoint) class ServCarol

Local cOrgId        := ''
Local aHeaders      := {}
Local cParams       := ''
Local cResult       := ""
Local oClient       := ::genClientRest()
Local oJson         := JsonObject():New()

Default cEndPoint   := '/api/v3/organizations/domain/'+cOrgname

aAdd(aHeaders, 'Accept: */*')
If ::lApiToken
    aAdd(aHeaders, 'X-Auth-Key: ' + ::getApiToken() )
    aAdd(aHeaders, 'X-Auth-ConnectorId: ' + ::getConector() )
Else
    aAdd(aHeaders, 'Authorization: Bearer ' + ::getAuthToken() )
EndIf
oClient:SetPath(cEndPoint)
oClient:Get(aHeaders,cParams)

If !Empty(cResult := oClient:GetResult())
    oJson:fromJson(cResult)
    If !Empty(oJson['mdmId'])
        cOrgId := ::defOrgId(oJson['mdmId'])
    EndIf
EndIf

Return cOrgId

// Realiza o post da query que será executada pela plataforma Caorl
// Ao realizar o post da query, assim que for executada, será possível
// recuperar o resultado, utilizando o método queryPolling, passando o id da query
method query(cQuery, cEndPoint, nPageSize) class ServCarol

Local cBody         := '{'
Local cResult       := ''
Local aHeaders      := {}
Local oClient       := ::genClientRest()
Local oResponse     := JsonObject():New()
Local cQueryId      := ''

Default cEndPoint   := '/api/v1/bigQuery/query'
Default nPageSize   := 25

cBody += '"mdmOrgId":"' + ::cOrgId + '",'
cBody += '"mdmTenantId":"' + ::cTenantId + '",'
cBody += '"pageSize":' + CVALTOCHAR( nPageSize ) + ','
cBody += '"query":"'+cQuery+'"'
cBody += '}'

aAdd(aHeaders, 'Accept: */*')
aAdd(aHeaders, "Content-type: application/json")
If ::lApiToken
    aAdd(aHeaders, 'X-Auth-Key: ' + ::getApiToken() )
    aAdd(aHeaders, 'X-Auth-ConnectorId: ' + ::getConector() )
Else
    aAdd(aHeaders, 'Authorization: Bearer ' + ::getAuthToken() )
EndIf

oClient:setPath(cEndPoint)
oClient:SetPostParams(EncodeUTF8(cBody))
oClient:Post(aHeaders)
If Valtype(oClient:oResponseh:cStatusCode)=='C'
    If VAL(oClient:oResponseh:cStatusCode) >= 200 .AND. VAL(oClient:oResponseh:cStatusCode) <= 299
        cResult := oClient:GetResult()
        oResponse:fromJson(cResult)
        cQueryId := oResponse['queryId']
    Else
        ::defError('query','Não foi possivel executar a query. Stayts code ' + oClient:oResponseh:cStatusCode)
    EndIf
EndIf

Return cQueryId

// Retorna o resultado da query, executada na plataforma caral
// É necessário informar o id da query
method queryPolling(cQueryId,cEndPoint,nPage,nRecLimit,lValidToken) class ServCarol

Local cBody         := ''
Local aHeaders      := {}
Local oClient       := ::genClientRest()
Local oResponse     := Nil
Local aRows         := {}

Default nRecLimit   := 5 //limite de recursividade
Default nPage       := 1
Default cEndPoint   := '/api/v1/bigQuery/query_polling'

cBody += '{'
cBody += '"queryId":"'+cQueryid+'",'
cBody += '"page":"'+CVALTOCHAR(nPage)+'"'
cBody += '}'

If nRecLimit > 0

    Sleep(2000)
    aAdd(aHeaders, 'Accept: */*')
    aAdd(aHeaders, "Content-type: application/json")
    If ::lApiToken
        aAdd(aHeaders, 'X-Auth-Key: ' + ::getApiToken() )
        aAdd(aHeaders, 'X-Auth-ConnectorId: ' + ::getConector() )
    Else
        aAdd(aHeaders, 'Authorization: Bearer ' + ::getAuthToken() )
    EndIf

    oClient:setPath(cEndPoint)
    oClient:SetPostParams(EncodeUTF8(cBody))
    oClient:Post(aHeaders)

    If Valtype(oClient:oResponseh:cStatusCode) == 'C'
        If VAL(oClient:oResponseh:cStatusCode) >= 200;
                .AND. VAL(oClient:oResponseh:cStatusCode) <= 299
            FWJsonDeserialize(oClient:GetResult(),@oResponse)
            If AttIsMemberOf(oResponse, 'queryPending')
                nRecLimit := nRecLimit - 1
                ::queryPolling(cQueryId,cEndPoint,nPage,nRecLimit)
            Else
                aRows := oResponse['rows']
            EndIf
        EndIf
    EndIf
EndIf

Return aRows

//Obtem os apontamentos da staging table clockinrecords
method getMark(initialDate, finalDate, query, pageSize, sortOrder, cOffset, scrolable) class ServCarol

Local aMark         := {}
Local nCountRegs    := 0
Local aTmp          := {}
Local cTenantId     := ""
Local cOrgId        := ""
Local cQryId        := ""
Local aRows         := {}

Default pageSize  := '10'
Default sortOrder := 'ASC'
Default scrolable := 'true'
Default cOffset   := '0'
Default cEndPoint := "/api/v3/queries/named/meuposto_mesa"
Default cFields	:= 'fields=mdmGoldenFieldAndValues.appname,mdmGoldenFieldAndValues.piscode,mdmGoldenFieldAndValues.nsrcode,mdmGoldenFieldAndValues.mdmeventdate,mdmGoldenFieldAndValues.eventdatestr,mdmGoldenFieldAndValues.mdmpersonid,mdmGoldenFieldAndValues.mdmname,mdmGoldenFieldAndValues.devicedescription,mdmGoldenFieldAndValues.mdmname,mdmGoldenFieldAndValues.devicecode,mdmGoldenFieldAndValues.coordinates,mdmGoldenFieldAndValues.isuserinsidegeofenceenum'

cTenantId   := ::getTenantId(/*cOrgname*/::getOrg(),/*cEndPoint*/) 
cOrgId      := ::getOrgId(/*cDomin*/::getDomin(),/*cEndPoint*/)
cQryId      := ::query(query)
aRows       := ::queryPolling(cQryId,'/api/v1/bigQuery/query_polling')

If Len(aRows) > 0
    // Adicionar valores no array de marcações
    For nCountRegs := 1 to Len(aRows)
        aTmp := {}
        aAdd(aTmp,aRows[nCountRegs]["clockinDatetimeStr"])
        aAdd(aTmp,aRows[nCountRegs]["employeePersonId"])
        aAdd(aTmp,aRows[nCountRegs]["deviceCode"])

        aAdd(aTmp,aRows[nCountRegs]["latitude"])
        aAdd(aTmp,aRows[nCountRegs]["longitude"])
        aAdd(aTmp,"")
        aAdd(aMark, aTmp)
    Next nCountRegs
EndIf

return aMark

//
method validToken(token, cEndPoint) class ServCarol

Local aHeaders       := {}
Local lRet          := .F.
Local oClient       := ::genClientRest()
Local oResponse     := JsonObject():New()
Local oObj          := Nil
Local cParams       := ""
Local cMsg          := ""

Default token       := ""
Default cEndPoint   := "/api/v3/apiKey/details"

cParams += "apiKey=" + token + "&"
cParams += "connectorId=" + ::getConector()

If !Empty(token) .AND. VALTYPE(token) == 'C' .AND. !Empty(::getConector())
    AAdd( aHeaders, "Accept: */*" )
	AAdd( aHeaders, "X-Auth-Key: " + token )
	AAdd( aHeaders, "X-Auth-ConnectorId: " + ::getConector() )

    oClient:setPath(cEndPoint)
    oClient:Get(aHeaders, cParams)

    If FWJsonDeserialize(oClient:GetResult(),@oObj)
       If oObj <> Nil
            cRet := oClient:GetResult()
            If oResponse:fromJson(cRet) == Nil .AND. oResponse['errorCode'] == Nil
                ::defLToken(.T.)
                lRet    := .T.
            EndIf
       EndIf 
    EndIf

    If ::lGeraLog
        If lRet 
            cMsg += 'Token validado com sucesso'
        Else
            cMsg += 'Erro na validação do token'
        EndIf
        ::defLog('Validação de token de API', cMsg)
    EndIf 
EndIf

return lRet

// Gera arquivo de log 
method gerarLog(cNomeArq) class ServCarol

    Local nLenArq		:= 0
    Local nI			:= 0
    Local nHandle		:= 0
    Local cLogPatch		:= GetSrvProfString("Startpath","")

    Default cNomeArq	:= ::cNomeLog

    If Len(::aLog) > 0 .And. !Empty(cNomeArq)
        nLenArq := Len(::aLog)
        If (nHandle := fopen(cLogPatch + cNomeArq + ".txt",2,Nil,.F.)) == -1
            If (nHandle := FCREATE(cLogPatch + cNomeArq + ".txt",,Nil,.F.)) != -1
                FSeek(nHandle, 0, 2)
                For nI:=1 To nLenArq
                    FWrite(nHandle, ::aLog[nI] + CRLF )
                Next
                FWrite(nHandle,CRLF)
            EndIf
        Else
            FSeek(nHandle, 0, 2)
            For nI:=1 To nLenArq
                FWrite(nHandle, ::aLog[nI] + CRLF )
            Next
            FWrite(nHandle,CRLF)
        EndIf

        fClose(nHandle)
    EndIf

    aLog := {}
Return

// Redefinição de senha de usuário, na plataforma carol
method resetPassword(cUserName, cEndPoint) class ServCarol
    Local aHeaders      := {}
    Local oClient       := ::genClientRest()
    Local cParams       := ""
    Local cMsgLog       := ""
    Local cResult       := ""

    Default cEndPoint :=  '/api/v1/users/passwordResetRequests

    aAdd( aHeaders, "Accept: application/json" )
    aAdd( aHeaders, "Content-Type: application/x-www-form-urlencoded" )

    If ::lApiToken
        aAdd(aHeaders, 'X-Auth-Key: ' + ::getApiToken() )
        aAdd(aHeaders, 'X-Auth-ConnectorId: ' + ::getConector() )
    Else
        aAdd(aHeaders, 'Authorization: Bearer ' + ::getAuthToken() )
    EndIf

    cParams += 'passwordResetRequestType=PASSWORD_EXPIRED&'
    cParams += 'subdomain=' + ::getOrg() + '&'
    cParams += 'orgSubdomain=meuposto&email=' + cUserName + '&'
    cParams += 'mailLocale=pt_BR&'
    cParams += 'url=https%3A%2F%2Fmeuposto.carol.ai%2Fauth%2Fchange-password'

    oClient:SetPostParamns(cParams)
    oClient:SetPath(cEndPoint)
    oClient:Post(aHeaders)
    cResult := oClient:GetResult()

    if ::lGeraLog
        If VAL(oClient:oResponseh:cStatusCode) >= 200 .AND. VAL(oClient:oResponseh:cStatusCode) <= 299 
            cMsgLog += DTOS(DDATABASE) + CRLF 
            cMsgLog += 'Usuario: ' + cUserName + CRLF
            cMsgLog += 'Sucesso no envio de reset de senha' + CRLF 
            cMsgLog += '########################' + CRLF

            ::defLog('Reset de senha enviado com sucesso para o usuário ' + cUserName, cMsgLog) 
        Else
            cMsgLog += DTOS(DDATABASE) + CRLF
            cMsgLog += 'Usuario: ' + cUserName + CRLF
            cMsgLog += cResult
            cMsgLog += '########################' + CRLF 
            
            ::defLog('Não foi possível enviar reset de senha para o usuario ' + cUserName, cMsgLog)
        EndIf
    EndIf

return cResult

// Criação de usuário na plataforma carol
method createUser(cBodyReq,cUser,cEndPoint,lResetPw) class ServCarol
    Local aHeaders      := {}
    Local oClient       := ::genClientRest()
    Local cMsgLog       := ""
    Local success       := 0 // 1 == criado, 2 == existente, 0 == erro
    Local oJsonResp     := NIL

    Default cUser       := ''
    Default lResetPw    := .T.
    Default cEndPoint   := "/api/v4/users"

    aAdd( aHeaders, "Accept: application/json" )
    aAdd( aHeaders, "Content-type: application/json" )
    
    If ::lApiToken
        aAdd(aHeaders, 'X-Auth-Key: ' + ::getApiToken() )
        aAdd(aHeaders, 'X-Auth-ConnectorId: ' + ::getConector() )
    Else
        aAdd(aHeaders, 'Authorization: Bearer ' + ::getAuthToken() )
    EndIf

    oClient:SetPath(cEndPoint)
    oClient:setPostParams(EncodeUTF8(cBodyReq))
    oClient:Post(aHeaders)
    cResult := oClient:GetResult()

    If VAL(oClient:oResponseh:cStatusCode) == 200
        
        success := 1
        If lResetPw
            ::resetPassword(cUser)
        EndIf
        If ::lGeraLog
            //cMsgLog += DTOS(DDATETIME) + CRLF
            cMsgLog += "Sucesso na criação do usuário" + CRLF
            cMsgLog += cResult
            cMsgLog += "############################" + CRLF
            ::deflog('Usuário criado com sucesso na plataforma Carol', cMsgLog)
        EndIf
    Else

        FWJsonDeserialize(oClient:cResult,@oJsonResp)
        If !Empty(oJsonResp)
            If oJsonResp:errorCode == 400
               if AT('Record already exists',oJsonResp:errorMessage) > 0
                    success := 2 
               EndIf 
            EndIf
        EndIf
        If ::lGeraLog
           // cMsgLog += DTOS(DDATETIME) + CRLF
            cMsgLog += "Erro ao criar usuário" + CRLF
            cMsgLog += cResult
            cMsgLog += "############################" + CRLF
            ::deflog('Erro na criação de usuário na plataforma Carol', cMsgLog)
        EndIf
    EndIf

return success

