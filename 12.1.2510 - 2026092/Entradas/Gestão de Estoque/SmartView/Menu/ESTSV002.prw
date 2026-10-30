#include "Protheus.ch"
#include "ESTSV002.ch"

//-------------------------------------------------------------------
/*{Protheus.doc} ESTSV002
Chamada do objeto de negócio Divergencias em Multiplas Contagens (SmartView)

@author Squad Entradas  
@since 09/2023
@version 1.0  
*/
//------------------------------------------------------------------- 
Function ESTSV002()

	Local lSuccess As Logical
	Local cError As character
	local lIsBlind := IsBlind() as logical

	If GetRpoRelease() > "12.1.2210"
		lSuccess := totvs.framework.treports.callTReports("backoffice.sv.est.differencesinmultiplecountings",,,,,lIsBlind,,.T.,@cError)
	Else
		FwLogMsg("WARN",, "SmartView",,, , STR0002, , ,)
	EndIf

Return
