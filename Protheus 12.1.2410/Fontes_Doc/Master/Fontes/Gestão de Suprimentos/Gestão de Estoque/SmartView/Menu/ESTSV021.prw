#include "Protheus.ch"

//-------------------------------------------------------------------
/*{Protheus.doc} ESTSV021
Chamada do objeto de negócio Produtos Vendidos (SmartView)

@author Squad Entradas
@since 09/2023
@version 1.0 
*/
//-------------------------------------------------------------------  
Function ESTSV021()

    local lSuccess as logical
    local cError as character
    local lIsBlind := IsBlind() as logical

	If GetRpoRelease() > "12.1.2210"
		lSuccess := totvs.framework.treports.callTReports("backoffice.sv.est.soldproducts",,,,,lIsBlind,,.T., @cError)
	Else
		FwLogMsg("WARN",, "SmartView ESTSV021",,, , "Funcionalidade nao disponivel para releases inferiores a 12.1.2310", , ,)
	EndIf
	
Return
