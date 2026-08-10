#include "Protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} LOCSV004
Função utilizada para execução do objeto de negócio do Custo Extra
@type Função
@author Leonardo Pacheco Fuga
@since 12/03/2025
/*/
//-------------------------------------------------------------------
Function LOCSV004()
Local lSuccess as logical
Local oSmartView as object
    
    If GetRpoRelease() > "12.1.2210"  

        oSmartView := totvs.framework.smartview.callSmartView():new("sigaloc.sv.loc.custoextra")
        oSmartView:setShowWizard(.T.)
        lSuccess := oSmartView:executeSmartView(.T.)
   
        oSmartView:destroy()

    EndIf

Return

