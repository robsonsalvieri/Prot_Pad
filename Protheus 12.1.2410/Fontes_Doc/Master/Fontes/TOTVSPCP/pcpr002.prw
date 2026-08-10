#include "protheus.ch"
#include "fwmvcdef.ch"
 
/*/{Protheus.doc} PCPR002 
Demandas do MRP - Smart View (Relatório)
 
@author  ana.paula
@since   25/09/2023
@version 1.0
/*/
Function pcpr002()
    Local lSuccess := .F. As Logical
    Local cError := "" as character
 
    lSuccess := totvs.framework.treports.callTReports("manufacturing.sv.pcp.demanda", nil, nil, nil, nil, .F., .T., nil , @cError)
    
    If !lSuccess
        If empty(cError)
            cError := "Não foi possivel estabelecer conexão com o Smart View, entre em contato com o administratdor."
        EndIf
        FWAlertError(cError, "Smart View")
    EndIf

Return
