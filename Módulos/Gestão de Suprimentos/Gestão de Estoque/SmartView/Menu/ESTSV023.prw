/*/{Protheus.doc} ESTSV023
Função utilizada para execução do objeto de negócio Movimentação Por Produto (Kardex)
@type   Função
@author Michel Sander
@since  Setembro 25, 2023
/*/

Function ESTSV023()

    local lSuccess as logical
    local cError as character
    local lIsBlind := IsBlind() as logical

    If GetRpoRelease() > "12.1.2210"
        lSuccess := totvs.framework.treports.callTReports("backoffice.sv.est.kardex",,,,,lIsBlind,,.T.,@cError)
    Else
        FwLogMsg("WARN",, "SmartView ESTSV023",,, , "Funcionalidade nao disponivel para releases inferiores a 12.1.2310", , ,)
    EndIf

Return
