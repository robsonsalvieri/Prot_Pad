/*/{Protheus.doc} ESTSV032 
Função utilizada para execução do objeto de negócio Consumo Real x Standard
@type  Função
@author Squad Entradas    
@since  11/2023    
/*/
Function ESTSV032()
	local lSuccess as logical
	local cError   as character
	local lIsBlind := IsBlind() as logical

	If GetRpoRelease() > "12.1.2210"
		lSuccess := totvs.framework.treports.callTReports("backoffice.sv.est.relxstdconsumption",,,,,lIsBlind,,.T., @cError)
	Else
		FwLogMsg("WARN",, "SmartView ESTSV032",,, , "Funcionalidade nao disponivel para releases inferiores a 12.1.2310", , ,)
	EndIf

Return
