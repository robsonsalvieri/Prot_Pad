#include "protheus.ch"
#include "totvs.ch"
#include "fisa319c.ch"

/*/{Protheus.doc} F319CRep
    Função responsável por coletar os valores dos dados
    e solicitar a criação da sched
    @type  Function
    @author Caique Carlos
    @since 21/08/2025
    @version version
    @param cBodyParams, character, body request 
    @return nil
    /*/
Function F319CRep(cBodyParams as character)
	Local jParam     := JsonObject():New() as json
	Local cDateStart := ""                 as character
	Local cDateEnd   := ""                 as character
	Local cEnvSched  := ""                 as character
	Local cDateSched := ""                 as character
	Local cTimeSched := ""                 as character

	jParam:FromJson(cBodyParams)

	cDateStart := jParam['dateSelected']['start']
	cDateEnd   := jParam['dateSelected']['end']
	cEnvSched  := jParam['environment']
	cDateSched := jParam['date']
	cTimeSched := jParam['time']

    SchCfg(cDateStart, cDateEnd, cTimeSched, cEnvSched, cDateSched)

    FwFreeObj(jParam)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA319C
    Programa que concentra as funções relativas ao schedule do TIT (TOTVS Inteligência Tributária), 
    tanto a criação automática dos agendamentos, como a chamada da função de extração dos dados.

    @Author Caique Carlos
    @Since 21/08/2025
    @Version 1.0
    /*/
//-------------------------------------------------------------------
Function FISA319C()
    Local oJsonProfile   as json
    Local oUpdateProfile as json
    Local oScheduleAuto  as object
    Local cDtStart       as character
    Local cDtEnd         as character
    Local cDtReprocess   as character
    Local cIdSchedule    as character

    oJsonProfile   := JsonObject():new()
    oUpdateProfile := JsonObject():new()

    // Buscando os dados do Profile
    FISA318F7OnboardProfile(2, @oJsonProfile)

    cDtReprocess := oJsonProfile["reprocessPeriod"] // AAAA-MM-DD|AAAA-MM-DD

    cDtStart := StrTran(SubStr(cDtReprocess,1,10),"-","")
    cDtEnd   := StrTran(SubStr(cDtReprocess,14,21),"-","")

    FIS319Extrator(cDtStart,cDtEnd)

    FISA318F7OnboardProfile(2, @oJsonProfile)
	If oJsonProfile["extractionStartPeriod"] > SubStr(cDtReprocess,1,10)
		oUpdateProfile["extractionStartPeriod"] := SubStr(cDtReprocess,1,10)
		FISA318F7OnboardProfile(3, oUpdateProfile)
	EndIf

    oScheduleAuto := totvs.framework.schedule.automatic():new()
    cIdSchedule := totvs.framework.schedule.utils.getSchedsByRotine("FISA319C")[1]
    oScheduleAuto:setSchedule(cIdSchedule)
    oScheduleAuto:deleteSchedule()

    FwFreeObj(oJsonProfile)
    FwFreeObj(oUpdateProfile)
    FwFreeObj(oScheduleAuto)
Return

/*-------------------------------------------------------------------------------
Informacoes de definicao dos parametros do schedule
@Return  Array com as informacoes de definicao dos parametros do schedule
		 Array[x,1] -> Caracter, Tipo: "P" - para Processo, "R" - para Relatorios
		 Array[x,2] -> Caracter, Nome do Pergunte
		 Array[x,3] -> Caracter, Alias(para Relatorio)
		 Array[x,4] -> Array, Ordem(para Relatorio)
		 Array[x,5] -> Caracter, Titulo(para Relatorio)

@author Caique Carlos
@since 21/02/2024
--------------------------------------------------------------------------------*/
Static Function SchedDef()
	Local aParam  := {} as array

	aParam := { "P";			//Tipo R para relatorio P para processo
	           	,"ParamDef";	//Pergunte do relatorio, caso nao use passar ParamDef
	            ,;				//Alias
	            ,;				//Array de ordens
                ,"TIT - Reprocessamento" }

Return ( aParam )

/*/
/{Protheus.doc} SchCfg()
    Criar automaticamente no Smart Schedule, uma tarefa de extração de dados para o TOTVS Inteligencia Tributaria

    @Param:
        cDateStart  	: Será utilizado na rotina de extração de dados como Data de Início do período de extração.
        cDateEnd  		: Será utilizado na rotina de extração de dados como Data Final do período de extração. 
        dDataPri  		: Data da primeira execução do Schedule.
        cTimeSched  	: Horário (HH:MM) da primeira execução do Schedule.
        cEnvSched 		: Ambiente em que será executado a schedule
        cDateSched      : Data em que será executado a schedule
    @Author Caique Carlos
    @Since 21/08/2025
    @Version 1.0
    @see https://tdn.totvs.com/display/public/framework/Classe+Automatic
/*/
Static Function SchCfg( cDateStart as character, cDateEnd as character, cTimeSched as character,;
                        cEnvSched as character, cDateSched as character)

    Local oScheduleAuto                                      as object
    Local oUpdateProfile := JsonObject():new()               as json
    Local nHourSched     := Val( Left( cTimeSched,2 ) )      as numeric
    Local nMinuSched     := Val( SubStr( cTimeSched,4,2 ) )  as numeric
    Local dDateSchedule  := Stod(StrTran(cDateSched,"-","")) as date

    oUpdateProfile["reprocessPeriod"] := cDateStart + "|" + cDateEnd

    // Gravando a data para ser reprocessada no profile
    FISA318F7OnboardProfile(3, oUpdateProfile)

    oScheduleAuto := totvs.framework.schedule.automatic():new()

    oScheduleAuto:setRoutine("FISA319C")
    oScheduleAuto:setManageable(.T.)  // Define se o Agendamento pode ser alterado pelo usuário.
    oScheduleAuto:setFirstExecution(dDateSchedule,cTimeSched + ":00")
    oScheduleAuto:setPeriod("U",,nHourSched,nMinuSched)
    oScheduleAuto:setEnvironment(cEnvSched,{{cEmpAnt,{cFilAnt}}})
    oScheduleAuto:setModule(9)
    oScheduleAuto:setUser(__cUserID)
    oScheduleAuto:setDescription(STR0003)

    oRest:setKeyHeaderResponse("Content-Type", "application/json")
    If oScheduleAuto:createSchedule()
        oRest:setResponse(fmtRespon(200, STR0001, ""))
    Else
        oRest:setResponse(fmtRespon(422, STR0002, oScheduleAuto:getErrorMessage()))
    EndIf

    FwFreeObj(oScheduleAuto)
    FwFreeObj(oUpdateProfile)
Return

/*/{Protheus.doc} fmtRespon
    Formata resposta para o body response
    @type  Static Function
    @author Caique
    @since 21/08/2025
    @param nCode, numeric, codigo htpp de retorno do processamento
    @param cMessage, character, mensagem de retorno
    @param cDetailMessage, character, detalhamento da mensagem
    @return jResponse, json, json formatado para o response
    @example
        fmtRespon(200, Success, Sucesso no processamento)
/*/
Static Function fmtRespon(nCode as numeric, cMessage as character, cDetailMessage as character)
    Local jResponse := JsonObject():New() as json

    jResponse["code"]          := nCode
    jResponse["message"]       := cMessage
    jResponse["detailMessage"] := cDetailMessage
Return jResponse
