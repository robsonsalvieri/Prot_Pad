
#include "msobject.ch"


Function PCOSV004()
Local lSuccess As Logical
Local cError := "" as Character
 
    If GetRpoRelease() >= "12.1.2310" 
        lSuccess := totvs.framework.treports.callTReports("backoffice.sv.pco.budgetaccounts",,,,,.F.,,.T., @cError) 
		If !lSuccess
            Conout(cError)
        EndIf
    else 
        Conout("rotina não disponivel")
    endIf
    
    
Return 
