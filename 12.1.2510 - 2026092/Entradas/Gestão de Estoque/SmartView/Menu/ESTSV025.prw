#include "Protheus.ch"

//-------------------------------------------------------------------
/*{Protheus.doc} ESTSV025
Chamada do objeto de negócio Nfs De/Em Terceiro (SmartView)

@author Squad Entradas
@since 09/2023
@version 1.0
*/
//------------------------------------------------------------------- 
Function ESTSV025()

    local lSuccess as logical
    local cError as character
    local lIsBlind := IsBlind() as logical

	If GetRpoRelease() > "12.1.2210"
		lSuccess := totvs.framework.treports.callTReports("backoffice.sv.est.invoicesfromandat3rdparties",,,,,lIsBlind,,.T., @cError)
	Else
		FwLogMsg("WARN",, "SmartView",,, , "Funcionalidade nao disponivel para releases inferiores a 12.1.2310", , ,)
	EndIf
Return
