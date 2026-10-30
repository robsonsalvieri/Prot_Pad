#include "ESTSV018.ch"

/*/{Protheus.doc} ESTSV018
Função utilizada para execução do objeto de negócio Posicao de Estoque por Lote/Sub-Lote
@type   Função
@author Michel Sander
@since  Setembro 24, 2023
/*/

Function ESTSV018()

    local lSuccess as logical
    local cError as character
    local lIsBlind := IsBlind() as logical

    If GetRpoRelease() > "12.1.2210"
        lSuccess := totvs.framework.treports.callTReports("backoffice.sv.est.stockpositionbylotsublot",,,,,lIsBlind,,.T.,@cError)
    Else
        FwLogMsg("WARN",, "SmartView ESTSV018",,, , "Funcionalidade nao disponivel para releases inferiores a 12.1.2310", , ,)
    EndIf

Return
