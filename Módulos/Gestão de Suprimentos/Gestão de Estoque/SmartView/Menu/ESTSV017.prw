/*/{Protheus.doc} ESTSV017
Função utilizada para execução do objeto de negócio Resumo por produto de entradas e saidas
@type   Função
@author Michel Sander
@since  Setembro 22, 2023 
/*/

Function ESTSV017()

    local lSuccess as logical
    local cError   as Character
    local lIsBlind := IsBlind() as logical

	If GetRpoRelease() > "12.1.2210"
		lSuccess := totvs.framework.treports.callTReports("backoffice.sv.est.inflowsandoutflows",,,,,lIsBlind,,.T.,@cError)
	Else
		FwLogMsg("WARN",, "SmartView ESTSV017",,, , "Funcionalidade nao disponivel para releases inferiores a 12.1.2310", , ,)
	ENDIF
Return
