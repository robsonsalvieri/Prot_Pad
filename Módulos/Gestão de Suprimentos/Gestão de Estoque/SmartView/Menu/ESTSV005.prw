#include "Protheus.ch"

//-------------------------------------------------------------------
/*{Protheus.doc} ESTSV005
Chamada do objeto de negócio Lista de Produtos a Endereçar (SmartView)

@author Squad Entradas
@since 09/2023
@version 1.0
*/
//------------------------------------------------------------------- 
Function ESTSV005()

	Local lSuccess As Logical
	Local cError As Character
	local lIsBlind := IsBlind() as logical

	If GetRpoRelease() > "12.1.2210"
		lSuccess := totvs.framework.treports.callTReports("backoffice.sv.est.listofproductstoadress",,,,,lIsBlind,,.T., @cError)
	Else
		FwLogMsg("WARN",, "SmartView ESTSV005",,, , "Funcionalidade nao disponivel para releases inferiores a 12.1.2310", , ,)
	EndIf

Return
