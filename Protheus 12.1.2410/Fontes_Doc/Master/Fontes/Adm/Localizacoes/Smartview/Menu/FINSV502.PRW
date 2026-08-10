#include "protheus.ch"

/*/{Protheus.doc} FINSV502
backoffice.sv.fin.cheques - SmartView
@type function
@version 12.1.2210  
@author marcelo.hruschka
@since 05/04/2024
/*/ 
Function FINSV502()
    Local lSuccess as logical
    Local oSmartView as object

    //Inicialização das variáveis
    oSmartView := Nil
 
    If GetRpoRelease() >= "12.1.2210"
        oSmartView := totvs.framework.smartview.callSmartView():new("backoffice.sv.fin.cheques")
        oSmartView:setShowWizard(.T.)
        lSuccess := oSmartView:executeSmartView(.T.)
        oSmartView:destroy()
        freeObj(oSmartView)
    EndIf
Return Nil



