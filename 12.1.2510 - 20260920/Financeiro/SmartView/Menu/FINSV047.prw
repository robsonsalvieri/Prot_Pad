#include "protheus.ch"

/*/{Protheus.doc} FINSV047
    Chamada do Smart View no menu 
    - Tabela Dinâmica
    - Visão de Dados
    - Previsão de Comissões

    @author Guilherme de Paula Santos
    @since 22/09/2023
    @version 12.1.2310
*/
Function FINSV047() 

    Local lSuccess  := .F. as logical 
    Local cError    := ""  as character

    lSuccess := .F.

    If GetRpoRelease() > '12.1.2210'
        lSuccess := totvs.framework.treports.callTReports("backoffice.sv.fin.forecastofcommission",,,,,.F.,,.T., @cError)
    EndIf

    If !lSuccess
        FwLogMsg("WARN",, "FINSV047",,,, "Program backoffice.sv.fin.forecastofcommission not avaliable.")
    EndIf

Return lSuccess
