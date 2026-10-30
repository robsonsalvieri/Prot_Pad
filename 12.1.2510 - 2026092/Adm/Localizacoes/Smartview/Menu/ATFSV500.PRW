#include "protheus.ch"

/*/{Protheus.doc} ATFSV500 
backoffice.sv.atf.depreciatedassets_mex - SmartView
@type function
@version 12.1.2410  
@author marcelo.hruschka
@since 24/03/2024
/*/ 
Function ATFSV500 ()
    Local lSuccess as logical
    Local oSmartView as object

    //Inicialização das variáveis
    oSmartView := Nil
 
    If GetRpoRelease() >= "12.1.2310"
        oSmartView := totvs.framework.smartview.callSmartView():new("backoffice.sv.atf.depreciatedassets_mex")
        oSmartView:setShowWizard(.T.)
        lSuccess := oSmartView:executeSmartView(.T.)
        IIf(!lSuccess,Conout(oSmartView:getError()),"")
        oSmartView:destroy()
        freeObj(oSmartView)
    EndIf

Return Nil

