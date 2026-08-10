#include "Protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} ESTSV001
Função utilizada para execução do objeto de negócio Formação de Preço
@type  Função
@author Squad Entradas
@since  Junho 21,2023
/*/
//-------------------------------------------------------------------
Function ESTSV001()

    local lSuccess              as logical
    local cError                as character
    local lIsBlind := IsBlind() as logical

    If GetRpoRelease() > "12.1.2210"
        lSuccess := totvs.framework.treports.callTReports("backoffice.sv.est.priceformation",,,,,lIsBlind,,.T., @cError)
    Else
        FwLogMsg("WARN",, "SmartView ESTSV001",,, , "Funcionalidade nao disponivel para releases inferiores a 12.1.2310", , ,)
    EndIf

Return
