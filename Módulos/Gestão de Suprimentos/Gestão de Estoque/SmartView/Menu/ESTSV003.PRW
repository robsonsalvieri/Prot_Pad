/*/{Protheus.doc} ESTSV001
Função utilizada para execução do objeto de negócio Requisições para Consumo
@type   Função
@author Michel Sander
@since  Setembro 22, 2023
/*/

Function ESTSV003()

    local lSuccess as logical
    local cError as character
    local lIsBlind := IsBlind() as logical

    If GetRpoRelease() > "12.1.2210"
        lSuccess := totvs.framework.treports.callTReports("backoffice.sv.est.consumptionrequirements",,,,,lIsBlind,,.T., @cError)
    Else
        FwLogMsg("WARN",, "SmartView ESTSV003",,, , "Funcionalidade nao disponivel para releases inferiores a 12.1.2310", , ,)
    EndIf

Return
