/*/{Protheus.doc} ESTSV038
Função utilizada para execução do objeto de negócio Grupos de Produtos
@type  Função
@author Marcio Lopes dos Santos
@since  11/2023
/*/
Function ESTSV038()
	local lSuccess as logical
	local lIsBlind := IsBlind() as logical
	local cError as character

	If GetRpoRelease() > "12.1.2210"
		lSuccess := totvs.framework.treports.callTReports("backoffice.sv.est.productgroup",,,,,lIsBlind,,.T.,@cError)
	Else
		FwLogMsg("WARN",, "SmartView ESTSV038",,, , "Funcionalidade nao disponivel para releases inferiores a 12.1.2310", , ,)
	EndIf

Return
