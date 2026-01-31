#include "Protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} LOCSV021
Função utilizada para execução do objeto de negócio Quadro Resumo
@type  Função
@author Leonardo Pacheco Fuga
@since  29/10/2025
/*/
//-------------------------------------------------------------------
Function LOCSV022()

local lSuccess as logical
local oSmartView as object
    
    If GetRpoRelease() > "12.1.2210" 

        oSmartView := totvs.framework.smartview.callSmartView():new("sigaloc.sv.loc.dispstatusana",,,,,.F.,,.T.,)
        oSmartView:setShowWizard(.T.)
        lSuccess := oSmartView:executeSmartView()

        oSmartView:destroy()

    EndIf

Return
