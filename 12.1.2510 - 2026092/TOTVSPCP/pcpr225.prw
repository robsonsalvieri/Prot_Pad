#include "protheus.ch"
#include "fwmvcdef.ch"

/*/{Protheus.doc} PCPR225 
Estrututa Simples - Smart View (Relatório)
 
@author  ana.paula
@since   22/09/2023
@version 1.0
/*/
Function pcpr225()
	Local lSuccess   := .F. as logical
	Local oSmartView := nil as object

	oSmartView := totvs.framework.smartview.callSmartView():new("manufacturing.sv.pcp.estrutura")
	lSuccess := oSmartView:executeSmartView()

	if !lSuccess
		FWAlertError(oSmartView:getError(), "Smart View - PCPR225")
	EndIf

	oSmartView:destroy()
	FwFreeObj(oSmartView)

Return
