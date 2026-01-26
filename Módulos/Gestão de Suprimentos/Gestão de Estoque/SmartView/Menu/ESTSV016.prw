#include "Protheus.ch"

//-------------------------------------------------------------------
/*{Protheus.doc} ESTSV016
Chamada do objeto de negócio Materiais De/Em Terceiros (SmartView)

@author Squad Entradas
@since 09/2023
@version 1.0
*/
//------------------------------------------------------------------- 

Function ESTSV016()

	Local lSuccess As Logical
	Local cError As character
	local lIsBlind := IsBlind() as logical

	If GetRpoRelease() > "12.1.2210"
		lSuccess := totvs.framework.treports.callTReports("backoffice.sv.est.materialsfromandwith3rdparty",,,,,lIsBlind,,.T., @cError)
	Else
		FwLogMsg("WARN",, "SmartView ESTSV016",,, , "Funcionalidade nao disponivel para releases inferiores a 12.1.2310", , ,)
	EndIf

Return
