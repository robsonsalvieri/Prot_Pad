#INCLUDE "totvs.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FISA319B.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA319B
Programa que concentra as funções relativas ao schedule do TIT (TOTVS Inteligência Tributária), 
tanto a criação automática dos agendamentos, como a chamada da função de extração dos dados.
Teve que ser criado como ".prw" pois possui a função SchedDef(), que até esta data (05/05/2025),
não funciona em fontes ".tlpp".

@Param:
Não há.

@Return:
Não há.

@Author Eduardo Nunes Cirqueira
@Since 05/05/2025
@Version 1.0
/*/
//-------------------------------------------------------------------
Function FISA319B()

// Função que verifica se a chamada partiu de Schedule: .T. = Sim; .F. = Não
// FWGetRunSchedule()
Local cDtStart       as character
Local cDtEnd         as character
Local oJsonProfile   as json
Local oUpdateProfile as json

oJsonProfile   := JsonObject():new()
oUpdateProfile := JsonObject():new()

// Buscando os dados do Profile
FISA318F7OnboardProfile(2, @oJsonProfile)

cDtStart := StrTran(oJsonProfile["extractionEndPeriod"], "-", "") 
cDtEnd   := DToS(dDataBase-1)

If cDtStart > cDtEnd
	cDtStart := cDtEnd
EndIf

FIS319Extrator(cDtStart,cDtEnd)

// Gravando a nova data final de extração
oUpdateProfile["extractionEndPeriod"] := Left(cDtEnd,4) +"-"+ SubString(cDtEnd,5,2) +"-"+ Right(cDtEnd,2)
FISA318F7OnboardProfile(3, oUpdateProfile)

Return

/*-------------------------------------------------------------------------------
Informacoes de definicao dos parametros do schedule
@Return  Array com as informacoes de definicao dos parametros do schedule
		 Array[x,1] -> Caracter, Tipo: "P" - para Processo, "R" - para Relatorios
		 Array[x,2] -> Caracter, Nome do Pergunte
		 Array[x,3] -> Caracter, Alias(para Relatorio)
		 Array[x,4] -> Array, Ordem(para Relatorio)
		 Array[x,5] -> Caracter, Titulo(para Relatorio)

@author Carlos Eduardo Nonato
@since 21/02/2024
--------------------------------------------------------------------------------*/
Static Function SchedDef()

	Local aParam  := {}

	aParam := { "P";			//Tipo R para relatorio P para processo
	           	,"ParamDef";	//Pergunte do relatorio, caso nao use passar ParamDef
	            ,;				//Alias
	            ,;				//Array de ordens
	            ,"TIT - Extrator" }

Return ( aParam )

/*/
/{Protheus.doc} TITSchdCfg()
Criar automaticamente no Smart Schedule, uma tarefa de extração de dados para o TOTVS Inteligencia Tributaria
    
@Param:
cIdSchedule		: ID de Schedule existente para alteração (Nenhum ID significa que é uma inclusão de um novo Schedule)
cJsonSchedule	: String Json com conteúdo das parametrizações do schedule a serem salvas no Profile do cliente caso salvar schedule seja bem sucedido
dDataIni  		: Será utilizado na rotina de extração de dados como Data de Início do período de extração.
dDataFim  		: Será utilizado na rotina de extração de dados como Data Final do período de extração. 
dDataPri  		: Data da primeira execução do Schedule.
cHoraPri  		: Horário (HH:MM:SS) da primeira execução do Schedule.
cPeriodo  		: Período para execução do Schedule ("D"iario; "M"ensal; "S"emanal; "U"nica).
aFrequency  	: Definição apenas para periodicidades "D"iária/"S"emanal/"M"ensal
lRecurrent		: Define a recorrência do agendamento.
nDiaIni			: Dia de início da execução do Schedule  (Apenas para o tipo "M"ensal).
nHoraIni  		: Hora de início da execução do Schedule.
nMinutoIni		: Minuto de início da execução do Schedule.
aWeekDays 		: Dias da Semana, Apenas para o tipo SEMANAL (["Tuesday","Thursday"]) 
cError 			: [REFERÊNCIA] Mensagem de erro que impediu a criação/alteração de um Schedule

@Return: lOk : Se Schedule foi criado/alterado com sucesso

@Author Eduardo Nunes Cirqueira
@Since 23/04/2025
@Version 1.0

@see https://tdn.totvs.com/display/public/framework/Classe+Automatic
@see https://tdn.totvs.com/display/tec/asort
/*/
Function TITSchdCfg(cIdSchedule as character, cJsonSchedule as character, dDataIni as Date, dDataFim as Date, dDataPri as Date, cHoraPri as character;
                  , cPeriodo as character, aFrequency as array, lRecurrent as logical, nDiaIni as numeric, nHoraIni as numeric, nMinutoIni as numeric, cEnv as character;
				  , aWeekDays as array, cError as character) as logical
  
