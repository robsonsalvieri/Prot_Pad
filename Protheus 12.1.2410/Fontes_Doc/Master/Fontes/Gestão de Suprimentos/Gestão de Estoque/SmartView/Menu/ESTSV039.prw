/*/{Protheus.doc} ESTSV039
Função utilizada para execução do objeto de negócio Saldo em Processo
@type   Função
@author Michel Sander   
@since  07/12/2023
/*/

Function ESTSV039()

	local lSuccess as logical
	local cError as character
	local lIsBlind := IsBlind() as logical	

	If GetRpoRelease() > "12.1.2210"
		lSuccess := totvs.framework.treports.callTReports("backoffice.sv.est.balanceinprocess",,,,,lIsBlind,,.T.,@cError)
	Else
		FwLogMsg("WARN",, "SmartView ESTSV039",,, , "Funcionalidade nao disponivel para releases inferiores a 12.1.2310", , ,)
	EndIf

Return
