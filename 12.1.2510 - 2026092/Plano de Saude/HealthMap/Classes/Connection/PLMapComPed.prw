#Include "PROTHEUS.CH"
#Include "FWMVCDEF.CH" 

//-------------------------------------------------------------------
/*/{Protheus.doc} PLMapComPed
Classe para comunicar o Pedido com a Integração
 
@author Vinicius Queiros Teixeira
@since 21/07/2021
@version Prothues 12
/*/
//-------------------------------------------------------------------
Class PLMapComPed From PlsRest

    Data cOperadora As String
    Data cCodIntegra As String
    Data cCodPedido As String
    Data cComEndPoint As String
    Data cJsonInteg As String
    Data aAutomacao As Array
    Data cClasseInteg As String
    Data lUnimed As Boolean
    Data aPedidos as Array

    // Dados de Autenticação
    Data cAutLogin As String
    Data cAutSenha As String
    Data cAutEndPoint As String 
    Data cAutBearer As String
    Data cAutCookie As String
    Data aAutTimeExper As Array
    Data lAuthentication As Boolean

    Method New(cJson, aAutomacao) Constructor
    Method Setup(cOperadora, cCodIntegra, cCodPedido, cClasse)
    Method SetDadosIntegra()
    Method Authorization()
    Method ProcAuthentication(cJsonResp, cCookie)
    Method PostApi(aPedidos)
    Method ProcResponse()
    Method ProcLtResponse()
    Method UpdatePedido(cStatus)
    Method MontaCookie(cCookie)
    Method GetAuthentication()
    

EndClass


//----------------------------------------------------------
/*/{Protheus.doc} New
Construtor da Classe

@author Vinicius Queiros Teixeira
@since 21/07/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Method New(cJson, aAutomacao) Class PLMapComPed

    Default aAutomacao := {}

    _Super:New()

    self:aAutomacao := aAutomacao
    self:cOperadora := ""
    self:cCodIntegra := ""
    self:cCodPedido := ""
    self:cComEndPoint := ""
    self:cJsonInteg := cJson
    self:cClasseInteg := ""
    self:lUnimed := .F.
    self:aPedidos := {}

    self:cAutLogin := ""
    self:cAutSenha := ""
    self:cAutEndPoint := ""
    self:cAutBearer := ""
    self:cAutCookie := ""
    self:aAutTimeExper := {}
    self:lAuthentication := .F.
    
Return


//----------------------------------------------------------
/*/{Protheus.doc} Setup
Configuração da comunicação do Pedido

@author Vinicius Queiros Teixeira
@since 21/07/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Method Setup(cOperadora, cCodIntegra, cCodPedido, cClasse) Class PLMapComPed
    
    self:cOperadora := cOperadora
    self:cCodIntegra := cCodIntegra
    self:cCodPedido := cCodPedido
    self:cClasseInteg := cClasse

    self:SetDadosIntegra()
    self:Authorization()

Return


//----------------------------------------------------------
/*/{Protheus.doc} SetDadosIntegra
Seta nos Atributos da Classes os dados referente a Integração

@author Vinicius Queiros Teixeira
@since 21/07/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Method SetDadosIntegra() Class PLMapComPed
    
    B7E->(DbSetOrder(1))
    If B7E->(MsSeek(xFilial("B7E")+self:cOperadora+self:cCodIntegra))

        self:cComEndPoint := Alltrim(B7E->B7E_ENDPOI)
        self:cAutLogin := Alltrim(B7E->B7E_USRAUT)
        self:cAutSenha := Alltrim(B7E->B7E_PASAUT)
        self:cAutEndPoint := Alltrim(B7E->B7E_ENDAUT)
        self:cAutBearer := Alltrim(B7E->B7E_BEAAUT)
        self:cAutCookie := Alltrim(B7E->B7E_COOAUT)
        self:aAutTimeExper := StrTokArr(Alltrim(B7E->B7E_TMPAUT), "|")
        If(B7E->(FieldPos('B7E_UNIME') ) > 0)
            self:lUnimed := IIF(B7E->B7E_UNIME == "1", .T., .F.)
        EndIf
    EndIf

Return


//----------------------------------------------------------
/*/{Protheus.doc} Authorization
Autoriza comunicação com a Integração

@author Vinicius Queiros Teixeira
@since 23/07/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Method Authorization() Class PLMapComPed

    Local lNewToken := .T.
    Local dDataToken := CToD(" / / ")
    Local nSecondsToken := 0
    Local oRequest := Nil

    If Len(self:aAutTimeExper) == 2
        dDataToken := StoD(self:aAutTimeExper[1])
        nSecondsToken := Val(self:aAutTimeExper[2])

        If dDataToken == dDataBase .And. Seconds() < nSecondsToken
            lNewToken := .F.
            self:lAuthentication := .T.
        EndIf
    EndIf

    If lNewToken .And. !Empty(self:cAutEndPoint) .And. !Empty(self:cAutLogin) .And. !Empty(self:cAutSenha)
        oRequest := JsonObject():New()
        self:cEndPoint := self:cAutEndPoint

        If self:lUnimed
            oRequest["grant_type"] := "password"
            oRequest["username"] := self:cAutLogin
            oRequest["password"] := self:cAutSenha
        Else
            oRequest["usuario"] := self:cAutLogin
            oRequest["senha"] := self:cAutSenha
        EndIF

        self:cJson := FWJsonSerialize(oRequest, .F., .F.)
        self:setHeadPar("Content-type", "application/json")

        If Len(self:aAutomacao) > 0
            self:lSucess := .T.
            self:cRespJson := self:aAutomacao[1]
        Else
            self:comunPost()
        EndIf

        If self:lSucess
            self:ProcAuthentication(self:cRespJson, self:cCookieResp)
        Else
            self:lAuthentication := .F.
        EndIf

        self:resetAtrib()
    EndIf 
