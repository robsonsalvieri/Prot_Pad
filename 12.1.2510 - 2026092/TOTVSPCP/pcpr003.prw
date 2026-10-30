#include "protheus.ch"
#include "fwmvcdef.ch"
 
/*/{Protheus.doc} PCPR003 
Ratreabilidade das Demandas - Smart View (Relatório)
 
@author  breno.ferreira
@since   07/11/2023
@version 1.0
/*/
Function pcpr003()
    Local lSuccess   := .F. as Logical
    Local oSmartView := Nil as object
 
    oSmartView := totvs.framework.smartview.callSmartView():new("manufacturing.sv.pcp.rastreabilidade.geral.rep", "report")
    lSuccess := oSmartView:executeSmartView()
    
    If !lSuccess
        FWAlertError(oSmartView:getError(), "Smart View")
    EndIf

    oSmartView:destroy()

Return
