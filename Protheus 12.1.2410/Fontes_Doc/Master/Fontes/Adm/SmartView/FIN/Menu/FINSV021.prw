#include "protheus.ch"

/*/{Protheus.doc} FINSV021
    Chamada do Smart View no menu 
    - Relatório analítico e sintético 
    - Movimentos bancários

    @author Fábio Henrique Andrade
    @since 22/09/2023
    @version 12.1.2310
*/
Function FINSV021() 

    Local lSuccess  := .F. as logical 
    Local cError    := ""  as character
 
    If GetRpoRelease() > '12.1.2210'

        lSuccess := totvs.framework.treports.callTReports("backoffice.sv.fin.bankactivities",,,,,.F.,,.T., @cError)
        If !lSuccess
            Conout(cError)
        EndIf
    Else
        Conout("Rotina não disponivel")
    EndIf

Return lSuccess
