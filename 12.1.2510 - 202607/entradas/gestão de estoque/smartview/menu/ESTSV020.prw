#INCLUDE "ESTSV020.CH"
/*/{Protheus.doc} ESTSV020
Função utilizada para execução do objeto de negócio Posicao de Estoque
@type   Função
@author Michel Sander
@since  Setembro 24, 2023
/*/

Function ESTSV020()

    local lSuccess as logical
    local cError as character
    local lIsBlind := IsBlind() as logical

    If GetRpoRelease() > "12.1.2210"
        lSuccess := totvs.framework.treports.callTReports("backoffice.sv.est.stockposition",,,,,lIsBlind,,.T.,@cError)
    Else
        FwLogMsg("WARN",, "SmartView",,, , STR0002, , ,)
    EndIf

Return
