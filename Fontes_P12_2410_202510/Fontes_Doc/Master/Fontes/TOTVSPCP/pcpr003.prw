#include "protheus.ch"
#include "fwmvcdef.ch"
 
/*/{Protheus.doc} PCPR003 
Ratreabilidade das Demandas - Smart View (Relatório)
 
@author  breno.ferreira
@since   07/11/2023
@version 1.0
/*/
Function pcpr003()
    Local lSuccess := .F. As Logical
    Local cError := "" as character
 
    lSuccess := totvs.framework.treports.callTReports("manufacturing.sv.pcp.rastreabilidade", nil, nil, nil, nil, .F., .T., nil , @cError)
    
    If !lSuccess
        FWAlertError(cError, "Smart View")
    EndIf

Return
