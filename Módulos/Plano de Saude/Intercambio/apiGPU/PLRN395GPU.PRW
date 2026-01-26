#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE 'FWMBROWSE.CH'
#INCLUDE 'FWMVCDEF.CH'

//-----------------------------------------------------------------
/*/{Protheus.doc} WRN395REST
 Classe para comunicacao dos protocolos GPU
 
@author renan.almeida
@since 17/05/2021
@version 1.0
/*/
//-----------------------------------------------------------------
Class PLRN395GPU From PlsRest

    Data aParam As Array
    Data lAuto As Boolean
    Data cJsonAuto As String
    Data cVersao As String
    Data cBearer As String
    Data cCookie As String
    Data cTransacao As String
    Data lAuthentication As Boolean

    Method New()
    Method comunGPU(aParam)
    Method getBearer()
    Method ProcAuthentication(cJson, cCookie)
    Method setupPost()
    Method datHorMask(dData,cHorario)
    Method convData(cDataHora)
    Method setCabEnv(cCodTran,cCodUniOri,cCodUniDes,cNumRegAns,cNumTraPre,dDatGer,cIDUsuario)
    Method setCabRes(cCodTran,cCodUniOri,cCodUniDes,cNumRegAns,cNumTraPre,cDataSol)
    Method setVarCab(oRequest,cCodUniOri,cCodUniDes,cNumRegAns,cNumTraPre,dDataGer,cIdUsuario)
    Method SetAtributo(xValor)
    Method GetAtributo(xValor, cTipo)
    Method SetLogGPU()
    Method MontaCookie(cCookie)
      
    //Metodos Set
    Method setaParam(aParam)

EndClass


//-----------------------------------------------------------------
/*/{Protheus.doc} New
 Classe Construtora
 
@author renan.almeida
@since 17/05/2021
@version 1.0
/*/
//-----------------------------------------------------------------
Method New() Class PLRN395GPU
    
    _Super:new()

    self:aParam := {}
    self:lAuto := .F.
    self:cJsonAuto := ""   
    self:cVersao := GetNewPar("MV_R395LAY","001")
    self:cBearer := ""
    self:cCookie := ""
    self:cTransacao := ""
    self:lAuthentication := .F.

    //Atributos PLSREST
    self:cCodOpe := PlsIntPad()
    self:SetLogGPU()
    
Return

//-----------------------------------------------------------------
/*/{Protheus.doc} Metodos Set
 
@author renan.almeida
@since 17/05/2021
@version 1.0
/*/
//-----------------------------------------------------------------
Method setaParam(aParam) Class PLRN395GPU
    self:aParam := aParam
Return


//-----------------------------------------------------------------
/*/{Protheus.doc} comunGPU
 Realiza a comunicacao
 
@author renan.almeida
@since 17/05/2021
@version 1.0
/*/
//-----------------------------------------------------------------
Method comunGPU(aParam) Class PLRN395GPU
    
    Local aRetFun := {}

    self:impLog("Comunicacao de Envio - GPU " + cvaltochar(dDataBase), .F.)  
    
    self:setaParam(aParam)  
    self:getBearer()

    If self:lAuthentication .Or. self:lAuto
        self:impLog("Autenticacao realizada com sucesso!")
        self:mntJson()
        self:setupPost()
    Else
        self:impLog("Falha na Autenticacao, verifique os dados no cadastro da Operadora.")
    EndIf

    aRetFun := self:procResp()
    self:impLog("", .F.)
    
Return aRetFun


