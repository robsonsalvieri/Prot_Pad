#include "protheus.ch"

/*/{Protheus.doc} PLSR743SV
Quantidade de Inclusão /Exclusão de Beneficiários por Produto (Visão de Dados e Tabela Dinãmica)

@type method
@version Protheus 12.1.2310  
@author Cesar Almeida
@since 23/09/2023
/*/ 
function PLSR743SV()

    local lSucess := .f. as logical
    local cError := "" as character

    lSucess := totvs.framework.treports.callTReports("health.sv.plan.familyinclusionexclusionbenef", nil, nil, nil, nil, .f., nil ,.t., @cError)

    if !lSucess
        if empty(cError)
            cError := "Não foi possivel estabelecer conexão com o Smart View, entre em contato com o administratdor."
        endif
        FWAlertError(cError, "Smart View")
    endif

return
