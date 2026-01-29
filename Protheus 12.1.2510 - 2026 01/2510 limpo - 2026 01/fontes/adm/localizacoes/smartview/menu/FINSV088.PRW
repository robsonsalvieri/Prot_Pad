#include "protheus.ch"

/*/{Protheus.doc} FINSV088
backoffice.sv.fin.AccountsReceivablePending - SmartView
@type function
@version 12.1.2210  
@author marcelo.hruschka
@since 11/03/2024
/*/ 
Function FINSV088()
    Local lSuccess as logical
    Local oSmartView as object

    //Inicialização das variáveis
    oSmartView := Nil
 
    If GetRpoRelease() >= "12.1.2210"
        oSmartView := totvs.framework.smartview.callSmartView():new("backoffice.sv.fin.AccountsReceivablePending")
        oSmartView:setShowWizard(.T.)
        lSuccess := oSmartView:executeSmartView(.T.)
        IIf(!lSuccess,Conout(oSmartView:getError()),"")
        oSmartView:destroy()
        freeObj(oSmartView)
    EndIf
Return Nil
