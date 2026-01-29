/*/{Protheus.doc} ESTSV004
Função utilizada para execução do objeto de negócio Análise de Movimentação
@type  Função
@author Squad Entradas
@since  Junho 26,2023
/*/
Function ESTSV004()
    local lSuccess as logical    
    local lIsBlind := IsBlind() as logical

    If GetRpoRelease() > "12.1.2210"        
        lSuccess := totvs.framework.treports.callTReports("backoffice.sv.est.analysisofmovement",,,,,lIsBlind,,.T.)
    Else
        FwLogMsg("WARN",, "SmartView ESTSV004",,, , "Funcionalidade nao disponivel para releases inferiores a 12.1.2310", , ,)
    EndIf

Return