//-----------------------------------------------------------------
/*/{Protheus.doc} getBearer
Solicita o bearer de acesso ao GPU

@author Vinicius Queiros Teixeira
@since 01/06/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Method getBearer() Class PLRN395GPU

    Local oRequest := JsonObject():New()
    Local aTimeExpiracao := ""
    Local lNovoToken := .T.
    Local dDtToken := CToD(" / / ")
    Local nSegToken := 0
    Local lCamposGIU := BA0->(FieldPos("BA0_USRGIU")) > 0 .And. BA0->(FieldPos("BA0_PASGIU")) > 0 .And. ;
                        BA0->(FieldPos("BA0_ENDGIU")) > 0 .And. BA0->(FieldPos("BA0_COOGIU")) > 0 .And. ;
                        BA0->(FieldPos("BA0_BEAGIU")) > 0 .And. BA0->(FieldPos("BA0_TMPGIU")) > 0

    self:impLog("Autenticando usuario no GIU...")   

    If !Empty(self:cCodOpe) .And. lCamposGIU
        self:impLog("Operadora: "+self:cCodOpe)   

        BA0->(DbSetOrder(1))
        If BA0->(MsSeek(xFilial("BA0")+self:cCodOpe))

            aTimeExpiracao := StrTokArr(Alltrim(BA0->BA0_TMPGIU), "|")

            If Len(aTimeExpiracao) >= 2
                dDtToken := StoD(aTimeExpiracao[1])
                nSegToken := Val(aTimeExpiracao[2])

                If dDtToken == dDataBase .And. Seconds() < nSegToken
                    lNovoToken := .F.
                EndIf
            EndIf

            If lNovoToken
                self:cEndPoint := Alltrim(BA0->BA0_ENDGIU)

                oRequest["grant_type"] := "password"
                oRequest["username"] := Alltrim(BA0->BA0_USRGIU)
                oRequest["password"] := Alltrim(BA0->BA0_PASGIU)

                self:cJson := FWJsonSerialize(oRequest, .F., .F.)
                self:setHeadPar("Content-type", "application/json")

                self:comunPost()

                If self:lSucess
                    self:ProcAuthentication(self:cRespJson, self:cCookieResp)
                Else
                    self:lAuthentication := .F.
                EndIf

                self:resetAtrib()
                self:SetLogGPU()
            Else
                self:cCookie := Alltrim(BA0->BA0_COOGIU)
                self:cBearer := Alltrim(BA0->BA0_BEAGIU)
                self:lAuthentication := .T.
            EndIf

        EndIf   
    EndIf
Return


//-----------------------------------------------------------------
/*/{Protheus.doc} ProcAuthentication
Processa Json de Resposta da Autenticacao do Token

@author Vinicius Queiros Teixeira
@since 01/06/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Method ProcAuthentication(cJsonResp, cCookie) Class PLRN395GPU

    Local oResponse := JsonObject():New()
    Local lRetorno := .F.
    Local nTimeExpiracao := 0
    Local cDataExpiracao := DtoS(dDataBase)

    oResponse:FromJSON(cJsonResp)

    If oResponse["access_token"] <> Nil
        lRetorno := .T.
        self:cCookie := Alltrim(self:MontaCookie(cCookie))
        self:cBearer := Alltrim(oResponse["access_token"])
        nTimeExpiracao := NoRound(Seconds(), 0) + (oResponse["expires_in"] - 100)

        If !Empty(self:cCookie) .And. !Empty(self:cBearer)
            BA0->(Reclock("BA0", .F.))
                BA0->BA0_BEAGIU := self:cBearer
                BA0->BA0_COOGIU := self:cCookie
                BA0->BA0_TMPGIU := cDataExpiracao+"|"+cValtoChar(nTimeExpiracao)
            BA0->(MsUnLock())
            self:lAuthentication := .T.
        Else    
            self:lAuthentication := .F.
        EndIf
    EndIf

Return lRetorno


