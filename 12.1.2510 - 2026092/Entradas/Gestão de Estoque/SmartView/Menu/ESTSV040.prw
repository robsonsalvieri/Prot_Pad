/*/{Protheus.doc} ESTSV040
Função utilizada para execução do objeto de negócio Relação por OP FIFO
@type  Função
@author Squad Entradas
@since  11/2023
/*/
Function ESTSV040()
	local lSuccess as logical
	local lIsBlind := IsBlind() as logical
	local cError as character

	If GetRpoRelease() > "12.1.2210"
		lSuccess := totvs.framework.treports.callTReports("backoffice.sv.est.reportoffifopo",,,,,lIsBlind,,.T.,@cError)
	Else
		FwLogMsg("WARN",, "SmartView ESTSV040",,, , "Funcionalidade nao disponivel para releases inferiores a 12.1.2310", , ,)
	EndIf

Return
