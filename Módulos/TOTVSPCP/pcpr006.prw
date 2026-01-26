#include "protheus.ch"
#include "fwmvcdef.ch"
 
/*/{Protheus.doc} PCPR006
Rastreabilidade de Lote - Smart View (Relatório)
 
@author  breno.ferreira
@since   03/07/2025
@version 1.0
/*/
Function pcpr006()
    Local lSuccess   := .F. as Logical
    Local oSmartView := Nil as object

    oSmartView := totvs.framework.smartview.callSmartView():new( "manufacturing.sv.pcp.rastreabilidade.lote.rep", "report" )
    lSuccess := oSmartView:executeSmartView()
    
    If !lSuccess
        FWAlertError(oSmartView:getError(), "Smart View")
    EndIf

    oSmartView:destroy()

Return
