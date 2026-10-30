#INCLUDE 'totvs.ch'
#INCLUDE 'restful.ch'
#INCLUDE "TopConn.ch"
#INCLUDE "OFIW131.ch"

WSRESTFUL dms_apontamentodetarefa DESCRIPTION STR0001 // "Integração REST para apontamento por tarefa"
	WSDATA cData as String
	WSDATA cChassi as String
	WSDATA cPlaca as String
    WSDATA cNumOS as String
    WSDATA cCodTec as String
    WSDATA cTarefa as String

	WSMETHOD GET  GAT01_BUSCAOS DESCRIPTION STR0002 WSSYNTAX "/dms_apontamentodetarefa/os?{cData, cChassi, cPlaca}" PATH "/dms_apontamentodetarefa/os" // "Busca as ordens de serviço"
    WSMETHOD GET  GAT02_MECANICOS DESCRIPTION STR0005 WSSYNTAX "/dms_apontamentodetarefa/mecanicos?{cChassi, cNumOS}" PATH "/dms_apontamentodetarefa/mecanicos" // "Busca os mecânicos"
    WSMETHOD GET  GAT03_TAREFAS DESCRIPTION STR0009 WSSYNTAX "/dms_apontamentodetarefa/tarefas?{cNumOS}" PATH "/dms_apontamentodetarefa/tarefas" // "Busca as tarefas"
    WSMETHOD GET  GAT04_BUSCACONFIG DESCRIPTION STR0011 WSSYNTAX "/dms_apontamentodetarefa/config" PATH "/dms_apontamentodetarefa/config" // "Busca Configuração para apontamento"
    WSMETHOD GET  GAT05_ATIVO DESCRIPTION STR0013 WSSYNTAX "/dms_apontamentodetarefa/apontamento-ativo?{cCodTec}" PATH "/dms_apontamentodetarefa/apontamento-ativo" // "Busca apontamento ativo"
    WSMETHOD GET  MOTREJECT DESCRIPTION STR0014 WSSYNTAX "/dms_apontamentodetarefa/motivos-pausa" PATH "/dms_apontamentodetarefa/motivos-pausa" // "Busca motivos de pausa"
    WSMETHOD POST GAT07_FINALIZA DESCRIPTION STR0015 WSSYNTAX "/dms_apontamentodetarefa/finalizar" PATH "/dms_apontamentodetarefa/finalizar" // "Finaliza apontamento"
    WSMETHOD POST GAT08_PAUSA DESCRIPTION STR0016 WSSYNTAX "/dms_apontamentodetarefa/pausar" PATH "/dms_apontamentodetarefa/pausar" // "Pausa apontamento"
    WSMETHOD POST GAT09_APONTAR DESCRIPTION STR0021 WSSYNTAX "/dms_apontamentodetarefa/apontar" PATH "/dms_apontamentodetarefa/apontar" // "Apontar apontamento"
END WSRESTFUL

/*/{Protheus.doc} GAT01_BUSCAOS
    Método que busca as ordens de serviço

    @type method
    @author Bruno Forcato
    @since 21/01/2026
/*/
WSMETHOD GET GAT01_BUSCAOS WSRECEIVE cData, cChassi, cPlaca WSSERVICE dms_apontamentodetarefa
    local oResponse := JsonObject():New()
    local oApontamentoDeTarefaClass := OFApontamentoDeTarefaClass():New()

    oResponse['ordemsDeServico'] := oApontamentoDeTarefaClass:buscaOS(self:cData, self:cChassi, self:cPlaca)
    HandleResponse(oResponse, 200, STR0003 + cValtoChar(Len(oResponse['ordemsDeServico'])) + STR0004) // "Foram encontradas " + " ordens de serviço"
    ::setResponse(oResponse:toJson())
Return .t.

/*/{Protheus.doc} GAT02_MECANICOS
    Método que busca os mecanicos

    @type method
    @author Bruno Forcato
    @since 21/01/2026
/*/
WSMETHOD GET GAT02_MECANICOS WSRECEIVE cChassi, cNumOS WSSERVICE dms_apontamentodetarefa
    local oResponse := JsonObject():New()
    local oApontamentoDeTarefaClass := OFApontamentoDeTarefaClass():New()

    oResponse['mecanicos'] := oApontamentoDeTarefaClass:buscaMecanicos(self:cNumOS, self:cChassi)
    HandleResponse(oResponse, 200, STR0007 + cValtoChar(Len(oResponse['mecanicos'])) + STR0008) // "Foram encontrados " + " mecânicos"
    ::setResponse(oResponse:toJson())
Return .t.

/*/{Protheus.doc} GAT03_TAREFAS
    Método que busca as tarefas

    @type method
    @author Bruno Forcato
    @since 21/01/2026
/*/
WSMETHOD GET GAT03_TAREFAS WSRECEIVE cNumOS WSSERVICE dms_apontamentodetarefa
    local oResponse := JsonObject():New()
    local oApontamentoDeTarefaClass := OFApontamentoDeTarefaClass():New()

    if empty(self:cNumOS)
        return HandleBadResponse(oResponse, 400, STR0006) // "Parâmetros inválidos, tente novamente!"
    endif

    oResponse['tarefas'] := oApontamentoDeTarefaClass:buscaTarefas(self:cNumOS)
    HandleResponse(oResponse, 200, STR0003 + cValtoChar(Len(oResponse['tarefas'])) + STR0010) // "Foram Encontradas " + " Tarefas"
    ::setResponse(oResponse:toJson())
