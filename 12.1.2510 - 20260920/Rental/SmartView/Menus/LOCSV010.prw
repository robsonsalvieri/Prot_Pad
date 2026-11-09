#include "Protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} LOCSV009
Função utilizada para execução do objeto de negócio Remessas
@type  Função
@author Leonardo Pacheco Fuga
@since  17/06/2025
/*/
//-------------------------------------------------------------------
Function LOCSV010()
    
local lSuccess as logical
local oSmartView as object
    
    If GetRpoRelease() > "12.1.2210" 

        oSmartView := totvs.framework.smartview.callSmartView():new("sigaloc.sv.loc.remessas",,,,,.F.,,.T.,)
        oSmartView:setShowWizard(.T.)
        lSuccess := oSmartView:executeSmartView(.T.)
    
        oSmartView:destroy()

    EndIf

Return
