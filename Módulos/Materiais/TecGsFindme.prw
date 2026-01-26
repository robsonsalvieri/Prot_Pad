#INCLUDE "PROTHEUS.CH"
#INCLUDE "TECGSFINDME.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} GsFindMe

@description Classe utilizada para integração Totvs Prestadores de Serviço Tercerização X FindMe

@author	Diego Bezerra
@since	29/11/2022
/*/
//------------------------------------------------------------------------------
class GsFindMe

    data cBaseUrl       AS CHARACTER
    data cToken         AS CHARACTER
    data cUser          AS CHARACTER
    data cPsw           AS CHARACTER
    data cIntegrations  AS CHARACTER
    data cError         AS CHARACTER
    data cHost          AS CHARACTER
    data lAuth          AS LOGICAL
    data aTokenData     AS ARRAY
    data aError         AS ARRAY
    data aClients       AS ARRAY
    data aHeader        AS ARRAY
    
    method new()
    method setBaseUrl()
    method getAuthToken()
    method setError()
    method setUser()
    method setPsw()
    method setlAuth()
    method setToken()
    method setHeader()
    method resetHeader()
    method getBaseUrl()
    method getHost()
    method getToken()
    method getIntegrations()
    method timezone()
    method alterClient()
    method alterStation()
    method canAddClient()
    method setIntegrations()
    method addClient()
    method addHeader()
    method addLocation()
    method addRegions()
    method addStation()
    // method alterLocation()
    method newUser()
    method removeHeader()
endclass

method new() class GsFindMe
    // Parâmetros necessários para a integração
    Local cBaseUrl      := Alltrim(GetMV("MV_GSXFM01", .F., "" )) // Url da api de integração
    Local cUser         := GetMV("MV_GSXFM02", .F., "" ) // Usuário utilizado na plataforma findme
    Local cPsw          := GetMV("MV_GSXFM03", .F., "" )  // Senha utilizada na plataforma findme
    Local cIntegration  := GetMV("MV_GSXFM04", .F., "" )

    ::cError := ""
    ::cIntegrations := ""
        
    If Empty(cBaseUrl)
        ::setBaseUrl("https://sandbox.api.findme.id/v3")
    Else
        ::setBaseUrl(cBaseUrl)
    EndIf
    
    If ( RAt("/",::cBaseUrl) == Len(::cBaseUrl) )
        ::cBaseUrl := Substr(::cBaseUrl,1,Rat("/",::cBaseUrl)-1)
    EndIf

    ::cHost := Substr(::cBaseUrl,At("/",::cBaseUrl)+2)
    ::cHost := IIf(At("/",::cHost) > 0, Substr(::cHost,1,RAt("/",::cHost)-1), ::cHost)
    // Gravando na classe os valores de usuário e senha da integração
    ::setUser(cUser)
    ::setPsw(cPsw)

    If !Empty(cUser) .AND. !Empty(cPsw) 
        // Realizando a autenticação na FindMe
        If ::getAuthToken()
            // Sucesso na autenticação e obtenção do token
            ::setlAuth(.T.)
            // Obtendo o id da integração, no sistema da FindMe
            If Empty(cIntegration)
                if ::getIntegrations()
                    // Gravando o id da integração na classe
                    PutMv("MV_GSXFM04",::cIntegrations)
                EndIf
            Else
                ::setIntegrations(cIntegration)
            EndIf

            ::SetHeader()

        Else
            // Falha na autenticação ou obtenção do token de autorização
            ::setlAuth(.F.)
        EndIf
    Else
        //Setar mensagem de erro
    EndIf 

return

//------------------------------------------------------------------------------
/*/{Protheus.doc} getAuthToken

@description Realiza a autenticação para comunicação com a API da FindMe

@return lRet, bool, se conseguiu realizar a autenticação

@author	Diego Bezerra
@since	29/11/2022
/*/
//------------------------------------------------------------------------------
method getAuthToken() class GsFindMe
    Local aHeader := {}
    Local oRest := FWRest():New(::cBaseUrl)
    Local oObj := Nil
    Local lRet := .T.

    If EMPTY(::aTokenData)
        ::aTokenData := {}
        lRet := .F.
        AAdd(aHeader, "Content-Type: application/x-www-form-urlencoded")
        AAdd(aHeader, "charset: UTF-8")

        oRest:SetPath("/settings/login")
        oRest:SetPostParams('email=' + ::cUser + '&password=' + ::cPsw)

        If oRest:Post(aHeader)
            If (lRet := FWJsonDeserialize(oRest:GetResult(),@oObj))
                ::setToken(oObj:token)
                If lRet .AND.  FindFunction("TECTelMets")
                    TECTelMets("autenticar_findme", "gestao-de-servicos-protheus_integracao-find-me-gs_total")
                EndIf
                AADD(::aTokenData, oObj:token)
                AADD(::aTokenData, TIME())
            EndIf
        EndIf

    EndIf
return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} setBaseUrl

@description Define a url base da api de integração

@param cSetValue, String, url da integração

@author	Diego Bezerra
@since	29/11/2022
/*/
//------------------------------------------------------------------------------
method setBaseUrl(cSetValue) class GsFindMe

return (::cBaseUrl := cSetValue)

//------------------------------------------------------------------------------
/*/{Protheus.doc} getBaseUrl

@description Retorna a Url base da api de integração

@author	Diego Bezerra
@since	29/11/2022
/*/
//------------------------------------------------------------------------------
method getBaseUrl() class GsFindMe

return (::cBaseUrl)

//------------------------------------------------------------------------------
/*/{Protheus.doc} getHost

@description Retorna o Host da api de integração

@author	Diego Bezerra
@since	20/10/2023
/*/
//------------------------------------------------------------------------------
method getHost() class GsFindMe

return (::cHost)

//------------------------------------------------------------------------------
/*/{Protheus.doc} setUser

@description Define o nome do usuário

@param cSetValue, String, nome do usuário

@author	Diego Bezerra
@since  29/11/2022
/*/
//------------------------------------------------------------------------------
method setUser(cSetUser) class GsFindMe

return (::cUser := cSetUser)

