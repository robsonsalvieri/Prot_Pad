#include "protheus.ch"

/*/{Protheus.doc} FINSV020
    Chamada do Smart View no menu 
    - Visão de Dados 
    - Títulos a pagar com retenção de impostos

    @author Fábio Henrique Andrade
    @since 22/09/2023
    @version 12.1.2310
*/
Function FINSV020() 

    Local lSuccess  := .F. as logical 
    Local cError    := ""  as character
 
    If GetRpoRelease() > '12.1.2210'

        lSuccess := totvs.framework.treports.callTReports("backoffice.sv.fin.billspayablewithholdingtaxes",,,,,.F.,,.T., @cError)
        If !lSuccess
            Conout(cError)
        EndIf
    Else
        Conout("Rotina não disponivel")
    EndIf

Return lSuccess
