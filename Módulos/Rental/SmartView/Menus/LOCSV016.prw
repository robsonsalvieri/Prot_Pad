#include "Protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} LOCSV016
Função utilizada para execução do objeto de negócio Histórico de Substituições
@type  Função
@author Leonardo Pacheco Fuga
@since  03/10/2025
/*/
//-------------------------------------------------------------------
Function LOCSV016()
    
local lSuccess As logical
local oSmartView as object
    
    If GetRpoRelease() > "12.1.2210" 

        oSmartView := totvs.framework.smartview.callSmartView():new("sigaloc.sv.loc.historicosubstituicao",,,,,.F.,,.T.,)
        //oSmartView := totvs.framework.smartview.callSmartView():new("loc.sv.rental.custoporequipamento.default.dg", "data-grid")
        oSmartView:setShowWizard(.T.)
        lSuccess := oSmartView:executeSmartView(.T.)
    
        oSmartView:destroy()

    EndIf

Return

//Dia:06/10/2025 - ajuste para o ADVPR