//------------------------------------------------------------------------------
/*/{Protheus.doc} setPsw

@description Define a senha do usuário findme

@param cSetPsw, String, senha do usuário findme

@author	Diego Bezerra
@since	29/11/2022
/*/
//------------------------------------------------------------------------------
method setPsw(cSetPsw) class GsFindMe

return (::cPsw := cSetPsw)

//------------------------------------------------------------------------------
/*/{Protheus.doc} setlAuth

@description Define variável de controle para saber se o usuário está autenticado

@param lAuth, lógico, .T. == Autenticado, .F. == Não Autenticado

@author	Diego Bezerra
@since	29/11/2022
/*/
//------------------------------------------------------------------------------
method setlAuth(lAuth) class GsFindMe

return (::lAuth := lAuth)

//------------------------------------------------------------------------------
/*/{Protheus.doc} setlAuth

@description Define token de autenticação

@param cSetToken, string, token de autenticação

@author	Diego Bezerra
@since	29/11/2022
/*/
//------------------------------------------------------------------------------
method setToken(cSetToken) class GsFindMe

return (::cToken := cSetToken)

//------------------------------------------------------------------------------
/*/{Protheus.doc} setHeader(aHeader)

@description Monta o header do REST que será utilizado nas requisições

@param aHeader, array, vetor com os dados do cabeçalho. Exemplo:
            aHeader[1], string, "Content-Type: application/json"
            aHeader[2], string, "charset: UTF-8"
            aHeader[3], string, "Authorization: Bearer " + ::cToken
@return nil
@author	Fernando Radu Muscalu
@since	27/11/2023
/*/
//------------------------------------------------------------------------------
method setHeader(aHeader) class GsFindMe

    Local nI     := 0

    Default aHeader := {}

    If ( Empty(aHeader) .Or. Empty(::aHeader) )
        ::resetHeader()
    EndIf

    If ( Len(aHeader) > 0 )

        ::aHeader := {}    

        For nI := 1 to Len(aHeader)
            aAdd(::aHeader,aHeader[nI])
        Next nI
    
    EndIf

return()

//------------------------------------------------------------------------------
/*/{Protheus.doc} resetHeader(aHeader)

@description Monta o header do REST no seu formato padrão para as APIs da FindMe

@param 
@return nil
@author	Fernando Radu Muscalu
@since	27/11/2023
/*/
//------------------------------------------------------------------------------
method resetHeader() class GsFindMe

    ::aHeader := {}

    AAdd(::aHeader, "Content-Type: application/json")
    AAdd(::aHeader, "charset: UTF-8")
    AAdd(::aHeader, "Authorization: Bearer " + ::cToken)

return()

//------------------------------------------------------------------------------
/*/{Protheus.doc} addHeader(xAdding)

@description Adiciona elementos ao header da requisição REST das APIs FindMe
	

@param	xAdding, ou Array ou String	- Item ou itens a serem adicionados ao header 
	da requisição
@return lRet, lógico	- .t. adicionou o elemento ao cabeçalho
@author	Fernando Radu Muscalu
@since	04/12/2023
/*/
//------------------------------------------------------------------------------
method addHeader(xAdding) class GsFindMe

    Local nI    := 0
    
    Local lRet  := .F.

    Default xAdding := ""

    If ( ValType(xAdding) == "A" )

        For nI := 1 to Len(xAdding)
            lRet := .T.
            aAdd(::aHeader,xAdding[nI])
        Next nI

    ElseIf ( ValType(xAdding) == "C" .and. !Empty(xAdding) )
        lRet := .T.
        aAdd(::aHeader,xAdding)
    EndIf

return(lRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc} removeHeader(xAdding)

@description Remove elementos do header da requisição REST das APIs FindMe

@param	xAdding, ou Array ou String	- Item ou itens a serem removidos do header 
	da requisição
@return lRet, lógico	- .t. removido o elemento ao cabeçalho
@author	Fernando Radu Muscalu
@since	04/12/2023
/*/
//------------------------------------------------------------------------------
method removeHeader(xAdding) class GsFindMe

    Local nI    := 0
    Local nP    := 0
    
    Local lRet  := .F.

    Default xAdding := ""

    If ( ValType(xAdding) == "A" )

        For nI := 1 to Len(xAdding)

            nP := aScan(::aHeader, {|x| xAdding[nI] $ x })
            
            If ( nP > 0 )
                
                lRet := .T.
                aDel(::aHeader,nP)
                
                aSize(::aHeader,Len(::aHeader)-1)

            EndIf
            
            
        Next nI

    ElseIf ( ValType(xAdding) == "C" .and. !Empty(xAdding) )

        nP := aScan(::aHeader, {|x| xAdding $ x })

        If ( nP > 0 )
            lRet := .T.
            aDel(::aHeader,nP)
            aSize(::aHeader,Len(::aHeader)-1)
        EndIf

    EndIf

return(lRet)
//------------------------------------------------------------------------------
/*/{Protheus.doc} getToken

@description Retorna token de autenticação

@author	Diego Bezerra
@since	29/11/2022
/*/
//------------------------------------------------------------------------------
method getToken() class GsFindMe

return (::cToken)

//------------------------------------------------------------------------------
/*/{Protheus.doc} setIntegrations

@description Grava o valor da variável cIntegrations (id da integração)

@author	Diego Bezerra
@since	06/12/2022
/*/
//------------------------------------------------------------------------------
method setIntegrations(cSetValue) class GsFindMe

Return (::cIntegrations:=cSetValue)

//------------------------------------------------------------------------------
/*/{Protheus.doc} setError

@description Grava valor do erro na propriedade cError

@author	Diego Bezerra
@since	06/12/2022
/*/
//------------------------------------------------------------------------------
method setError(cSetValue) class GsFindMe
    
Return (::cError := cSetValue)

//------------------------------------------------------------------------------
/*/{Protheus.doc} getIntegrations

@description obtem integrações ativas

