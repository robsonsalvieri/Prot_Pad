/*/{Protheus.doc} ESTSV015
Função utilizada para execução do objeto de negócio Consumo mês a mês
@type  Função
@author Squad Entradas
@since  Junho 23,2023
/*/
Function ESTSV015()
	local lSuccess				as logical
	local cError				as character
	local lIsBlind := IsBlind()	as logical


	If GetRpoRelease() > "12.1.2210"
		lSuccess := totvs.framework.treports.callTReports("backoffice.sv.est.monthlyconsumption",,,,,lIsBlind,,.T., @cError)
	Else
		FwLogMsg("WARN",, "SmartView",,, , "Funcionalidade nao disponivel para releases inferiores a 12.1.2310", , ,)
	EndIf
Return
