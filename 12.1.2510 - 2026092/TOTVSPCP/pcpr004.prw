#include "protheus.ch"
#include "fwmvcdef.ch"
 
/*/{Protheus.doc} PCPR004
Resultados do MRP - Smart View (Relatório)
 
@author  breno.ferreira
@since   22/02/2024
@version 1.0
/*/
Function pcpr004()
    Local lSuccess := .F. As Logical
    Local cError := "" as character
 
    lSuccess := totvs.framework.treports.callTReports("manufacturing.sv.pcp.resultadosmrp", nil, nil, nil, nil, .F., .T., nil , @cError)
    
    If !lSuccess
        FWAlertError(cError, "Smart View")
    EndIf

Return
