#include "protheus.ch"

/*/{Protheus.doc} PLSSV005
Familia x Beneficiario - Smart View (Visão de Dados)

@type function
@version 12.1.2510  
@author guilherme.bonni
@since 11/10/2024
/*/ 
Function PLSSV005()

	local oSmartView as object

	if totvs.protheus.health.smartview.plan.utils.UtilsBusinessObject():isConfig()
		oSmartView := totvs.framework.smartview.callSmartView():new("health.sv.plan.familybeneficiary.default.dg", "data-grid")

		oSmartView:executeSmartView()

		oSmartView:destroy()
	endif

	freeObj(oSmartView)

Return 
