#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE 'FWMBROWSE.CH'
#INCLUDE 'FWMVCDEF.CH'

//-----------------------------------------------------------------
/*/{Protheus.doc} PGPUConHis
Classe para Enviar uma mensagem para a Unimed referente à consulta 
do histórico de protocolos do beneficiário ou não cliente.
 
@author Vinicius Queiros Teixeira
@since 28/05/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Class PGPUConHis From PLRN395GPU

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
@since 28/05/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Method New() Class PGPUConHis
    
    _Super:new()
    self:cTransacao := "009"

Return


//-----------------------------------------------------------------
/*/{Protheus.doc} mntJson
Monta Json de comunicação com o GPU 
 
@author Vinicius Queiros Teixeira
@since 28/05/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Method mntJson() Class PGPUConHis

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
    Local dDatSol := self:aParam[09]
    Local dDatResp := self:aParam[10]

    //Cabecalho
    oCabec := self:setCabEnv("009", cCodUniOri, cCodUniDes, cNumRegAns, cNumTraOri, dDatGer, cIDUsuario)

    //Body
    oBody["cd_unimed"] := self:setAtributo(cCodUniBen)
    oBody["id_benef"] := self:setAtributo(cIDBenef)
    oBody["dt_inicio_historico"] := self:setAtributo(self:datHorMask(dDatSol, Time()))
    oBody["dt_fim_historico"] := self:setAtributo(self:datHorMask(dDatResp, Time()))

    //Monta json completo
    oGPU["cabecalho_transacao"] := oCabec
    oGPU["consulta_historico"] := oBody

    self:cJson := FWJsonSerialize(oGPU, .F., .F.)

Return


//-----------------------------------------------------------------
/*/{Protheus.doc} procResp
Processa a resposta da comunicacao
 
@author Vinicius Queiros Teixeira
@since 28/05/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Method procResp() Class PGPUConHis

    Local oResponse := JsonObject():New()
    Local lRet := .F.
    Local aRetFun := {}
    Local aCriticas := {}  
    Local nTotalHist := 0
    Local nX := 0
    // Dados da Resposta
    Local cIdErro := ""
    Local cMensagem := ""
    Local aHist := {}

    oResponse:fromJSON(self:cRespJson)

    Do Case
        Case !self:lAuthentication .And. !self:lAuto
            Aadd(aCriticas,{"999", "Falha na autenticação no GIU, verifique os dados no cadastro de Operadoras" })

        Case self:lSucess .And. oResponse["cabecalho_transacao"]["cd_transacao"] == "010"             
            lRet := .T.
            Do Case
                Case ValType(oResponse["resposta_consulta_historico"]) <> "A" 
                    Aadd(aHist, { oResponse["resposta_consulta_historico"]["nr_protocolo"],; 
                                oResponse["resposta_consulta_historico"]["dt_manifestacao"],;
                                "",; // idUsuario não utilizado no JSON
                                "",; // numeroTransacaoIntercambioPrestadora não utilizado no JSON
                                "",; // numeroTransacaoOrigemBeneficiario não utilizado no JSON
                                cValToChar(oResponse["resposta_consulta_historico"]["id_resposta"]),;  
                                "",; // tipoManifestacao não utilizado no JSON
                                "",; // tipoCategoria não utilizado no JSON
                                ""}) // tipoSentimento não utilizado no JSON
                    
                Case ValType(oResponse["resposta_consulta_historico"]) == "A" 
                    nTotalHist := Len(oResponse["resposta_consulta_historico"])

                    For nX := 1 To nTotalHist
                        Aadd(aHist, { oResponse["resposta_consulta_historico"][nX]["nr_protocolo"],; 
                                    oResponse["resposta_consulta_historico"][nX]["dt_manifestacao"],;
                                    "",; // idUsuario não utilizado no JSON
                                    "",; // numeroTransacaoIntercambioPrestadora não utilizado no JSON
                                    "",; // numeroTransacaoOrigemBeneficiario não utilizado no JSON
                                    cValToChar(oResponse["resposta_consulta_historico"][nX]["id_resposta"]),;  
                                    "",; // tipoManifestacao não utilizado no JSON
                                    "",; // tipoCategoria não utilizado no JSON
                                    ""}) // tipoSentimento não utilizado no JSON                              
                    Next nX     			
            EndCase
        
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
	Aadd(aRetFun,lRet)					
	Aadd(aRetFun,aCriticas)
	Aadd(aRetFun,aHist)

    self:impLog(IIF(lRet, "Json de Resposta processado com sucesso!", "Falha ao processar Json de Resposta."))

Return aRetFun


//-----------------------------------------------------------------
/*/{Protheus.doc} procSolic
Processa Solicitação
 