Return .t.

/*/{Protheus.doc} GAT04_BUSCACONFIG
    Método que busca a configuracao para prosseguir com o apontamento

    @type method
    @author Bruno Forcato
    @since 30/01/2026
/*/
WSMETHOD GET GAT04_BUSCACONFIG WSSERVICE dms_apontamentodetarefa
    local oResponse := JsonObject():New()
    local oApontamentoDeTarefaClass := OFApontamentoDeTarefaClass():New()

    oResponse := oApontamentoDeTarefaClass:buscaConfig()

    if !empty(oResponse["erro"])
        return HandleBadResponse(oResponse, 400, oResponse["erro"])
    endif

    HandleResponse(oResponse, 200, STR0012) // "Configuração encontrada com sucesso"
    ::setResponse(oResponse:toJson())
Return .t.

/*/{Protheus.doc} GAT05_ATIVO
    Método que busca apontamento ativo do mecanico

    @type method
    @author Bruno Forcato
    @since 01/07/2026
/*/
WSMETHOD GET GAT05_ATIVO WSRECEIVE cCodTec WSSERVICE dms_apontamentodetarefa
    local oResponse := JsonObject():New()
    local oApontamentoDeTarefaClass := OFApontamentoDeTarefaClass():New()

    if empty(self:cCodTec)
        return HandleBadResponse(oResponse, 400, STR0006) // "Parâmetros inválidos, tente novamente!"
    endif

    oResponse := oApontamentoDeTarefaClass:buscaApontamentoAtivo(self:cCodTec)
    HandleResponse(oResponse, 200, STR0017) // "Apontamento consultado com sucesso"
    ::setResponse(oResponse:toJson())
Return .t.

/*/{Protheus.doc} MOTREJECT
    Método que busca motivos de pausa

    @type method
    @author Bruno Forcato
    @since 01/07/2026
/*/
WSMETHOD GET MOTREJECT WSSERVICE dms_apontamentodetarefa
    local oResponse := JsonObject():New()
    local oApontamentoDeTarefaClass := OFApontamentoDeTarefaClass():New()

    oResponse['motivos'] := oApontamentoDeTarefaClass:buscaMotivosPausa()
    HandleResponse(oResponse, 200, STR0018) // "Motivos encontrados com sucesso"
    ::setResponse(oResponse:toJson())
Return .t.

/*/{Protheus.doc} GAT07_FINALIZA
    Método que finaliza apontamentos

    @type method
    @author Bruno Forcato
    @since 01/07/2026
/*/
WSMETHOD POST GAT07_FINALIZA WSSERVICE dms_apontamentodetarefa
    local oResponse := JsonObject():New()
    local oRequest := JsonObject():New()
    local oApontamentoDeTarefaClass := OFApontamentoDeTarefaClass():New()

    oRequest:FromJson(::GetContent())
    oResponse := oApontamentoDeTarefaClass:finalizaApontamento(oRequest)

    if !empty(oResponse["erro"])
        return HandleBadResponse(oResponse, 400, oResponse["erro"])
    endif

    HandleResponse(oResponse, 200, STR0019) // "Apontamento finalizado com sucesso"
    ::setResponse(oResponse:toJson())
Return .t.

/*/{Protheus.doc} GAT08_PAUSA
    Método que pausa apontamentos

    @type method
    @author Bruno Forcato
    @since 01/07/2026
/*/
WSMETHOD POST GAT08_PAUSA WSSERVICE dms_apontamentodetarefa
    local oResponse := JsonObject():New()
    local oRequest := JsonObject():New()
    local oApontamentoDeTarefaClass := OFApontamentoDeTarefaClass():New()

    oRequest:FromJson(::GetContent())
    oResponse := oApontamentoDeTarefaClass:pausaApontamento(oRequest)

    if !empty(oResponse["erro"])
        return HandleBadResponse(oResponse, 400, oResponse["erro"])
    endif

    HandleResponse(oResponse, 200, STR0020) // "Apontamento pausado com sucesso"
    ::setResponse(oResponse:toJson())
Return .t.


WSMETHOD POST GAT09_APONTAR WSSERVICE dms_apontamentodetarefa
    local oResponse := JsonObject():New()
    local oRequest := JsonObject():New()
    local oApontamentoDeTarefaClass := OFApontamentoDeTarefaClass():New()
	local oContenct

	oContenct := ::getContent()

	oRequest:FromJson(oContenct)
    oResponse := oApontamentoDeTarefaClass:apontarTarefa(oRequest)

    if !empty(oResponse["erro"])
        return HandleBadResponse(oResponse, 400, oResponse["erro"])
    endif

    HandleResponse(oResponse, 200, STR0022) // "Apontamento processado"
    ::setResponse(oResponse:toJson())
Return .t.





/*/{Protheus.doc} HandleResponse
    Funcao para ligar com respostas que deram sucesso

    @type function
    @author Bruno Forcato
    @since 21/01/2026
/*/
Static Function HandleResponse(oResponse, nCode, cMessage)
    oResponse['code'] := nCode
    oResponse['message'] := cMessage
Return .t.

/*/{Protheus.doc} HandleBadResponse
    Funcao para ligar com respostas que deram erro

    @type function
    @author Bruno Forcato
    @since 21/01/2026
/*/
Static Function HandleBadResponse(oResponse, nCode, cMessage)
    oResponse['code'] := nCode
    oResponse['message'] := cMessage

    SetRestFault(nCode, cMessage)
return .f.