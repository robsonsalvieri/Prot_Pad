#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE 'FWMBROWSE.CH'
#INCLUDE 'FWMVCDEF.CH'

//-----------------------------------------------------------------
/*/{Protheus.doc} PGPUConSta
Classe para Enviar uma mensagem para a Unimed referente à consulta 
de status de um protocolo existente.
 
@author Vinicius Queiros Teixeira
@since 25/05/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Class PGPUConSta From PLRN395GPU

    Method New()
    Method mntJson()
    Method procResp()
    Method procSolic(cJson)
    Method jsonResp(aRet)

EndClass


//-----------------------------------------------------------------
/*/{Protheus.doc} New
Classe Construtora
 
@author Vinicius Queiros Teixeira
@since 25/05/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Method New() Class PGPUConSta
    
    _Super:new()
    self:cTransacao := "007"

Return


//-----------------------------------------------------------------
/*/{Protheus.doc} mntJson
Monta Json de comunicação com o GPU 
 
@author Vinicius Queiros Teixeira
@since 25/05/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Method mntJson() Class PGPUConSta

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

    //Cabecalho
    oCabec := self:setCabEnv("007", cCodUniOri, cCodUniDes, cNumRegAns, cNumTraOri, dDatGer, cIDUsuario)

    //Body
    oBody["cd_unimed"] := self:setAtributo(cCodUniBen)
    oBody["id_benef"] := self:setAtributo(cIDBenef)
    oBody["nr_protocolo"] := self:setAtributo(cNumProto)

    //Monta json completo
    oGPU["cabecalho_transacao"] := oCabec
    oGPU["consulta_status_protocolo"] := oBody

    self:cJson := FWJsonSerialize(oGPU, .F., .F.)

Return


//-----------------------------------------------------------------
/*/{Protheus.doc} procResp
Processa a resposta da comunicacao
 
@author Vinicius Queiros Teixeira
@since 25/05/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Method procResp() Class PGPUConSta

    Local oResponse := JsonObject():New()
    Local lRet := .F.
    Local aRetFun := {}
    Local aCriticas := {}
    // Dados da Resposta
    Local cIdErro := ""
    Local cMensagem := ""
    Local cNumProtoc := ""
    Local cTpManif := ""
    Local cTpCateg := ""
    Local cSubCtg := ""
    Local cTpSentim := ""
    Local cIdResp := ""
    Local cIdUsuario := ""
    Local cDtSolicitacao := ""
    Local aMenPedido := {}
    Local aMenResp := {}

    oResponse:fromJSON(self:cRespJson)

    Do Case
        Case !self:lAuthentication .And. !self:lAuto
            Aadd(aCriticas,{"999", "Falha na autenticação no GIU, verifique os dados no cadastro de Operadoras" })

        Case self:lSucess .And. oResponse["cabecalho_transacao"]["cd_transacao"] == "008"             
            lRet := .T.
            cNumProtoc := self:GetAtributo(oResponse["resposta_consulta_status_protocolo"]["nr_protocolo"])
            cTpManif := self:GetAtributo(cValtoChar(oResponse["resposta_consulta_status_protocolo"]["tp_manifestacao"]))
            cTpCateg := self:GetAtributo(cValtoChar(oResponse["resposta_consulta_status_protocolo"]["tp_categoria_manifestacao"]))
            cSubCtg := self:GetAtributo(cValtoChar(oResponse["resposta_consulta_status_protocolo"]["tp_sub_categoria"]))
            cIdResp := self:GetAtributo(cValtoChar(oResponse["resposta_consulta_status_protocolo"]["id_resposta"])) 
            cIdUsuario := self:GetAtributo(oResponse["resposta_consulta_status_protocolo"]["id_usuario"])
            cDtSolicitacao := self:GetAtributo(oResponse["resposta_consulta_status_protocolo"]["dt_solicitacao_protocolo"])
            cMensagem := self:GetAtributo(oResponse["resposta_consulta_status_protocolo"]["mensagem"])

            Aadd(aMenPedido,{cIdUsuario, cDtSolicitacao, cDtSolicitacao, cMensagem})
        
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

	// Monta array especifico de retorno
	Aadd(aRetFun, lRet)					
	Aadd(aRetFun, aCriticas)
	Aadd(aRetFun, cNumProtoc)  
	Aadd(aRetFun, cTpManif)
	Aadd(aRetFun, cTpCateg)
    Aadd(aRetFun, cSubCtg)
	Aadd(aRetFun, cTpSentim)     
	Aadd(aRetFun, cIdResp)        
	Aadd(aRetFun, aMenPedido)
	Aadd(aRetFun, aMenResp)

    self:impLog(IIF(lRet, "Json de Resposta processado com sucesso!", "Falha ao processar Json de Resposta."))

Return aRetFun


