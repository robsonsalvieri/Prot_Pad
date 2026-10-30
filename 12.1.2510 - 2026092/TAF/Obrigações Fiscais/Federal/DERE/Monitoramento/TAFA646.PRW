#include 'totvs.ch'

/*----------------------------------------------------------------------
{Protheus.doc} TAFA646
Responsável por chamar a função de monitoramento do retorno da Dere

@author Rafael de Paula Leme
@since 25/08/2026
//----------------------------------------------------------------------*/
Function TAFA646()
	
    Local oSchedule := backoffice.taf.dere.monitoring.TAFDereEventsMonitor():New()

    oSchedule:TafDereMonitorsSentEvents()
    
    FWFreeObj(oSchedule)
Return

/*-------------------------------------------------------------------------------
Informacoes de definicao dos parametros do schedule

@author Rafael de Paula Leme
@since 25/08/2026
--------------------------------------------------------------------------------*/
Static Function Scheddef()
	Local aParam := {}

	aParam := {'P', 'PARAMDEF', '', {}, ''}
Return aParam
