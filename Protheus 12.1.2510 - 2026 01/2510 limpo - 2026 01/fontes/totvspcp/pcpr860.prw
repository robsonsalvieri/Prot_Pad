#include "protheus.ch"
#include "fwmvcdef.ch"
 
/*/{Protheus.doc} PCPR860
Relação das Ordens de Produção (Movimentos) - Smart View (Relatório)
 
@author  ana.paula
@since   22/09/2023
@version 1.0
/*/
Function pcpr860()
    Local lSuccess   := .F. as Logical
    Local oSmartView := Nil as object
 
    oSmartView := totvs.framework.smartview.callSmartView():new("manufacturing.sv.pcp.movimentacao.geral.rep", "report")
    lSuccess := oSmartView:executeSmartView()
    
    If !lSuccess
        FWAlertError(oSmartView:getError(), "Smart View")
    EndIf

    oSmartView:destroy()

Return
