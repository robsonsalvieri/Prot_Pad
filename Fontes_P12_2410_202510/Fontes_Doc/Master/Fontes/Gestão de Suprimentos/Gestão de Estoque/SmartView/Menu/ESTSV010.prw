/*/{Protheus.doc} ESTSV010
Função utilizada para execução do objeto de negócio Kardex por Lote/Sublote
@type  Função
@author Squad Entradas
@since  Junho 23,2023  
/*/
Function ESTSV010()
    local lSuccess as logical
    local cError   as Character
    local lIsBlind := IsBlind() as logical

    If GetRpoRelease() > "12.1.2210"
        lSuccess := totvs.framework.treports.callTReports("backoffice.sv.est.kardexbylotsublot",,,,,lIsBlind,,.T., @cError)
    Else
        FwLogMsg("WARN",, "SmartView ESTSV010",,, , "Funcionalidade nao disponivel para releases inferiores a 12.1.2310", , ,)
    EndIf

Return
