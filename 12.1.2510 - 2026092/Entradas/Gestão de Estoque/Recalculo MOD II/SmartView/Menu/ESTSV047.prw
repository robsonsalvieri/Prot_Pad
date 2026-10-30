#include "Protheus.ch"

//-------------------------------------------------------------------
/*{Protheus.doc} ESTSV047
Chamada do objeto de negócio Kardex em Partes (SmartView)
@author Leonardo Kichitaro
@since 01/2026
@version 1.0
*/ 
//-------------------------------------------------------------------
Function ESTSV047()
	Local lSuccess As Logical
	Local cError As Character
	local lIsBlind := IsBlind() as logical
	Local lExecute  := FnVldCMod2() as logical

	If GetRpoRelease() > "12.1.2210" .And. lExecute
		lSuccess := totvs.framework.treports.callTReports("backoffice.sv.est.kardexinparts",,,,,lIsBlind,,.T., @cError)
	Else
		FwLogMsg("WARN",, "SmartView ESTSV046",,, , "Funcionalidade nao disponivel", , ,)
	ENDIF
Return