Return


//-----------------------------------------------------------------
/*/{Protheus.doc} ProcAuthentication
Processa Json de Resposta da Autenticacao do Token

@author Vinicius Queiros Teixeira
@since 31/08/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Method ProcAuthentication(cJsonResp, cCookie) Class PLMapComPed

    Local oResponse := JsonObject():New()
    Local lRetorno := .F.
    Local nTimeExpiracao := 0
    Local cDataExpiracao := DtoS(dDataBase)
    Local aToken := {}
    Local oModel := Nil
    Local aAreaB7E := B7E->(GetArea())

    oResponse:FromJSON(cJsonResp)
    Do Case
        Case self:lUnimed .AND. oResponse["access_token"] <> Nil
            self:cAutCookie := Alltrim(self:MontaCookie(cCookie))
            self:cAutBearer := Alltrim(oResponse["access_token"])
            nTimeExpiracao := NoRound(Seconds(), 0) + (oResponse["expires_in"] - 100)

        Case oResponse["jwt"] <> Nil
            aToken := StrTokArr(Alltrim(oResponse["jwt"]), ".")

            If Len(aToken) == 3

                self:cAutCookie := "X-CSRF-TOKEN="+aToken[1]
                self:cAutBearer := "Bearer "+aToken[1]+"."+aToken[2]+"."+aToken[3]
                nTimeExpiracao := NoRound(Seconds(), 0) + 240 // 4 Minutos para Expirar o Token  
            
            EndIf
    EndCase

    //ATUALIZA OS DADOS 
    If !Empty(self:cAutCookie) .And. !Empty(self:cAutBearer)
                
        B7E->(DbSetOrder())
        If B7E->(MsSeek(xFilial("B7E")+self:cOperadora+self:cCodIntegra))

            oModel := FWLoadModel("PLMapIntegra")
            oModel:SetOperation(MODEL_OPERATION_UPDATE)
            oModel:Activate()

            oModel:SetValue("MASTERB7E", "B7E_BEAAUT", self:cAutBearer)
            oModel:SetValue("MASTERB7E", "B7E_COOAUT", self:cAutCookie)
            oModel:SetValue("MASTERB7E", "B7E_TMPAUT", cDataExpiracao+"|"+cValtoChar(nTimeExpiracao))
            
            If oModel:VldData()
                oModel:CommitData()
                lRetorno := .T.
            EndIf
                
            oModel:DeActivate()
        EndIf

        self:lAuthentication := .T.
    EndIf

    RestArea(aAreaB7E)

    FreeObj(oResponse)
    oResponse := Nil

Return lRetorno


//----------------------------------------------------------
/*/{Protheus.doc} PostApi
Realiza o envio do Metodo POST para a Api da Integração

@author Vinicius Queiros Teixeira
@since 23/07/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Method PostApi(aPedidos) Class PLMapComPed

    Local nRetorno := 0

    Default aPedidos := {}

    self:aPedidos := aPedidos

    If self:lAuthentication
        self:setEndPoin(self:cComEndPoint)
        // Configuração do Headers
        self:setHeadPar("Authorization", self:cAutBearer)
        self:setHeadPar("Cookie", self:cAutCookie)
        self:setHeadPar("Content-type", "application/json")
        self:setJson(self:cJsonInteg)

        If Len(self:aAutomacao) > 0
            self:lSucess := .T.
            self:cRespJson := self:aAutomacao[2] 
        Else
            self:comunPost()
        EndIf
        If empty(aPedidos)
            nRetorno := self:ProcResponse()
        Else
            nRetorno := self:ProcLtResponse()
        EndIf
    EndIf

Return nRetorno


