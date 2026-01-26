#INCLUDE "ESTSV036.CH"
/*/{Protheus.doc} ESTSV036
Função utilizada para execução do objeto de negócio Análise de Estoques por Estrutura
@type  Função
@author Squad Entradas
@since  Dezembro 04,2023
/*/
Function ESTSV036()
    local lSuccess as logical
    local lIsBlind := IsBlind() as logical
    local cError as character

    If GetRpoRelease() > "12.1.2210"
        lSuccess := totvs.framework.treports.callTReports("backoffice.sv.est.stockanalysisbystructure",,,,,lIsBlind,,.T.,@cError)
    Else
        FwLogMsg("WARN",, "SmartView",,, , STR0002, , ,)
    EndIf
Return
