#include "ESTSV041.ch"
/*/{Protheus.doc} ESTSV039
Função utilizada para execução do objeto de negócio Custo de Reposição dos Materiais
@type  Função
@author Squad Entradas
@since  Junho 26,2023
/*/
Function ESTSV041()

    local lSuccess as logical
    local lIsBlind := IsBlind() as logical
    Local cError as character

    If GetRpoRelease() > "12.1.2210"
        lSuccess := totvs.framework.treports.callTReports("backoffice.sv.est.kardexfifolifo.main.rep","report",,,,lIsBlind,,.T., @cError)
    Else
        FwLogMsg("WARN",, "SmartView ESTSV041",,, , STR0002, , ,)
    EndIf

Return