//----------------------------------------------------------
/*/{Protheus.doc} ProcResponse
Processa a Resposta da comunicação

@author Vinicius Queiros Teixeira
@since 23/07/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Method ProcResponse() Class PLMapComPed

    Local oResponse := JsonObject():New()
    Local nRetorno := 0

    oResponse:FromJSON(self:cRespJson)

    If self:lSucess
        Do Case
            Case self:cClasseInteg $  "PLMapJsInter|PLMapJsSocor" 
                self:cRespJson := Replace(self:cRespJson, "[", "")
                self:cRespJson := Replace(self:cRespJson, "]", "")
                oResponse:FromJSON(self:cRespJson)
                nRetorno := Iif(Valtype(oResponse["sucesso"]) == "L" .And. oResponse["sucesso"], 1, 0)
            Case self:cClasseInteg $  "PLPtuJsPCad" 
                oResponse:FromJSON(self:cRespJson)
                //Vamos atualizar o Pedido unitario
                If Valtype(oResponse["beneficiarioDetalhe"]) == "A" .AND. Len(oResponse["beneficiarioDetalhe"]) > 0
                    nRetorno := Iif(oResponse["beneficiarioDetalhe"][1]['status'] == '1' .OR. (Ascan(oResponse["beneficiarioDetalhe"][1]['detalhes'],{ |x| "JÁ EXISTE" $ UPPER(x) }) > 0), 1, 0)
                EndIf
            Otherwise
            nRetorno := 1
        EndCase

        IIF(nRetorno == 1, self:UpdatePedido("1"), self:UpdatePedido("2"))
        
    Else
        self:UpdatePedido("2")
    EndIf

    FreeObj(oResponse)
    oResponse := Nil

Return nRetorno


//----------------------------------------------------------
/*/{Protheus.doc} ProcLtResponse
Processa a Resposta de comunicação do Lote

@author Vinicius Queiros Teixeira
@since 23/07/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Method ProcLtResponse() Class PLMapComPed
    Local oResponse := JsonObject():New()
    Local nRetorno := 0
    Local nX := 0
    Local lRetorno := .F.

    oResponse:FromJSON(self:cRespJson)
    If self:lSucess
        nRetorno := 1
        For nX:= 1 to Len(self:aPedidos)
            self:cCodPedido := self:aPedidos[nX][1]
            //Matricula -> aPedidos[nX][2]
            lRetorno := IIF(Ascan(oResponse["beneficiarioDetalhe"], { |x| x["detalhes"][1] == self:aPedidos[nX][2] .Or. (x["cdCarteiraTitular"] == Alltrim(self:aPedidos[nX][2]) .And. Empty(x["detalhes"][1]) )}) > 0,self:UpdatePedido("1"),self:UpdatePedido("2") )
                 
            If !lRetorno 
                nRetorno := 0                
            EndIf
        Next
    Else
        nRetorno := 0
        For nX:= 1 to Len(self:aPedidos)
            self:cCodPedido := self:aPedidos[nX][1]
            self:UpdatePedido("2") 
        Next
    EndIf

    FreeObj(oResponse)
    oResponse := Nil
Return nRetorno


//----------------------------------------------------------
/*/{Protheus.doc} UpdatePedido
Atualiza Pedido após a comunicação

@author Vinicius Queiros Teixeira
@since 23/07/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Method UpdatePedido(cStatus) Class PLMapComPed

    Local lRetorno := .F.
    Local nQtdEnvio := 0
    Local aAreaB7F := B7F->(GetArea())
    Local oModel := Nil

    B7F->(DbSetOrder(1))
    If B7F->(MsSeek(xFilial("B7F")+self:cOperadora+self:cCodIntegra+self:cCodPedido))

        oModel := FWLoadModel("PLMapPedidos")
        oModel:SetOperation(MODEL_OPERATION_UPDATE)
        oModel:Activate() 

        oModel:SetValue("MASTERB7F", "B7F_DATCOM", dDataBase)
        oModel:SetValue("MASTERB7F", "B7F_ENVJSO", self:cJson)
        oModel:SetValue("MASTERB7F", "B7F_RECJSO", DecodeUTF8(self:cRespJson))

        nQtdEnvio := oModel:GetValue("MASTERB7F", "B7F_TENVIO") + 1
        oModel:SetValue("MASTERB7F", "B7F_TENVIO", nQtdEnvio)

        If cStatus <> "1" .And. oModel:GetValue("MASTERB7F", "B7F_TENVIO") >= oModel:GetValue("DETAILB7E", "B7E_MAXENV")
            oModel:SetValue("MASTERB7F", "B7F_STATUS", "3") 
        Else
            oModel:SetValue("MASTERB7F", "B7F_STATUS", cStatus)
        EndIf
 
        If oModel:VldData()
            oModel:CommitData()
            lRetorno := .T.
        EndIf
            
        oModel:DeActivate()
    EndIf

    RestArea(aAreaB7F)

Return


//-----------------------------------------------------------------
/*/{Protheus.doc} MontaCookie
Monta Cookie para Autenticação com o GPU

@author Vinicius Queiros Teixeira
@since 02/06/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Method MontaCookie(cCookie) Class PLMapComPed

    Local cCookieRet := ""
    Local aCookie := {}

    If !Empty(cCookie)
        aCookie := StrTokArr(cCookie, ";")
        If Len(aCookie) >= 4
            cCookieRet := aCookie[1]+";"+;
                          " Path=/api"+";"+;
                          aCookie[2]+";"+;
                          aCookie[3]+";"+;
                          aCookie[4]+";"
        EndIf 
    EndIf

Return cCookieRet


//----------------------------------------------------------
/*/{Protheus.doc} GetAuthentication
Retorna se foi realizada a Autenticação da Integração

@author Vinicius Queiros Teixeira
@since 31/08/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Method GetAuthentication() Class PLMapComPed
Return self:lAuthentication
