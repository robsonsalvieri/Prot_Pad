#include "protheus.ch"

/*/{Protheus.doc} PLSSV009
Inadimplência - Smart View (Relatório)

@type function
@version 12.1.2510  
@author diogo.sousa
@since 28/05/2025
/*/ 
Function PLSSV009()

	local oSmartView as object

	if totvs.protheus.health.smartview.plan.utils.UtilsBusinessObject():isConfig()
		oSmartView := totvs.framework.smartview.callSmartView():new("health.sv.plan.financialdelinquency.default.rep", "report")
		
        oSmartView:executeSmartView()
    
		oSmartView:destroy()
	endif

	freeObj(oSmartView)

Return 
