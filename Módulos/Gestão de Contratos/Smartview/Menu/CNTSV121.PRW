#include "protheus.ch"

/*/{Protheus.doc} CNTSV121
backoffice.sv.gct.Contracts - SmartView
@type function
@version 12.1.2210  
@author marcelo.hruschka
@since 11/03/2024
/*/ 
Function CNTSV121()
    Local lSuccess as logical
    Local oSmartView as object

    //Inicialização das variáveis
    oSmartView := Nil
 
    If GetRpoRelease() >= "12.1.2310"
        oSmartView := totvs.framework.smartview.callSmartView():new("backoffice.sv.gct.ContractMeasurementsNoMade")
        oSmartView:setShowWizard(.T.)
        lSuccess := oSmartView:executeSmartView(.T.)
        IIf(!lSuccess,FwLogMsg( 'INFO', ' ', 'INFO', FunName(), '', '01', oSmartView:getError(), 0, 0, { } ),"")
        oSmartView:destroy()
        freeObj(oSmartView)
    EndIf
    
Return Nil
