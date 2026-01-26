#include "protheus.ch"

/*/{Protheus.doc} FINSV018
    Chamada do Smart View no menu 
    - Tabela Dinâmica 
    - Visão de Dados 
    - Movimento de caixa diário

    @author Fábio Henrique Andrade
    @since 22/09/2023
    @version 12.1.2310
*/
Function FINSV018() 

    Local lSuccess  := .F. as logical 
    Local cError    := ""  as character
 
    If GetRpoRelease() > '12.1.2210'

        lSuccess := totvs.framework.treports.callTReports("backoffice.sv.fin.cashierdailymovements",,,,,.F.,,.T., @cError)
        If !lSuccess
            Conout(cError)
        EndIf
    Else
        Conout("Rotina não disponivel")
    EndIf

Return lSuccess
