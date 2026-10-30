#include "ESTSV026.ch"
/*/{Protheus.doc} ESTSV026
Chamada de menu do objeto de negocios Termo de Retirada
@author Rodrigo Lombardi
@since 13/10/2023
/*/
Function ESTSV026()
    local lSuccess as logical
    local lIsBlind := IsBlind() as logical
    local cError as character

    If GetRpoRelease() > "12.1.2210"
        lSuccess := totvs.framework.treports.callTReports("backoffice.sv.est.withdrawal",,,,,lIsBlind,,.T.,@cError)
    Else            
    FwLogMsg("WARN",, "SmartView ESTSV026",,, , STR0002, , ,)
    EndIf
Return
