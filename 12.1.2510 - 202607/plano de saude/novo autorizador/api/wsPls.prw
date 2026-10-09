#INCLUDE "TOTVS.CH"
#INCLUDE 'restful.ch'

#DEFINE LOG_AUDITORIA_NOVO_AUTORIZADOR "auditoria_novo_autorizador.log"
#DEFINE LOG_CALCULO_COPARTICIPACAO "coparticipacao_novo_autorizador.log"

WSRESTFUL WsPls DESCRIPTION "Servico REST para o software de gestão SIGAPLS" FORMAT APPLICATION_JSON

    WSDATA beneficiaryId as STRING  OPTIONAL

    WSMETHOD POST grvAuditoria DESCRIPTION "POST para gravar uma guia em auditoria";
        WSsyntax "grvAuditoria";
        PATH "grvAuditoria" PRODUCES APPLICATION_JSON 

    WSMETHOD POST calcCopartAto DESCRIPTION "POST para obter valor de coparticipacao no ato";
        WSsyntax "copartAto";
        PATH "copartAto" PRODUCES APPLICATION_JSON 
        
    WSMETHOD GET healthcheck  DESCRIPTION "Rest Disponível";
	    WSsyntax "healthcheck";
	    PATH "healthcheck" PRODUCES APPLICATION_JSON

    WSMETHOD GET beneficiary  DESCRIPTION "GET para obter beneficiário e entidades relacionadas BA1, BA3, BTS, BI3, BT5, BT6 e BQC";
	    WSsyntax "beneficiary/{beneficiaryId}";
	    PATH "beneficiary/{beneficiaryId}" 
    
END WSRESTFUL

WSMETHOD POST grvAuditoria WSSERVICE WsPls
    
    Local cJson := self:getContent()
    Local JParser := JSonParser():New()
    Local hMapAtend := nil
    Local oAtend := nil
    Local cGuia := ""

    JParser:setJson(cJson)
    hMapAtend := JParser:parseJson()

    PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] WSPLS GRVAUDITORIA: SERVIÇO DE LOG INICIO PROCESSAMENTO ",LOG_AUDITORIA_NOVO_AUTORIZADOR)

    if JParser:isJsonValid()
        if "consultaGuia" $ cJson
            oAtend := AutConsulta():New(hMapAtend)
            cGuia := "GUIA DE CONSULTA"
        elseif "sadtSolicitacaoGuia" $ cJson
            oAtend := AutExame():New(hMapAtend)
            cGuia := "GUIA DE SP/SADT"
        elseif "guiaSP-SADT" $ cJson
            oAtend := AutExecucao():New(hMapAtend)
            cGuia := "GUIA DE SP/SADT"
        elseif "internacaoSolicitacaoGuia" $ cJson
            oAtend := AutInternacao():New(hMapAtend)
            cGuia := "SOLICITACAO DE INTERNACAO"
        endIf

        oAtend:insert()
        
        Self:SetResponse('{"complete": true }')
        PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] WSPLS GRVAUDITORIA: " + cGuia + " GRAVADA  ",LOG_AUDITORIA_NOVO_AUTORIZADOR)
    else
        Self:SetResponse('{"msgError": "JSON Inválido", "complete": false }')
        PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] WSPLS GRVAUDITORIA: JSON INVÁLIDO (" + cJson + ")",LOG_AUDITORIA_NOVO_AUTORIZADOR)
    endIf

Return .T.

WSMETHOD POST calcCopartAto WSSERVICE WsPls

    Local cJson := self:getContent()
    Local JParser := JSonParser():New()
    Local hMapProced := nil
    Local oCopart := nil

    JParser:setJson(cJson)
    hMapProced := JParser:parseJson()

    PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] WSPLS CALC_COPART: SERVIÇO DE LOG INICIO PROCESSAMENTO ",LOG_CALCULO_COPARTICIPACAO)
    
    if JParser:isJsonValid()
        oCopart := CalcCopart():New(hMapProced)
        if oCopart:calculate()
            Self:SetResponse('{"complete": true, "copartValue": "' + oCopart:getValCopart() + '" }')        
            PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] WSPLS CALC_COPART: SERVIÇO DE LOG FINAL CALCULO. VALOR: " + oCopart:getValCopart(), LOG_CALCULO_COPARTICIPACAO)
        else
            Self:SetResponse('{"complete": false, "msgError": "' + EncodeUTF8(oCopart:cMsg) + '" }')        
            PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] WSPLS CALC_COPART: SERVIÇO DE LOG FINAL CALCULO. ERRO NO PROCESSAMENTO", LOG_CALCULO_COPARTICIPACAO)
        endif
    else
        Self:SetResponse('{"msgError": "JSON Invalido", "complete": false }')
        PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] WSPLS GRVAUDITORIA: JSON INVÁLIDO (" + cJson + ")",LOG_AUDITORIA_NOVO_AUTORIZADOR)
    endIf

Return .T.

WSMETHOD GET healthcheck WSSERVICE WsPls
    local lReturn := .f.
    local cMsg    := 'BAD'
    local nStatus := 400
    local oJson   := jsonObject():new()
    local bErro   := errorBlock({|e| lReturn := .f. })
    local nhWnd   := nil

    Begin sequence
        
        nhWnd := TCLink()
    
        if TCIsConnected(nhWnd)

            BA0->(dbsetorder(1))
            BA0->( msSeek(xFilial('BA0')) )

            if ! BA0->(eof())
                cMsg    := "OK"
                nStatus := 200
                lReturn := .t.
            endIf

        endIf

        TCUnlink()

    End sequence

    oJson["SERVER REST"] := cMsg

    self:setStatus(nStatus)
    self:setResponse(oJson:toJSon())  

    errorBlock(bErro)

Return lReturn


WSMETHOD GET beneficiary PATHPARAM beneficiaryId WSSERVICE WsPls
    local lReturn := .T.
    local oPlHatBenef := PlHatBenef():New(self:beneficiaryId)
    local oJson := nil
    local cResponse := ""

    if oPlHatBenef:buscar()
        cResponse := oPlHatBenef:getResponse()
        cResponse := iif(empty(EncodeUTF8(cResponse)), cResponse, EncodeUTF8(cResponse))
        self:setStatus(200)
        self:setResponse(cResponse)
    else
        oJson := JsonObject():New()
        oJson["code"] := 404
        oJson["message"] := "Não encontrado"
        oJson["detailedMessage"] := "Beneficiário não encontrado"
        cResponse := iif(empty(EncodeUTF8(oJson:toJson())),oJson:toJson(),EncodeUTF8(oJson:toJson()))
        self:setStatus(404)
        self:setResponse(cResponse)
    endIf
Return lReturn