@author	Diego Bezerra
@since	02/12/2022
/*/
//------------------------------------------------------------------------------
method getIntegrations() class GsFindMe
    Local aHeader := {}
    Local oRest := FWRest():New(::cBaseUrl)
    Local oObj := Nil
    Local lRet := .T.
    Local cPath := "/integrations"
    If !EMPTY(::aTokenData)
        Aadd(aHeader, "Content-Type: application/json")
        AAdd(aHeader, "charset: UTF-8")
        AAdd(aHeader, "Authorization: Bearer " + ::aTokenData[1])

        oRest:SetPath(cPath)

        If oRest:Get(aHeader)
            If FWJsonDeserialize(oRest:GetResult(),@oObj)
                ::setIntegrations(oObj[1]:uuid)
            EndIf
        EndIf
    Else
        ::setError(STR0001) //"Não foi possível obter o token de autorização."
        lRet := .F.
    EndIf
return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} canAddClient

@description verifica se um cliente já foi cadastrado na base de dados da FindMe
Retorna variável lógica

lCanAdd == .T. == Liberado para inclusão (cliente ainda não cadastrado na base FindMe)
lCanAdd == .F. == Não liberado para inclusão (cliente já cadastrado na base FindMe)

@param codigo, string, codigo do cliente

@author	Diego Bezerra
@since	02/12/2022
/*/
//------------------------------------------------------------------------------
method canAddClient(codigo,filial,loja) class GsFindMe 
    Local aHeader := {}
    Local oRest := FWRest():New(::cBaseUrl)
    Local lRet := .T.
    Local cPath := "/integrations"
    Local lCanAdd := .F.

    if !Empty(::cIntegrations)
        cPath += "/" + ::cIntegrations + "/clients/find?codigo="+codigo+"&filial="+filial+"&loja="+loja
    EndIf

    If lRet .AND. !EMPTY(::getToken())
        Aadd(aHeader, "Content-Type: application/json")
        AAdd(aHeader, "charset: UTF-8")
        AAdd(aHeader, "Authorization: Bearer " + ::getToken())

        oRest:SetPath(cPath)
        
        If !oRest:Get(aHeader)
            lCanADd := .T.
        EndIf

    EndIf

return lCanAdd

//------------------------------------------------------------------------------
/*/{Protheus.doc} addClient

@description Grava o valor da variável cIntegrations (id da integração)
@param, aFlds, array, dados do cliente que será incluído, no seguinte formato:
    1 - {"codigo","0000001"} ----> código do cliente
    2 - {"filial","d mg 01"} ----> filial do cliente
    3 - {"loja","01"} -----------> loja do cadastro de cliente
    4 - {"descricao","xyz"} -----> descrição do cadastro 
    5 - {"name","Totvs S.A"} ----> nome do cliente
@param, aRegions, array, dados da região vinculada ao cliente
        {"000001","0101","01"}, --> Código da região, filial, loja
        {"Norte","Sao_Paulo"} ---> nome da região, timezone
@author	Diego Bezerra
@since	06/12/2022
/*/
//------------------------------------------------------------------------------
method addClient(aFlds,aRegions) class GsFindMe

    Local aHeader := {}
    Local oRest := FWRest():New(::getBaseUrl())
    Local lRet := .T.
    Local cBodyReq := ""
    Local cPath := "/integrations"
    Default aRegions := {}

    if !Empty(::cIntegrations)
        cPath += "/" + ::cIntegrations + "/clients"
    Else
        lRet := .F.
    EndIf

    if lRet .AND. LEN(aFlds) > 0
        cBodyReq += '{"integration":{'
            cBodyReq += '"codigo":"'+aFlds[1][2]+'",'
            cBodyReq += '"filial":"'+aFlds[2][2]+'",'
            cBodyReq += '"loja":"'+aFlds[3][2]+'"'
        cBodyReq += "},"
        cBodyReq += '"customData":{'
            cBodyReq += '"descricao":"'+Alltrim(aFlds[4][2])+'"'
        cBodyReq += "},"
        cBodyReq += '"name":"'+Alltrim(aFlds[5][2])+'"}'
    EndIF

    If lRet .AND. !EMPTY(::cToken)
        AAdd(aHeader, "Content-Type: application/json")
        AAdd(aHeader, "charset: UTF-8")
        AAdd(aHeader, "Authorization: Bearer " + ::cToken)

        oRest:SetPath(cPath)
        oRest:SetPostParams(EncodeUTF8(cBodyReq))
        lRet := oRest:Post(aHeader)
        If lRet
            If FindFunction("TECTelMets")
                TECTelMets("incluir_cliente_findme", "gestao-de-servicos-protheus_integracao-find-me-gs_total")
            EndIf

            if !Empty(aRegions)
                If !::addRegions(aRegions[1][1], aRegions[1][2], aRegions[1][3], aRegions[2])
                    ::setError(STR0002) //"Erro ao incluir região."
                EndIf
            EndIf
        Else
            ::setError(STR0003) //"Erro ao incluir o cliente."
        EndIf
    EndIf

return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} alterClient

@description Realiza alteração do cliente
@param codigo, string, código do cliente
@param filial, string, filial do cliente
@param loja, string, código da loja
@param aFlds, dados que serão alterados, no formato:
    1 - {"codigo","0000001"} 
    2 - {"filial","d mg 01"} 
    3 - {"loja","01"} 
    4 - {"descricao","local de atendimento xyz"} 
    5 - {"name","Totvs S.A"}
