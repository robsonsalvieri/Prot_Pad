#include "Protheus.ch"

//-------------------------------------------------------------------
/*{Protheus.doc} ESTSV043
Chamada do objeto de negócio Custo de Entrada (SmartView)
@author Leonardo Kichitaro
@since 10/2025
@version 1.0
*/ 
//-------------------------------------------------------------------
Function ESTSV043()

	Local lSuccess As Logical
	Local cError As Character
	local lIsBlind := IsBlind() as logical
	Local lExecute  := FnVldCMod2() as logical

	If GetRpoRelease() > "12.1.2210" .And. lExecute
		lSuccess := totvs.framework.treports.callTReports("backoffice.sv.est.acquisitioncost",,,,,lIsBlind,,.T., @cError)
	Else
		FwLogMsg("WARN",, "SmartView ESTSV043",,, , "Funcionalidade nao disponivel", , ,)
	ENDIF
Return
