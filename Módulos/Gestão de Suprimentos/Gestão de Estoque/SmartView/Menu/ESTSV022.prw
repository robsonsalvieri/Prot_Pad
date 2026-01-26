/*/{Protheus.doc} ESTSV022
Função utilizada para execução do objeto de negócio Lista de Produtos 
@type  Função
@author Squad Entradas
@since  Junho 25,2023
/*/
Function ESTSV022()

	local cError as character
	local lSuccess as logical
	local lIsBlind := IsBlind() as logical

	If GetRpoRelease() > "12.1.2210"
		lSuccess := totvs.framework.treports.callTReports("backoffice.sv.est.listofproducts",,,,,lIsBlind,,.T.,@cError)
	Else
		FwLogMsg("WARN",, "SmartView ESTSV022",,, , "Funcionalidade nao disponivel para releases inferiores a 12.1.2310", , ,)
	EndIf

Return
