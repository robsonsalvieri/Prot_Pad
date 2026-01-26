#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECTAE
@author Diego Bezerra
@since 2024
@description Classe utilizada para a integração entre os produtos de terceirização 
com a plataforma de assinatura digital TAE
*/
Class TecTAE

    data baseUrl        AS CHARACTER
    data endPoint       AS CHARACTER
    data authToken      AS CHARACTER
    data userName       AS CHARACTER
    data pwAuth         AS CHARACTER
    data logError       AS ARRAY
    data authSucc       AS LOGICAL
    data hasError       AS LOGICAL

    method new()
    method genClientRest()
    method auth()

//get
    method checkStatus()
    method getBaseUrl()
    method getEndPoint()
    method getUser()
    method getPw()
    method getErrorLog()
    method hasError()
    method getAuthToken()
    method getConSucc()
   
//def
    method defBaseURL()
    method defEndPoint()
    method defUser()
    method defPw()
    method defAuthToken()
    method defHasError()
    method defError()
    method defConSucc()

//Realiza upload de arquivo
    method uploadFile()

//Realiza a publicação do arquivo 
    method publicar()

//Obtem status da publicação enviada
    method detailPub()

//Realiza cancelamento da publicação enviada
    method pubCancel()

endClass

method new(baseURL) class TecTAE

    Default baseURL := "https://totvssign.staging.totvs.app"
    ::defBaseURL(baseURL)
    ::defAuthToken("")
    ::defConSucc(.F.)
    ::authToken := ''
    ::logError  := {}   

return

//------------------------------------------------------------------------------
/*/{Protheus.doc} genClientRest
@author Diego Bezerra
@since 2024
@description método para criação de client, utilizado para requisições rest
@return client objeto do tipo FwRest, com a url base definida e obtida via getBaseUrl 
*/
method genClientRest() class TecTAE
    Local client := FwRest():New(::getBaseUrl())
    client:SetPath(::getEndpoint())
Return client


//------------------------------------------------------------------------------
/*/{Protheus.doc} auth
@author Diego Bezerra
@since 2024
@description realiza autenticação na plataforma TAE e grava o tokem Bearer na propriedade
authToken
@param endPoint, string, endpoint de autenticação. Em caso de valor em branco, 
o valor /identity/v2/auth/login é definid como padrão
@param msgErr, string, variável passada por referência para guardar mensagens de erro
@return lAuth, boolean, .T. autenticação com sucesso, .F. autenticação sem sucesso 

*/
method auth(endPoint,msgErr) class TecTAE
    local client        := ::genClientRest()
    Local headers       := {}
    Local body          := ''
    local response      := ''
    Local resp          := Nil
    Local lAuth         := .F.
    
    Default msgErr      := ''
    Default endPoint    := "/identity/v2/auth/login"

    ::defEndPoint(endPoint)

    AAdd( headers, "Accept: */*" )
    AAdd( headers, "Content-Type: application/json" )
    
    body += '{'
    body += '"UserName":"' + ::getUser() + '",'
    body += '"Password":"' + ::getPw() + '"'
    body += '}'

    client:setPath(::getEndPoint())
    client:setPostParams(EncodeUTF8(body))

    If client:Post(headers) 
        If FWJsonDeserialize(client:GetResult(),@resp)
            if resp <> NIL
                response := client:GetResult()
                If AttIsMemberOf(resp, 'succeeded')
                    If resp:succeeded
                        lAuth := .T.
                        If AttIsMemberOf(resp, 'data') .AND. resp:data <> ''
                            ::defAuthToken(resp:data:token)
                            ::defHasError(.F.)
                        EndIf
                    EndIf
                EndIf
            Endif
        EndIf
        ::defConSucc(lAuth)
    Else
        ::defConSucc(lAuth)
        If VAL(client:oResponseh:cStatusCode) > 299
            msgErr += "Ocorreu algum problema durante a autenticação" + CRLF
            msgErr += 'Reponse code: ' + client:oResponseh:cStatusCode + CRLF
            ::defError('Auth',msgErr)  
        EndIf
    EndIf

