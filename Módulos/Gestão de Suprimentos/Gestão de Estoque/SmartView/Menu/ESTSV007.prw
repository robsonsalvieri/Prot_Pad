#include "Protheus.ch"

//-------------------------------------------------------------------
/*{Protheus.doc} ESTSV007 
Chamada do objeto de negócio Diferenças de Estoque (SmartView)

@author Squad Entradas
@since 09/2023
@version 1.0
*/
//-------------------------------------------------------------------   
Function ESTSV007()

	Local lSuccess As Logical
	Local cError As Character
	local lIsBlind := IsBlind() as logical

	If GetRpoRelease() > "12.1.2210"
		lSuccess := totvs.framework.treports.callTReports("backoffice.sv.est.stockdifferences",,,,,lIsBlind,,.T., @cError)
	Else
		FwLogMsg("WARN",, "SmartView ESTSV007",,, , "Funcionalidade nao disponivel para releases inferiores a 12.1.2310", , ,)
	EndIf

Return
