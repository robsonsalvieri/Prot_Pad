/*/{Protheus.doc} ESTSV014
Função utilizada para execução do objeto de negócio Listagem dos Itens Inventariados
@type   Função
@author Michel Sander
@since  Setembro 22, 2023
/*/

Function ESTSV014()

    local lSuccess as logical
    local cError as character
    local lIsBlind := IsBlind() as logical

    If GetRpoRelease() > "12.1.2210"
        lSuccess := totvs.framework.treports.callTReports("backoffice.sv.est.inventorieditemsreport",,,,,lIsBlind,,.T.,@cError)
    Else
        FwLogMsg("WARN",, "SmartView ESTSV014",,, , "Funcionalidade nao disponivel para releases inferiores a 12.1.2310", , ,)
    EndIf

Return
