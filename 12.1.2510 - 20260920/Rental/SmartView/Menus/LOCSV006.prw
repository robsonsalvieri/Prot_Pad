#include "Protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} LOCSV006
Função utilizada para execução do objeto de negócio Medição
@type  Função
@author Leonardo Pacheco Fuga
@since  12/03/2025
/*/
//-------------------------------------------------------------------
Function LOCSV006()
    local lSuccess As logical
    local oSmartView as object
    
    If GetRpoRelease() > "12.1.2210" 

        oSmartView := totvs.framework.smartview.callSmartView():new("sigaloc.sv.loc.planilhadeprojeto") //Retirada de comentarios sem utilidade (DSERLOCA-13176) 
        oSmartView:setShowWizard(.T.)
        lSuccess := oSmartView:executeSmartView(.T.)

    
        oSmartView:destroy()

    EndIf

Return