//-----------------------------------------------------------------
/*/{Protheus.doc} setupPost
Realiza Post com o GPU

@author renan.almeida
@since 17/05/2021
@version 1.0
/*/
//-----------------------------------------------------------------
Method setupPost() Class PLRN395GPU

    self:impLog("Processando comunicacao o GPU... " + cvaltochar(dDataBase))

    self:setHeadPar("Authorization", self:cBearer)
    self:setHeadPar("Cookie", self:cCookie)
    self:setHeadPar("Content-type", "application/json")

    Do Case
        Case self:cTransacao == "001" //"solicitarProtocolo"
            self:cEndPoint := GetNewPar("MV_R395SOL", "https://gpupainelhml.unimed.coop.br/gpu-core/rest/solicitar-protocolo")    
               
        Case self:cTransacao == "003" //"complementoProtocolo"
            self:cEndPoint := GetNewPar("MV_R395COM", "https://gpupainelhml.unimed.coop.br/gpu-core/rest/complemento-protocolo")	     	
              
        Case self:cTransacao == "005" //"respostaAtendimento"
            self:cEndPoint := GetNewPar("MV_R395RES", "https://gpupainelhml.unimed.coop.br/gpu-core/rest/resposta-atendimento") 

        Case self:cTransacao == "007" //"consultaStatusProtocolo"
            self:cEndPoint := GetNewPar("MV_R395STA", "https://gpupainelhml.unimed.coop.br/gpu-core/rest/consulta-status")

        Case self:cTransacao == "009" //"consultaHistorico"
            self:cEndPoint := GetNewPar("MV_R395HIS", "https://gpupainelhml.unimed.coop.br/gpu-core/rest/consulta-historico")	   
              
        Case self:cTransacao == "011" //"cancelamento"
            self:cEndPoint := GetNewPar("MV_R395CAN", "https://gpupainelhml.unimed.coop.br/gpu-core/rest/cancelamento") 
                                    
        Case self:cTransacao == "013" //"encaminharExecucao"
            self:cEndPoint := GetNewPar("MV_R395ENC", "https://gpupainelhml.unimed.coop.br/gpu-core/rest/encaminhar-execucao")

        Case self:cTransacao == "017" //"protocoloNaoCliente"
            self:cEndPoint := GetNewPar("MV_R395RNC", "https://gpupainelhml.unimed.coop.br/gpu-core/rest/resposta-atendimento-nao-cliente")		
    EndCase
    
    self:comunPost()
   
Return


//-----------------------------------------------------------------
/*/{Protheus.doc} datHorMask
 
@author renan.almeida
@since 17/05/2021
@version 1.0
/*/
//-----------------------------------------------------------------
Method datHorMask(dData,cHorario) Class PLRN395GPU

    Local cRet := ""                         
    Default cHorario := Time()   

    if !Empty(dData)
        cRet := Substr(Dtos(dData),1,4)+"-"+Substr(Dtos(dData),5,2)+"-"+Substr(Dtos(dData),7,2)+" "+cHorario
    endIf

Return cRet


//-----------------------------------------------------------------
/*/{Protheus.doc} convData
 
@author renan.almeida
@since 17/05/2021
@version 1.0
/*/
//-----------------------------------------------------------------
Method convData(cDataHora) Class PLRN395GPU
Return Stod(StrTran(Substr(cDataHora,1,10),"-",""))


//-----------------------------------------------------------------
/*/{Protheus.doc} setCabEnv
  Monta cabecalho de para realizar uma solicitacao

@author renan.almeida
@since 17/05/2021
@version 1.0
/*/
//-----------------------------------------------------------------
Method setCabEnv(cCodTran,cCodUniOri,cCodUniDes,cNumRegAns,cNumTraPre,dDatGer,cIDUsuario) Class PLRN395GPU

    Local oCabec := JsonObject():New()
    
    oCabec["cd_transacao"] := cCodTran
    oCabec["tp_cliente"] := "UNIMED"
    oCabec["cd_uni_origem"] := self:setAtributo(Strzero(Val(cCodUniOri),4))
    oCabec["cd_uni_destino"] := self:setAtributo(Strzero(Val(cCodUniDes),4))
    oCabec["nr_ans"] := self:setAtributo(cNumRegAns)
    oCabec["nr_transacao_prestadora"] := self:setAtributo(cNumTraPre)
    If cCodTran == "011"
        oCabec["dt_cancelamento"] := self:datHorMask(dDatGer)
    Else
        oCabec["dt_manifestacao"] := self:datHorMask(dDatGer)
    EndIf
    oCabec["id_usuario"] := cIDUsuario
    oCabec["nr_versao"] := self:cVersao

Return oCabec


