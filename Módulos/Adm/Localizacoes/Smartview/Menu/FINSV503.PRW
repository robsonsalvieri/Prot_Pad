#include "protheus.ch"

/*/{Protheus.doc} FINSV503
backoffice.sv.fin.PaymentOrder - SmartView
@type function
@version 12.1.2210  
@author marcelo.hruschka
@since 11/03/2024
/*/ 
Function FINSV503()
    Local lSuccess as logical
    Local oSmartView as object

    //Inicialização das variáveis
    oSmartView := Nil
 
    If GetRpoRelease() >= "12.1.2210"
        oSmartView := totvs.framework.smartview.callSmartView():new("backoffice.sv.fin.PaymentOrder")
        oSmartView:setShowWizard(.T.)
        lSuccess := oSmartView:executeSmartView(.T.)
        If !lSuccess
            Conout(oSmartView:getError())
        EndIf  
        oSmartView:destroy()
        freeObj(oSmartView)
    EndIf
Return Nil