Local cTime          := IncTime( Time(), 0, 2, 0 )    as character
Local cGroup         := 'TOTVSInteligenciaTributaria' as character
Local oScheduleAuto                                   as object
Local oJsonProfile   := JsonObject():new()            as json
Local dDataExtrat    := dDataBase - 1                 as date
Local lInclui        := .T.                           as logical
Local lOk 			 := .F.							  as logical

Default cIdSchedule	:= ""
Default cError		:= ""	
Default dDataIni     := dDataExtrat
Default dDataFim     := dDataExtrat
Default dDataPri     := dDataBase
Default cHoraPri     := Time()
Default cPeriodo     := "D"
Default lRecurrent	 := .F.
Default nDiaIni		 := Nil
Default nHoraIni     := Val( Left( cTime,2 ) )
Default nMinutoIni   := Val( SubStr( cTime,4,2 ) )
Default cEnv         := GetEnvServer()
Default aWeekDays    := {}
Default aFrequency	 := {"D", 1,,,}

// Buscando os dados do Profile
FISA318F7OnboardProfile(2, @oJsonProfile)
lInclui := Empty(cIdSchedule) .Or. Empty(totvs.framework.schedule.utils.getSchedsByRotine("FISA319B"))

oScheduleAuto := totvs.framework.schedule.automatic():new()

If lInclui
	oScheduleAuto:setRoutine("FISA319B")
Else
	oScheduleAuto:setSchedule(cIdSchedule)
    oScheduleAuto:setManageable(.T.)  // Define se o Agendamento pode ser alterado pelo usuário.
EndIf

oScheduleAuto:setFirstExecution(dDataPri,cHoraPri)
oScheduleAuto:setPeriod(cPeriodo,nDiaIni,nHoraIni,nMinutoIni,aWeekDays)

If Len(aFrequency) > 0
	oScheduleAuto:setFrequency(;
		aFrequency[1],; // Tipo da Frequência: D - Dia, H - Hora, M - Minuto
		aFrequency[2],; // Intervalo de execução/frequência.
		aFrequency[3],; // Dia do Término.
		aFrequency[4],; // Hora do Término.
		aFrequency[5]; //Minuto do Término.
	)
EndIf

oScheduleAuto:setDiscard(.T.)
oScheduleAuto:setEnvironment(cEnv,{{cEmpAnt,{cFilAnt}}})
oScheduleAuto:setModule(9)
oScheduleAuto:setUser(__cUserID)
oScheduleAuto:setDescription("TOTVS Inteligência Tributária")
oScheduleAuto:setRecurrence(lRecurrent)

If lInclui
	If oScheduleAuto:createSchedule()
		FWLogMsg("INFO",, cGroup, FunName(),,, STR0001) // "Schedule criado com Sucesso !"

		lOk	:= .T.
	Else
		cError	:= oScheduleAuto:getErrorMessage()
		FWLogMsg("ERROR",, cGroup, FunName(),,, STR0002 + cError ) // "Erro na criação do Schedule: "

		lOk	:= .F.
	EndIf
Else
    If oScheduleAuto:updateSchedule()
		FWLogMsg("INFO",, cGroup, FunName(),,, STR0003) // "Schedule alterado com Sucesso !"

		lOk	:= .T.
    Else
		cError	:= oScheduleAuto:getErrorMessage()
		FWLogMsg("ERROR",, cGroup, FunName(),,, STR0004 + cError ) // "Erro na alteração do Schedule: "

		lOk	:= .F.
    EndIf
EndIf

FWLogMsg("DEBUG",, "BusinessObject",,,,,,, ;
	{;
		{"cIdSchedule", cIdSchedule}, {"dDataIni", dDataIni}, {"dDataFim", dDataFim}, {"dDataPri", dDataPri},;
		{"cHoraPri", cHoraPri}, {"cPeriodo", cPeriodo}, {"nHoraIni", nHoraIni}, {"nMinutoIni", nMinutoIni},;
		{"cEnv", cEnv}, {"aWeekDays", aWeekDays}, {"cError", cError}, {"cEmpAnt", cEmpAnt}, {"cFilAnt", cFilAnt},;
		{"cJsonSchedule", cJsonSchedule};
	};
)

FwFreeArray(aWeekDays)
FwFreeArray(aFrequency)
Return lOk
