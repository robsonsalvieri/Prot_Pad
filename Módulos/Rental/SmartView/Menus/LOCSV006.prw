#include "Protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} LOCSV001
Função utilizada para execução do objeto de negócio Medição
@type  Função
@author Dennis Calabrez
@since  12/03/2025
/*/
//-------------------------------------------------------------------
Function LOCSV006()
    /*
    local lSuccess              as logical
    local cError                as character
    local lIsBlind := IsBlind() as logical

    If GetRpoRelease() > "12.1.2310"
        //lSuccess := totvs.framework.treports.callTReports("loc.sv.rental.CustoEquipamentoTReportsBusinessObject",,,,,lIsBlind,,.T., @cError)
        lSuccess := totvs.framework.treports.callTReports("loc.sv.rental.CustoEquipamentoTReportsBusinessObject",,,,,,,,)
    Else
        FwLogMsg("WARN",, "SmartView LOCSV001",,, , "Funcionalidade nao disponivel para releases inferiores a 12.1.2310", , ,)
    EndIf
    */
    local lSuccess As logical
    local oSmartView as object
    
    If GetRpoRelease() > "12.1.2210" 

        oSmartView := totvs.framework.smartview.callSmartView():new("sigaloc.sv.loc.planilhadeprojeto")
        //oSmartView := totvs.framework.smartview.callSmartView():new("loc.sv.rental.custoporequipamento.default.dg", "data-grid")
        oSmartView:setShowWizard(.T.)
        lSuccess := oSmartView:executeSmartView(.T.)

    
        oSmartView:destroy()

    EndIf

Return

