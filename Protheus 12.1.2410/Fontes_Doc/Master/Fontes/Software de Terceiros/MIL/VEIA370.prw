#include "VEIA370.CH"
#include "PROTHEUS.CH"

static cVRZ_CODINT
static cVRX_AGRUP
static cVRX_CODINT
static lSetOnlyView

/*/{Protheus.doc} VEIA370
	Chamada para abrir o APP do checklist

	@author Bruno Forcato
	@since 17/12/2024
/*/
Function VEIA370()
    VA37000012_OpenResponseChecklist()
Return Nil

/*/{Protheus.doc} JsToAdvpl
	Funcao que recebe e manda mensagens para o poui por WebChannel

	@author Bruno Forcato
	@since 17/12/2024
/*/
Static Function JsToAdvpl(oWebChannel,cType,cContent)
    //setChecklistTypes
    local jsonTypes as json
    local aGetTypes := {}

    //setRoute
    local jRouteParams as Json

    if (cType == 'preLoad')
        jsonTypes := JsonObject():New()
        aGetTypes := getChecklistTypes()

        oWebChannel:AdvPLToJS('setChecklistTypes', ArrToJson(aGetTypes))

        if !empty(cVRZ_CODINT) .AND. !empty(cVRX_AGRUP)
            jRouteParams := JsonObject():New()
            jRouteParams['VRZ_CODINT'] := cVRZ_CODINT
            jRouteParams['VRX_AGRUP'] := cVRX_AGRUP

            if !empty(cVRX_CODINT)
                jRouteParams['VRX_CODINT'] := cVRX_CODINT
            endif
            oWebChannel:AdvPLToJS('setRoute', 'response')
            oWebChannel:AdvPLToJS('setResponseParameters', jRouteParams:ToJson())
        Else
            oWebChannel:AdvPLToJS('setRoute', 'checklist')
        endif

        if !empty(lSetOnlyView) .AND. lSetOnlyView == .T.
            oWebChannel:AdvPLToJS('setOnlyView', 'true')
        else
            oWebChannel:AdvPLToJS('setOnlyView', 'false')
        endif
    endif
Return .T.


/*/{Protheus.doc} getChecklistTypes
	Função que monta e retorna a lista de tipos de checklist

	@author Bruno Forcato
	@since 17/12/2024
/*/
static Function getChecklistTypes()
    local aTypes := {}
    aadd(aTypes, {"0001", STR0001}) // Avaliação de Usados
    aadd(aTypes, {"0002", STR0002}) //"Abertura de Ordem de Serviço"
    aadd(aTypes, {"0003", STR0003}) //"Liberação de Ordem de Serviço"
    aadd(aTypes, {"0004", STR0004}) //"Atendimento de Veiculos"
return aTypes


/*/{Protheus.doc} VA37000012_OpenResponseChecklist
	Chamada para abrir o APP do checklist mas na parte de resposta
    de checklist

	@author Bruno Forcato
	@since 17/12/2024
/*/
Function VA37000012_OpenResponseChecklist(cVrzCodInt, cVrxAgrup, lOnlyView, cVrxCodInt)
    cVRZ_CODINT := cVrzCodInt
    cVRX_AGRUP := cVrxAgrup
    lSetOnlyView := lOnlyView
    cVRX_CODINT := cVrxCodInt

    If AmIOnRestEnv()
        FwCallApp('dms-checklist')
    Else
        FMX_HELP("OA370ERR001",STR0005,STR0006) //"Porta multiprotocolo desabilitada" / "Para utilizar essa opção é necessário que habilite a porta multiprotoloco no ambiente."
    EndIf

return .t.
