#include "ESTSV012.ch"
/*/{Protheus.doc} ESTSV012
Função utilizada para execução do objeto de negócio Listagem para Inventário
@type   Função
@author Michel Sander
@since  Setembro 22, 2023
/*/

Function ESTSV012()

    local lSuccess as logical
    local cError as character
    local lIsBlind := IsBlind() as logical

    If GetRpoRelease() > "12.1.2210"
        lSuccess := totvs.framework.treports.callTReports("backoffice.sv.est.inventorylist",,,,,lIsBlind,,.T.,@cError)
    Else            
    	FwLogMsg("WARN",, "SmartView",,, , STR0002, , ,)
    EndIf

Return
