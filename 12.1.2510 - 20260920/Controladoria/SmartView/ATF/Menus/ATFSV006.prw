
#include "msobject.ch"


Function ATFSV006()
Local lSuccess As Logical
Local cError := "" as Character
 
    If GetRpoRelease() >= "12.1.2310" 
        lSuccess := totvs.framework.treports.callTReports("backoffice.sv.atf.inventory",,,,,.F.,,.T., @cError) 
		If !lSuccess
            Conout(cError)
        EndIf
    else 
        Conout("rotina não disponivel")
    endIf
    
    
Return 