@author Vinicius Queiros Teixeira
@since 28/05/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Method procSolic(cJson) Class PGPUConHis

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
    Local cDatSol := ""
    Local cDatResp := ""
    local cVersao := ""

    self:impLog("Comunicacao de Recebimento - GPU", .F.)
    self:impLog("Json Recebido: "+cJson)

    oRequest:fromJSON(cJson)
    
    //Cabecalho
    self:setVarCab(oRequest, @cCodUniOri, @cCodUniDes, @cNumRegAns, @cNumTraPre, @dDataGer, @cIdUsuario, @cVersao)

    cMatric := self:GetAtributo(oRequest['consulta_historico']['cd_unimed']) + self:GetAtributo(oRequest['consulta_historico']['id_benef'])
    cNumProtoc := "" // Não utilizado no Json
    cDatSol := DToS(self:convData(oRequest['consulta_historico']['dt_inicio_historico']))
    cDatResp := DToS(self:convData(oRequest['consulta_historico']['dt_fim_historico']))

	// Chamada da funcao de processamento
    self:impLog("Processando Resposta...")
	aRet := PLConHisWB(cCodUniOri, cCodUniDes, cNumRegAns, cNumTraPre, dDataGer, cIdUsuario, ;
                       cMatric, cNumProtoc, cDatSol, cDatResp) 

    // Monta Json de Resposta
    aJsonResp := self:jsonResp(aRet)

    self:impLog("Json de Resposta: "+aJsonResp[2])
    self:impLog("", .F.)
 
Return aJsonResp


//-----------------------------------------------------------------
/*/{Protheus.doc} jsonResp
Monta json de resposta

@author Vinicius Queiros Teixeira
@since 28/05/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Method jsonResp(aRet) Class PGPUConHis

    Local cJson := ""
    Local oResponse := JsonObject():New()
    Local oCabec := JsonObject():New()
    Local oBody := JsonObject():New()
    Local aBody := {}
    Local nX := 0
    Local lObject := .F.
    Local lStatus := .T.
    // Cabecalho
    Local cCodUniOri := ""
	Local cCodUniDes := ""
	Local cNumRegAns := ""
	Local cNumTraPre := ""
    Local cIDUsuario := ""
    // Body
    Local nIdErro := 0

    //Arquivo processado com sucesso
    If Empty(aRet[3])

        cCodUniOri := aRet[1][3]
        cCodUniDes := aRet[1][4]
        cNumRegAns := aRet[1][5]

        If Len(aRet[1][8]) > 0
            cNumTraPre := aRet[1][8][1][1]
            cIDUsuario := aRet[1][8][1][3]
        EndIf

        oCabec := self:setCabRes("010", cCodUniOri, cCodUniDes, cNumRegAns, cNumTraPre, , cIDUsuario)

        If Len(aRet[1][8]) == 1 
            oBody["dt_manifestacao"] := self:setAtributo(aRet[1][8][1][2]) 
            oBody["nr_protocolo"] := self:setAtributo(aRet[1][8][1][4])  
            oBody["id_resposta"] := self:setAtributo(aRet[1][8][1][13], "N")  
            oBody["id_sistema"] := 1 
            lObject := .T.
        Else
            For nX := 1 To Len(aRet[1][8])              
                oBody["dt_manifestacao"] := self:setAtributo(aRet[1][8][nX][2]) 
                oBody["nr_protocolo"] := self:setAtributo(aRet[1][8][nX][4])  
                oBody["id_resposta"] := self:setAtributo(aRet[1][8][nX][13], "N")  
                oBody["id_sistema"] := 1

                aAdd(aBody, oBody)
                FreeObj(oBody)
                oBody := Nil
                oBody := JsonObject():New()
            Next nX 
        EndIf   

        //Monta json completo
        oResponse["cabecalho_transacao"] := oCabec
        If lObject
            oResponse["resposta_consulta_historico"] := oBody
        Else
            oResponse["resposta_consulta_historico"] := aBody
        EndIf
        
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