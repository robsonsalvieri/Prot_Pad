#include "ESTSV037.ch"
/*/{Protheus.doc} ESTSV037
Função utilizada para execução do objeto de negócio PickList Por OP
@type  Função
@author Squad Entradas
@since  Junho 26,2023
/*/ 
Function ESTSV037()
	local lSuccess as logical
	local cError   as character
	local lIsBlind := IsBlind() as logical

    If GetRpoRelease() > "12.1.2210"
       lSuccess := totvs.framework.treports.callTReports("backoffice.sv.est.picklistbyop",,,,,lIsBlind,,.T., @cError)
    Else
        FwLogMsg("WARN",, "SmartView ESTSV037",,, , STR0002, , ,)
    EndIf

Return
