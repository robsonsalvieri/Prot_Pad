/*/{Protheus.doc} ESTSV031
Função utilizada para execução do objeto de negócio Controle Solicitação ao Armazém
@type  Função
@author Marcio Lopes dos Santos
@since  11/2023
/*/
Function ESTSV031()
	local lSuccess as logical
	local lIsBlind := IsBlind() as logical
	local cError as character

	If GetRpoRelease() > "12.1.2210"
		lSuccess := totvs.framework.treports.callTReports("backoffice.sv.est.controlwarehouserequisitions",,,,,lIsBlind,,.T.,@cError)
	Else
		FwLogMsg("WARN",, "SmartView ESTSV031",,, , "Funcionalidade nao disponivel para releases inferiores a 12.1.2310", , ,)
	EndIf

Return
