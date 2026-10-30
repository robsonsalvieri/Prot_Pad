#include "Protheus.ch"

//-------------------------------------------------------------------
/*{Protheus.doc} ESTSV044
Chamada do objeto de negócio Custo Total x Partes (SmartView)
@author Leonardo Kichitaro
@since 11/2025
@version 1.0
*/ 
//-------------------------------------------------------------------
Function ESTSV044()
	Local lSuccess As Logical
	Local cError As Character
	local lIsBlind := IsBlind() as logical
	Local lExecute  := FnVldCMod2() as logical

	If GetRpoRelease() > "12.1.2210" .And. lExecute
		lSuccess := totvs.framework.treports.callTReports("backoffice.sv.est.totalcostvspartcost",,,,,lIsBlind,,.T., @cError)
	Else
		FwLogMsg("WARN",, "SmartView ESTSV044",,, , "Funcionalidade nao disponivel", , ,)
	ENDIF
Return
