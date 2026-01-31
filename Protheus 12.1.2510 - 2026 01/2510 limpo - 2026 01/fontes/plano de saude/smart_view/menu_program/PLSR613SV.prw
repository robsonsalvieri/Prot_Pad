#include "protheus.ch"

/*/{Protheus.doc} PLSR613SV
Apresenta cadastro de Beneficiários e também informações de seu contrato

@type method
@version Protheus 12.1.2310
@author José Paulo
@since 23/09/2023
/*/
function PLSR613SV()

    local lSucess := .f. as logical
    local cError := "" as character

    lSucess := totvs.framework.treports.callTReports("health.sv.plan.beneficiariesregistration", nil, nil, nil, nil, .f., nil ,.t., @cError)

    IIF (!lSucess .And. empty(cError),cError := "Não foi possivel estabelecer conexão com o Smart View, entre em contato com o administratdor.","")
    IIF (!lSucess,FWAlertError(cError, "Smart View"),"")

return