@author	Diego Bezerra
@since	06/12/2022
/*/
//------------------------------------------------------------------------------
method alterClient(codigo,filial,loja,aFlds) class GsFindMe

    Local aHeader := {}
    Local oRest := FWRest():New(::cBaseUrl)
    Local lRet := .T.
    Local cBodyReq := ""
    Local cPath := "/integrations"
    Default aCustomAdd := {}
    Default aCustomAlt := {}

    If !Empty(::cIntegrations)
        cPath += "/" + ::cIntegrations + "/clients/record?codigo="+codigo+"&filial="+filial+"&loja="+loja
    Else
        lRet := .F.
    EndIf

    If lRet .AND. LEN(aFlds) > 0
        cBodyReq += '{"integration":{'
            cBodyReq += '"codigo":"'+aFlds[1][2]+'",'
            cBodyReq += '"filial":"'+aFlds[2][2]+'",'
            cBodyReq += '"loja":"'+aFlds[3][2]+'"'
        cBodyReq += "},"
        cBodyReq += '"customData":null,'
        cBodyReq += '"name":"'+aFlds[5][2]+'"}'
    EndIF
    
    If lRet .AND. !EMPTY(::cToken)
        Aadd(aHeader, "Content-Type: application/json")
        AAdd(aHeader, "charset: UTF-8")
        AAdd(aHeader, "Authorization: Bearer " + ::cToken)

        oRest:SetPath(cPath)
        
        lRet := oRest:Put(aHeader,cBodyReq)
        If !lRet
            ::setError(STR0004) //"Erro ao alterar o cliente."
        EndIf
    EndIf
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} addRegions

@description inclusão de região
@param cClient, string, código da região incluída
@param, cFilial, string, código da região incluída
@param, cLoja, string, código da loja 
@param, aFlds, array, Região que será incluída
         {"Norte","Sao_Paulo"}
@author	Diego Bezerra
@since	06/12/2022
/*/
//------------------------------------------------------------------------------
method addRegions(cCodReg, cCodFil,cLoja,aFlds, cError) class GsFindMe

    Local aHeader := {}
    Local oRest := FWRest():New(::cBaseUrl)
    Local lRet := .T.
    Local cBodyReq := ""
    Local cPath := "/integrations"

    Default cError := ""

    if !Empty(::cIntegrations)
        cPath += "/" + ::cIntegrations + "/regions"
    Else
        lRet := .F.
    EndIf

    If lRet .AND. !EMPTY(::cToken)
        Aadd(aHeader, "Content-Type: application/json")
        AAdd(aHeader, "charset: UTF-8")
        AAdd(aHeader, "Authorization: Bearer " + ::cToken)

        if lRet
            cBodyReq += '{"integration":{'
                cBodyReq += '"codigo":"' + cCodReg+'",'
                cBodyReq += '"filial":"' + cCodFil+'",'
                cBodyReq += '"loja":"' + cLoja+'"'
            cBodyReq += "},"
            cBodyReq += '"name":"' + aFlds[1]+'",'
            cBodyReq += '"timezone":"' + aFlds[2]+'"}'
        EndIF

        oRest:SetPath(cPath)
        oRest:SetPostParams(EncodeUTF8(cBodyReq))
        lRet := oRest:Post(aHeader)
        
        if !lRet
             if(oRest:ORESPONSEH:CSTATUSCODE == '409') // Região já existe
                cError += "Status code " + oRest:ORESPONSEH:CSTATUSCODE
                
                If AttIsMemberOf(oRest:ORESPONSEH, "CREASON")
                    cError += CRLF + oRest:ORESPONSEH:CREASON
                EndIf

                lRet := .T.
             else

                cError += "Status code " + oRest:ORESPONSEH:CSTATUSCODE
                If AttIsMemberOf(oRest:ORESPONSEH, "CREASON")
                    cError += CRLF + oRest:ORESPONSEH:CREASON
                EndIf
                
                ::setError(STR0002) //"Erro ao incluir a região."
             EndIf
            
        Else
            If FindFunction("TECTelMets")
                TECTelMets("incluir_regiao", "gestao-de-servicos-protheus_integracao-find-me-gs_total")
            EndIf
        EndIf
    EndIf

return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} addLocation

@description inclusão de local de atendimento
@param aClient, array, dados do cliente, vinculado ao local que será cadastrado
        1 - {"codigo","000003"},
        2 - {"filial","0101"},
        3 - {"loja":"01"}
@param, aIdLoc, array, identificador único do novo local
        1 - {"codigo","0001"},
        2 - {"filial","0101"},
        3 - {"loja":"01"}
@param, cFilial, string, código da filial integrada
@param, cLoja, string, código da loja integrada
@param, aLocation, array, array com os dados do posto de trabalho, no seguinte formato
        1 -  {"name":"Totvs Matriz"},
        2 -  {"address": "Avenida Braz Leme 1000"},
        3 -  {"timezone": "America/Sao_Paulo"},
        4 -  {"latitude":-23.5083671},
        5 -  {"longitude":-46.6535622},
        6 -  {"radius":10},
        7 -  {"autoFinishRadius":0},
        8 -  {"geolocationAdjustment": false},
        9 -  {"password":""},
        10 - {"counterPassword":""},
        11 - {"securityPhone":""}
