#include "protheus.ch"

/*/{Protheus.doc} PLSR612SV
Cadastro de Famílias - Smart View (Relatório)

@type method
@version Protheus 12.1.2310  
@author vinicius.queiros
@since 23/09/2023
/*/ 
function PLSR612SV()

    local lSucess := .f. as logical
    local cError := "" as character

    lSucess := totvs.framework.treports.callTReports("health.sv.plan.family", nil, nil, nil, nil, .f., nil ,.t., @cError)

    if !lSucess
        if empty(cError)
            cError := "Não foi possivel estabelecer conexão com o Smart View, entre em contato com o administratdor."
        endif
        FWAlertError(cError, "Smart View")
    endif

return
