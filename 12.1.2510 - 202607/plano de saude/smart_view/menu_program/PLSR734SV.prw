#include "protheus.ch"

/*/{Protheus.doc} PLSR734SV
Receita x Despesa - Smart View (Visão de Dados)

@type method
@version Protheus 12.1.2310  
@author vinicius.queiros
@since 16/09/2023
/*/ 
function PLSR734SV()

    local lSucess := .f. as logical
    local cError := "" as character

    lSucess := totvs.framework.treports.callTReports("health.sv.plan.incomeexpense", nil, nil, nil, nil, .f., nil ,.t., @cError)

    if !lSucess
        if empty(cError)
            cError := "Não foi possivel estabelecer conexão com o Smart View, entre em contato com o administratdor."
        endif
        FWAlertError(cError, "Smart View")
    endif

return