@author	Diego Bezerra
@since	07/12/2022
/*/
//------------------------------------------------------------------------------
method addLocation(aClient,aIdLoc,aReg, aLocation) class GsFindMe

    Local aHeader   := {}
    Local oRest     := FWRest():New(::cBaseUrl)
    Local lRet      := .T.
    Local cBodyReq  := ""
    Local cPath     := "/integrations"
    Local cEstado   := 'SP'
    Local cCidade   := 'São Paulo'
    Local cTimeZone := 'America/Sao_Paulo'
    Local cAux      := ''

    If ValType(aIdLoc[4]) == 'C'
        If !Empty(aIdLoc[4])
            cEstado := aIdLoc[4]
        EndIf
    EndIf

    If ValType(aIdLoc[5]) == 'C'
        If !Empty(aIdLoc[5])
            cCidade := aIdLoc[5] 
        EndIf
    EndIf

    cAux := ::timezone('BR',cEstado,cCidade)
    If Valtype(cAux) == 'C' .AND. !Empty(cAux)
        cTimeZone := cAux
    EndIf

    if !Empty(::cIntegrations)
        cPath += "/" + ::cIntegrations + "/locations"
    Else
        lRet := .F.
    EndIf

    If lRet .AND. !EMPTY(::cToken)
        Aadd(aHeader, "Content-Type: application/json")
        AAdd(aHeader, "charset: UTF-8")
        AAdd(aHeader, "Authorization: Bearer " + ::cToken)

        if lRet .AND. LEN(aLocation) > 0
            cBodyReq += '{"clientIntegration":{'
            cBodyReq +=     '"codigo":"' + aClient[1][2] + '",'
            cBodyReq +=     '"filial":"' + aClient[2][2] + '",'
            cBodyReq +=     '"loja":"' + aClient[3][2] + '"'
            cBodyReq += '},'
            cBodyReq += '"integration":{'
            cBodyReq +=     '"codigo":"' + aIdLoc[1] + '",'
            cBodyReq +=     '"filial":"' + aIdLoc[2] + '",'
            cBodyReq +=     '"loja":"' + aIdLoc[3] + '"'
            cBodyReq += '},'
            cBodyReq += '"regionIntegration":{'
            cBodyReq +=     '"codigo":"' + aReg[1] + '",'
            cBodyReq +=     '"filial":"' + aReg[3] + '",'
            cBodyReq +=     '"loja":"' + aReg[2] + '"'
            cBodyReq += '},'
            //cBodyReq += '"customData": null,'
            cBodyReq += '"name":"' + RTRIM(aLocation[1]) + '",'
            cBodyReq += '"address":"' + RTRIM(aLocation[2]) + '",'
            cBodyReq += '"timezone":"' + aLocation[3] + '",'
            cBodyReq += '"latitude":' + aLocation[4] + ','
            cBodyReq += '"longitude":' + aLocation[5] + ','
            cBodyReq += '"radius":' + cValToChar(aLocation[6]) + ','
            cBodyReq += '"autoFinishRadius":' + cValToChar(aLocation[7]) + ','
            cBodyReq += '"geolocationAdjustment":"' + aLocation[8] + '",'
            cBodyReq += '"password":"' + aLocation[9] + '",'
            cBodyReq += '"counterPassword":"' + aLocation[10] + '",'
            cBodyReq += '"securityPhone":"' + aLocation[11] + '"'
            cBodyReq += '}'
        EndIF

        oRest:SetPath(cPath)
        oRest:SetPostParams(EncodeUTF8(cBodyReq))
        lRet := oRest:Post(aHeader)
        if !lRet
            if(oRest:ORESPONSEH:CSTATUSCODE == '409')
                lRet := .T.
                //Quando o posto já existe
                //::setError("Posto já integrado.")
                If FindFunction("TECTelMets")
                    TECTelMets("incluir_local", "gestao-de-servicos-protheus_integracao-find-me-gs_total")
                EndIf
            Else
                ::setError(STR0005) //"Erro ao incluir o local."
            EndIf
        Else
            If FindFunction("TECTelMets")
                TECTelMets("incluir_local", "gestao-de-servicos-protheus_integracao-find-me-gs_total")
            EndIf
        EndIf
    EndIf

return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} alterLocation

@description inclusão de local de atendimento
@param aClient, array, dados do cliente, vinculado ao local que será cadastrado
        1 - {"codigo","000003"},
        2 - {"filial","0101"},
        3 - {"loja":"01"}
@param, aIdLoc, array, identificador único do novo local
        1 - {"codigo","0001"},
        2 - {"filial","0101"},
        3 - {"loja":"01"}
@param, cFilial, string, código da filial integrada
@param, cLoja, string, código da loja integrada
@param, aLocation, array, array com os dados do posto de trabalho, no seguinte formato
        1 -  {"name":"Totvs Matriz"},
        2 -  {"address": "Avenida Braz Leme 1000"},
        3 -  {"timezone": "America/Sao_Paulo"},
        4 -  {"latitude":-23.5083671},
        5 -  {"longitude":-46.6535622},
        6 -  {"radius":10},
        7 -  {"autoFinishRadius":0},
        8 -  {"geolocationAdjustment": false},
        9 -  {"password":""},
        10 - {"counterPassword":""},
        11 - {"securityPhone":""}
@param aCustomAdd, array, dados de customData que serão incluido
        {"armamento",{ {"codigo","descricao"},{"codigo","descricao"} } },
        {"matImp",{ {"codigo","quant.","descri."},{"codigo","quant.","descri."} } }
@author	Diego Bezerra
@since	19/12/2022
/*/
//------------------------------------------------------------------------------
/*method alterLocation(aClient,aIdLoc,cCodReg, cFilReg, cLojReg, aLocation, aCustomAdd) class GsFindMe

    Local aHeader := {}
    Local oRest := FWRest():New(::cBaseUrl)
    Local lRet := .T.
    Local lArm := .F.
    Local cBodyReq := ""
    Local cPath := "/integrations"
    Local nX := 1
    Local nY := 1
    Local nZ := 1

    if !Empty(::cIntegrations)
        cPath += "/" + ::cIntegrations + "/locations"
    Else
        lRet := .F.
    EndIf

    If lRet .AND. !EMPTY(::cToken)
        Aadd(aHeader, "Content-Type: application/json")
        AAdd(aHeader, "charset: UTF-8")
        AAdd(aHeader, "Authorization: Bearer " + ::cToken)

        if lRet .AND. LEN(aLocation) > 0
            // For nX := 1 to LEN(aLocation)
                cBodyReq += '{"clientIntegration":{'
                cBodyReq +=     '"codigo":"' + aClient[1][2] + '",'
                cBodyReq +=     '"filial":"' + aClient[2][2] + '",'
                cBodyReq +=     '"loja":"' + aClient[3][2] + '"'
                cBodyReq += '},'
                cBodyReq += '"integration":{'
                cBodyReq +=     '"codigo":"' + aIdLoc[1][2] + '",'
                cBodyReq +=     '"filial":"' + aIdLoc[2][2] + '",'
                cBodyReq +=     '"loja":"' + aIdLoc[3][2] + '"'
                cBodyReq += '},'
                cBodyReq += '"regionIntegration":{'
                cBodyReq +=     '"codigo":"' + cCodReg + '",'
                cBodyReq +=     '"filial":"' + cFilReg + '",'
                cBodyReq +=     '"loja":"' + cLojReg + '"'
                cBodyReq += '},'
            
                if !Empty(aCustomAdd) .AND. Len(aCustomAdd) > 0
                    cBodyReq += '"customData":{'
                        For nY := 1 to Len(aCustomAdd)
                            if aCustomAdd[nY][1] == "armamento"
                                lArm := .T.
                                cBodyReq += '"armamento":['
                                    For nZ := 1 to Len(aCustomAdd[nY][2])
                                        cBodyReq += '{"codigo":"'+aCustomAdd[nY][2][nZ][1]+'",'
                                        cBodyReq += '"descricao":"'+aCustomAdd[nY][2][nZ][2]+'"}'
                                    Next nZ
                                    cBodyReq := Left(cBodyReq, Len(cBodyReq)-1)
                                cBodyReq += ']'
                            EndIf
                        Next nY
                    cBodyReq += '},'
                Else
                    cBodyReq += '"customData": null,'
                EndIF
                
                cBodyReq += '"name":"' + aLocation[1][2] + '",'
                cBodyReq += '"address":"' + aLocation[2][2] + '",'
                cBodyReq += '"timezone":"' + aLocation[3][2] + '",'
                cBodyReq += '"latitude":"' + aLocation[4][2] + '",'
                cBodyReq += '"longitude":"' + aLocation[5][2] + '",'
                cBodyReq += '"radius":"' + aLocation[6][2] + '",'
                cBodyReq += '"autoFinishRadius":"' + aLocation[7][2] + '",'
                cBodyReq += '"geolocationAdjustment":"' + aLocation[8][2] + '",'
                cBodyReq += '"password":"' + aLocation[9][2] + '",'
                cBodyReq += '"counterPassword":"' + aLocation[10][2] + '",'
                cBodyReq += '"securityPhone":"' + aLocation[11][2] + '"'
                cBodyReq += '}'
            // Next nX
        EndIF

        oRest:SetPath(cPath)
        lRet := oRest:Put(aHeader,cBodyReq)
        if !lRet
            ::setError(STR0006) //"Erro ao alterar o local."
        Else
            If lArm
                TECTelMets("incluir_armamento", "gestao-de-servicos-protheus_integracao-find-me-gs_total")
            EndIf

            If FindFunction("TECTelMets")
                TECTelMets("incluir_local", "gestao-de-servicos-protheus_integracao-find-me-gs_total")
            EndIf
        EndIf
    EndIf

return lRet
*/
//------------------------------------------------------------------------------
/*/{Protheus.doc} addStation

@description Inclusão de posto de trabalho

##### dados do local #########
@param cLocCod, string, código do local
@param cFilInt, string, filial do local
@param cLojInt, string, código da loja do local

##### dados do posto #########
@param cFilPosto, string, código da filial do posto
@param cLojPosto, string, código da loja do posto
@param cCodPosto, string, código do posto
@param cNomePosto,string, nome do posto

@author	Diego Bezerra
@since	06/12/2022
/*/
//------------------------------------------------------------------------------
method addStation(  cLocCod,;
                    cFilInt,;
                    cLojInt,;
                    cFilPosto,;
                    cLojPosto,;
                    cCodPosto,;
                    cNomePosto,;
                    nOptype;
                ) class GsFindMe

    Local aHeader   := {}
    Local oRest     := FWRest():New(::cBaseUrl)
    Local lRet      := .T.
    Local cBodyReq  := ""
    Local cPath     := "/integrations"
    Default nOptype := '2'  //Na FindMe, se o Posto seria (uma lista de opções, 2- vigilante / técnico)
    if !Empty(::cIntegrations)
        cPath += "/" + ::cIntegrations + "/stations"
    Else
        lRet := .F.
    EndIf

    If lRet .AND. !EMPTY(::cToken)
        Aadd(aHeader, "Content-Type: application/json")
        AAdd(aHeader, "charset: UTF-8")
        AAdd(aHeader, "Authorization: Bearer " + ::cToken)

        cBodyReq += '{'
            cBodyReq += '"locationIntegration":{'
                cBodyReq += '"codigo":"' + cLocCod + '",'
                cBodyReq += '"filial":"' + cFilInt + '",'
                cBodyReq += '"loja":"' + cLojInt + '"'
            cBodyReq += '},'
            cBodyReq += '"integration":{'
                cBodyReq += '"codigo":"' + cCodPosto + '",'
                cBodyReq += '"filial":"' + cFilPosto + '",'
                cBodyReq += '"loja":"' + cLojPosto + '"'
            cBodyReq += '},'
            cBodyReq += '"name":"' + cNomePosto + '",'
            cBodyReq += '"operationType":' + CVALTOCHAR( nOptype ) + ','
            cBodyReq += '"shift1":"06:00",'
            cBodyReq += '"shift2":"18:00"'
        cBodyReq += '}'
        
        oRest:SetPath(cPath)
        oRest:SetPostParams(EncodeUTF8(cBodyReq))
        lRet := oRest:Post(aHeader)

        if !lRet
            ::setError(STR0005) //"Erro ao incluir o local."
        Else
            If FindFunction("TECTelMets")
                TECTelMets("incluir_posto", "gestao-de-servicos-protheus_integracao-find-me-gs_total")
            EndIf
        EndIf
    EndIF

