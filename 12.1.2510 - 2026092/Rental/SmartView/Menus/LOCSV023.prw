#include "Protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} LOCSV023
Função utilizada para execução do objeto de negócio Timesheet
@type  Função
@author Leonardo Pacheco Fuga
@since  21/11/2025
/*/
//-------------------------------------------------------------------
Function LOCSV023()

local lSuccess as logical
local oSmartView as object
    
    If GetRpoRelease() > "12.1.2210" 

        oSmartView := totvs.framework.smartview.callSmartView():new("sigaloc.sv.loc.timesheet",,,,,.F.,,.T.,)
        oSmartView:setShowWizard(.T.)
        lSuccess := oSmartView:executeSmartView()

        oSmartView:destroy()

    EndIf

Return
