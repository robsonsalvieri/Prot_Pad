#include 'protheus.ch'
#include 'fwschedule.ch'


//-------------------------------------------------------------------
/*/{Protheus.doc} TAFSchedStartup
Classe responsável pela criação de agendamentos do schedule
 no startup do TAF Cloud

Baseada na especificação http://tdn.totvs.com/display/TAF/Web+Service+REST+-+TAFSETUP

@since   13/04/2018
@protected
/*/
//-------------------------------------------------------------------
CLASS TAFSchedStartup FROM LongNameClass
    
    METHOD New()
    METHOD CreateSched()

ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor

@since   13/04/2018
/*/
//-------------------------------------------------------------------
METHOD New() CLASS TAFSchedStartup

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} CreateSched
Efetua criação de agendametno para tarefa TafDemand

@param lActive - Define se será será criado como ativo ou inativo 

@since   11/05/2018
@protected
/*/
//-------------------------------------------------------------------
METHOD CreateSched( lActive ) CLASS TAFSchedStartup
    Local cSchedID AS CHARACTER
    
    cSchedID := FWSchdByFunction('TAFDEMAND("01")')
    If !Empty(cSchedID)
        FWDelSchedule(cSchedID)
    EndIf

	If lActive
		FWInsSchedule('TAFDEMAND("01")',"000000",,ALWAYS,"00:00",Upper(GetEnvServer()),"01;",SCHD_ACTIVE,Date(),84)
	Else
		FWInsSchedule('TAFDEMAND("01")',"000000",,ALWAYS,"00:00",Upper(GetEnvServer()),"01;",SCHD_DEACTIVATE,Date(),84)	
	EndIf

Return

// Dummy
Function __TAFSched()
Return

                                                                                                                                             
