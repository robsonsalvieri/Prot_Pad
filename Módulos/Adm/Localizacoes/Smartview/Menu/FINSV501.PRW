#include "protheus.ch"

/*/{Protheus.doc} FINSV501
backoffice.sv.fin.AccountsReceivable - SmartView
@type function
@version 12.1.2210  
@author marcelo.hruschka
@since 08/03/2024
/*/ 
Function FINSV501()
    Local lSuccess as logical
    Local oSmartView as object

    //Inicialização das variáveis
    oSmartView := Nil
 
    If GetRpoRelease() >= "12.1.2210"
        oSmartView := totvs.framework.smartview.callSmartView():new("backoffice.sv.fin.AccountsReceivable")
        oSmartView:setShowWizard(.T.)
        lSuccess := oSmartView:executeSmartView(.T.)
        If !lSuccess
            Conout(oSmartView:getError())
        EndIf  
        oSmartView:destroy()
        freeObj(oSmartView)
    EndIf
Return Nil
