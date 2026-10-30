#include "msobject.ch"

//-------------------------------------------------------------------
/*{Protheus.doc}  Função para chamada do relatório do Smart View
backoffice.sv.atf.transfers.bra.tlpp		
Responsáveis x Bens

@author Bruno Oliveira
@since 31/10/2023
@version 1.0
*/
//-------------------------------------------------------------------
Function ATFSV014()
Local lSuccess As Logical
Local cError := "" as Character
 
    If GetRpoRelease() >= "12.1.2310" 
        lSuccess := totvs.framework.treports.callTReports("backoffice.sv.atf.transfers",,,,,.F.,,.T., @cError) 
		If !lSuccess
            Conout(cError)
        EndIf
    else 
        Conout("rotina não disponivel")
    endIf
    
    
Return 