return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} alterStation(aIntLocal,aIntPosto,aCustomData,nOptype)

@description Efetua PUT para alterar o cadastro do Posto na Findme, afim
    de enviar o checklist (pelo atributo customData)

@param  aIntPosto, Array, Informações para o atributo integration
            aIntPosto[1], string, Id (código) Station (Posto)
            aIntPosto[2], string, Filial 
            aIntPosto[3], string, Loja
            aIntPosto[4], string, Station Name (Nome do Posto)
        aIntLocal, Array, Informações para o atributo locationIntegration
            aIntLocal[1], string, Código (Id) Location (Local)
            aIntLocal[2], string, Filial 
            aIntLocal[3], string, Loja
        aCustomData, Array, Possui dados do CheckList de Materiais
            aCustomData[x] - Array
                aCustomData[x][1] - caracter, nome do agrupador (Grupo)
                aCustomData[x][2] - array dos itens do grupo (lista de materiais do checklist)
                    aCustomData[x][2][y] - Array dos atributos do item
                        aCustomData[x][2][y][1,1] - Identificador do atributo
                        aCustomData[x][2][y][2,2] - Conteúdo do atributo
            
            Exemplo:

                aCustomData Array {size=1}
                    aCustomData[1]: Array {size=2}
                        aCustomData[1][1]: "Implantação"
                        aCustomData[1][2]: Array {size=2}
                            aCustomData[1][2][1]: Array {size=7}    //Item 01 de Implantação
                                aCustomData[1][2][1][1]: Array {size=2}
                                    aCustomData[1][2][1][1][1]: "idAppointmentIntegration"
                                    aCustomData[1][2][1][1][2]: "001"
                                aCustomData[1][2][1][2]: Array {size=2}
                                    aCustomData[1][2][1][2][1]: "idMaterialIntegration"
                                    aCustomData[1][2][1][2][2]: "001"
                                aCustomData[1][2][1][3]: Array {size=2}
                                    aCustomData[1][2][1][3][1]: "idProdIntegration"
                                    aCustomData[1][2][1][3][2]: "001"
                                aCustomData[1][2][1][4]: Array {size=2}
                                    aCustomData[1][2][1][4][1]: "name"
                                    aCustomData[1][2][1][4][2]: "Baldes"
                                aCustomData[1][2][1][5]: Array {size=2}
                                    aCustomData[1][2][1][5][1]: "kind"
                                    aCustomData[1][2][1][5][2]: "quantity"
                                aCustomData[1][2][1][6]: Array {size=2}
                                    aCustomData[1][2][1][6][1]: "value"
                                    aCustomData[1][2][1][6][2]: "5"
                                aCustomData[1][2][1][7]: Array {size=2}
                                    aCustomData[1][2][1][7][1]: "requiresPhoto"
                                    aCustomData[1][2][1][7][2]: "false"
                            aCustomData[1][2][2]: Array {size=7}    //Item 02 de Implantação
                                aCustomData[1][2][2][1]: Array {size=2}
                                    aCustomData[1][2][2][1][1]: "idAppointmentIntegration"
                                    aCustomData[1][2][2][1][2]: "003"
                                aCustomData[1][2][2][2]: Array {size=2}
                                    aCustomData[1][2][2][2][1]: "idMaterialIntegration"
                                    aCustomData[1][2][2][2][2]: "003"
                                aCustomData[1][2][2][3]: Array {size=2}
                                    aCustomData[1][2][2][3][1]: "idProdIntegration"
                                    aCustomData[1][2][2][3][2]: "PROD031"
                                aCustomData[1][2][2][4]: Array {size=2}
                                    aCustomData[1][2][2][4][1]: "name"
                                    aCustomData[1][2][2][4][2]: "Notebook"
                                aCustomData[1][2][2][5]: Array {size=2}
                                    aCustomData[1][2][2][5][1]: "kind"
                                    aCustomData[1][2][2][5][2]: "Unity"
                                aCustomData[1][2][2][6]: Array {size=2}
                                    aCustomData[1][2][2][6][1]: "value"
                                    aCustomData[1][2][2][6][2]: "10"
                                aCustomData[1][2][2][7]: Array {size=2}
                                    aCustomData[1][2][2][7][1]: "requiresPhoto"
                                    aCustomData[1][2][2][7][2]: "true"
                    aCustomData[2]: Array {size=2}
                        aCustomData[2][1]: "Consumo"
                            aCustomData[2][2]: Array {size=2}
                                aCustomData[2][2][1]: Array {size=7}    //Item 01 de Cosumo
                    . 
                    .
                    .
                    . e assim, a mesma lógica se aplica para o grupo de consumo           
                *Layout original que a FindMe espera receber no PUT. Assim, seria 
                obrigatório possuir estas informações, quando passar o array
                aCustomData por parâmetro
            
