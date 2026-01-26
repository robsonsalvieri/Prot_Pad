#include "Protheus.ch"
#include "ESTSV008.ch"
//-------------------------------------------------------------------
/*{Protheus.doc} ESTSV008
Chamada do objeto de negócio Posição das Solicitações ao Armazém (SmartView)

@author Squad Entradas
@since 09/2023
@version 1.0
*/
//------------------------------------------------------------------- 
Function ESTSV008()

	Local lSuccess As Logical
	Local cError As Character
	local lIsBlind := IsBlind() as logical

	If GetRpoRelease() > "12.1.2210"
		lSuccess := totvs.framework.treports.callTReports("backoffice.sv.est.requestforpurchases",,,,,lIsBlind,,.T., @cError)
    Else            
    	FwLogMsg("WARN",, "SmartView",,, , STR0002, , ,)
	EndIf
Return
