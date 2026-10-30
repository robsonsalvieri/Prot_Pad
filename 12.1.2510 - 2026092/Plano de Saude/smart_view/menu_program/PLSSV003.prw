#include "protheus.ch"

/*/{Protheus.doc} PLSSV003
Menu/rotina da Conferência da PPCNG - SmartView
@type function
@version 12.1.2310  
@author diogo.sousa
@since 27/03/2024
/*/ 
Function PLSSV003()

	local lSuccess as logical
	local oSmartView as object

	if totvs.protheus.health.smartview.plan.utils.UtilsBusinessObject():isConfig()
		oSmartView := totvs.framework.smartview.callSmartView():new("health.sv.plan.ppcngconference.default.dg", "data-grid")

		lSuccess := oSmartView:executeSmartView()

		if !lSuccess
			fwAlertError(oSmartView:getError(), "Smart View")
		endif

		oSmartView:destroy()
	endif

	freeObj(oSmartView)

Return 
