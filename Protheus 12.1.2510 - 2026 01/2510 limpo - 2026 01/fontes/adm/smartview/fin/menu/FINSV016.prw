#include "protheus.ch"

/*/{Protheus.doc} FINSV016
    Chamada do Smart View no menu 
    - Visão de Dados 
    - Relatório 
    - Fluxo de Caixa Realizado

    @author Fábio Henrique Andrade
    @since 21/09/2023
    @version 12.1.2310
*/
Function FINSV016() 

    Local lSuccess  := .F. as logical 
    Local cError    := ""  as character
 
    If GetRpoRelease() > '12.1.2210'

        lSuccess := totvs.framework.treports.callTReports("backoffice.sv.fin.realizedcashflow",,,,,.F.,,.T., @cError)
        If !lSuccess
            Conout(cError)
        EndIf
    Else
        Conout("Rotina não disponível")
    EndIf

Return lSuccess
