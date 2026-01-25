#include "ESTSV006.CH"
/*/{Protheus.doc} ESTSV006 
Função utilizada para execução do objeto de negócio Relação das Movimentações Internas
@type  Função
@author Squad Entradas    
@since  Junho 22,2023
/*/
Function ESTSV006()
    local lSuccess as logical
    Local cError As character
    local lIsBlind := IsBlind() as logical

   
    If GetRpoRelease() > "12.1.2210"        
       lSuccess := totvs.framework.treports.callTReports("backoffice.sv.est.internaltransactions",,,,,lIsBlind,,.T., @cError)
    else 
        FwLogMsg("WARN",,"SmartView",,,,STR0002,,,)
    EndIf

Return