//-----------------------------------------------------------------
/*/{Protheus.doc} setCabRes
  Monta cabecalho para montar uma resposta

@author renan.almeida
@since 17/05/2021
@version 1.0
/*/
//-----------------------------------------------------------------
Method setCabRes(cCodTran,cCodUniOri,cCodUniDes,cNumRegAns,cNumTraPre,cDataSol,cIdUsuario) Class PLRN395GPU

    Local oCabec := JsonObject():New()

    Default cDataSol := ""
    Default cIdUsuario := ""
    
    oCabec["cd_transacao"] := cCodTran
    oCabec["tp_cliente"] := "UNIMED"
    oCabec["cd_uni_origem"] := self:setAtributo(Strzero(Val(cCodUniOri),4))
    oCabec["cd_uni_destino"] := self:setAtributo(Strzero(Val(cCodUniDes),4))
    oCabec["nr_ans"] := self:setAtributo(cNumRegAns)
    oCabec["nr_transacao_prestadora"] := self:setAtributo(cNumTraPre)
    Do Case
        Case cCodTran == "008" .Or. cCodTran == "020" // Consulta Status
            oCabec["dt_sol_protocolo"] := self:setAtributo(cDataSol)

        OtherWise
            oCabec["id_usuario"] := self:setAtributo(cIdUsuario)
    EndCase
    oCabec["nr_versao"] := self:cVersao

Return oCabec


//-----------------------------------------------------------------
/*/{Protheus.doc} setVarCab
  Seta as variaveis com dados do cabecalho

@author renan.almeida
@since 17/05/2021
@version 1.0
/*/
//-----------------------------------------------------------------
Method setVarCab(oRequest, cCodUniOri, cCodUniDes, cNumRegAns, cNumTraPre, dDataGer, cIdUsuario, cTransacao, cVersao) Class PLRN395GPU

    Default cTransacao := ""

    cCodUniOri := oRequest['cabecalho_transacao']['cd_uni_origem']
	cCodUniDes := oRequest['cabecalho_transacao']['cd_uni_destino']
	cNumRegAns := oRequest['cabecalho_transacao']['nr_ans']	
	cNumTraPre := oRequest['cabecalho_transacao']['nr_transacao_prestadora']
    If cTransacao == "011"
        dDataGer := self:convData(oRequest['cabecalho_transacao']['dt_cancelamento'])
    Else
	    dDataGer := self:convData(oRequest['cabecalho_transacao']['dt_manifestacao'])
        cVersao := oRequest['cabecalho_transacao']['nr_versao']
    EndIf
	cIdUsuario := oRequest['cabecalho_transacao']['id_usuario']

Return

//-----------------------------------------------------------------
/*/{Protheus.doc} setAtributo
Set Atributo no JSON

@author Vinicius Queiros Teixeira
@since 31/05/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Method SetAtributo(xValor, cTipo) Class PLRN395GPU
    
    Local xRetorno

    Default xValor := ""
    Default cTipo := ""

    If !Empty(xValor)
        xRetorno := xValor
        Do Case
            Case cTipo == "N" .And. ValType(xRetorno) == "C"
                xRetorno := Val(xRetorno)

            Case cTipo == "C" .And. ValType(xRetorno) == "N"
                xRetorno := cValToChar(xRetorno)
        EndCase
    Else
        xRetorno := Nil
    EndIf

Return xRetorno


//-----------------------------------------------------------------
/*/{Protheus.doc} GetAtributo
Get Atributo do JSON

@author Vinicius Queiros Teixeira
@since 31/05/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Method GetAtributo(xValor, cTipo) Class PLRN395GPU
    
    Local xRetorno

    Default xValor := ""
    Default cTipo := "C"

    If !Empty(xValor)
        xRetorno := xValor
        Do Case
            Case cTipo == "N" .And. ValType(xRetorno) == "C"
                xRetorno := Val(xRetorno)

            Case cTipo == "C" .And. ValType(xRetorno) == "N"
                xRetorno := cValToChar(xRetorno)
        EndCase
    Else    
        Do Case
            Case cTipo == "C"
                xRetorno := ""
            Case cTipo == "N"
                xRetorno := 0
        EndCase
    EndIf

Return xRetorno


//-----------------------------------------------------------------
/*/{Protheus.doc} SetLogGPU
Set Log do GPU

@author Vinicius Queiros Teixeira
@since 01/06/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Method SetLogGPU() Class PLRN395GPU

    self:lGeraLog := .T.
    self:cNameLog := 'plgpurest.log'

Return


//-----------------------------------------------------------------
/*/{Protheus.doc} MontaCookie
Monta Cookie para Autenticação com o GPU

@author Vinicius Queiros Teixeira
@since 02/06/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Method MontaCookie(cCookie) Class PLRN395GPU

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
