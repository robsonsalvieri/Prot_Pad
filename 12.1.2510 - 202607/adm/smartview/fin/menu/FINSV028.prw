#include "protheus.ch"

/*/{Protheus.doc} FINSV028
    Chamada do Smart View no menu 
    - Visão de Dados 
    - Títulos a pagar por natureza

    @author Fábio Henrique Andrade
    @since 22/09/2023
    @version 12.1.2310
*/
Function FINSV028() 

    Local lSuccess  := .F. as logical 
    Local cError    := ""  as character
 
    If GetRpoRelease() > '12.1.2210'

        lSuccess := totvs.framework.treports.callTReports("backoffice.sv.fin.billspayableperclass",,,,,.F.,,.T., @cError)
        If !lSuccess
            Conout(cError)
        EndIf
    Else
        Conout("Rotina não disponivel")
    EndIf

Return lSuccess
