#include "protheus.ch"

/*/{Protheus.doc} PLSSV001
Menu/rotina da Conferência do lote de cobrança - SmartView
@type function
@version 12.1.2310  
@author vinicius.queiros
@since 02/02/2024
/*/ 
function PLSSV001()

    local lSuccess as logical
    local oSmartView as object
 
    if totvs.protheus.health.smartview.plan.utils.UtilsBusinessObject():isConfig()
        oSmartView := totvs.framework.smartview.callSmartView():new("health.sv.plan.billingbatchconference")

        lSuccess := oSmartView:executeSmartView()
    
        if !lSuccess
            fwAlertError(oSmartView:getError(), "Smart View")
        endif

        oSmartView:destroy()
    endif

    freeObj(oSmartView)

return