@author	Fernando Radu
@since	03/07/2023
/*/
//------------------------------------------------------------------------------
Method alterStation(    aIntPosto,;
                        aIntLocal,;
                        aCustomData,;
                        nOptype,;
                        lAltIntPosto;
                    ) class GsFindMe 
    
    Local oRest     := FWRest():New(::cBaseUrl)
    
    Local lRet      := .T.
    
    Local cBodyReq  := ""
    Local cPath     := "/integrations"
        
    Local nI        := 0
    Local nX        := 0
    Local nZ        := 0

    Default aIntLocal   := {}
    Default aCustomData := {}
    Default nOptype     := '2'  //Na FindMe, se o Posto seria (uma lista de opções, 2- vigilante / técnico)
    Default lAltIntPosto:= .F.
    
    If ( !Empty(::cIntegrations) )
        cPath += "/" + ::cIntegrations + "/stations/record?codigo="+Escape(aIntPosto[1])+"&filial="+Escape(aIntPosto[2])+"&loja="+Escape(aIntPosto[3])
    Else
        lRet := .F.
    EndIf

    If ( lRet )
        
        cBodyReq := '{'

        If ( Len(aIntPosto) == 3 .And. lAltIntPosto )

            cBodyReq += '"integration":{'
                cBodyReq += '"codigo":"'+aIntPosto[1] + '",'
                cBodyReq += '"filial":"'+aIntPosto[2] + '",'
                cBodyReq += '"loja":"'+aIntPosto[3] + '"'
            cBodyReq += "},"

        EndIf
        
        If ( Len(aIntLocal) == 3 )

            cBodyReq += '"locationIntegration":{'
                cBodyReq += '"codigo":"' + aIntLocal[1] + '",'
                cBodyReq += '"filial":"' + aIntLocal[2] + '",'
                cBodyReq += '"loja":"' + aIntLocal[3] + '"'
            cBodyReq += '},'

        EndIf

        If ( len(aIntPosto) > 4 .and. !Empty(aIntPosto[4]) )
            cBodyReq += '"name":"' + aIntPosto[4] +'",'
        EndIf

        If ( Len(aCustomData) > 0 )

            cBodyReq += '"customData": {'
	        cBodyReq += '"name": "Checklist de posto",'
	        cBodyReq += '"groups": ['

            For nI := 1 to Len(aCustomData)
                
                cBodyReq += '{'
                    cBodyReq += '"name": "' + aCustomData[nI,1] + '",'
	                cBodyReq += '"items": ['
            
                        For nX := 1 to Len(aCustomData[nI,2])

                            cBodyReq += '{'
                            
                            For nZ := 1 to Len(aCustomData[nI,2,nX])
                                
                                cBodyReq += '"' + aCustomData[nI,2,nX][nZ,1] + '":' 
                                
                                If ( !(Lower(aCustomData[nI,2,nX][nZ,2]) $ "true|false") )
                                    cBodyReq += '"' + aCustomData[nI,2,nX][nZ,2] + '"' 
                                Else
                                    cBodyReq +=  aCustomData[nI,2,nX][nZ,2] 
                                EndIf

                                cBodyReq += Iif(nZ < Len(aCustomData[nI,2,nX]),',','')

                            Next nZ

                            cBodyReq += '}' + Iif(nX < Len(aCustomData[nI,2]),',','')

                        Next nX

                    cBodyReq += ']'
                cBodyReq += '}' + Iif(nI < Len(aCustomData),',','')

            Next nI
	        
            cBodyReq += ']'
	        cBodyReq += '}'            

        Else
            cBodyReq += '"customData":null,'
        EndIf
        
        cBodyReq += '}'

        If ( lRet .AND. !EMPTY(::cToken) )
            
            oRest:SetPath(cPath)
            ::addHeader("Host: " + ::getHost())
            
            lRet := oRest:Put(::aHeader,EncodeUTF8(cBodyReq))

            If !lRet
                ::setError("Erro na tentativa de alterar o Posto na FindMe.") //"Erro na tentativa de alterar o Posto na FindMe."
            EndIf
        EndIf
    
    EndIf

Return(lRet)
        

//------------------------------------------------------------------------------
/*/{Protheus.doc} timezone

