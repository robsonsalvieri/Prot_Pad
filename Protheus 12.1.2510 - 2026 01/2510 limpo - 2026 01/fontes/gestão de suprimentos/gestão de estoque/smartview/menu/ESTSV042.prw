#include "Protheus.ch"

//-------------------------------------------------------------------
/*{Protheus.doc} ESTSV042
Chamada do objeto de negócio Lista de Faltas (SmartView)
@author Squad Entradas
@since 12/2023
@version 1.0
*/ 
//-------------------------------------------------------------------
Function ESTSV042()

	Local lSuccess As Logical
	Local cError As Character
	local lIsBlind := IsBlind() as logical

	If GetRpoRelease() > "12.1.2210"
		lSuccess := totvs.framework.treports.callTReports("backoffice.sv.est.listoffaults",,,,,lIsBlind,,.T., @cError)
	Else
		FwLogMsg("WARN",, "SmartView ESTSV042",,, , "Funcionalidade nao disponivel para releases inferiores a 12.1.2310", , ,)
	ENDIF
Return