return lAuth

//------------------------------------------------------------------------------
/*/{Protheus.doc} uploadFile
@author Diego Bezerra
@since 2024
@description Realiza o upload de arquivos para na plataforma TAE

@param cFileContent, string, conteúdo do arquivo
@param cFileName, string, nome do arquivo, com extensão. Exemplo: arquivo1.pdf
@param envName, string, nome do envelope
@param response, string, armazena a resposta da api do TAE - passado via referência
@param msgErr, string, armazena mensagens de erro - passado via referência
@param endPoint, string, endpoint para upload de documentos. Valor padrão: "/documents/v1/envelopes/upload"
@param type, string, tipo do arquivo que será enviado. Tipos aceitos: pdf, doc, docx
@return succeeded, boolean
*/
method uploadFile(cFileContent, cFileName, envName, response, msgErr, endPoint, docType) class TecTAE
    Local headers       := {}
    Local client        := ::genClientRest() 
    Local cBody         := "" 
    Local cBoundary     := "----WebKitFormBoundaryFbmu0bODj7UvfQEV"
    Local succeeded     := .F.

    Default docType     := 'pdf'
    Default response    := Nil
    Default envName     := 'TECTAE'
    Default endPoint    := "/documents/v1/envelopes/upload"
   
    ::defEndPoint(endPoint)

    client:setPath(::getEndPoint())

    AAdd( headers, "Accept: */*" )
    AAdd( headers, "Content-Type: multipart/form-data; boundary=" + cBoundary )
    AAdd( headers, "authorization: Bearer " + ::getAuthToken())
    
    cBody += "--" + cBoundary + CRLF
    cBody += 'Content-Disposition: form-data; name="NomeEnvelope"' + CRLF + CRLF
    cBody += envName + CRLF
    cBody += "--" + cBoundary + CRLF
    cBody += 'Content-Disposition: form-data; name="Envelope"; filename="' + cFileName + '"' + CRLF
    cBody += 'Content-Type: application/' + docType + CRLF + CRLF
    cBody += cFileContent + CRLF
    cBody += "--" + cBoundary + "--" + CRLF
    
    client:setPostParams(cBody)

    If client:post(headers)
        succeeded := .T.
        FWJsonDeserialize(client:cResult,@response)
    Else
        succeeded := .F.
        response := client:oResponseh
        If VAL(client:oResponseh:cStatusCode) > 299
            msgErr += "Erro ao realizar upload de documento." + CRLF
            msgErr += 'Codigo da resposta: ' + client:oResponseh:cStatusCode + CRLF
            ::defError('Upload', msgErr)  
        EndIf
    EndIf

Return succeeded

