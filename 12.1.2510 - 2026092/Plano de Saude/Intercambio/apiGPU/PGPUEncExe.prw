#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE 'FWMBROWSE.CH'
#INCLUDE 'FWMVCDEF.CH'

//-----------------------------------------------------------------
/*/{Protheus.doc} PGPUEncExe
Classe para Enviar uma mensagem da Unimed Origem do Beneficiário 
para a Unimed Repasse resolver uma manifestação (conforme acordo 
prévio entre as Singulares). O retorno da mensagem será uma 
Confirmação de recebimento e uma posterior Resposta do Atendimento 
pela Unimed Repasse.
 
@author Vinicius Queiros Teixeira
@since 27/05/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Class PGPUEncExe From PLRN395GPU

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
@since 27/05/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Method New() Class PGPUEncExe
    
    _Super:new()
    self:cTransacao := "013"

Return


//-----------------------------------------------------------------
/*/{Protheus.doc} mntJson
Monta Json de comunicação com o GPU 
 
@author Vinicius Queiros Teixeira
@since 27/05/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Method mntJson() Class PGPUEncExe

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
    Local cNome := self:aParam[09]
    Local cCPF := self:aParam[10]
    Local cDDD := self:aParam[11]
    Local cTelefone := self:aParam[12]
    Local cEmail := self:aParam[13]
    Local cTipManif := self:aParam[14]
    Local cTipCateg := self:aParam[15]
    Local cNumTraInt := self:aParam[16]
    Local cNumProAnt := self:aParam[17]
    Local cMsgLivre := self:aParam[18]

    //Cabecalho
    oCabec := self:setCabEnv("013", cCodUniOri, cCodUniDes, cNumRegAns, cNumTraOri, dDatGer, cIDUsuario)

    //Body
    oBody["cd_unimed"] := self:setAtributo(cCodUniBen)
    oBody["id_benef"] := self:setAtributo(cIDBenef)
    oBody["nome"] := self:setAtributo(cNome)
    oBody["cd_cpf"] := self:setAtributo(cCPF)
    oBody["ddd"] := self:setAtributo(cDDD)
    oBody["telefone"] := self:setAtributo(cTelefone)
    oBody["email"] := self:setAtributo(cEmail)
    oBody["tp_manifestacao"] := self:setAtributo(cTipManif)
    oBody["tp_categoria_manifestacao"] := {self:setAtributo(cTipCateg, "N")}
    oBody["nr_transacao_intercambio"] := self:setAtributo(cNumTraInt)
    oBody["nr_protocolo_anterior"] := self:setAtributo(cNumProAnt)
    oBody["mensagem"] := self:setAtributo(cMsgLivre)

    //Monta json completo
    oGPU["cabecalho_transacao"] := oCabec
    oGPU["encaminhar_execucao"] := oBody

    self:cJson := FWJsonSerialize(oGPU, .F., .F.)

Return


//-----------------------------------------------------------------
/*/{Protheus.doc} procResp
Processa a resposta da comunicacao
 
@author Vinicius Queiros Teixeira
@since 27/05/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Method procResp() Class PGPUEncExe

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

        Case self:lSucess .And. oResponse["cabecalho_transacao", "cd_transacao"] == "014"             
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
@since 27/05/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Method procSolic(cJson) Class PGPUEncExe

    Local oRequest := JsonObject():New()
    Local aJsonResp := {}
    // Cabecalho
    Local cCodUniOri := ""
    Local cCodUniDes := ""
    Local cNumRegAns := ""
    Local cNumTraIni := ""
    Local dDataGer := CToD(" / / ")
    Local cIdUsuario := ""
    Local cNumTraOri := ""
    // Body
    Local cMatric := ""      
    Local cNomeBenef := ""
    Local cCPF := ""
    Local cDDD := ""
    Local cTelefone := ""
    Local cEmail := ""
    Local cTipManif := ""
    Local cTipCateg := ""
    Local cTipSentim := ""	
    Local cNumProAnt := ""
    Local cNrTrolOri := ""
    Local cMsgLivre := ""
    Local cNumProto := ""
    local cVersao := ""

    self:impLog("Comunicacao de Recebimento - GPU", .F.)
    self:impLog("Json Recebido: "+cJson)
          
    oRequest:fromJSON(cJson)
    
    //Cabecalho
    self:setVarCab(oRequest, @cCodUniOri, @cCodUniDes, @cNumRegAns, @cNumTraIni, @dDataGer, @cIdUsuario, @cVersao)

    cMatric := self:GetAtributo(oRequest['encaminhar_execucao']['cd_unimed']) + self:GetAtributo(oRequest['encaminhar_execucao']['id_benef'])
    cNomeBenef := self:GetAtributo(oRequest['encaminhar_execucao']['nome'])
	cCPF := self:GetAtributo(oRequest['encaminhar_execucao']['cd_cpf'])      
	cDDD := self:GetAtributo(oRequest['encaminhar_execucao']['ddd'])      
	cTelefone := self:GetAtributo(oRequest['encaminhar_execucao']['telefone']) 
	cEmail := self:GetAtributo(oRequest['encaminhar_execucao']['email'])     
	cTipManif := self:GetAtributo(oRequest['encaminhar_execucao']['tp_manifestacao']) 
	cTipCateg := self:GetAtributo(oRequest['encaminhar_execucao']['tp_categoria_manifestacao'][1])  
	cTipSentim := "" // Não utilizado no JSON        
	cNrTrolOri := self:GetAtributo(oRequest['encaminhar_execucao']['nr_transacao_intercambio'])  
	cNumProto:= self:GetAtributo(oRequest['encaminhar_execucao']['nr_protocolo_anterior'])
	cNumProAnt := self:GetAtributo(oRequest['encaminhar_execucao']['nr_protocolo_anterior']) 
	cMsgLivre := self:GetAtributo(oRequest['encaminhar_execucao']['mensagem'])

	// Chamada da funcao de processamento
    self:impLog("Processando Resposta...")
	aRet := PLEncExeWB(cCodUniOri, cCodUniDes, cNumRegAns, cNumTraIni, cNumTraOri, dDataGer, cIDUsuario, cMatric,;
					   cNomeBenef, cCPF, cDDD, cTelefone, cEmail, cTipManif, cTipCateg, cTipSentim, cNrTrolOri,;
                       cNumProto, cNumProAnt, cMsgLivre)

    // Monta Json de Resposta
    aJsonResp := self:jsonResp(aRet, cNumProAnt)

    self:impLog("Json de Resposta: "+aJsonResp[2])
    self:impLog("", .F.)
 
Return aJsonResp


//-----------------------------------------------------------------
/*/{Protheus.doc} jsonResp
Monta json de resposta

@author Vinicius Queiros Teixeira
@since 27/05/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Method jsonResp(aRet, cNumProtoc) Class PGPUEncExe

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
    Local nIdErro := ""
    
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

        oCabec := self:setCabRes("014", cCodUniOri, cCodUniDes, cNumRegAns, cNumTraOri, ,cIDUsuario)

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
    EndIf

    cJson := FWJsonSerialize(oResponse, .F., .F.)

Return {lStatus, cJson}