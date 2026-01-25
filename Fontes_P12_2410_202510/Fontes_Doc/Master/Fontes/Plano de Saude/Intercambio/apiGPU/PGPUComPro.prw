#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE 'FWMBROWSE.CH'
#INCLUDE 'FWMVCDEF.CH'

//-----------------------------------------------------------------
/*/{Protheus.doc} PGPUComPro
Classe para Enviar uma mensagem para a Unimed referente à uma 
manifestação de seu beneficiário. Essa mensagem poderá ser 
vinculada à uma transação de Intercâmbio entre as Unimeds e/ou a 
um protocolo de atendimento existente.
 
@author renan.almeida
@since 31/05/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Class PGPUComPro From PLRN395GPU

    Method New()
    Method mntJson()
    Method procResp()
    Method procSolic(cJson)
    Method jsonResp(aRet)

EndClass


//-----------------------------------------------------------------
/*/{Protheus.doc} New
Classe Construtora
 
@author renan.almeida
@since 31/05/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Method New() Class PGPUComPro
    
    _Super:new()
    self:cTransacao := "003"

Return


//-----------------------------------------------------------------
/*/{Protheus.doc} mntJson
Monta Json de comunicação com o GPU
 
@author renan.almeida
@since 12/02/2019
@version 1.0
/*/
//-----------------------------------------------------------------
Method mntJson() Class PGPUComPro

    Local oGPU := JsonObject():New()
    Local oCabec := JsonObject():New()
    Local oBody := JsonObject():New()
    //Cabecalho
    Local cCodUniOri := self:aParam[01]
    Local cCodUniDes := self:aParam[02]
    Local cNumRegAns := self:aParam[03]
    Local cNumTraOri := self:aParam[04]
    Local dDatGer := self:aParam[05]
	Local cIDUsuario := self:aParam[06]
    //Body
    Local cCodUniBen := self:aParam[07]
    Local cIDBenef := self:aParam[08]
    Local cNumProto := self:aParam[09]
    Local cNrTrol := self:aParam[10]
    Local cMsg := self:aParam[11]

    //Cabecalho
    oCabec := self:setCabEnv("003", cCodUniOri, cCodUniDes, cNumRegAns, cNumTraOri, dDatGer, cIDUsuario)

    //Body
    oBody["cd_unimed"] := self:setAtributo(cCodUniBen)
    oBody["id_benef"] := self:setAtributo(cIDBenef)
    oBody["nr_protocolo"] := self:setAtributo(cNumProto)
    oBody["mensagem"] := self:setAtributo(cMsg)
    oBody["nr_transacao_intercambio"] := self:setAtributo(cNrTrol)

    //Monta json completo
    oGPU["cabecalho_transacao"] := oCabec
    oGPU["pedido_complemento_protocolo"] := oBody

    self:cJson := FWJsonSerialize(oGPU, .F., .F.)

Return


//-----------------------------------------------------------------
/*/{Protheus.doc} procResp
Processa a resposta da comunicacao
 
@author renan.almeida
@since 31/05/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Method procResp() Class PGPUComPro

    Local oResponse := JsonObject():New()
    Local lRet := .F.
    Local aRetFun := {}
    Local aCriticas := {}
    // Dados da Resposta
    Local cIdErro := ""
    Local cMensagem := ""

    oResponse:fromJSON(self:cRespJson)

    Do Case
        Case !self:lAuthentication .And. !self:lAuto
            Aadd(aCriticas,{"999", "Falha na autenticação no GIU, verifique os dados no cadastro de Operadoras" })

        Case self:lSucess .And. oResponse["cabecalho_transacao"]["cd_transacao"] == "004"        
            lRet := .T.
            
        Case !self:lSucess .And. oResponse["id_identificador"] == 2 // Conteúdo com erro
            cIdErro := StrZero(oResponse["id_erro"], 4)
            cMensagem := self:GetAtributo(oResponse["mensagem"])
            If Val(cIdErro) <> 0
                Aadd(aCriticas,{cIdErro, cMensagem}) 
            Else
                Aadd(aCriticas, {"999", "Situacao Invalida"})
            EndIf

        OtherWise
            Aadd(aCriticas,{"999","Falha na comunicacao com o GPU." })
    EndCase

	// Monta array de especifico de retorno
	Aadd(aRetFun, lRet)
	Aadd(aRetFun, aCriticas)

    self:impLog(IIF(lRet, "Json de Resposta processado com sucesso!", "Falha ao processar Json de Resposta."))

Return aRetFun


//-----------------------------------------------------------------
/*/{Protheus.doc} procSolic
Processa Solicitação
 
