#include "protheus.ch"
#include "fwmvcdef.ch"
 
/*/{Protheus.doc} PCPR005
Projeção de Estoque - Smart View (Relatório)
 
@author  ana.paula
@since   20/03/2024
@version 1.0
/*/
Function pcpr005()
    Local lSuccess := .F. As Logical
    Local cError := "" as character
 
    lSuccess := totvs.framework.treports.callTReports("manufacturing.sv.pcp.projecao", nil, nil, nil, nil, .F., .T., nil , @cError)
    
    If !lSuccess
        FWAlertError(cError, "Smart View")
    EndIf

Return
