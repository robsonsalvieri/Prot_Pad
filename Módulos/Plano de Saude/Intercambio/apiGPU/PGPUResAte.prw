#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE 'FWMBROWSE.CH'
#INCLUDE 'FWMVCDEF.CH'

//-----------------------------------------------------------------
/*/{Protheus.doc} PGPUResAte
Classe para Enviar uma mensagem para a Unimed referente à resposta 
de manifestação de seu beneficiário.
 
@author renan.almeida
@since 31/05/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Class PGPUResAte From PLRN395GPU

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
Method New() Class PGPUResAte
    
    _Super:new()
    self:cTransacao := "005"

Return


//-----------------------------------------------------------------
/*/{Protheus.doc} mntJson
Monta Json de comunicação com o GPU 
 
@author renan.almeida
@since 31/05/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Method mntJson() Class PGPUResAte

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
    Local cIdResposta := self:aParam[10]
    Local cNrTrol := self:aParam[11]
    Local cMsgLivre := self:aParam[12]

    //Cabecalho
    oCabec := self:setCabEnv("005", cCodUniOri, cCodUniDes, cNumRegAns, cNumTraOri, dDatGer, cIDUsuario)

    //Body
    oBody["cd_unimed"] := self:setAtributo(cCodUniBen) 
    oBody["id_benef"] := self:setAtributo(cIDBenef)  
    oBody["nr_protocolo"] := self:setAtributo(cNumProto)  
    oBody["id_resposta"] := self:setAtributo(cIdResposta, "N")
    oBody["nr_transacao_origem_benef"] := self:setAtributo(cNrTrol)  
    oBody["mensagem"] := self:setAtributo(cMsgLivre) 
    //oBody["nr_transacao_intercambio"]
    
    //Monta json completo
    oGPU["cabecalho_transacao"] := oCabec
    oGPU["resposta_atendimento"] := oBody

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
Method procResp() Class PGPUResAte

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

        Case self:lSucess .And. oResponse["cabecalho_transacao"]["cd_transacao"] == "006"      
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
            Aadd(aCriticas,{"999", "Falha na comunicacao com o GPU." })
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
Method procSolic(cJson) Class PGPUResAte

    Local oRequest := JsonObject():New()
    Local aJsonResp := {}
    Local aMsg := {}
    //Cabecalho
    Local cCodUniOri := ""
    Local cCodUniDes := ""
    Local cNumRegAns := ""
    Local cNumTraPre := ""
    Local dDataGer := ""
    Local cIDUsuario := ""
    //Body
    Local cMatric := ""
    Local cNumProtoc := ""
    Local cIDResp := ""
    Local cNrTrolOri := ""
    Local cTime := ""
    Local cMsgLivre := ""
    local cVersao := ""

    self:impLog("Comunicacao de Recebimento - GPU", .F.)
    self:impLog("Json Recebido: "+cJson)

    oRequest:fromJSON(cJson)

    //Cabecalho
    self:setVarCab(oRequest, @cCodUniOri, @cCodUniDes, @cNumRegAns, @cNumTraPre, @dDataGer, @cIdUsuario, @cVersao)

    //Body
	cMatric := self:GetAtributo(oRequest['resposta_atendimento']['cd_unimed']) + self:GetAtributo(oRequest['resposta_atendimento']['id_benef'])
    cNumProtoc := self:GetAtributo(oRequest['resposta_atendimento']['nr_protocolo'])
    cIDResp := self:GetAtributo(oRequest['resposta_atendimento']['id_resposta'])
    cNrTrolOri := self:GetAtributo(oRequest['resposta_atendimento']['nr_transacao_origem_benef']) 
    cMsgLivre  := self:GetAtributo(oRequest['resposta_atendimento']['mensagem'])
    AAdd(aMsg, cMsgLivre)
    cTime := SubStr(self:GetAtributo(oRequest['cabecalho_transacao']['dt_manifestacao']), 12, 8)

    // Chamada da funcao de processamento
    self:impLog("Processando Resposta...")
	aRet := PLResAteWB(cCodUniOri, cCodUniDes, cNumRegAns, cNumTraPre, dDataGer, cIDUsuario,;
                       cMatric, cNumProtoc, cIDResp, cNrTrolOri, aMsg, cTime)  
    
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
Method jsonResp(aRet) Class PGPUResAte

    Local cJson := ''
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

        cCodUniBen := Strzero(Val(aRet[1,9]), 4)
        cIDBenef := aRet[1,10]

        oCabec := self:setCabRes("006", cCodUniOri, cCodUniDes, cNumRegAns, cNumTraPre, , cIdUsuario)

        oBody["cd_unimed"] := self:setAtributo(cCodUniBen)
        oBody["id_benef"] := self:setAtributo(cIDBenef)
        oBody["id_origem_resposta"] := 1 // 1-Sistema próprio da Unimed | 2-Gestão de Protocolos 

        //Monta json completo
        oResponse["cabecalho_transacao"] := oCabec
        oResponse["resposta_atendimento"] := oBody

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