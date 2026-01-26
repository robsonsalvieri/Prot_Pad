#include "ESTSV027.ch"
/*/{Protheus.doc} ESTSV027
Chamada de menu do objeto de negocios Comparativo de Custos
@author Rodrigo Lombardi
@since 20/10/2023
/*/
Function ESTSV027()

    local lSuccess as logical
    local lConfig  as logical
    local lIsBlind := IsBlind() as logical
    local cError   as character

    If GetRpoRelease() > "12.1.2210"
       lSuccess := totvs.framework.treports.callTReports("backoffice.sv.est.costComparison",,,,,lIsBlind,,.T., @cError)
    Else            
       FwLogMsg("WARN",, "SmartView ESTSV027",,, , STR0002, , ,)
    EndIf

Return