@description retorna o timezone no formato entendido pelo sistema findme

@param pais, string, sigla do país
@param estado, string, sigla do estado
@param cidade, string, nome da cidade

@author	Diego Bezerra
@since	03/07/2023
/*/
//------------------------------------------------------------------------------
method timeZone(pais,estado,cidade) class GsFindMe 
    Local aHeader := {}
    Local oRest := FWRest():New(::cBaseUrl)
    Local cPath := "/geoname/timezone?country=" + Escape(pais) + "&state=" + Escape(estado) + "&city=" + Escape(cidade)
    local cTimezone := GetMV("MV_FINTIME", .F., "" )   //'America/Sao_Paulo'
    Local oObj := Nil
    
    If !EMPTY(::getToken())
        
        AAdd(aHeader, "Accept: */*")
        AAdd(aHeader, "Accept-Charset: UTF-8")
        AAdd(aHeader, "Accept-Encoding: gzip, deflate, br")
        AAdd(aHeader, "Connection: keep-alive")
        AAdd(aHeader, "Authorization: Bearer " + ::getToken())
        AAdd(aHeader, "Host: " + ::getHost())    //sandbox.api.findme.id
    
        oRest:SetPath(cPath)
        If oRest:Get(aHeader)
            if FWJsonDeserialize(oRest:GetResult(),@oObj)
                cTimezone := oObj:timezone  
            EndIf
        EndIf
    EndIf

return cTimezone

//------------------------------------------------------------------------------
/*/{Protheus.doc} newUser

@description Criar um usuário novo na plataforma find-me

@param aPostoInfo, array, informações do posto
{loja,código,filial}

@param aAtendInfo, array, informações do atendente
{codigo,filial,loja,name,email,identifier,password,locale,phone} //identifier==matricula

@author	Diego Bezerra
@since	14/09/2023

@return lRet, lógico, sucesso na criação do usuário
/*/
//------------------------------------------------------------------------------
method newUser(aPostoInfo, aAtendInfo) class GsFindMe
    
    Local aHeader       := {}
    Local oRest         := FWRest():New(::getBaseUrl())
    Local lRet          := .T.
    Local cBodyReq      := ""
    Local cPath         := "/integrations"
    Default aPostoInfo  := {}

    if !Empty(::cIntegrations)
        cPath += "/" + ::cIntegrations + "/users"
    Else
        lRet := .F.
    EndIf

    if lRet .AND. LEN(aAtendInfo) > 0
        Aadd(aHeader, "Content-Type: application/json")
        AAdd(aHeader, "charset: UTF-8")
        AAdd(aHeader, "Authorization: Bearer " + ::cToken)
        //Criação do body da requisição, com os campos obrigatórios
        cBodyReq += '{"integration":{'
            cBodyReq += '"codigo":"' + aAtendInfo[1] + '",'
            cBodyReq += '"filial":"' + aAtendInfo[2] + '",'
            cBodyReq += '"loja":"' + aAtendInfo[3] + '"'
        cBodyReq += '},'
        cBodyReq += '"name":"' + aAtendInfo[4] + '",'
        cBodyReq += '"role":"' + aAtendInfo[5] + '",'
        cBodyReq += '"email":"' + aAtendInfo[6] + '",'
        cBodyReq += '"identifier":"' + aAtendInfo[7] + '",'
        cBodyReq += '"password":"'+aAtendInfo[8]+'",'
        cBodyReq += '"phone":"' + aAtendInfo[10] + '",'

        //Para casos onde o atendente não pertence a nenhum posto
        If len(aPostoInfo) > 0
            cBodyReq += '"locale":"' + aAtendInfo[9] + '",'
            cBodyReq += '"stationIntegration":{'
                cBodyReq += '"codigo":"' + aPostoInfo[1] + '",'
                cBodyReq += '"filial":"' + aPostoInfo[2] + '",'
                cBodyReq += '"loja":"' + aPostoInfo[3] + '"}'
            cBodyReq += '}'
        Else
            cBodyReq += '"locale":"' + aAtendInfo[9] + '"}'
        EndIf

        oRest:SetPath(cPath)
        oRest:SetPostParams(EncodeUTF8(cBodyReq))
        lRet := oRest:Post(aHeader)

        if !lRet
            if(oRest:ORESPONSEH:CSTATUSCODE == '409')
                lRet := .T.
                //registro de métricas ao tentar incluir usuário
                If FindFunction("TECTelMets")
                    TECTelMets("incluir_usuario", "gestao-de-servicos-protheus_integracao-find-me-gs_total")
                EndIf
            Else
                //inclusão de erro na propriedade de erro da classe
                ::setError("Erro ao incluir o Usuário.")
            EndIf
        Else
            //registro de métricas ao tentar incluir usuário
            If FindFunction("TECTelMets")
                TECTelMets("incluir_usuario", "gestao-de-servicos-protheus_integracao-find-me-gs_total")
            EndIf
        EndIf
    EndIF

Return lRet

