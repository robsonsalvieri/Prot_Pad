#INCLUDE "ESTSV024.CH"
/*/{Protheus.doc} ESTSV024
Função utilizada para execução do objeto de negócio Saldos Iniciais
@type  Função
@author Squad Entradas
@since  Junho 25,2023
/*/
Function ESTSV024()
    local lSuccess as logical
    local cError as character
    local lIsBlind := IsBlind() as logical

    If GetRpoRelease() > "12.1.2210"
       lSuccess := totvs.framework.treports.callTReports("backoffice.sv.est.initialbalances",,,,,lIsBlind,,.T., @cError)
    Else
        FwLogMsg("WARN",, "SmartView",,, , STR0002, , ,)
    EndIf
Return
