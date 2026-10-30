#include "Protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} LOCSV014
Função utilizada para execução do objeto de negócio Faturamento parado e substituicao pendente
@type  Função
@author Leonardo Pacheco Fuga
@since  13/08/2025
/*/
//-------------------------------------------------------------------
Function LOCSV014()

local lSuccess as logical
local oSmartView as object
    
    If GetRpoRelease() > "12.1.2210" 

        oSmartView := totvs.framework.smartview.callSmartView():new("sigaloc.sv.loc.faturamentoparado",,,,,.F.,,.T.,)
        oSmartView:setShowWizard(.T.)
        lSuccess := oSmartView:executeSmartView(.T.)
    
        oSmartView:destroy()

    EndIf

Return

