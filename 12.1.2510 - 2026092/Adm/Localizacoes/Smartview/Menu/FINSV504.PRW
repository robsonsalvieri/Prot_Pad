#include "protheus.ch"

/*/{Protheus.doc} FINSV504
backoffice.sv.fin.PreOrder - SmartView
@type function
@version 12.1.2210  
@author marcelo.hruschka
@since 11/03/2024
/*/ 
Function FINSV504()
    Local lSuccess as logical
    Local oSmartView as object

    //Inicialização das variáveis
    oSmartView := Nil
 
    If GetRpoRelease() >= "12.1.2210"
        oSmartView := totvs.framework.smartview.callSmartView():new("backoffice.sv.fin.PreOrder")
        oSmartView:setShowWizard(.T.)
        lSuccess := oSmartView:executeSmartView(.T.)
        IIf(!lSuccess,Conout(oSmartView:getError()),"") 
        oSmartView:destroy()
        freeObj(oSmartView)
    EndIf
Return Nil