@author renan.almeida
@since 31/05/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Method procSolic(cJson) Class PGPUComPro

    Local oRequest := JsonObject():New()
    Local aJsonResp := {}
    //Cabecalho
    Local cCodUniOri := ""
    Local cCodUniDes := ""
    Local cNumRegAns := ""
    Local cNumTraPre := ""
    Local cIdUsuario := ""
    local cVersao := ""
    //Body
    Local cMatric := ""
    Local cNumProtoc := "" 
    Local cNrTrolOri := ""
    Local dDataGer := CToD(" / / ") 

    self:impLog("Comunicacao de Recebimento - GPU", .F.)
    self:impLog("Json Recebido: "+cJson)

    oRequest:fromJSON(cJson)
    
    //Cabecalho
    self:setVarCab(oRequest, @cCodUniOri, @cCodUniDes, @cNumRegAns, @cNumTraPre, @dDataGer, @cIdUsuario, @cVersao)

    cMatric := self:GetAtributo(oRequest['pedido_complemento_protocolo']['cd_unimed']) + self:GetAtributo(oRequest['pedido_complemento_protocolo']['id_benef'])
    cNumProtoc := self:GetAtributo(oRequest['pedido_complemento_protocolo']['nr_protocolo'])
    cNrTrolOri := self:GetAtributo(oRequest['pedido_complemento_protocolo']['nr_transacao_intercambio'])

	// Chamada da funcao de processamento
    self:impLog("Processando Resposta...")
	aRet := PLComProWB(cCodUniOri, cCodUniDes, cNumRegAns, cNumTraPre, dDataGer, cIDUsuario, cMatric, cNumProtoc, cNrTrolOri)

    // Monta Json de Resposta
    aJsonResp := self:jsonResp(aRet)

    self:impLog("Json de Resposta: "+aJsonResp[2])
    self:impLog("", .F.)
 
Return aJsonResp


//-----------------------------------------------------------------
/*/{Protheus.doc} jsonResp
Monta json de resposta

@author renan.almeida
@since 31/05/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Method jsonResp(aRet) Class PGPUComPro

    Local cJson := ""
    Local oResponse := JsonObject():New()
    Local oCabec := JsonObject():New()
    Local oBody := JsonObject():New()
    Local lStatus := .T.
    //Cabecalho
    Local cCodUniOri := ""
	Local cCodUniDes := ""
	Local cNumRegAns := ""
	Local cNumTraPre := ""
    Local cIdUsuario := ""
    //Body
    Local cCodUniBen := ""
    Local cIDBenef := ""
    Local nIdErro := 0

    //Arquivo processado com sucesso
    If Empty(aRet[3])

        cCodUniOri := aRet[1][3]
        cCodUniDes := aRet[1][4]
        cNumRegAns := aRet[1][5]
        cNumTraPre := aRet[1][6]
        cIdUsuario := aRet[1][8]

        cCodUniBen := Strzero(Val(aRet[1][9]),4)
        cIDBenef := aRet[1][10]
 
        //Cabecalho
        oCabec := self:setCabRes("004", cCodUniOri, cCodUniDes, cNumRegAns, cNumTraPre, , cIdUsuario)

        oBody["cd_unimed"] := self:setAtributo(cCodUniBen)
        oBody["id_benef"] := self:setAtributo(cIDBenef)
        oBody["id_origem_resposta"] := 1 // 1-Sistema próprio da Unimed | 2-Gestão de Protocolos 

        //Monta json completo
        oResponse["cabecalho_transacao"]  := oCabec
        oResponse["resposta_complemento"] := oBody

        self:impLog("Resposta processada com sucesso!")
    Else //Arquivo com erro
        lStatus := .F.
        nIdErro := Val(aRet[3])
        oResponse["id_Identificador"] := 2 // 1-Confirmado | 2-Conteúdo com erro 
        oResponse["id_erro"] := nIdErro

        self:impLog("Resposta com Erro.")
    EndIf

    cJson := FWJsonSerialize(oResponse,.F.,.F.)

Return {lStatus, cJson}