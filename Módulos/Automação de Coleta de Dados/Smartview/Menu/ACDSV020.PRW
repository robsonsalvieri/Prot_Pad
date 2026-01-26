#include "protheus.ch"

/*/{Protheus.doc} ACDSV020
backoffice.sv.acd.Labels - SmartView
@type function
@version 12.1.2210  
@author marcelo.hruschka
@since 11/03/2024
/*/ 
Function ACDSV020()
    Local lSuccess as logical
    Local oSmartView as object

    //Inicialização das variáveis
    oSmartView := Nil
 
    If GetRpoRelease() >= "12.1.2210"
        oSmartView := totvs.framework.smartview.callSmartView():new("backoffice.sv.acd.Labels")
        oSmartView:setShowWizard(.T.)
        lSuccess := oSmartView:executeSmartView(.T.)
        IIf(!lSuccess,Conout(oSmartView:getError()),"")
        oSmartView:destroy()
        freeObj(oSmartView)
    EndIf
Return Nil

