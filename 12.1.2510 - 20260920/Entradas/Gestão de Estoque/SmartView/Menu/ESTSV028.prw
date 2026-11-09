#include "ESTSV028.ch"
/*/{Protheus.doc} ESTSV028
Função utilizada para execução do objeto de negócio Relação de baixas do CQ
@type  Função
@author Squad Entradas
@since  Junho 26,2023
/*/
Function ESTSV028()
    local lSuccess as logical
    local lIsBlind := IsBlind() as logical
    local cError as character

    If GetRpoRelease() > "12.1.2210"
        lSuccess := totvs.framework.treports.callTReports("backoffice.sv.est.qccasualtyratio",,,,,lIsBlind,,.T.,@cError)
    Else
        FwLogMsg("WARN",, "SmartView ESTSV028",,, , STR0002, , ,)
    EndIf

Return
