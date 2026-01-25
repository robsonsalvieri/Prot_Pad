#INCLUDE "ESTSV035.CH"
/*/{Protheus.doc} ESTSV024
Função utilizada para execução do objeto de negócio Complemento de Produto
@type  Função
@author Squad Entradas
@since  Dezembro 01,2023
/*/
Function ESTSV035()
    local lSuccess as logical
    local lConfig  as logical
    local lIsBlind := IsBlind() as logical

    If GetRpoRelease() > "12.1.2210"
        lConfig := totvs.framework.smartview.util.isConfig()
        If lConfig
            lSuccess := totvs.framework.treports.callTReports("backoffice.sv.est.productcomplement",,,,,lIsBlind,,.T.)
        Else
            FwLogMsg("WARN",, "SmartView",,, , STR0001, , ,)
        EndIf
    Else
        FwLogMsg("WARN",, "SmartView",,, , STR0002, , ,)
    EndIf
Return
