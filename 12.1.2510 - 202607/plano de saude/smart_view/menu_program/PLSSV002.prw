#include "protheus.ch"

/*/{Protheus.doc} PLSSV002
Visão de Dados da Receita x Despesa - SmartView
@type function
@version 12.1.2410  
@author vinicius.queiros
@since 02/02/2024
/*/ 
function PLSSV002()

	local oSmartView as object

	if totvs.protheus.health.smartview.plan.utils.UtilsBusinessObject():isConfig()
		oSmartView := totvs.framework.smartview.callSmartView():new("health.sv.plan.incomeexpense.default.dg", "data-grid")

		oSmartView:executeSmartView()

		oSmartView:destroy()
	endif

	freeObj(oSmartView)

return
