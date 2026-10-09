/*/{Protheus.doc} ESTSV030
Função utilizada para execução do objeto de negócio Recursividade por Movimentação
@type   Função
@author Michel Sander
@since  27/11/2023
/*/

Function ESTSV030()

	local lSuccess as logical
	local cError as character
	local lIsBlind := IsBlind() as logical

	If GetRpoRelease() > "12.1.2210"
		lSuccess := totvs.framework.treports.callTReports("backoffice.sv.est.moverecursion",,,,,lIsBlind,,.T.,@cError)
	Else
		FwLogMsg("WARN",, "SmartView ESTSV030",,, , "Funcionalidade nao disponivel para releases inferiores a 12.1.2310", , ,)
	EndIf

Return