/*
    @Author Diego Bezerra
    @since 2024
    @description método responsável por enviar documento para assinatura no TAE
    @param idDoc, string, identificador do documento o TAE
    @param aDest, array, array contendo objetos para envio de destinatários do documento, exemplo:
            "destinatarios": [
                {
                    "email": "email@totvs.com.br",
                    "acao": 0,
                    "workflow": 0,
                    "papelAssinante": "como arrendante",
                    "nomeCompleto": "destinatario@email.com.br",
                    "tipoAutenticacao": 2,
                    "tipoIdentificacao": 1,
                    "identificacao": "31044309857"
                }
                ........
            ],
    @param aObserv, array, array contendo objetos para envio dos observadores, exemplo:
            "observadores": [
                {
                "email": "emailobservador@totvs.com.br"
                }
                .........
            ]
    @param cPapel, string, papel do assinante, conforme lista do TAE
    @param cAssina, string, objeto com informações sobre o responsável pela assinatura, conforme exemplo:
            "assinaturaResponsavel": {
                "idDocumento": 321348,
                "enderecoIp": "",
                "enderecoIpV6": "",
                "geoLocalizacao": "",
                "id": 0,
                "tipoDeAssinatura": 1,
                "papelAssinante": "como arrendante"
            },
    @param cPubOpt, string, objeto com informações sobre a publicação, conforme exemplo:
              "publicacaoOpcoes": {
                "idDocumento": 321348,
                "solicitaAssinaturaManuscrita": true,
                "assuntoMensagem": "Assinatura teste - postman 01",
                "corpoMensagem": "Teste de integração - envio postman 01",
                "permiteRejeitarDocumento": true,
                "intervaloLembrete": 0
              }
    @param cDtExp, string, data no formato string, conforme exemplo:
            "2024-10-03T19:21:24.402Z"
            "HHHH-MM-DDTHH:MM:SS.000Z"
*/
method publicar(idDoc, aDest, aObserv, cPapel, cDtExp, cAssunto, cMsgTAE, response, endPoint ) class TecTAE

    Local cBody         := ""
    Local msgErr        := ""
    Local client        := ::genClientRest()
    Local nX            := 0
    Local headers       := {}
    Local succeeded     := .F.

    Default response    := Nil
    Default endPoint    := '/signintegration/v2/Publicacoes'

    ::defEndPoint(endPoint)

    client:setPath(::getEndPoint())

    AAdd( headers, "Accept: */*" )
    AAdd( headers, "Content-Type: application/json")
    AAdd( headers, "authorization: Bearer " + ::getAuthToken())

    If Valtype(aDest) == "A" .AND. Valtype(aObserv) == "A"

        cBody += '{'
        cBody +=    '"idDocumento":' + CVALTOCHAR(idDoc)+','

        cBody +=    '"destinatarios": ['
            For nX := 1 to Len(aDest)// 1=Email; 2=Nome; 3=CPF
               
                cBody += '{'
                cBody +=    '"email":"' + ALLTRIM(aDest[nX][1])+'",'
                cBody +=    '"acao":0,'
                cBody +=    '"workflow":0,'
                cBody +=    '"papelAssinante":"' + cPapel + '",'
                cBody +=    '"nomeCompleto":"' + ALLTRIM(aDest[nX][2])+'",'
                cBody +=    '"tipoAutenticacao":2,'
                cBody +=    '"tipoIdentificacao":1,'
                cBody +=    '"identificacao":"' + ALLTRIM(aDest[nX][3]) + '"'

                If nX < Len(aDest)  
                    cBody +='},'
                Else
                    cBody +='}'
                EndIf
            Next nX

        cBody +=    '],'

        cBody +=    '"observadores":['
            For nX := 1 to Len(aObserv)
                cBody += '{"email": "' + ALLTRIM(aObserv[nX])
                
                If nX < Len(aObserv)
                    cBody += '"},'
                Else
                    cBody += '"}'
                EndIf
            Next nX
        cBody +=    '],'

        cBody +=    '"utilizaWorkflow": true,'
        cBody +=    '"responsavelAssinaDocumento": true,'

        cBody +=    '"assinaturaResponsavel":{"idDocumento": ' + CVALTOCHAR(idDoc) + ','
        cBody +=    '"enderecoIp": "",'
        cBody +=    '"enderecoIpV6": "",'
        cBody +=    '"geoLocalizacao": "",'
        cBody +=    '"id": 0,'
        cBody +=    '"tipoDeAssinatura": 2,
        cBody +=    '"papelAssinante": "' + cPapel + '"},'

        cBody +=    '"enderecoIp": "",'
        cBody +=    '"dataExpiracao":"' + cDtExp + '",'

        cBody +=    '"publicacaoOpcoes": {"idDocumento": ' + CVALTOCHAR(idDoc) + ','
        cBody +=    '"solicitaAssinaturaManuscrita": false,'
        cBody +=    '"assuntoMensagem": "' + cAssunto + '",'
        cBody +=    '"corpoMensagem": "' + cMsgTAE + '",'
        cBody +=    '"permiteRejeitarDocumento": true,'
        cBody +=    '"intervaloLembrete": 0 }'
       
        cBody += '}'

        client:setPostParams(encodeUtf8(cBody))

        If client:post(headers)
            succeeded := .T.
            response := client:oResponseh
        Else
            msgErr += "Erro ao publicar o documento para assinatura." + CRLF
            msgErr += 'Codigo da reposta: ' + client:oResponseh:cStatusCode + CRLF
        EndIf
    EndIf
    
