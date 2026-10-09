#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TAFA444S.CH"
#Include "FWEVENTVIEWCONSTS.CH"

Static dDataAtu := dDataBase as Date

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA444S

Rotina responsável por tratar as chamadas de encerramento de período via
SmartSchedule

@Author	 Rafael de Paula Leme
@Since	 05/02/2025
@Version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA444S()

	Local cTributo  as character

	cTributo := MV_PAR01

	TAFECFSCHD(cTributo)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA444S

Função responsável por preencher os parâmetros necessários para o
encerramento em lote agendado via schedule.

@Author	 Rafael de Paula Leme
@Since	 05/02/2025
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function TAFECFSCHD(cTributo)

	Local aParSchd   as array
	Local dDataIni   as date
	Local dDataFin   as date
	Local cLogViewer as character

	Default cTributo  := ''

	dDataIni := FirstYDate(MonthSub(dDataAtu, 1))

	If Type('lAutomato') == 'L' .and. lAutomato
		dDataAtu := StoD('20250401')
	EndIf

	aParSchd := {}

	If Month(dDataAtu) > 1
		dDataIni := FirstYDate(dDataAtu)
	EndIf

	dDataFin := LastDate(MonthSub(dDataAtu, 1))
	aParSchd := {cTributo, '', dDataIni, dDataFin}

	TAF444ELTE(.F., aParSchd, @cLogViewer)

	cLogViewer += Chr(13)+Chr(10) + STR0001 //"As mensagens de encerramento e envio para ECF podem ser verificadas na aba Apuração dos períodos encerrados."
	EventInsert(FW_EV_CHANEL_ENVIRONMENT, FW_EV_CATEGORY_MODULES, "087", 0, "", STR0002, cLogViewer,.F.) //"Encerramento de Período"

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Scheddef

Pergunte criado para escolha do tributo a ser encerrado via 
smartschedule

@Author	 Rafael de Paula Leme
@Since	 05/02/2025
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function Scheddef()

	Local aParam  := {} as array

	aParam := { "P",;  //Tipo R para relatorio P para processo
         "ECFSCD01",; //Pergunte do relatorio, caso nao use passar ParamDef
                   ,; //Alias
                   ,; //Array de ordens
              }       //Titulo

Return aParam
