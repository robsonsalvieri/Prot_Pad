#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE 'FWMBROWSE.CH'
#INCLUDE 'FWMVCDEF.CH'

//-----------------------------------------------------------------
/*/{Protheus.doc} PGPUCanAte
Classe para Enviar uma mensagem de cancelamento para a Unimed.
 
@author Vinicius Queiros Teixeira
@since 26/05/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Class PGPUCanAte From PLRN395GPU

    Method New()
    Method mntJson()
    Method procResp()
    Method procSolic(cJson)
    Method jsonResp(aRet,cNumProtoc)

EndClass


//-----------------------------------------------------------------
/*/{Protheus.doc} New
Classe Construtora
 
@author Vinicius Queiros Teixeira
@since 26/05/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Method New() Class PGPUCanAte
    
    _Super:new()
    self:cTransacao := "011"

Return


//-----------------------------------------------------------------
/*/{Protheus.doc} mntJson
Monta Json de comunicação com o GPU 
 
@author Vinicius Queiros Teixeira
@since 26/05/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Method mntJson() Class PGPUCanAte

    Local oGPU := JsonObject():New()
    Local oCabec := JsonObject():New()
    Local oBody := JsonObject():New()
    //Cabecalho
    Local cCodUniOri := self:aParam[01]
    Local cCodUniDes := self:aParam[02]
    Local cNumRegAns := self:aParam[03]
    Local cNumTraOri := self:aParam[04]
    Local dDatCancel := self:aParam[05]
	Local cIDUsuario := self:aParam[06]
    //Body
    Local cCodUniBen := self:aParam[07]
    Local cIDBenef := self:aParam[08]
    Local cNumProto := self:aParam[09]
    Local cMotivo := self:aParam[10]

    //Cabecalho
    oCabec := self:setCabEnv("011", cCodUniOri, cCodUniDes, cNumRegAns, cNumTraOri, dDatCancel, cIDUsuario)

    //Body
    oBody["cd_unimed"] := self:setAtributo(cCodUniBen)
    oBody["id_benef"] := self:setAtributo(cIDBenef)
    oBody["nr_protocolo"] := self:setAtributo(cNumProto)
    oBody["motivo_cancelamento"] := self:setAtributo(cMotivo)

    //Monta json completo
    oGPU["cabecalho_transacao"] := oCabec
    oGPU["cancelamento"] := oBody

    self:cJson := FWJsonSerialize(oGPU, .F., .F.)

Return


//-----------------------------------------------------------------
/*/{Protheus.doc} procResp
Processa a resposta da comunicacao
 
@author Vinicius Queiros Teixeira
@since 26/05/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Method procResp() Class PGPUCanAte

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

        Case self:lSucess .And. oResponse["cabecalho_transacao", "cd_transacao"] == "012"                  
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

	// Monta array especifico de retorno
	Aadd(aRetFun, lRet)					
	Aadd(aRetFun, aCriticas)

    self:impLog(IIF(lRet, "Json de Resposta processado com sucesso!", "Falha ao processar Json de Resposta."))

Return aRetFun


//-----------------------------------------------------------------
/*/{Protheus.doc} procSolic
Processa Solicitação
 
@author Vinicius Queiros Teixeira
@since 26/05/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Method procSolic(cJson) Class PGPUCanAte

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
    Local cDescMot := ""
    Local cTime := ""

    self:impLog("Comunicacao de Recebimento - GPU", .F.)
    self:impLog("Json Recebido: "+cJson)

    oRequest:fromJSON(cJson)
    
    //Cabecalho
    self:setVarCab(oRequest, @cCodUniOri, @cCodUniDes, @cNumRegAns, @cNumTraPre, @dDataGer, @cIdUsuario, "011")
    cTime := Substr(self:GetAtributo(oRequest['cabecalho_transacao']['dt_cancelamento']), 12, 5)

    cMatric := self:GetAtributo(oRequest['cancelamento']['cd_unimed']) + self:GetAtributo(oRequest['cancelamento']['id_benef'])
    cNumProtoc := self:GetAtributo(oRequest['cancelamento']['nr_protocolo'])
    cDescMot := self:GetAtributo(oRequest['cancelamento']['motivo_cancelamento'])

	// Chamada da funcao de processamento
    self:impLog("Processando Resposta...")
	aRet := PLCanAteWB(cCodUniOri, cCodUniDes, cNumRegAns, cNumTraPre, dDataGer, cIDUsuario, ;
                       cMatric, cNumProtoc, cDescMot, cTime) 

    // Monta Json de Resposta
    aJsonResp := self:jsonResp(aRet, cNumProtoc)

    self:impLog("Json de Resposta: "+aJsonResp[2])
    self:impLog("", .F.)
 
Return aJsonResp


//-----------------------------------------------------------------
/*/{Protheus.doc} jsonResp
Monta json de resposta

@author Vinicius Queiros Teixeira
@since 26/05/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Method jsonResp(aRet, cNumProtoc) Class PGPUCanAte

    Local cJson := ""
    Local oResponse := JsonObject():New()
    Local oCabec := JsonObject():New()
    Local oBody := JsonObject():New()
    Local lStatus := .T.
    //Cabecalho
    Local cCodUniOri := ""
    Local cCodUniDes := ""
    Local cNumRegAns := ""
    Local cNumTraOri := ""
	Local cIDUsuario := ""
    //Body
    Local cCodUniBen := ""
    Local cIDBenef := ""
    Local cIDResposta := ""
    Local cIDSistema := ""
    Local nIdErro := 0

    //Arquivo processado com sucesso
    If Empty(aRet[3])
        
        cCodUniOri := aRet[1,3]
        cCodUniDes := aRet[1,4]
        cNumRegAns := aRet[1,5]
        cNumTraOri := aRet[1,6]
        cIDUsuario := aRet[1,8]

        cCodUniBen := Strzero(Val(aRet[1][9]),4)
        cIDBenef := aRet[1][10]
        cIDResposta := aRet[1][11]
        cIDSistema := aRet[1][12]

        oCabec := self:setCabRes("012", cCodUniOri, cCodUniDes, cNumRegAns, cNumTraOri, ,cIDUsuario)

        oBody["cd_unimed"] := self:setAtributo(cCodUniBen)
        oBody["id_benef"] := self:setAtributo(cIDBenef)
        oBody["id_resposta"] := self:setAtributo(cIDResposta, "N")
        oBody["nr_protocolo"] := self:setAtributo(cNumProtoc)
        oBody["id_sistema"] := self:setAtributo(cIDSistema, "N")

        //Monta json completo
        oResponse["cabecalho_transacao"] := oCabec
        oResponse["confirmacao"] := oBody

        self:impLog("Resposta processada com sucesso!")
	Else //Arquivo com erro
        lStatus := .F.
        nIdErro := Val(aRet[3])
        oResponse["id_Identificador"] := 2 // 1-Confirmado | 2-Conteúdo com erro 
        oResponse["id_erro"] := nIdErro

        self:impLog("Resposta com Erro.")
	Endif

    cJson := FWJsonSerialize(oResponse, .F., .F.)

Return {lStatus, cJson}