return succeeded

//Cancelamento de publicação
//@param idDoc, numérico, id do envelope
method pubCancel(idDoc) class TecTAE
    
    Local client        := ::genClientRest()
    Local headers       := {}
    Local endPoint      := '/documents/v1/publicacoes/'
    Local succeeded     := .F.
    Local response      := ""

    AAdd( headers, "Accept: */*" )
    AAdd( headers, "Content-Type: application/json")
    AAdd( headers, "authorization: Bearer " + ::getAuthToken())

    If !Empty(idDoc) .AND. Valtype(idDoc) == 'N'
        endPoint += cValToChar(idDoc) + '/cancelar'
        ::defEndPoint(endPoint)

        client:setPath(::getEndPoint())

        If client:post(headers)
            succeeded := .T.
        Else
            succeeded := .F.
        Endif
        response := client:oResponseh
    EndIf

Return succeeded

//0 = erro
//1 = pendente
//2 = finalizado
//5 = cancelado
method detailPub(idDoc,endPoint) class TecTAE
    Local headers       := {}
    Local client        := ::genClientRest()
    Local oObj          := Nil
    Local status        := 0
    
    Default endPoint    := "/documents/v2/publicacoes/"

    If !Empty(idDoc) .AND. Valtype(idDoc) == "N"

        AAdd( headers, "Accept: */*" )
        AAdd( headers, "Content-Type: application/json")
        AAdd( headers, "authorization: Bearer " + ::getAuthToken())
        
        endPoint += cValToChar(idDoc)
        ::defEndPoint(endPoint)

        client:setPath(::getEndPoint())

        If client:Get(headers)
            FWJsonDeserialize(client:getResult(),@oObj)
            If AttIsMemberOf( oObj, "DATA" )
                status := oObj:DATA:status
            EndIf
        EndIf
    EndIf

Return status

//get
method getBaseUrl() class TecTAE
return ::baseUrl

//get
method getEndPoint() class TecTAE
return ::endPoint

//get
method getUser() class TecTAE
return ::userName

//get
method getPw() class TecTAE
return ::pwAuth

//get
method getErrorLog() class TecTAE
return ::hasError

//get
method getAuthToken() class TecTAE
return ::authToken

//get
method getConSucc() class TecTAE
return ::authSucc

//def
method defAuthToken(value) class TecTAE
    If VALTYPE(value) == 'C'
        ::authToken := value
    EndIf
return

//def
method defBaseURL(value) class TecTAE
    If VALTYPE(value) == 'C'
        ::baseURL := value
    EndIf
return

//def
method defEndPoint(value) class TecTAE
    If VALTYPE(value) == 'C'
        ::endPoint := value
    EndIf
return

//def
method defUser(value) class TecTAE
    If VALTYPE(value) == 'C'
        ::userName := value
    EndIf
return

//def
method defPw(value) class TecTAE
    If VALTYPE(value) == 'C'
        ::pwAuth := value
    EndIf
return 

//def
method defHasError(value) class TecTAE
    If Valtype(value) == 'L'
        ::hasError := value
    EndIf
return

//def
method defError(identificador,descricao) class TecTAE
    If VALTYPE(identificador) == 'C' .AND. VALTYPE(descricao) == 'C'
        ::defHasError(.T.)
        AADD(::logError,{identificador,descricao})
    EndIf
return

//def
method defConSucc(value) class TecTAE
    If VALTYPE(value) == 'L'
        ::authSucc := value
    EndIf 
return

//def
method hasError() class TecTAE
Return ::hasError
