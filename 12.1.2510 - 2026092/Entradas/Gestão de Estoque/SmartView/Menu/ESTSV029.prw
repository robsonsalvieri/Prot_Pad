/*/{Protheus.doc} ESTSV029
Função utilizada para execução do objeto de negócio Transferência entre Filiais
@type   Função
@author Michel Sander
@since  22/11/2023
/*/

Function ESTSV029()

	local lSuccess as logical
	local cError as character
	local lIsBlind := IsBlind() as logical

	If GetRpoRelease() > "12.1.2210"
		lSuccess := totvs.framework.treports.callTReports("backoffice.sv.est.transferbetweenbranches",,,,,lIsBlind,,.T.,@cError)
	Else
		FwLogMsg("WARN",, "SmartView ESTSV029",,, , "Funcionalidade nao disponivel para releases inferiores a 12.1.2310", , ,)
	EndIf

Return
