#include "protheus.ch"

/*/{Protheus.doc} PLSR022S
eXTRATO DE UTILIZAÇÃO- Smart View (Visão de Dados)

@type method
@version Protheus 12.1.2310  
@author Robson Nayland Benjamim
@since 14/12/2023
/*/ 
function PLSR022S()

    local lSucess := .f. as logical
    local cError := "" as character

    lSucess := totvs.framework.treports.callTReports("health.sv.plan.extractUse", nil, nil, nil, nil, .f., nil ,.t., @cError)

    if !lSucess
        if empty(cError)
            cError := "Não foi possivel estabelecer conexão com o Smart View, entre em contato com o administratdor."
        endif
        FWAlertError(cError, "Smart View")
    endif

return
