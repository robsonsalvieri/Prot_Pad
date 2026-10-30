#include "protheus.ch"

/*/{Protheus.doc} PLSSV007
Cadastro de Famílias - Smart View (Relatório)

@type function
@version 12.1.2510  
@author guilherme.bonni
@since 15/10/2024
/*/ 
Function PLSSV007()

	local oSmartView as object

	if totvs.protheus.health.smartview.plan.utils.UtilsBusinessObject():isConfig()
		oSmartView := totvs.framework.smartview.callSmartView():new("health.sv.plan.family.default.rep", "report")

		oSmartView:executeSmartView()

		oSmartView:destroy()
	endif

	freeObj(oSmartView)

Return 
