#include "protheus.ch"
#include "fwmvcdef.ch"
 
/*/{Protheus.doc} PCPR840
Operações por Produto - Smart View (Relatório)
 
@author  ana.paula
@since   22/09/2023
@version 1.0
/*/
Function pcpr840()
    Local lSuccess := .F. As Logical
    Local cError := "" as character
 
    lSuccess := totvs.framework.treports.callTReports("manufacturing.sv.pcp.operacao", nil, nil, nil, nil, .F., .T., nil, @cError)
    
    If !lSuccess
        If empty(cError)
            cError := "Não foi possivel estabelecer conexão com o Smart View, entre em contato com o administratdor."
        EndIf
        FWAlertError(cError, "Smart View")
    EndIf

Return