//-----------------------------------------------------------------
/*/{Protheus.doc} procSolic
Processa Solicitação
 
@author Vinicius Queiros Teixeira
@since 25/05/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Method procSolic(cJson) Class PGPUConSta

    Local oRequest := JsonObject():New()
    Local aJsonResp := {}
    //Cabecalho
    Local cCodUniOri := ""
	Local cCodUniDes := ""
	Local cNumRegAns := ""
	Local cNumTraPre := ""
	Local dDataGer := CToD(" / / ")
	Local cIdUsuario := ""
    //Body
    Local cMatric := ""
    Local cNumProtoc := "" 
    local cVersao := ""

    self:impLog("Comunicacao de Recebimento - GPU", .F.)
    self:impLog("Json Recebido: "+cJson)

    oRequest:fromJSON(cJson)
    
    //Cabecalho
    self:setVarCab(oRequest, @cCodUniOri, @cCodUniDes, @cNumRegAns, @cNumTraPre, @dDataGer, @cIdUsuario,@cVersao)

    cMatric := self:GetAtributo(oRequest['consulta_status_protocolo']['cd_unimed']) + self:GetAtributo(oRequest['consulta_status_protocolo']['id_benef'])
    cNumProtoc := self:GetAtributo(oRequest['consulta_status_protocolo']['nr_protocolo'])

	// Chamada da funcao de processamento
    self:impLog("Processando Resposta...")
	aRet := PLConStaWB(cCodUniOri, cCodUniDes, cNumRegAns, cNumTraPre, dDataGer, cIDUsuario, cMatric, cNumProtoc) 

    // Monta Json de Resposta
    aJsonResp := self:jsonResp(aRet)

    self:impLog("Json de Resposta: "+aJsonResp[2])
    self:impLog("", .F.)
 
Return aJsonResp


//-----------------------------------------------------------------
/*/{Protheus.doc} jsonResp
Monta json de resposta

@author Vinicius Queiros Teixeira
@since 25/05/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Method jsonResp(aRet) Class PGPUConSta

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
    Local cDtSolicit := ""
    //Body
    Local cCodUniBen := ""
    Local cIDBenef := ""
    Local cNome := ""
    Local cTpManifest := ""
    Local cTpCategManif := ""
    Local cTipSubCtg := ""
    Local cNumProtocolo := ""
    Local cIDRespota := ""
    Local cNumPrestTrans := ""
    Local cNumOrigTrans := ""
    Local cIDUsuario := ""
    Local cDTSolProtoc := ""
    Local cMensagem := ""
    Local cIDOrigem := ""
    Local nIdErro := 0

    //Arquivo processado com sucesso
    If Empty(aRet[3])

        cCodUniOri := aRet[1,3]
        cCodUniDes := aRet[1,4]
        cNumRegAns := aRet[1,5]
        cNumTraPre := aRet[1,7]
        cDtSolicit := aRet[1,6]
        cCodUniBen := Strzero(Val(aRet[1][14]),4)
        cIDBenef := aRet[1][15]
        cNome := aRet[1][13]
        cTpManifest := aRet[1][10]
        cTpCategManif := aRet[1][11] 
        cTipSubCtg := aRet[1][23] 
        cNumProtocolo := aRet[1][9]
        cIDRespota := aRet[1][18]
        cNumPrestTrans := aRet[1][16]
        cNumOrigTrans := aRet[1][17]
        cIDUsuario := aRet[1][20][1][1]
        cDTSolProtoc := aRet[1][20][1][2]
        cMensagem := aRet[1][20][1][4]
        cIDOrigem := aRet[1][22]
 
        oCabec := self:setCabRes("008", cCodUniOri, cCodUniDes, cNumRegAns, cNumTraPre, cDtSolicit)

        oBody["cd_unimed"] := self:setAtributo(cCodUniBen)
        oBody["id_benef"] := self:setAtributo(cIDBenef)
        oBody["nome"] := self:setAtributo(cNome)
        oBody["tp_manifestacao"] := self:setAtributo(Val(cTpManifest))
        oBody["tp_categoria_manifestacao"] := self:setAtributo(Val(cTpCategManif))

        if cTipSubCtg != "0"
            oBody["tp_sub_categoria"] := self:setAtributo(Val(cTipSubCtg))
        endif
  
        oBody["nr_protocolo"] := self:setAtributo(cNumProtocolo)
        oBody["id_resposta"] := self:setAtributo(Val(cIDRespota))
        oBody["Num_trans_interc_prestadora"] := self:setAtributo(cNumPrestTrans)
        oBody["Num_trans_origem_beneficiario"] := self:setAtributo(cNumOrigTrans)
        oBody["id_usuario"] := self:setAtributo(cIDUsuario)
        oBody["dt_solicitacao_protocolo"] := self:setAtributo(cDTSolProtoc)
        oBody["mensagem"] := self:setAtributo(cMensagem)
        oBody["id_origem_resposta"] := self:setAtributo(Val(cIDOrigem))

        //Monta json completo
        oResponse["cabecalho_transacao"] := oCabec
        oResponse["resposta_consulta_status_protocolo"] := oBody

        self:impLog("Resposta processada com sucesso!")
	Else //Arquivo com erro
        lStatus := .F.
        nIdErro := Val(aRet[3])
        oResponse["id_Identificador"] := 2 // 1-Confirmado | 2-Conteúdo com erro 
        oResponse["id_erro"] := nIdErro

        self:impLog("Resposta com Erro.")
    EndIf

    cJson := FWJsonSerialize(oResponse, .F., .F.)

Return {lStatus, cJson}
