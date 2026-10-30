#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

//-----------------------------------------------------------------
/*/{Protheus.doc} PGPUResNoClient
Classe para Enviar uma mensagem para a Unimed referente à resposta 
de manifestação de um não cliente.
 
@author Vinicius Queiros Teixeira
@since 28/07/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Class PGPUResNoClient From PLRN395GPU

    Method New()
    Method mntJson()
    Method procResp()

EndClass


//-----------------------------------------------------------------
/*/{Protheus.doc} New
Classe Construtora
 
@author Vinicius Queiros Teixeira
@since 28/07/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Method New() Class PGPUResNoClient
    
    _Super:new()
    self:cTransacao := "017"

Return


//-----------------------------------------------------------------
/*/{Protheus.doc} mntJson
Monta Json de comunicação com o GPU 
 
@author Vinicius Queiros Teixeira
@since 28/07/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Method mntJson() Class PGPUResNoClient

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
    Local cNumProto := self:aParam[07]
	Local cIdResposta := self:aParam[08]
	Local cMsgLivre := self:aParam[09]
	Local cTipoSolic := self:aParam[10]
	Local cCpf := self:aParam[11]
	Local cCnpj := self:aParam[12]
	Local cEmail := self:aParam[13]				
	Local cIdDevolucao := self:aParam[14]

    //Cabecalho
    oCabec := self:setCabEnv("017", cCodUniOri, cCodUniDes, cNumRegAns, cNumTraOri, dDatGer, cIDUsuario)

    //Body
    oBody["tp_solicitante"] := self:setAtributo(cTipoSolic)
    oBody["cd_cpf"] := self:setAtributo(cCpf)
    oBody["cd_cnpj"] := self:setAtributo(cCnpj)
    oBody["email"] := self:setAtributo(cEmail)   
    oBody["nr_protocolo"] := self:setAtributo(cNumProto)  
    oBody["id_resposta"] := self:setAtributo(cIdResposta, "N")
    oBody["id_devolucao"] := self:setAtributo(cIdDevolucao)
    oBody["mensagem"] := self:setAtributo(cMsgLivre) 
    
    //Monta json completo
    oGPU["cabecalho_transacao"] := oCabec
    oGPU["resposta_atendimento"] := oBody

    self:cJson := FWJsonSerialize(oGPU, .F., .F.)

Return


//-----------------------------------------------------------------
/*/{Protheus.doc} procResp
Processa a resposta da comunicacao
 
@author Vinicius Queiros Teixeira
@since 28/07/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Method procResp() Class PGPUResNoClient

    Local oResponse := JsonObject():New()
    Local lRet := .F.
    Local aRetFun := {}
    Local aCriticas := {}
    // Dados da Resposta
    Local cIdErro := ""
    Local cMensagem := ""

    oResponse:FromJSON(self:cRespJson)

    Do Case
        Case !self:lAuthentication .And. !self:lAuto
            Aadd(aCriticas,{"999", "Falha na autenticação no GIU, verifique os dados no cadastro de Operadoras" })

        Case self:lSucess .And. oResponse["cabecalho_transacao"]["cd_transacao"] == "018"      
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