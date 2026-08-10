#include "protheus.ch"

/*/{Protheus.doc} PLSR606SV
Cadastro de Rede de Atendimento - Smart View (Relatório)

@type method
@version Protheus 12.1.2310  
@author guilherme.carreiro
@since 23/09/2023
/*/ 
function PLSR606SV()

    local lSucess := .f. as logical
    local cError := "" as character

    lSucess := totvs.framework.treports.callTReports("health.sv.plan.servicenetwork", nil, nil, nil, nil, .f., nil ,.t., @cError)

    if !lSucess
        if empty(cError)
            cError := "Não foi possivel estabelecer conexão com o Smart View, entre em contato com o administrador."
        endif
        FWAlertError(cError, "Smart View")
    endif

return
