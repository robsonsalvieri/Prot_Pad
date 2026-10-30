#include "protheus.ch"
#include "fwmvcdef.ch"
 
/*/{Protheus.doc} PCPR820 
Ordem de Produção - Smart View (Relatório)
 
@author  ana.paula
@since   22/09/2023
@version 1.0
/*/
Function pcpr820()
    Local lSuccess := .F. As Logical
    Local cError := "" as character
 
    lSuccess := totvs.framework.treports.callTReports("manufacturing.sv.pcp.ordem", nil, nil, nil, nil, .F., .T., nil, @cError)
    
    If !lSuccess
        If empty(cError)
            cError := "Não foi possivel estabelecer conexão com o Smart View, entre em contato com o administratdor."
        EndIf
        FWAlertError(cError, "Smart View")
    EndIf

Return
