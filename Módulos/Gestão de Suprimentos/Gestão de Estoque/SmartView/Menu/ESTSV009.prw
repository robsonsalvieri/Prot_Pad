#include "Protheus.ch"
#include "ESTSV009.ch"
//-------------------------------------------------------------------
/* {Protheus.doc} ESTSV009
Chamada do objeto de negócio Conferência de Saldos (SmartView)

@author Squad Entradas
@since 09/2023
@version 1.0
*/
//------------------------------------------------------------------- 
Function ESTSV009()

	Local lSuccess As Logical
	Local cError As character
	local lIsBlind := IsBlind() as logical

	If GetRpoRelease() > "12.1.2210"
		lSuccess := totvs.framework.treports.callTReports("backoffice.sv.est.checkingofstockbalance",,,,,lIsBlind,,.T., @cError)
    Else            
    	FwLogMsg("WARN",, "SmartView",,, , STR0002, , ,)
	EndIf
Return
