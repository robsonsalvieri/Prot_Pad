/*/{Protheus.doc} ESTSV033
Função utilizada para execução do objeto de negócio Pick-List Endereço Por Nota Fiscal
@type   Função
@author Michel Sander  
@since  29/11/2023
/*/

Function ESTSV033()

    local lSuccess as logical
    local cError as character
    local lIsBlind := IsBlind() as logical

	If GetRpoRelease() > "12.1.2210"
		lSuccess := totvs.framework.treports.callTReports("backoffice.sv.est.PickListAddressPerInvoice",,,,,lIsBlind,,.T.,@cError)
	Else
		FwLogMsg("WARN",, "SmartView ESTSV033",,, , "Funcionalidade nao disponivel para releases inferiores a 12.1.2310", , ,)
	EndIf

Return
