#include "ESTSV034.ch"
/*/{Protheus.doc} ESTSV028
Função utilizada para execução do objeto de negócio Custo de Reposição dos Materiais
@type  Função
@author Squad Entradas
@since  Junho 26,2023
/*/
Function ESTSV034()
    local lSuccess as logical
    local cError As Character
    local lIsBlind := IsBlind() as logical

    If GetRpoRelease() > "12.1.2210"
        lSuccess := totvs.framework.treports.callTReports("backoffice.sv.est.replacementcostofmaterials",,,,,lIsBlind,,.T., @cError)
    Else
        FwLogMsg("WARN",, "SmartView ESTSV034",,, , STR0002, , ,)
    EndIf

Return
